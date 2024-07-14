import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taxi_driver/screens/PaymentScreen.dart';
import 'package:taxi_driver/screens/WithDrawScreen.dart';

import '../../main.dart';
import '../../network/RestApis.dart';
import '../model/UserDetailModel.dart';
import '../model/WalletListModel.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import 'BankInfoScreen.dart';

class WalletScreen extends StatefulWidget {
  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addMoneyController = TextEditingController();
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;

  int currentIndex = -1;

  List<WalletModel> walletData = [];

  int totalAmount = 0;

  UserBankAccount? userBankAccount;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    getBankDetail();
    getWalletData();
  }

  getWalletData() async {
    await getWalletList(pageData: currentPage).then((value) {
      appStore.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (value.walletBalance != null) totalAmount = value.walletBalance!.totalAmount!.toInt();
      if (currentPage == 1) {
        walletData.clear();
      }
      walletData.addAll(value.data ?? []);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }
  getBankDetail() async {
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      userBankAccount = value.data!.userBankAccount;
      setState(() {});
    }).then((value) {
      log(value);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.wallet, style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(language.availableBalance, style: secondaryTextStyle(color: Colors.white)),
                          SizedBox(height: 8),
                          Text(printAmount(totalAmount.toStringAsFixed(digitAfterDecimal)), style: boldTextStyle(size: 22, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Text(language.recentTransactions, style: primaryTextStyle()),
                  AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: walletData.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        WalletModel data = walletData[index];

                        return AnimationConfiguration.staggeredList(
                          delay: Duration(milliseconds: 200),
                          position: index,
                          duration: Duration(milliseconds: 375),
                          child: SlideAnimation(
                            child: Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.2)),
                                    padding: EdgeInsets.all(8),
                                    child: Icon(data.type == CREDIT ? Icons.add : Icons.remove, color: primaryColor),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data.type == DEBIT ? language.moneyDebit : language.moneyDeposited, style: boldTextStyle(size: 16)),
                                        SizedBox(height: 4),
                                        Text(printDate(data.createdAt!), style: secondaryTextStyle(size: 12)),
                                      ],
                                    ),
                                  ),
                                  Text("${data.type == CREDIT ? "+" : "-"} ${printAmount(data.amount!.toStringAsFixed(digitAfterDecimal))}",
                                      style: boldTextStyle(color: data.type == CREDIT ? Colors.green : Colors.red))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            ),
            !appStore.isLoading && walletData.isEmpty ? emptyWidget() : SizedBox(),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            if (totalAmount != 0)
              Expanded(
                child: AppButtonWidget(
                  text: language.withDraw,
                  width: MediaQuery.of(context).size.width,
                  onTap: () async {
                    if (userBankAccount != null)
                      launchScreen(
                          context,
                          WithDrawScreen(
                            bankInfo: userBankAccount!,
                            onTap: () {
                              init();
                            },
                          ));
                    else {
                      toast(language.bankInfoNotFound);
                      var res = await launchScreen(context, BankInfoScreen());
                      if (res != null) {
                        getBankDetail();
                      }
                    }
                  },
                ),
              ),
            if (totalAmount != 0) SizedBox(width: 16),
            Expanded(
              child: AppButtonWidget(
                text: language.addMoney,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                    builder: (_) {
                      return Form(
                        key: formKey,
                        child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.addMoney, style: boldTextStyle()),
                                        CloseButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            addMoneyController.clear();
                                            currentIndex = -1;
                                          },
                                        )
                                      ],
                                    ),
                                    AppTextField(
                                      controller: addMoneyController,
                                      textFieldType: TextFieldType.PHONE,
                                      keyboardType: TextInputType.number,
                                      errorThisFieldRequired: language.thisFieldRequired,
                                      onChanged: (val) {
                                        //
                                      },
                                      validator: (String? val) {
                                        if (appStore.minAmountToAdd != null && int.parse(val!) < appStore.minAmountToAdd!) {
                                          addMoneyController.text = appStore.minAmountToAdd.toString();
                                          addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStore.minAmountToAdd.toString().length));
                                          return "${language.minimum} ${appStore.minAmountToAdd} ${language.required}";
                                        } else if (appStore.maxAmountToAdd != null && int.parse(val!) > appStore.maxAmountToAdd!) {
                                          addMoneyController.text = appStore.maxAmountToAdd.toString();
                                          addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStore.maxAmountToAdd.toString().length));
                                          return "${language.maximum} ${appStore.maxAmountToAdd} ${language.required}";
                                        }
                                        return null;
                                      },
                                      decoration: inputDecoration(context, label: language.amount),
                                    ),
                                    SizedBox(height: 16),
                                    Wrap(
                                      runSpacing: 8,
                                      spacing: 8,
                                      children: appStore.walletPresetTopUpAmount.split('|').map((e) {
                                        return inkWellWidget(
                                          onTap: () {
                                            currentIndex = appStore.walletPresetTopUpAmount.split('|').indexOf(e);
                                            if (appStore.minAmountToAdd != null && int.parse(e) < appStore.minAmountToAdd!) {
                                              addMoneyController.text = appStore.minAmountToAdd.toString();
                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStore.minAmountToAdd.toString().length));
                                              toast("${language.minimum}  ${appStore.minAmountToAdd} ${language.required}");
                                            } else if (appStore.minAmountToAdd != null &&
                                                int.parse(e) < appStore.minAmountToAdd! &&
                                                appStore.maxAmountToAdd != null &&
                                                int.parse(e) > appStore.maxAmountToAdd.toString().length) {
                                              addMoneyController.text = appStore.maxAmountToAdd.toString();
                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: e.length));
                                              toast("${language.maximum} ${appStore.maxAmountToAdd} ${language.required}");
                                            } else {
                                              addMoneyController.text = e;
                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: e.length));
                                            }

                                            setState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: currentIndex == appStore.walletPresetTopUpAmount.split('|').indexOf(e) ? primaryColor : Colors.white,
                                              border: Border.all(color: currentIndex == appStore.walletPresetTopUpAmount.split('|').indexOf(e) ? primaryColor : Colors.grey),
                                              borderRadius: BorderRadius.circular(defaultRadius),
                                            ),
                                            child: Text(
                                              printAmount(e),
                                              style: boldTextStyle(color: currentIndex == appStore.walletPresetTopUpAmount.split('|').indexOf(e) ? Colors.white : primaryColor),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 16),
                                    AppButtonWidget(
                                      text: language.addMoney,
                                      textStyle: boldTextStyle(color: Colors.white),
                                      width: MediaQuery.of(context).size.width,
                                      color: primaryColor,
                                      onTap: () {
                                        if (addMoneyController.text.isNotEmpty) {
                                          if (formKey.currentState!.validate() && addMoneyController.text.isNotEmpty) {
                                            Navigator.pop(context);
                                            launchScreen(context, PaymentScreen(amount: int.parse(addMoneyController.text)), pageRouteAnimation: PageRouteAnimation.SlideBottomTop).then((value) {
                                              getWalletData();
                                              setState(() {});
                                            });

                                            addMoneyController.clear();
                                            currentIndex = -1;
                                          } else {
                                            toast(language.pleaseSelectAmount);
                                          }
                                        } else {
                                          toast(language.pleaseSelectAmount);
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

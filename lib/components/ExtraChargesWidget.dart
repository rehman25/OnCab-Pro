import 'package:flutter/material.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../model/AdditionalFeesList.dart';
import '../model/ExtraChargeRequestModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class ExtraChargesWidget extends StatefulWidget {
  final List<ExtraChargeRequestModel>? data;

  ExtraChargesWidget({this.data});

  @override
  ExtraChargesWidgetState createState() => ExtraChargesWidgetState();
}

class ExtraChargesWidgetState extends State<ExtraChargesWidget> {
  TextEditingController extraController = TextEditingController();
  List<AdditionalFeesModel> additionalFeesData = [];
  String? extraCharges;

  List<ExtraChargeRequestModel> list = [];

  num total = 50;

  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoad = true;
    });
    await getAdditionalFees().then((value) {
      additionalFeesData.addAll(value.data!);
      setState(() {
        isLoad = false;
      });
    }).catchError((error) {
      log(error.toString());
    });
    if (widget.data != null && widget.data!.isNotEmpty) {
      list.addAll(widget.data!);

      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Stack(
        children: [
          !isLoad && additionalFeesData.isNotEmpty
              ? StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.addExtraCharges, style: boldTextStyle()),
                          CloseButton(),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.15)),
                        width: MediaQuery.of(context).size.width,
                        child: DropdownButton<String>(
                          hint: Padding(padding: EdgeInsets.only(left: 16,right: 16), child: Text(language.applyExtraCharges)),
                          value: extraCharges,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: additionalFeesData.map((e) {
                            return DropdownMenuItem(
                              value: e.title,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16,right: 16),
                                child: Text(e.title.validate(), style: primaryTextStyle()),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            extraCharges = val!;
                            if (list.isNotEmpty) {
                              list.forEach((element) {
                                if (element.key == val) {
                                  extraController.text = element.value.toString();
                                }
                              });
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: AppTextField(
                              controller: extraController,
                              autoFocus: false,
                              textFieldType: TextFieldType.PHONE,
                              errorThisFieldRequired: language.thisFieldRequired,
                              decoration: inputDecoration(context, label: language.enterAmount),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: AppButtonWidget(
                              child: Icon(Icons.add,color: Colors.white),
                              onTap: () {
                                if (extraCharges != null) {
                                  if (extraController.text.isNotEmpty) {
                                    if (list.isNotEmpty) {
                                      if (list.any((element) => element.key == extraCharges)) {
                                        ExtraChargeRequestModel data = list.firstWhere((element) => element.key == extraCharges);
                                        list.remove(data);
                                        list.add(ExtraChargeRequestModel(key: extraCharges, value: int.parse(extraController.text.trim())));
                                      } else {
                                        list.add(ExtraChargeRequestModel(key: extraCharges, value: int.parse(extraController.text.trim())));
                                      }
                                    } else {
                                      list.add(ExtraChargeRequestModel(key: extraCharges, value: int.parse(extraController.text.trim())));
                                    }
                                    hideKeyboard(context);
                                    extraController.clear();
                                    setState(() {});
                                  } else {
                                    toast(language.pleaseAddedAmount);
                                  }
                                } else {
                                  toast(language.pleaseSelectExtraCharges);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      if (list.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(language.title, style: boldTextStyle())),
                                Expanded(child: Text(language.charges, style: boldTextStyle())),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 8),
                            Column(
                              children: list.map((e) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(e.key.validate(), style: primaryTextStyle()),
                                    ),
                                    Expanded(
                                      child: Text(e.value.toString(), style: primaryTextStyle()),
                                    ),
                                    Expanded(
                                      child: inkWellWidget(
                                        onTap: () {
                                          list.remove(e);
                                          setState(() {});
                                        },
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButtonWidget(
                              text: language.saveCharges,
                              onTap: () {
                                Navigator.pop(context, list);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                })
              : isLoad
                  ? loaderWidget()
                  : emptyWidget(),
          isLoad ? loaderWidget() : SizedBox(),
        ],
      ),
    );
  }
}

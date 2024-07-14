import 'dart:convert';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/DashboardScreen.dart';
import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Constants.dart';
import 'package:taxi_driver/utils/Extensions/AppButtonWidget.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/CurrentRequestModel.dart';
import '../model/RideHistory.dart';
import '../model/RiderModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Images.dart';
import 'RideHistoryScreen.dart';

class DetailScreen extends StatefulWidget {
  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  CurrentRequestModel? currentData;
  RiderModel? riderModel;
  Payment? payment;
  List<RideHistory> rideHistory = [];
  bool isPaymentDone = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    currentRideRequest();
    mqttForUser();
  }

  Future<void> currentRideRequest() async {
    appStore.setLoading(true);
    await getCurrentRideRequest().then((value) async {
      appStore.setLoading(false);
      currentData = value;
      await orderDetailApi();
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> savePaymentApi() async {
    appStore.setLoading(true);
    Map req = {
      "id": currentData!.payment!.id,
      "rider_id": currentData!.payment!.riderId,
      "ride_request_id": currentData!.payment!.rideRequestId,
      "datetime": DateTime.now().toString(),
      "total_amount": currentData!.payment!.totalAmount,
      "payment_type": currentData!.payment!.paymentType,
      "txn_id": "",
      "payment_status": "paid",
      "transaction_detail": ""
    };
    log(req);
    await savePayment(req).then((value) {
      appStore.setLoading(false);
      launchScreen(context, DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> orderDetailApi() async {
    appStore.setLoading(true);
    await rideDetail(orderId: currentData!.payment!.rideRequestId).then((value) {
      appStore.setLoading(false);

      riderModel = value.data;
      payment = value.payment!;
      rideHistory = value.rideHistory!;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);

      log('${error.toString()}');
    });
  }

  mqttForUser() async {
    client.setProtocolV311();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      debugPrint(e.toString());
      client.connect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.onSubscribed = onSubscribed;

      log('connected');
      debugPrint('connected');
    } else {
      client.connect();
    }

    void onconnected() {
      debugPrint('connected');
    }

    client.subscribe(mMQTT_UNIQUE_TOPIC_NAME + 'ride_request_status_' + sharedPref.getInt(USER_ID).toString(), MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (jsonDecode(pt)['success_type'] == 'rating') {
        currentRideRequest();
      } else if (jsonDecode(pt)['success_type'] == 'change_payment_type') {
        currentRideRequest();
      } else if (jsonDecode(pt)['success_type'] == 'payment_status_message') {
        setState(() {
          isPaymentDone = true;
        });
        Future.delayed(
          Duration(seconds: 5),
          () {
            setState(() {
              isPaymentDone = false;
            });
            launchScreen(context, DashboardScreen(), isNewTask: true);
          },
        );
      }
    });

    client.onConnected = onconnected;
  }

  void onConnected() {
    log('Connected');
  }

  void onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.detailScreen, style: boldTextStyle(color: Colors.white)),
      ),
      body: currentData != null && riderModel != null
          ? Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addressComponent(),
                      if (riderModel!.otherRiderData != null) SizedBox(height: 12),
                      if (riderModel!.otherRiderData != null) riderDataComponent(),
                      SizedBox(height: 12),
                      paymentDetail(),
                      SizedBox(height: 12),
                      priceWidget(),
                    ],
                  ),
                ),
                Visibility(visible: isPaymentDone, child: Center(child: Lottie.asset(paymentSuccessful, width: 400, height: 400, fit: BoxFit.contain))),
              ],
            )
          : Observer(builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            }),
      bottomNavigationBar: currentData != null
          ? Padding(
              padding: EdgeInsets.all(16),
              child: currentData!.payment!.paymentType == CASH
                  ? AppButtonWidget(
                      text: language.cashCollected,
                      onTap: () {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureCollectThisPayment,
                            context, onAccept: (v) {
                          savePaymentApi();
                        });
                      },
                    )
                  : AppButtonWidget(
                      text: language.waitingForDriverConformation,
                      textStyle: boldTextStyle(color: Colors.white, size: 12),
                      color: primaryColor,
                      onTap: () {
                        if (currentData!.payment!.paymentStatus == COMPLETED) {
                          launchScreen(context, DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                        } else {
                          //currentRideRequest();
                          toast(language.waitingForDriverConformation);
                        }
                      },
                    ),
            )
          : SizedBox(),
    );
  }

  Widget addressComponent() {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: dividerColor.withOpacity(0.5)), borderRadius: radius()),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Ionicons.calendar, color: textSecondaryColorGlobal, size: 16),
                  SizedBox(width: 4),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('${printDate(riderModel!.createdAt.validate())}', style: primaryTextStyle(size: 14)),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Text(language.rideId, style: boldTextStyle(size: 16)),
                  SizedBox(width: 8),
                  Text('#${riderModel!.id}', style: boldTextStyle(size: 16)),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('${language.distance}: ${riderModel!.distance!.toStringAsFixed(2)} ${riderModel!.distanceUnit.toString()}', style: boldTextStyle(size: 14)),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.near_me, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (riderModel!.startTime != null) Text(riderModel!.startTime != null ? printDate(riderModel!.startTime!) : '', style: secondaryTextStyle(size: 12)),
                        if (riderModel!.startTime != null) SizedBox(height: 4),
                        Text(riderModel!.startAddress.validate(), style: primaryTextStyle(size: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  SizedBox(
                    height: 30,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      lineThickness: 1,
                      dashLength: 2,
                      dashColor: primaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 18),
                  SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (riderModel!.endTime != null) Text(riderModel!.endTime != null ? printDate(riderModel!.endTime!) : '', style: secondaryTextStyle(size: 12)),
                        if (riderModel!.endTime != null) SizedBox(height: 4),
                        Text(riderModel!.endAddress.validate(), style: primaryTextStyle(size: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          inkWellWidget(
            onTap: () {
              launchScreen(context, RideHistoryScreen(rideHistory: rideHistory), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.viewHistory, style: secondaryTextStyle()),
                Icon(Entypo.chevron_right, color: dividerColor, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chargesWidget({String? name, String? amount}) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name!, style: primaryTextStyle()),
          Text(amount!, style: primaryTextStyle()),
        ],
      ),
    );
  }

  Widget paymentDetail() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: dividerColor.withOpacity(0.5).withOpacity(0.5)),
        borderRadius: radius(),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.paymentDetails, style: boldTextStyle(size: 16)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.via, style: primaryTextStyle()),
              Text(paymentStatus(riderModel!.paymentType.validate()), style: boldTextStyle()),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.status, style: primaryTextStyle()),
              Text(paymentStatus(riderModel!.paymentStatus.validate()), style: boldTextStyle(color: paymentStatusColor(riderModel!.paymentStatus.validate()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: dividerColor.withOpacity(0.5).withOpacity(0.5)),
        borderRadius: radius(),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.priceDetail, style: boldTextStyle(size: 16)),
          SizedBox(height: 12),
          riderModel!.subtotal! <= riderModel!.minimumFare!
              ? totalCount(title: language.minimumFees, amount: riderModel!.minimumFare)
              : Column(
                  children: [
                    totalCount(title: language.basePrice, amount: riderModel!.baseFare),
                    SizedBox(height: 8),
                    totalCount(title:language.distancePrice, amount: riderModel!.perDistanceCharge),
                    SizedBox(height: 8),
                    totalCount(title:language.minutePrice, amount: riderModel!.perMinuteDriveCharge),
                    SizedBox(height: 8),
                    totalCount(title:language.waitingTimePrice, amount: riderModel!.perMinuteWaitingCharge),
                  ],
                ),
          SizedBox(height: 8),
          if (riderModel!.couponData != null && riderModel!.couponDiscount != 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.couponDiscount, style: secondaryTextStyle()),
                Text(
                  "- " + printAmount(riderModel!.couponDiscount!.toStringAsFixed(digitAfterDecimal)),
                  style: boldTextStyle(color: Colors.green, size: 14),
                ),
              ],
            ),
          if (riderModel!.couponData != null && riderModel!.couponDiscount != 0)  SizedBox(height: 8),
          if (riderModel!.tips != null) totalCount(title: language.tips, amount: riderModel!.tips),
          if (riderModel!.tips != null) SizedBox(height: 8),
          if (riderModel!.extraCharges!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.additionalFees, style: boldTextStyle()),
                ...riderModel!.extraCharges!.map((e) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key.validate().capitalizeFirstLetter(), style: secondaryTextStyle()),
                        Text(printAmount(e.value!.toStringAsFixed(digitAfterDecimal)), style: boldTextStyle(size: 14)),
                      ],
                    ),
                  );
                }).toList()
              ],
            ),

          Divider(height: 16, thickness: 1),
          riderModel!.tips != null
              ? totalCount(title: language.total, amount: riderModel!.subtotal! + riderModel!.tips!, isTotal: true)
              : totalCount(title: language.total, amount: riderModel!.subtotal, isTotal: true),
        ],
      ),
    );
  }

  Widget riderDataComponent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: dividerColor.withOpacity(0.5).withOpacity(0.5)),
            borderRadius: radius(),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.riderInformation.capitalizeFirstLetter(), style: boldTextStyle()),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Ionicons.person_outline, size: 18),
                  SizedBox(width: 8),
                  Text(riderModel!.otherRiderData!.name.validate(), style: primaryTextStyle()),
                ],
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse('tel:${riderModel!.otherRiderData!.conatctNumber.validate()}'), mode: LaunchMode.externalApplication);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Icon(Icons.call_sharp, size: 18, color: Colors.green), SizedBox(width: 8), Text(riderModel!.otherRiderData!.conatctNumber.validate(), style: primaryTextStyle())],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';

class EarningTodayWidget extends StatefulWidget {
  @override
  EarningTodayWidgetState createState() => EarningTodayWidgetState();
}

class EarningTodayWidgetState extends State<EarningTodayWidget> {
  num totalCashRide = 0;
  num totalWalletRide = 0;
  num todayEarnings = 0;
  num todayRideRequest = 0;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
    init();
  }

  void init() async {
    Map req = {
      "type": "today",
    };
    await earningList(req: req).then((value) {
      totalCashRide = value.totalCashRide!;
      totalWalletRide = value.totalWalletRide!;
      todayEarnings = value.todayEarnings!;
      todayRideRequest = value.todayRideRequest!;
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: 16, bottom: 16, right: 16, left: 16),
          child: Column(
            children: [
              // Text('${printDate('${DateTime.now()}')}', style: boldTextStyle(size: 20)),
              earningText(title: language.rides, amount: todayRideRequest,isRides: true),
              SizedBox(height: 16),
              earningText(title: language.cash, amount: totalCashRide),
              SizedBox(height: 16),
              earningText(title: language.wallet, amount: totalWalletRide),
              // SizedBox(height: 16),

              SizedBox(height: 16),
              Divider(color: primaryColor),
              earningText(title: language.todayEarning, amount: todayEarnings, isTotal: true),
              SizedBox(height: 16),
            ],
          ),
        ),
        Visibility(
          visible: appStore.isLoading,
          child: loaderWidget(),
        )
      ],
    );
  }
}

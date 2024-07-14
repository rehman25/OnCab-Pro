import 'package:flutter/material.dart';

import '../components/EarningReportWidget.dart';
import '../components/EarningTodayWidget.dart';
import '../components/EarningWeekWidget.dart';
import '../main.dart';
import '../model/EarningListModelWeek.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/app_common.dart';

class EarningScreen extends StatefulWidget {
  @override
  EarningScreenState createState() => EarningScreenState();
}

class EarningScreenState extends State<EarningScreen> {
  EarningListModelWeek? earningListModelWeek;
  List<WeekReport> weekReport = [];

  num totalRideCount = 0;
  num totalCashRide = 0;
  num totalWalletRide = 0;
  num totalCardRide = 0;
  num totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    Map req = {
      "type": "week",
    };
    await earningList(req: req).then((value) {
      appStore.setLoading(false);

      totalRideCount = value.totalRideCount!;
      totalCashRide = value.totalCashRide!;
      totalWalletRide = value.totalWalletRide!;
      totalCardRide = value.totalCardRide!;
      totalEarnings = value.totalEarnings!;

      weekReport.addAll(value.weekReport!);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.earning, style: boldTextStyle(color: appTextPrimaryColorWhite)),
        ),
        body: Column(
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.only(right: 16, left: 16, top: 16),
              decoration: BoxDecoration(color: Colors.transparent,border: Border.all(color: dividerColor), borderRadius: radius()),
              child: TabBar(
                indicator: BoxDecoration(borderRadius: radius(), color: primaryColor),
                labelColor: Colors.white,
                unselectedLabelColor: primaryColor,
                labelStyle: boldTextStyle(color: Colors.white, size: 14),
                tabs: [
                  Text(language.today),
                  Text(language.weekly),
                  Text(language.report),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  EarningTodayWidget(),
                  EarningWeekWidget(),
                  EarningReportWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

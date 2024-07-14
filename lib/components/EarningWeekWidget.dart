import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../main.dart';
import '../model/EarningListModelWeek.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';

class EarningWeekWidget extends StatefulWidget {
  @override
  EarningWeekWidgetState createState() => EarningWeekWidgetState();
}

class EarningWeekWidgetState extends State<EarningWeekWidget> {
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

      if (value.totalRideCount != null) totalRideCount = value.totalRideCount!;
      if (value.totalCashRide != null) totalCashRide = value.totalCashRide!;
      if (value.totalWalletRide != null) totalWalletRide = value.totalWalletRide!;
      if (value.totalCardRide != null) totalCardRide = value.totalCardRide!;
      if (value.totalEarnings != null) totalEarnings = value.totalEarnings!;

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
    return Observer(
      builder: (_) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    height: 350,
                    child: SfCartesianChart(
                      title: ChartTitle(text: language.weeklyOrderCount, textStyle: boldTextStyle(color: primaryColor)),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<WeekReport, String>>[
                        StackedColumnSeries<WeekReport, String>(
                          color: primaryColor,
                          enableTooltip: true,
                          markerSettings: MarkerSettings(isVisible: true),
                          dataSource: weekReport,
                          xValueMapper: (WeekReport exp, _) => exp.day,
                          yValueMapper: (WeekReport exp, _) => exp.amount,
                        ),
                      ],
                      primaryXAxis: CategoryAxis(isVisible: true),
                    ),
                    decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: dividerColor), borderRadius: radius()),
                  ),
                  SizedBox(height: 24),
                  earningText(title: language.rides, amount: totalRideCount, isRides: true),
                  SizedBox(height: 16),
                  earningText(title: language.cash, amount: totalCashRide),
                  SizedBox(height: 16),
                  earningText(title: language.wallet, amount: totalWalletRide),
                  SizedBox(height: 16),
                  Divider(color: primaryColor),
                  earningText(title: language.totalEarning, amount: totalEarnings, isTotal: true),
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
      },
    );
  }
}

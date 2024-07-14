import 'package:flutter/material.dart';

import '../components/CreateTabScreen.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class RidesListScreen extends StatefulWidget {
  @override
  RidesListScreenState createState() => RidesListScreenState();
}

class RidesListScreenState extends State<RidesListScreen> {
  int currentPage = 1;
  int totalPage = 1;
  List<String> riderStatus = [COMPLETED, CANCELED];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: riderStatus.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.rides, style: boldTextStyle(color: appTextPrimaryColorWhite)),
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
                unselectedLabelColor: primaryColor,indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: boldTextStyle(color: Colors.white, size: 14),
                tabs: riderStatus.map((e) {
                  return Tab(
                    child: Text(changeStatusText(e)),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: riderStatus.map((e) {
                  return CreateTabScreen(status: e);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

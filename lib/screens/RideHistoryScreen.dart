import 'package:flutter/material.dart';
import 'package:taxi_driver/model/RideHistory.dart';
import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Common.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../main.dart';

class RideHistoryScreen extends StatefulWidget {
  final List<RideHistory> rideHistory;

  RideHistoryScreen({required this.rideHistory});

  @override
  RideHistoryScreenState createState() => RideHistoryScreenState();
}

class RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.rideHistory, style: boldTextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.rideHistory.length,
        itemBuilder: (context, index) {
          RideHistory mData = widget.rideHistory[index];
          return TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: index == 0 ? true : false,
            axis: TimelineAxis.vertical,
            isLast: index == (widget.rideHistory.length - 1) ? true : false,
            indicatorStyle: IndicatorStyle(
              color: primaryColor,
              indicatorXY: 0.1,
              drawGap: true,
              width: 40,
              padding: EdgeInsets.symmetric(vertical: 8),
              height: 40,
              indicator: Container(
                padding: EdgeInsets.all(8),
                child: ImageIcon(AssetImage(statusTypeIcon(type: mData.historyType)), color: Colors.black),
                decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: dividerColor.withOpacity(0.5)), borderRadius: radius()),
              ),
            ),
            afterLineStyle: LineStyle(color: primaryColor, thickness: 1),
            endChild: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 24, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${printDate('${mData.createdAt}')}', style: secondaryTextStyle(size: 12)),
                  SizedBox(height: 2),
                  Text('${mData.historyType!.replaceAll("_", " ").capitalizeFirstLetter()}', style: boldTextStyle()),
                  SizedBox(height: 2),
                  Text(mData.historyMessage.validate(), style: secondaryTextStyle(color: textPrimaryColorGlobal)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

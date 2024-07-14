import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:taxi_driver/model/RiderModel.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../screens/RideDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class CreateTabScreen extends StatefulWidget {
  final String? status;

  CreateTabScreen({this.status});

  @override
  CreateTabScreenState createState() => CreateTabScreenState();
}

class CreateTabScreenState extends State<CreateTabScreen> {
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  List<RiderModel> riderData = [];
  List<String> riderStatus = [COMPLETED, CANCELED];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage != totalPage) {
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
    await getRiderRequestList(page: currentPage, status: widget.status, driverId: sharedPref.getInt(USER_ID)).then((value) {
      appStore.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        riderData.clear();
      }
      riderData.addAll(value.data!);
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
    return Observer(builder: (context) {
      return Stack(
        children: [
          AnimationLimiter(
            child: ListView.builder(
                itemCount: riderData.length,
                controller: scrollController,
                padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                itemBuilder: (_, index) {
                  RiderModel data = riderData[index];
                  return AnimationConfiguration.staggeredList(
                    delay: Duration(milliseconds: 200),
                    position: index,
                    duration: Duration(milliseconds: 375),
                    child: SlideAnimation(
                      child: IntrinsicHeight(child: rideCardWidget(data: data)),
                    ),
                  );
                }),
          ),
          Visibility(
            visible: appStore.isLoading,
            child: loaderWidget(),
          ),
          if (riderData.isEmpty) appStore.isLoading ? SizedBox() : emptyWidget(),
        ],
      );
    });
  }

  Widget rideCardWidget({required RiderModel data}) {
    return inkWellWidget(
      onTap: () {
        if (data.status != CANCELED) {
          launchScreen(context, RideDetailScreen(orderId: data.id!), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.calendar, color: textSecondaryColorGlobal, size: 16),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text('${printDate(data.createdAt.validate())}', style: primaryTextStyle(size: 14)),
                    ),
                  ],
                ),
                Text('${language.rideId} #${data.id}', style: boldTextStyle(size: 14)),
              ],
            ),
            Divider(height: 20, thickness: 0.5),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.near_me, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Expanded(child: Text(data.startAddress.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      SizedBox(
                        height: 34,
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
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 18),
                      SizedBox(width: 4),
                      Expanded(child: Text(data.endAddress.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

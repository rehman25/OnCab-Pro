import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../model/UserDetailModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';

class AboutWidget extends StatefulWidget {
  final int? driverId;

  AboutWidget({this.driverId});

  @override
  AboutWidgetState createState() => AboutWidgetState();
}

class AboutWidgetState extends State<AboutWidget> {
  UserData? userData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    getUserDetail(userId: widget.driverId).then((value) {
      userData = value.data!;
      setState(() {});
      appStore.setLoading(false);
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
    return userData != null
        ? Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.riderInformation.capitalizeFirstLetter(), style: boldTextStyle()),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                        child: Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: commonCachedNetworkImage(userData!.profileImage.validate(), height: 45, width: 45, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData!.firstName.validate(), style: boldTextStyle(size: 14)),
                        SizedBox(height: 4),
                        if (userData!.rating != null)
                          RatingBar.builder(
                            direction: Axis.horizontal,
                            glow: false,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            wrapAlignment: WrapAlignment.spaceBetween,
                            itemCount: 5,
                            itemSize: 10,
                            initialRating: double.parse(userData!.rating.toString()),
                            itemPadding: EdgeInsets.symmetric(horizontal: 0),
                            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              //
                            },
                          ),
                        SizedBox(height: 4),
                        Text(userData!.email.validate(), style: secondaryTextStyle()),
                      ],
                    ),
                  ],
                ),

              ],
            ),
          )
        : Visibility(
            visible: userData != null && appStore.isLoading,
            child: loaderWidget(),
          );
  }
}

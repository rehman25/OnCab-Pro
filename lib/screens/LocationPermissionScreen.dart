import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Images.dart';

class LocationPermissionScreen extends StatefulWidget {
  @override
  LocationPermissionScreenState createState() => LocationPermissionScreenState();
}

class LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    determinePosition().then((value) {
      log("value---$value");
      sharedPref.setDouble(LATITUDE, value!.latitude);
      sharedPref.setDouble(LONGITUDE, value.longitude);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(locationGIF, height: 200, width: 200, fit: BoxFit.cover),
              SizedBox(height: 32),
              Text(language.mostReliableMightyDriverApp, style: boldTextStyle(size: 18)),
              SizedBox(height: 16),
              Text(language.toEnjoyYourRideExperiencePleaseAllowPermissions, style: secondaryTextStyle(color: primaryColor), textAlign: TextAlign.center),
              SizedBox(height: 32),
              AppButtonWidget(
                width: MediaQuery.of(context).size.width,
                text: language.allow,
                onTap: () async {
                  if (await checkPermission()) {
                    await Geolocator.getCurrentPosition().then((value) {
                      sharedPref.setDouble(LATITUDE, value.latitude);
                      sharedPref.setDouble(LONGITUDE, value.longitude);
                    });
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<Position?> determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(language.locationNotAvailable);
    }
  } else {
    //throw Exception('Error');
  }
  return await Geolocator.getCurrentPosition();
}

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as map;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:taxi_driver/utils/Extensions/Loader.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Images.dart';
import '../main.dart';
import '../model/RideDetailModel.dart';
import '../model/UserDetailModel.dart';
import '../network/RestApis.dart';
import '../screens/ChatScreen.dart';
import '../screens/DashboardScreen.dart';
import '../screens/RidesListScreen.dart';
import 'Colors.dart';
import 'Constants.dart';
import 'Extensions/app_common.dart';

Widget dotIndicator(list, i) {
  return SizedBox(
    height: 16,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        list.length,
        (ind) {
          return Container(
            height: 8,
            width: 8,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(color: i == ind ? Colors.white : Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(defaultRadius)),
          );
        },
      ),
    ),
  );
}

InputDecoration inputDecoration(BuildContext context, {String? label, Widget? prefixIcon, Widget? suffixIcon}) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: dividerColor)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: dividerColor)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: dividerColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.black)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: dividerColor)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.red)),
    alignLabelWithHint: true,
    filled: false,
    isDense: true,
    labelText: label ?? "Sample Text",
    labelStyle: primaryTextStyle(),
  );
}

extension BooleanExtensions on bool? {
  /// Validate given bool is not null and returns given value if null.
  bool validate({bool value = false}) => this ?? value;
}

EdgeInsets dynamicAppButtonPadding(BuildContext context) {
  return EdgeInsets.symmetric(vertical: 14, horizontal: 16);
}

Widget inkWellWidget({Function()? onTap, required Widget child}) {
  return InkWell(onTap: onTap, child: child, highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent);
}

Widget commonCachedNetworkImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  double? radius,
}) {
  if (url != null && url.isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.network(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('images/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center);
}

List<BoxShadow> defaultBoxShadow({
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
}) {
  return [
    BoxShadow(
      color: shadowColor ?? Colors.grey.withOpacity(0.2),
      blurRadius: blurRadius ?? 4.0,
      spreadRadius: spreadRadius ?? 1.0,
      offset: offset,
    )
  ];
}

/// Hide soft keyboard
void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());

const double degrees2Radians = pi / 180.0;

double radians(double degrees) => degrees * degrees2Radians;

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

Widget loaderWidget() {
  return Center(
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 10, spreadRadius: 0, offset: Offset(0.0, 0.0)),
        ],
      ),
      width: 50,
      height: 50,
      child: CircularProgressIndicator(strokeWidth: 3, color: primaryColor),
    ),
  );
}

void afterBuildCreated(Function()? onCreated) {
  makeNullable(SchedulerBinding.instance)!.addPostFrameCallback((_) => onCreated?.call());
}

T? makeNullable<T>(T? value) => value;

String printDate(String date) {
  return DateFormat('dd MMM yyyy').format(DateTime.parse(date).toLocal()) + " at " + DateFormat('hh:mm a').format(DateTime.parse(date).toLocal());
}

String printAmount(String amount) {
  return appStore.currencyPosition == LEFT ? '${appStore.currencyCode} $amount' : '$amount ${appStore.currencyCode}';
}

Widget emptyWidget() {
  return Center(child: Image.asset(ic_no_data, width: 150, height: 250));
}

buttonText({String? status}) {
  if (status == NEW_RIDE_REQUESTED) {
    return language.accepted;
  } else if (status == ACCEPTED) {
    return language.arriving;
  } else if (status == IN_PROGRESS) {
    return language.endRide;
  } else if (status == CANCELED) {
    return language.cancelled;
  } else if (status == ARRIVING) {
    return language.arrived;
  } else if (status == ARRIVED) {
    return language.startRide;
  } else {
    return language.accepted;
  }
}

String statusTypeIcon({String? type}) {
  String icon = ic_history_img1;
  if (type == NEW_RIDE_REQUESTED) {
    icon = ic_history_img1;
  } else if (type == ACCEPTED) {
    icon = ic_history_img2;
  } else if (type == ARRIVING) {
    icon = ic_history_img3;
  } else if (type == ARRIVED) {
    icon = ic_history_img4;
  } else if (type == IN_PROGRESS) {
    icon = ic_history_img5;
  } else if (type == CANCELED) {
    icon = ic_history_img6;
  } else if (type == COMPLETED) {
    icon = ic_history_img7;
  }
  return icon;
}

bool get isRTL => rtlLanguage.contains(appStore.selectedLanguage);

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return (12742 * asin(sqrt(a))).toStringAsFixed(digitAfterDecimal).toDouble();
}

Widget totalCount({String? title, num? amount, bool? isTotal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(title!, style: isTotal == true ? boldTextStyle(color: Colors.green, size: 18) : secondaryTextStyle())),
      Text(printAmount(amount!.toStringAsFixed(digitAfterDecimal)), style: isTotal == true ? boldTextStyle(color: Colors.green, size: 18) : boldTextStyle(size: 14)),
    ],
  );
}

Future<bool> checkPermission() async {
  // Request app level location permission
  LocationPermission locationPermission = await Geolocator.requestPermission();

  if (locationPermission == LocationPermission.whileInUse || locationPermission == LocationPermission.always) {
    // Check system level location permission
    if (!await Geolocator.isLocationServiceEnabled()) {
      return await Geolocator.openLocationSettings().then((value) => false).catchError((e) => false);
    } else {
      return true;
    }
  } else {
    toast(language.pleaseEnableLocationPermission);

    // Open system level location permission
    await Geolocator.openAppSettings();

    return true;
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

/// Handle error and loading widget when using FutureBuilder or StreamBuilder
Widget snapWidgetHelper<T>(AsyncSnapshot<T> snap,
    {Widget? errorWidget, Widget? loadingWidget, String? defaultErrorMessage, @Deprecated('Do not use this') bool checkHasData = false, Widget Function(String)? errorBuilder}) {
  if (snap.hasError) {
    log(snap.error);
    if (errorBuilder != null) {
      return errorBuilder.call(defaultErrorMessage ?? snap.error.toString());
    }
    return Center(
      child: errorWidget ??
          Text(
            defaultErrorMessage ?? snap.error.toString(),
            style: primaryTextStyle(),
          ),
    );
  } else if (!snap.hasData) {
    return loadingWidget ?? Loader();
  } else {
    return SizedBox();
  }
}

String changeStatusText(String? status) {
  if (status == COMPLETED) {
    return language.completed;
  } else if (status == CANCELED) {
    return language.cancelled;
  }
  return '';
}

String changeGender(String? name) {
  if (name == MALE) {
    return language.male;
  } else if (name == FEMALE) {
    return language.female;
  } else if (name == OTHER) {
    return language.other;
  }
  return '';
}

String paymentStatus(String paymentStatus) {
  if (paymentStatus.toLowerCase() == PAYMENT_PENDING.toLowerCase()) {
    return language.pending;
  } else if (paymentStatus.toLowerCase() == PAYMENT_FAILED.toLowerCase()) {
    return language.failed;
  } else if (paymentStatus == PAYMENT_PAID) {
    return language.paid;
  } else if (paymentStatus == CASH) {
    return language.cash;
  } else if (paymentStatus == Wallet) {
    return language.wallet;
  }
  return language.pending;
}

Widget loaderWidgetLogIn() {
  return Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

Widget earningWidget({String? text, String? image, num? totalAmount}) {
  return Container(
    width: 160,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 10.0, spreadRadius: 0),
      ],
      color: primaryColor,
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text!, style: boldTextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text(totalAmount.toString(), style: boldTextStyle(color: Colors.white)),
          ],
        ),
        Expanded(
          child: SizedBox(width: 8),
        ),
        Container(
          margin: EdgeInsets.only(left: 2),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(defaultRadius)),
          child: Image.asset(image!, fit: BoxFit.cover, height: 40, width: 40),
        )
      ],
    ),
  );
}

Widget earningText({String? title, num? amount, bool? isTotal = false, bool? isRides = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title!, style: isTotal == true ? boldTextStyle(size: 18) : primaryTextStyle()),
      Text(isRides.validate() ? amount.toString() : printAmount(amount!.toStringAsFixed(digitAfterDecimal)),
          style: isTotal == true ? boldTextStyle(size: 18, color: Colors.green) : primaryTextStyle()),
    ],
  );
}

String getMessageFromErrorCode(FirebaseException error) {
  switch (error.code) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "The email address is already in use by another account.";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
    // case "ERROR_OPERATION_NOT_ALLOWED":
    case "operation-not-allowed":
      return "Server error, please try again later.";
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
    default:
      return error.message.toString();
  }
}

Widget mapRedirectionWidget({required LatLng latLong}) {
  return inkWellWidget(
    onTap: () async {
      log("lat long $latLong");
      final availableMaps = await map.MapLauncher.installedMaps;
      await availableMaps.first.showDirections(
        destination: map.Coords(latLong.latitude, latLong.longitude),
      );
    },
    child: Container(
      padding: EdgeInsets.all(4),
      decoration:
          BoxDecoration(color: !appStore.isDarkMode ? scaffoldColorLight : scaffoldColorDark, borderRadius: BorderRadius.all(radiusCircular(8)), border: Border.all(width: 1, color: dividerColor)),
      child: Image.asset(ic_map_icon),
      width: 30,
      height: 30,
    ),
  );
}

Widget chatCallWidget(IconData icon) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(border: Border.all(color: dividerColor), color: appStore.isDarkMode ? scaffoldColorDark : scaffoldColorLight, borderRadius: BorderRadius.circular(defaultRadius)),
    child: Icon(icon, size: 18, color: primaryColor),
  );
}

Color paymentStatusColor(String paymentStatus) {
  Color color = textPrimaryColor;

  switch (paymentStatus) {
    case PAYMENT_PAID:
      color = Colors.green;
    case PAYMENT_FAILED:
      color = Colors.red;
    case PAYMENT_PENDING:
      color = Colors.grey;
  }
  return color;
}

Future<void> updatePlayerId() async {
  Map req = {
    "player_id": sharedPref.getString(PLAYER_ID),
  };
  updateStatus(req).then((value) {
    log(value.message);
  }).catchError((error) {});
}

oneSignalSettings() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);
  OneSignal.Notifications.requestPermission(true);

  OneSignal.initialize(mOneSignalAppIdDriver);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
    event.preventDefault();
    event.notification.display();
  });

  saveOneSignalPlayerId();
  if (appStore.isLoggedIn) {
    updatePlayerId();
  }
  OneSignal.Notifications.addClickListener((notification) async {
    var notId = notification.notification.additionalData!["id"];
    log("$notId---" + notification.notification.additionalData!['type'].toString());
    var notType = notification.notification.additionalData!['type'];
    if (notType != null) {
      await rideDetail(orderId: notId).then((value) {
        RideDetailModel mRideModel = value;
        if (mRideModel.data!.driverId != null) {
          if (sharedPref.getInt(USER_ID) == mRideModel.data!.driverId) {
            if (mRideModel.data!.paymentStatus == "paid") {
              launchScreen(getContext, RidesListScreen());
            } else {
              launchScreen(getContext, DashboardScreen());
            }
          } else {
            toast("Sorry! You missed this ride");
          }
        }
      }).catchError((error) {
        appStore.setLoading(false);
        log('${error.toString()}');
      });
    }
    if (notId != null) {
      if (notId.toString().contains('CHAT')) {
        UserDetailModel user = await getUserDetail(userId: int.parse(notId.toString().replaceAll("CHAT_", "")));
        launchScreen(getContext, ChatScreen(userData: user.data));
      }
    }
  });
}

Future<void> saveOneSignalPlayerId() async {
  // await OneSignal.shared.getDeviceState().then((value) async {
  // });
  OneSignal.User.pushSubscription.addObserver((state) async {
    print(OneSignal.User.pushSubscription.optedIn);
    print("Player Id" + OneSignal.User.pushSubscription.id.toString());
    print(OneSignal.User.pushSubscription.token);
    print(state.current.jsonRepresentation());

    if (OneSignal.User.pushSubscription.id.validate().isNotEmpty) await sharedPref.setString(PLAYER_ID, OneSignal.User.pushSubscription.id.validate());
  });
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../screens/BankInfoScreen.dart';
import '../screens/EarningScreen.dart';
import '../screens/EditProfileScreen.dart';
import '../screens/EmergencyContactScreen.dart';
import '../screens/RidesListScreen.dart';
import '../screens/WalletScreen.dart';
import '../screens/SettingScreen.dart';
import '../screens/VehicleScreen.dart';
import '../screens/DocumentsScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Images.dart';
import 'DrawerWidget.dart';

class DrawerComponent extends StatefulWidget {
  final Function? onCall;

  DrawerComponent({this.onCall});

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 35),
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Observer(builder: (context) {
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: radius(),
                      child: commonCachedNetworkImage(appStore.userProfile.validate().validate(), height: 70, width: 70, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sharedPref.getString(FIRST_NAME).validate().capitalizeFirstLetter() + " " + sharedPref.getString(LAST_NAME).validate().capitalizeFirstLetter(), style: boldTextStyle()),
                          SizedBox(height: 4),
                          Text(appStore.userEmail, style: secondaryTextStyle()),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Divider(thickness: 1, height: 40),
            DrawerWidget(
                title: language.profile,
                iconData: ic_my_profile,
                icon: FontAwesome.user_o,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, EditProfileScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.rides,
                iconData: ic_my_rides,
                icon: Ionicons.car_outline,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, RidesListScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.vehicleInfo,
                iconData: ic_vehical_detail,
                icon: Ionicons.car_outline,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, VehicleScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.wallet,
                iconData: ic_my_wallet,
                icon: Ionicons.ios_wallet_outline,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, WalletScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.emergencyContacts,
                iconData: ic_emergency,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, EmergencyContactScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.earnings,
                iconData: ic_wallet,
                icon: Ionicons.ios_wallet_outline,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, EarningScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.documents,
                icon: Ionicons.document_outline,
                iconData: ic_verify_document,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, DocumentsScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.bankInfo,
                iconData: ic_update_bank_info,
                icon: MaterialCommunityIcons.bank_outline,
                onTap: () {
                  Navigator.pop(context);
                  launchScreen(context, BankInfoScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.settings,
                iconData: ic_setting,
                onTap: () {
                  launchScreen(context, SettingScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                }),
            DrawerWidget(
                title: language.logOut,
                iconData: ic_logout,
                onTap: () async {
                  await showConfirmDialogCustom(context,
                      primaryColor: primaryColor,
                      dialogType: DialogType.CONFIRMATION,
                      title: language.areYouSureYouWantToLogoutThisApp,
                      positiveText: language.yes,
                      negativeText: language.no, onAccept: (v) async {
                    widget.onCall!();
                    await Future.delayed(Duration(milliseconds: 500));
                    await logout();
                  });
                }),
          ],
        ),
      ),
    );
  }
}

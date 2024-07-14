import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/model/UserDetailModel.dart';
import 'package:taxi_driver/network/RestApis.dart';
import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Extensions/AppButtonWidget.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';

import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_textfield.dart';

class VehicleScreen extends StatefulWidget {
  @override
  VehicleScreenState createState() => VehicleScreenState();
}

class VehicleScreenState extends State<VehicleScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carPlateNumberController = TextEditingController();
  TextEditingController carProductionYearController = TextEditingController();
  TextEditingController vehicleService = TextEditingController();

  UserDetail userDetail = UserDetail();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      userDetail = value.data!.userDetail!;
      carModelController.text = userDetail.carModel.validate();
      carColorController.text = userDetail.carColor.validate();
      carPlateNumberController.text = userDetail.carPlateNumber.validate();
      carProductionYearController.text = userDetail.carProductionYear.validate();
      vehicleService.text = value.data!.driverService!.name.validate();
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> updateVehicle() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      updateVehicleDetail(
        carColor: carColorController.text.trim(),
        carModel: carModelController.text.trim(),
        carPlateNumber: carPlateNumberController.text.trim(),
        carProduction: carProductionYearController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);

        Navigator.pop(context);
        toast(language.vehicleInfoUpdateSucessfully);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.vehicleInfo, style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextField(
                    controller: vehicleService,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    readOnly: true,
                    decoration: inputDecoration(context, label: language.serviceInfo),
                    onTap: () {
                      toast(language.youCannotChangeService);
                    },
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carModelController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.carModel),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carColorController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.carColor),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carPlateNumberController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.carPlateNumber),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carProductionYearController,
                    textFieldType: TextFieldType.PHONE,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.carProductionYear),
                  ),
                ],
              ),
            ),
            Observer(builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            })
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.updateVehicle,
          color: primaryColor,
          textStyle: boldTextStyle(color: Colors.white),
          onTap: () {
            updateVehicle();
          },
        ),
      ),
    );
  }
}

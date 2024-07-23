import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi_driver/screens/DashboardScreen.dart';
import '../components/ImageSourceDialog.dart';
import '../model/ServiceModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import '../utils/Images.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import 'DocumentsScreen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isGoogle;

  EditProfileScreen({this.isGoogle = false});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  XFile? imageProfile;
  String countryCode = defaultCountryCode;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carPlateNumberController = TextEditingController();
  TextEditingController carProductionYearController = TextEditingController();

  List<ServiceList> listServices = [];
  int? selectedService;

  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode firstnameFocus = FocusNode();
  FocusNode lastnameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    if (widget.isGoogle) {
      await getServices().then((value) {
        listServices.addAll(value.data!);
        setState(() {});
      }).catchError((error) {
        log(error.toString());
      });
    }
    getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      emailController.text = value.data!.email.validate();
      usernameController.text = value.data!.username.validate();
      firstNameController.text = value.data!.firstName.validate();
      lastNameController.text = value.data!.lastName.validate();
      addressController.text = value.data!.address.validate();
      contactNumberController.text =
          value.data!.contactNumber.validate().splitAfter('$countryCode');

      if (value.data!.userDetail != null) {
        carModelController.text = value.data!.userDetail!.carModel.validate();
        carColorController.text = value.data!.userDetail!.carColor.validate();
        carPlateNumberController.text =
            value.data!.userDetail!.carPlateNumber.validate();
        carProductionYearController.text =
            value.data!.userDetail!.carProductionYear.validate();
      }
      selectedService = value.data!.driverService!.id;

      appStore.setUserEmail(value.data!.email.validate());
      appStore.setUserName(value.data!.username.validate());
      appStore.setFirstName(value.data!.firstName.validate());

      sharedPref.setString(USER_EMAIL, value.data!.email.validate());
      sharedPref.setString(FIRST_NAME, value.data!.firstName.validate());
      sharedPref.setString(LAST_NAME, value.data!.lastName.validate());

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
      appStore.setLoading(false);
    });
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(File(imageProfile!.path),
              height: 100,
              width: 100,
              fit: BoxFit.fill,
              alignment: Alignment.center),
        ),
      );
    } else {
      if (appStore.userProfile.validate().isNotEmpty) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: commonCachedNetworkImage(appStore.userProfile.validate(),
                fit: BoxFit.fill, height: 100, width: 100),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(ic_person, height: 90, width: 90),
            ),
          ),
        );
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> saveProfile() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      await updateProfile(
        uid: sharedPref.getString(UID).toString(),
        file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
        contactNumber: widget.isGoogle == true
            ? '$countryCode${contactNumberController.text.trim()}'
            : contactNumberController.text.trim(),
        address: addressController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userEmail: emailController.text.trim(),
        carColor: carColorController.text.trim(),
        carModel: carModelController.text.trim(),
        carPlateNumber: carPlateNumberController.text.trim(),
        carProduction: carProductionYearController.text.trim(),
        serviceId: selectedService,
      ).then((value) {
        appStore.setLoading(false);
        toast(language.profileUpdateMsg);
        if (widget.isGoogle == true) {
          updateProfileUid();
          if (sharedPref.getInt(IS_Verified_Driver) == 1) {
            launchScreen(context, DashboardScreen(),
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          } else {
            launchScreen(context, DocumentsScreen(isShow: true),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        } else {
          Navigator.pop(context);
        }
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
        title: Text(language.profile,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      profileImage(),
                      if (sharedPref.getString(LOGIN_TYPE) != LoginTypeGoogle)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: primaryColor),
                            child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft:
                                              Radius.circular(defaultRadius),
                                          topRight:
                                              Radius.circular(defaultRadius))),
                                  builder: (_) {
                                    return Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: ImageSourceDialog(
                                        onCamera: () async {
                                          Navigator.pop(context);
                                          imageProfile = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 100);
                                          setState(() {});
                                        },
                                        onGallery: () async {
                                          Navigator.pop(context);
                                          imageProfile = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 100);
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 20),
                  AppTextField(
                    readOnly: true,
                    enabled: false,
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: emailFocus,
                    nextFocus: userNameFocus,
                    decoration: inputDecoration(context, label: language.email),
                    onTap: () {
                      toast(language.notChangeEmail);
                    },
                  ),
                  if (sharedPref.getString(LOGIN_TYPE) != LoginTypeOTP &&
                      sharedPref.getString(LOGIN_TYPE) != null)
                    SizedBox(height: 16),
                  if (sharedPref.getString(LOGIN_TYPE) != LoginTypeOTP &&
                      sharedPref.getString(LOGIN_TYPE) != null)
                    AppTextField(
                      readOnly: true,
                      enabled: false,
                      controller: usernameController,
                      textFieldType: TextFieldType.USERNAME,
                      focus: userNameFocus,
                      nextFocus: firstnameFocus,
                      decoration:
                          inputDecoration(context, label: language.userName),
                      onTap: () {
                        toast(language.notChangeUsername);
                      },
                    ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: firstNameController,
                    textFieldType: TextFieldType.NAME,
                    focus: firstnameFocus,
                    nextFocus: lastnameFocus,
                    decoration:
                        inputDecoration(context, label: language.firstName),
                    errorThisFieldRequired: language.thisFieldRequired,
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: lastNameController,
                    textFieldType: TextFieldType.NAME,
                    focus: lastnameFocus,
                    nextFocus: contactFocus,
                    decoration:
                        inputDecoration(context, label: language.lastName),
                    errorThisFieldRequired: language.thisFieldRequired,
                  ),
                  SizedBox(height: 16),
                  widget.isGoogle == true
                      ? AppTextField(
                          controller: contactNumberController,
                          textFieldType: TextFieldType.PHONE,
                          focus: contactFocus,
                          nextFocus: addressFocus,
                          decoration: inputDecoration(
                            context,
                            label: language.phoneNumber,
                            prefixIcon: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountryCodePicker(
                                    padding: EdgeInsets.zero,
                                    initialSelection: countryCode,
                                    showCountryOnly: false,
                                    dialogSize: Size(
                                        MediaQuery.of(context).size.width - 60,
                                        MediaQuery.of(context).size.height *
                                            0.6),
                                    showFlag: true,
                                    showFlagDialog: true,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                    textStyle: primaryTextStyle(),
                                    dialogBackgroundColor:
                                        Theme.of(context).cardColor,
                                    barrierColor: Colors.black12,
                                    dialogTextStyle: primaryTextStyle(),
                                    searchDecoration: InputDecoration(
                                      iconColor: Theme.of(context).dividerColor,
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: primaryColor)),
                                    ),
                                    searchStyle: primaryTextStyle(),
                                    onInit: (c) {
                                      countryCode = c!.dialCode!;
                                    },
                                    onChanged: (c) {
                                      countryCode = c.dialCode!;
                                    },
                                  ),
                                  VerticalDivider(
                                      color: Colors.grey.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty)
                              return errorThisFieldRequired;
                            return null;
                          },
                        )
                      : AppTextField(
                          controller: contactNumberController,
                          textFieldType: TextFieldType.PHONE,
                          focus: contactFocus,
                          nextFocus: addressFocus,
                          isValidationRequired: true,
                          enabled: false,
                          readOnly: true,
                          decoration: inputDecoration(
                            context,
                            label: language.phoneNumber,
                            prefixIcon: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountryCodePicker(
                                    padding: EdgeInsets.zero,
                                    initialSelection: countryCode,
                                    showCountryOnly: false,
                                    dialogSize: Size(
                                        MediaQuery.of(context).size.width - 60,
                                        MediaQuery.of(context).size.height *
                                            0.6),
                                    showFlag: true,
                                    showFlagDialog: true,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                    textStyle: primaryTextStyle(),
                                    dialogBackgroundColor:
                                        Theme.of(context).cardColor,
                                    barrierColor: Colors.black12,
                                    dialogTextStyle: primaryTextStyle(),
                                    searchDecoration: InputDecoration(
                                      iconColor: Theme.of(context).dividerColor,
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: primaryColor)),
                                    ),
                                    searchStyle: primaryTextStyle(),
                                    onInit: (c) {
                                      countryCode = c!.dialCode!;
                                    },
                                    onChanged: (c) {
                                      countryCode = c.dialCode!;
                                    },
                                  ),
                                  VerticalDivider(
                                      color: Colors.grey.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            toast(language.youCannotChangePhoneNumber);
                          },
                        ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: addressController,
                    focus: addressFocus,
                    textFieldType: TextFieldType.ADDRESS,
                    textInputAction: TextInputAction.done,
                    decoration:
                        inputDecoration(context, label: language.address),
                  ),
                  if (widget.isGoogle) SizedBox(height: 16),
                  if (widget.isGoogle)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.vehicleInfo, style: boldTextStyle()),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: inputDecoration(context,
                              label: language.selectService),
                          items: listServices.map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  commonCachedNetworkImage(e.serviceImage,
                                      fit: BoxFit.cover, height: 50, width: 50),
                                  SizedBox(width: 8),
                                  Expanded(
                                      child: Text(e.name.validate(),
                                          style: primaryTextStyle())),
                                ],
                              ),
                            );
                          }).toList(),
                          value: selectedService,
                          onChanged: (value) {
                            selectedService = value;
                            setState(() {});
                          },
                          validator: (value) {
                            if (selectedService == null)
                              return errorThisFieldRequired;
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          controller: carModelController,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: language.thisFieldRequired,
                          decoration: inputDecoration(context,
                              label: language.carModel),
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          controller: carColorController,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: language.thisFieldRequired,
                          decoration: inputDecoration(context,
                              label: language.carColor),
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          controller: carPlateNumberController,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: language.thisFieldRequired,
                          decoration: inputDecoration(context,
                              label: language.carPlateNumber),
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          controller: carProductionYearController,
                          textFieldType: TextFieldType.PHONE,
                          errorThisFieldRequired: language.thisFieldRequired,
                          textInputAction: TextInputAction.done,
                          decoration: inputDecoration(context,
                              label: language.carProductionYear),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Observer(
            builder: (_) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.updateProfile,
          onTap: () {
            if (sharedPref.getString(USER_EMAIL) == 'mark80@gmail.com') {
              toast(language.demoMsg);
            } else {
              saveProfile();
            }
          },
        ),
      ),
    );
  }
}

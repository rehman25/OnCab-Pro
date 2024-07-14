import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/DetailScreen.dart';
import 'package:taxi_driver/screens/DashboardScreen.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import '../model/CurrentRequestModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class ReviewScreen extends StatefulWidget {
  final int rideId;
  final CurrentRequestModel currentData;

  ReviewScreen({required this.rideId, required this.currentData});

  @override
  ReviewScreenState createState() => ReviewScreenState();
}

class ReviewScreenState extends State<ReviewScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController reviewController = TextEditingController();

  num rattingData = 0;
  Payment? paymentData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  Future<void> userReviewData() async {
    if (formKey.currentState!.validate()) {
      hideKeyboard(context);
      if (rattingData == 0) return toast(language.pleaseSelectRating);
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);
      Map req = {
        "ride_request_id": widget.rideId,
        "rating": rattingData,
        "comment": reviewController.text.trim(),
      };
      await ratingReview(request: req).then((value) {
        getRiderCheck();
        appStore.setLoading(false);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  Future<void> getRiderCheck() async {
    appStore.setLoading(false);
    await rideDetail(orderId: widget.rideId).then((value) {
      if (value.payment != null && value.payment!.paymentStatus == PENDING) {
        launchScreen(context, DetailScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else {
        launchScreen(context, DashboardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);

      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(language.howWasYourRide, style: boldTextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: commonCachedNetworkImage(widget.currentData.rider!.profileImage.validate(), fit: BoxFit.fill, height: 70, width: 70),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('${widget.currentData.rider!.firstName.validate()} ${widget.currentData.rider!.lastName.validate()}', style: boldTextStyle()),
                          SizedBox(height: 8),
                          Text(widget.currentData.rider!.email.validate(), style: secondaryTextStyle()),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  RatingBar.builder(
                    direction: Axis.horizontal,
                    glow: false,
                    allowHalfRating: false,
                    wrapAlignment: WrapAlignment.spaceBetween,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      rattingData = rating;
                      print(rattingData);
                    },
                  ),
                  SizedBox(height: 32),
                  Text(language.addReviews, style: boldTextStyle(color: primaryColor)),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: reviewController,
                    decoration: inputDecoration(context, label: language.writeYourComments),
                    textFieldType: TextFieldType.NAME,
                    textInputAction: TextInputAction.done,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  AppButtonWidget(
                    text: language.continueD,
                    width: MediaQuery.of(context).size.width,
                    onTap: () {
                      userReviewData();
                    },
                  )
                ],
              ),
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
    );
  }
}

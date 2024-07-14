import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get thisFieldRequired;

  String get email;

  String get password;

  String get forgotPassword;

  String get logIn;

  String get orLogInWith;

  String get donHaveAnAccount;

  String get signUp;

  String get firstName;

  String get lastName;

  String get userName;

  String get phoneNumber;

  String get changePassword;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordDoesNotMatch;

  String get passwordInvalid;

  String get yes;

  String get no;

  String get writeMessage;

  String get enterTheEmailAssociatedWithYourAccount;

  String get submit;

  String get language;

  String get notification;

  String get useInCaseOfEmergency;

  String get notifyAdmin;

  String get notifiedSuccessfully;

  String get complain;

  String get pleaseEnterSubject;

  String get writeDescription;

  String get saveComplain;

  String get address;

  String get updateProfile;

  String get notChangeUsername;

  String get notChangeEmail;

  String get profileUpdateMsg;

  String get emergencyContact;

  String get areYouSureYouWantDeleteThisNumber;

  String get addContact;

  String get save;

  String get availableBalance;

  String get recentTransactions;

  String get moneyDeposited;

  String get addMoney;

  String get cancel;

  String get pleaseSelectAmount;

  String get amount;

  String get confirm;

  String get wallet;

  String get paymentDetail;

  String get rideId;

  String get viewHistory;

  String get paymentDetails;

  String get paymentType;

  String get paymentStatus;

  String get priceDetail;

  String get basePrice;

  String get distancePrice;

  String get waitTime;

  String get extraCharges;

  String get couponDiscount;

  String get total;

  String get payment;

  String get cash;

  String get waitingForDriverConformation;

  String get tip;

  String get pay;

  String get howWasYourRide;

  String get addReviews;

  String get writeYourComments;

  String get continueD;

  String get detailScreen;

  String get rideHistory;

  String get emergencyContacts;

  String get logOut;

  String get areYouSureYouWantToLogoutThisApp;

  String get destinationLocation;

  String get profile;

  String get privacyPolicy;

  String get helpSupport;

  String get termsConditions;

  String get aboutUs;

  String get rides;

  String get sendOTP;

  String get carModel;

  String get sos;

  String get signInUsingYourMobileNumber;

  String get accepted;

  String get arriving;

  String get arrived;

  String get cancelled;

  String get completed;

  String get pleaseEnableLocationPermission;

  String get pending;

  String get failed;

  String get paid;

  String get male;

  String get female;

  String get other;

  String get addExtraCharges;

  String get enterAmount;

  String get pleaseAddedAmount;

  String get title;

  String get charges;

  String get saveCharges;

  String get bankName;

  String get bankCode;

  String get accountHolderName;

  String get accountNumber;

  String get updateBankDetail;

  String get addBankDetail;

  String get bankInfoUpdateSuccessfully;

  String get youAreOnlineNow;

  String get youAreOfflineNow;

  String get requests;

  String get areYouSureYouWantToCancelThisRequest;

  String get decline;

  String get accept;

  String get areYouSureYouWantToAcceptThisRequest;

  String get call;

  String get areYouSureYouWantToArriving;

  String get areYouSureYouWantToArrived;

  String get enterOtp;

  String get pleaseEnterValidOtp;

  String get pleaseSelectService;

  String get userDetail;

  String get selectService;

  String get carColor;

  String get carPlateNumber;

  String get carProductionYear;

  String get withDraw;

  String get withdrawHistory;

  String get approved;

  String get requested;

  String get updateVehicle;

  String get userNotApproveMsg;

  String get uploadFileConfirmationMsg;

  String get selectDocument;

  String get addDocument;

  String get areYouSureYouWantToDeleteThisDocument;

  String get expireDate;

  String get goDashBoard;

  String get deleteAccount;

  String get account;

  String get areYouSureYouWantPleaseReadAffect;

  String get deletingAccountEmail;

  String get areYouSureYouWantDeleteAccount;

  String get yourInternetIsNotWorking;

  String get allow;

  String get mostReliableMightyDriverApp;

  String get toEnjoyYourRideExperiencePleaseAllowPermissions;

  String get cashCollected;

  String get areYouSureCollectThisPayment;

  String get txtURLEmpty;

  String get lblFollowUs;

  String get bankInfo;

  String get duration;

  String get moneyDebit;

  String get vehicleInfo;

  String get demoMsg;

  String get youCannotChangePhoneNumber;

  String get offLine;

  String get online;

  String get aboutRider;

  String get pleaseEnterMessage;

  String get pleaseSelectRating;

  String get serviceInfo;

  String get youCannotChangeService;

  String get vehicleInfoUpdateSucessfully;

  String get isMandatoryDocument;

  String get someRequiredDocumentAreNotUploaded;

  String get areYouCertainOffline;

  String get areYouCertainOnline;

  String get pleaseAcceptTermsOfServicePrivacyPolicy;

  String get rememberMe;

  String get agreeToThe;

  String get invoice;

  String get riderInformation;

  String get customerName;

  String get sourceLocation;

  String get invoiceNo;

  String get invoiceDate;

  String get orderedDate;

  String get totalEarning;

  String get pleaseSelectFromDateAndToDate;

  String get fromDate;

  String get toDate;

  String get ride;

  String get weeklyOrderCount;

  String get distance;

  String get iAgreeToThe;

  String get today;

  String get weekly;

  String get report;

  String get earning;

  String get todayEarning;

  String get available;

  String get notAvailable;

  String get youWillReceiveNewRidersAndNotifications;

  String get youWillNotReceiveNewRidersAndNotifications;

  String get yourAccountIs;

  String get pleaseContactSystemAdministrator;

  String get youCanNotThisActionsPerformBecauseYourCurrentRideIsNotCompleted;

  String get applyExtraCharges;

  String get pleaseSelectExtraCharges;

  String get unsupportedPlatForm;

  String get description;

  String get price;

  String get gallery;

  String get camera;

  String get locationNotAvailable;

  String get bankInfoNotFound;

  String get minimum;

  String get maximum;

  String get required;

  String get paymentFailed;

  String get checkConsoleForError;

  String get transactionFailed;

  String get transactionSuccessful;

  String get payWithCard;

  String get success;

  String get declined;

  String get endRide;

  String get startRide;

  String get invoiceCapital;

  String get validateOtp;

  String get otpCodeHasBeenSentTo;

  String get pleaseEnterOtp;

  String get selectSources;

  String get file;

  String get earnings;

  String get documents;

  String get settings;

  String get finishMsg;

  String get extraFees;

  String get skip;

  String get noteSelectFromDate;

  String get chatWithAdmin;

  String get startRideAskOTP;

  String get lessWalletAmountMsg;

  String get via;

  String get status;

  String get minutePrice;

  String get waitingTimePrice;

  String get additionalFees;

  String get minimumFees;

  String get tips;

  String get welcome;

  String get signcontinue;
}

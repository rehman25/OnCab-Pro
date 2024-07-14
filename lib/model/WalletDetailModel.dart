import 'WalletListModel.dart';

class WalletDetailModel {
  UserWalletModel? walletBalance;
  num? minAmountToGetRide;
  num? totalAmount;
  num? subscriptionAmountToGetRide;
  bool? isDriverSubscriptionExpire;

  WalletDetailModel({this.walletBalance, this.minAmountToGetRide, this.totalAmount, this.subscriptionAmountToGetRide, this.isDriverSubscriptionExpire});

  factory WalletDetailModel.fromJson(Map<String, dynamic> json) {
    return WalletDetailModel(
      walletBalance: json['wallet_balance'] != null ? UserWalletModel.fromJson(json['wallet_balance']) : null,
      minAmountToGetRide: json['min_amount_to_get_ride'],
      totalAmount: json['total_amount'],
      subscriptionAmountToGetRide: json['subscription_amount_to_get_ride'],
      isDriverSubscriptionExpire: json['is_driver_subscription_expire'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.walletBalance != null) {
      data['wallet_balance'] = this.walletBalance!.toJson();
    }
    data['min_amount_to_get_ride'] = this.minAmountToGetRide;
    data['total_amount'] = this.totalAmount;
    data['subscription_amount_to_get_ride'] = this.subscriptionAmountToGetRide;
    data['is_driver_subscription_expire'] = this.isDriverSubscriptionExpire;
    return data;
  }
}

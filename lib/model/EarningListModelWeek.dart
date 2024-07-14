class EarningListModelWeek {
  String? fromDate;
  String? toDate;
  String? todayDate;
  num? totalCardRide;
  num? totalCashRide;
  num? totalEarnings;
  num? totalRideCount;
  num? totalWalletRide;
  num? todayEarnings;
  num? todayRideRequest;
  List<WeekReport>? weekReport;

  EarningListModelWeek({
    this.fromDate,
    this.toDate,
    this.todayDate,
    this.totalCardRide,
    this.totalCashRide,
    this.totalEarnings,
    this.totalRideCount,
    this.totalWalletRide,
    this.weekReport,
    this.todayEarnings,
    this.todayRideRequest,
  });

  factory EarningListModelWeek.fromJson(Map<String, dynamic> json) {
    return EarningListModelWeek(
      fromDate: json['from_date'],
      toDate: json['to_date'],
      todayDate: json['today_date'],
      totalCardRide: json['total_card_ride'],
      totalCashRide: json['total_cash_ride'],
      totalEarnings: json['total_earnings'],
      totalRideCount: json['total_ride_count'],
      totalWalletRide: json['total_wallet_ride'],
      todayEarnings: json['today_earnings'],
      todayRideRequest: json['today_ride_request'],
      weekReport: json['week_report'] != null ? (json['week_report'] as List).map((i) => WeekReport.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    data['today_date'] = this.todayDate;
    data['total_card_ride'] = this.totalCardRide;
    data['total_cash_ride'] = this.totalCashRide;
    data['total_earnings'] = this.totalEarnings;
    data['total_ride_count'] = this.totalRideCount;
    data['total_wallet_ride'] = this.totalWalletRide;
    data['today_earnings'] = this.todayEarnings;
    data['today_ride_request'] = this.todayRideRequest;
    if (this.weekReport != null) {
      data['week_report'] = this.weekReport!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WeekReport {
  num? amount;
  String? date;
  String? day;

  WeekReport({this.amount, this.date, this.day});

  factory WeekReport.fromJson(Map<String, dynamic> json) {
    return WeekReport(
      amount: json['amount'],
      date: json['date'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['day'] = this.day;
    return data;
  }
}

class orderwiseearning {
  bool? success;
  List<EarningData>? data;
  dynamic totalEarning;

  orderwiseearning({this.success, this.data, this.totalEarning});

  orderwiseearning.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <EarningData>[];
      json['data'].forEach((v) {
        data!.add(new EarningData.fromJson(v));
      });
    }
    totalEarning = json['total_earning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total_earning'] = this.totalEarning;
    return data;
  }
}

class EarningData {
  dynamic earning;
  dynamic orderId;
  String? userName;
  String? date;
  String? time;

  EarningData(
      {this.earning, this.orderId, this.userName, this.date, this.time});

  EarningData.fromJson(Map<String, dynamic> json) {
    earning = json['earning'];
    orderId = json['order_id'];
    userName = json['user_name'];
    date = json['date'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['earning'] = this.earning;
    data['order_id'] = this.orderId;
    data['user_name'] = this.userName;
    data['date'] = this.date;
    data['time'] = this.time;
    return data;
  }
}

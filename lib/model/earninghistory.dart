class earninghistory {
  bool? success;
  Data? data;

  earninghistory({this.success, this.data});

  earninghistory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? currentMonth;
  String? todayEarning;
  String? weekEarning;
  String? yearliyEarning;
  String? totalAmount;
  List<Graph>? graph;

  Data(
      {this.currentMonth,
        this.todayEarning,
        this.weekEarning,
        this.yearliyEarning,
        this.totalAmount,
        this.graph});

  Data.fromJson(Map<String, dynamic> json) {
    currentMonth = json['current_month'];
    todayEarning = json['today_earning'];
    weekEarning = json['week_earning'];
    yearliyEarning = json['yearliy_earning'];
    totalAmount = json['total_amount'];
    if (json['graph'] != null) {
      graph = <Graph>[];
      json['graph'].forEach((v) {
        graph!.add(new Graph.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_month'] = this.currentMonth;
    data['today_earning'] = this.todayEarning;
    data['week_earning'] = this.weekEarning;
    data['yearliy_earning'] = this.yearliyEarning;
    data['total_amount'] = this.totalAmount;
    if (this.graph != null) {
      data['graph'] = this.graph!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Graph {
  String? month;
  String? monthEarning;

  Graph({this.month, this.monthEarning});

  Graph.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    monthEarning = json['month_earning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month'] = this.month;
    data['month_earning'] = this.monthEarning;
    return data;
  }
}


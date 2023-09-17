class orderhistory {
  bool? success;
  Data? data;

  orderhistory({this.success, this.data});

  orderhistory.fromJson(Map<String, dynamic> json) {
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
  List<Complete>? complete;
  List<Cancel>? cancel;

  Data({this.complete, this.cancel});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['complete'] != null) {
      complete = <Complete>[];
      json['complete'].forEach((v) {
        complete!.add(new Complete.fromJson(v));
      });
    }
    if (json['cancel'] != null) {
      cancel = <Cancel>[];
      json['cancel'].forEach((v) {
        cancel!.add(new Cancel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.complete != null) {
      data['complete'] = this.complete!.map((v) => v.toJson()).toList();
    }
    if (this.cancel != null) {
      data['cancel'] = this.cancel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Complete {
  int? id;
  int? addressId;
  dynamic amount;
  String? orderId;
  int? userId;
  int? vendorId;
  String? paymentStatus;
  String? orderStatus;
  Vendor? vendor;
  User? user;
  UserAddress? userAddress;
  List<OrderItems>? orderItems;

  Complete(
      {this.id,
      this.addressId,
      this.amount,
      this.orderId,
      this.userId,
      this.vendorId,
      this.paymentStatus,
      this.orderStatus,
      this.vendor,
      this.user,
      this.userAddress,
      this.orderItems});

  Complete.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressId = json['address_id'];
    amount = json['amount'] != null ? json['amount'] : 0.0;
    orderId = json['order_id'];
    userId = json['user_id'];
    vendorId = json['vendor_id'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    userAddress = json['user_address'] != null
        ? new UserAddress.fromJson(json['user_address'])
        : null;
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(new OrderItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address_id'] = this.addressId;
    data['amount'] = this.amount;
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    data['vendor_id'] = this.vendorId;
    data['payment_status'] = this.paymentStatus;
    data['order_status'] = this.orderStatus;
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.userAddress != null) {
      data['user_address'] = this.userAddress!.toJson();
    }
    if (this.orderItems != null) {
      data['orderItems'] = this.orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vendor {
  String? name;
  String? mapAddress;
  String? image;
  String? lat;
  String? lang;

  // List<Null> cuisine;
  dynamic rate;
  int? review;

  Vendor(
      {this.name,
      this.mapAddress,
      this.image,
      this.lat,
      this.lang,
      this.rate,
      this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mapAddress = json['map_address'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['map_address'] = this.mapAddress;
    data['image'] = this.image;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? image;
  String? emailId;
  String? emailVerifiedAt;
  String? deviceToken;
  String? phone;
  int? isVerified;
  int? status;
  int? otp;
  String? faviroute;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.name,
      this.image,
      this.emailId,
      this.emailVerifiedAt,
      this.deviceToken,
      this.phone,
      this.isVerified,
      this.status,
      this.otp,
      this.faviroute,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    deviceToken = json['device_token'];
    phone = json['phone'];
    isVerified = json['is_verified'];
    status = json['status'];
    otp = json['otp'];
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['email_id'] = this.emailId;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['device_token'] = this.deviceToken;
    data['phone'] = this.phone;
    data['is_verified'] = this.isVerified;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['faviroute'] = this.faviroute;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class UserAddress {
  String? address;
  String? lat;
  String? lang;

  UserAddress({this.address, this.lat, this.lang});

  UserAddress.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    return data;
  }
}

class OrderItems {
  int? id;
  List<dynamic>? custimization;
  int? item;
  dynamic price;
  int? qty;
  String? itemName;

  OrderItems(
      {this.id,
      this.custimization,
      this.item,
      this.price,
      this.qty,
      this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    custimization = json['custimization'];
    item = json['item'];
    price = json['price'] != null ? json['price'] : 0.0;
    qty = json['qty'];
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['custimization'] = this.custimization;
    data['item'] = this.item;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['itemName'] = this.itemName;
    return data;
  }
}

class Cancel {
  int? id;
  int? addressId;
  dynamic amount;
  String? orderId;
  String? cancelReason;
  int? userId;
  int? vendorId;
  String? paymentStatus;
  String? orderStatus;
  Vendor? vendor;
  User? user;
  UserAddress? userAddress;
  List<OrderItems>? orderItems;

  bool arrowdown = true;
  bool arrowup = false;
  bool reason = false;

  Cancel(
      {this.id,
      this.addressId,
      this.amount,
      this.orderId,
      this.cancelReason,
      this.userId,
      this.vendorId,
      this.paymentStatus,
      this.orderStatus,
      this.vendor,
      this.user,
      this.userAddress,
      this.orderItems});

  Cancel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressId = json['address_id'];
    amount = json['amount'] != null ? json['amount'].todouble() : 0.0;
    orderId = json['order_id'];
    cancelReason = json['cancel_reason'];
    userId = json['user_id'];
    vendorId = json['vendor_id'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    vendor =
        json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    userAddress = json['user_address'] != null
        ? new UserAddress.fromJson(json['user_address'])
        : null;
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(new OrderItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address_id'] = this.addressId;
    data['amount'] = this.amount;
    data['order_id'] = this.orderId;
    data['cancel_reason'] = this.cancelReason;
    data['user_id'] = this.userId;
    data['vendor_id'] = this.vendorId;
    data['payment_status'] = this.paymentStatus;
    data['order_status'] = this.orderStatus;
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.userAddress != null) {
      data['user_address'] = this.userAddress!.toJson();
    }
    if (this.orderItems != null) {
      data['orderItems'] = this.orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

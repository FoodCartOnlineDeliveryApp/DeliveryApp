class login {
  bool? success;
  LoginData? data;

  login({this.success, this.data});

  login.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new LoginData.fromJson(json['data']) : null;
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

class LoginData {
  int? id;
  int? otp;
  String? lat;
  String? lang;
  String? image;
  String? firstName;
  String? phoneCode;
  int? isOnline;
  String? lastName;
  int? isVerified;
  String? emailId;
  String? password;
  String? contact;
  Null fullAddress;
  Null vehicleType;
  Null vehicleNumber;
  Null licenceNumber;
  Null nationalIdentity;
  Null licenceDoc;
  Null deliveryZoneId;
  int? status;
  int? notification;
  String? createdAt;
  String? updatedAt;
  String? token;

  LoginData(
      {this.id,
      this.otp,
      this.lat,
      this.lang,
      this.image,
      this.firstName,
      this.phoneCode,
      this.isOnline,
      this.lastName,
      this.isVerified,
      this.emailId,
      this.password,
      this.contact,
      this.fullAddress,
      this.vehicleType,
      this.vehicleNumber,
      this.licenceNumber,
      this.nationalIdentity,
      this.licenceDoc,
      this.deliveryZoneId,
      this.status,
      this.notification,
      this.createdAt,
      this.updatedAt,
      this.token});

  LoginData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    otp = json['otp'];
    lat = json['lat'];
    lang = json['lang'];
    image = json['image'];
    firstName = json['first_name'];
    phoneCode = json['phone_code'];
    isOnline = json['is_online'];
    lastName = json['last_name'];
    isVerified = json['is_verified'];
    emailId = json['email_id'];
    password = json['password'];
    contact = json['contact'];
    fullAddress = json['full_address'];
    vehicleType = json['vehicle_type'];
    vehicleNumber = json['vehicle_number'];
    licenceNumber = json['licence_number'];
    nationalIdentity = json['national_identity'];
    licenceDoc = json['licence_doc'];
    deliveryZoneId = json['delivery_zone_id'];
    status = json['status'];
    notification = json['notification'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['otp'] = this.otp;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['image'] = this.image;
    data['first_name'] = this.firstName;
    data['phone_code'] = this.phoneCode;
    data['is_online'] = this.isOnline;
    data['last_name'] = this.lastName;
    data['is_verified'] = this.isVerified;
    data['email_id'] = this.emailId;
    data['password'] = this.password;
    data['contact'] = this.contact;
    data['full_address'] = this.fullAddress;
    data['vehicle_type'] = this.vehicleType;
    data['vehicle_number'] = this.vehicleNumber;
    data['licence_number'] = this.licenceNumber;
    data['national_identity'] = this.nationalIdentity;
    data['licence_doc'] = this.licenceDoc;
    data['delivery_zone_id'] = this.deliveryZoneId;
    data['status'] = this.status;
    data['notification'] = this.notification;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['token'] = this.token;
    return data;
  }
}

class resendotp {
  bool? success;
  Data? data;

  resendotp({this.success, this.data});

  resendotp.fromJson(Map<String, dynamic> json) {
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
  String? fullAddress;
  String? vehicleType;
  String? vehicleNumber;
  String? licenceNumber;
  String? nationalIdentity;
  String? licenceDoc;
  String? deliveryZoneId;
  int? status;
  int? notification;
  String? deviceToken;
  String? createdAt;
  String? updatedAt;

  Data(
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
      this.deviceToken,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
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
    deviceToken = json['device_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['device_token'] = this.deviceToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

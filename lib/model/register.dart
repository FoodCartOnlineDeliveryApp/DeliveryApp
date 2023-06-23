class register {
  bool? success;
  Data? data;
  String? msg;

  register({this.success, this.data, this.msg});

  register.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  String? firstName;
  String? lastName;
  String? emailId;
  String? image;
  String? contact;
  String? phoneCode;
  int? status;
  int? isOnline;
  int? isVerified;
  String? password;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? otp;

  Data(
      {this.firstName,
      this.lastName,
      this.emailId,
      this.image,
      this.contact,
      this.phoneCode,
      this.status,
      this.isOnline,
      this.isVerified,
      this.password,
      this.updatedAt,
      this.createdAt,
      this.id,
      this.otp});

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    emailId = json['email_id'];
    image = json['image'];
    contact = json['contact'];
    phoneCode = json['phone_code'];
    status = json['status'];
    isOnline = json['is_online'];
    isVerified = json['is_verified'];
    password = json['password'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email_id'] = this.emailId;
    data['image'] = this.image;
    data['contact'] = this.contact;
    data['phone_code'] = this.phoneCode;
    data['status'] = this.status;
    data['is_online'] = this.isOnline;
    data['is_verified'] = this.isVerified;
    data['password'] = this.password;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['otp'] = this.otp;
    return data;
  }
}

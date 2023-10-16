class CurrentOrder {
  CurrentOrder({
    bool? success,
    CurrentOrderData? data,
  }) {
    _success = success;
    _data = data;
  }

  CurrentOrder.fromJson(dynamic json) {
    _success = json['success'];
    _data =
        json['data'] != null ? CurrentOrderData.fromJson(json['data']) : null;
  }
  bool? _success;
  CurrentOrderData? _data;
  CurrentOrder copyWith({
    bool? success,
    CurrentOrderData? data,
  }) =>
      CurrentOrder(
        success: success ?? _success,
        data: data ?? _data,
      );
  bool? get success => _success;
  CurrentOrderData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class CurrentOrderData {
  CurrentOrderData({
    int? id,
    String? orderId,
    int? vendorId,
    int? userId,
    int? deliveryPersonId,
    String? date,
    String? time,
    String? paymentType,
    String? paymentToken,
    String? paymentStatus,
    dynamic amount,
    dynamic adminCommission,
    dynamic vendorAmount,
    String? deliveryType,
    dynamic promocodeId,
    int? promocodePrice,
    dynamic vendorDiscountId,
    dynamic vendorDiscountPrice,
    int? addressId,
    int? deliveryCharge,
    String? orderStatus,
    dynamic cancelBy,
    dynamic cancelReason,
    String? tax,
    String? orderStartTime,
    String? orderEndTime,
    dynamic vendorPendingAmount,
    String? createdAt,
    String? updatedAt,
    Vendor? vendor,
    User? user,
    List<OrderItems>? orderItems,
    UserAddress? userAddress,
  }) {
    _id = id;
    _orderId = orderId;
    _vendorId = vendorId;
    _userId = userId;
    _deliveryPersonId = deliveryPersonId;
    _date = date;
    _time = time;
    _paymentType = paymentType;
    _paymentToken = paymentToken;
    _paymentStatus = paymentStatus;
    _amount = amount;
    _adminCommission = adminCommission;
    _vendorAmount = vendorAmount;
    _deliveryType = deliveryType;
    _promocodeId = promocodeId;
    _promocodePrice = promocodePrice;
    _vendorDiscountId = vendorDiscountId;
    _vendorDiscountPrice = vendorDiscountPrice;
    _addressId = addressId;
    _deliveryCharge = deliveryCharge;
    _orderStatus = orderStatus;
    _cancelBy = cancelBy;
    _cancelReason = cancelReason;
    _tax = tax;
    _orderStartTime = orderStartTime;
    _orderEndTime = orderEndTime;
    _vendorPendingAmount = vendorPendingAmount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _vendor = vendor;
    _user = user;
    _orderItems = orderItems;
    _userAddress = userAddress;
  }

  CurrentOrderData.fromJson(dynamic json) {
    _id = json['id'];
    _orderId = json['order_id'];
    _vendorId = json['vendor_id'];
    _userId = json['user_id'];
    _deliveryPersonId = json['delivery_person_id'];
    _date = json['date'];
    _time = json['time'];
    _paymentType = json['payment_type'];
    _paymentToken = json['payment_token'];
    _paymentStatus = json['payment_status'];
    _amount = json['amount'];
    _adminCommission = json['admin_commission'];
    _vendorAmount = json['vendor_amount'];
    _deliveryType = json['delivery_type'];
    _promocodeId = json['promocode_id'];
    _promocodePrice = json['promocode_price'];
    _vendorDiscountId = json['vendor_discount_id'];
    _vendorDiscountPrice = json['vendor_discount_price'];
    _addressId = json['address_id'];
    _deliveryCharge = json['delivery_charge'];
    _orderStatus = json['order_status'];
    _cancelBy = json['cancel_by'];
    _cancelReason = json['cancel_reason'];
    _tax = json['tax'];
    _orderStartTime = json['order_start_time'];
    _orderEndTime = json['order_end_time'];
    _vendorPendingAmount = json['vendor_pending_amount'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['orderItems'] != null) {
      _orderItems = [];
      json['orderItems'].forEach((v) {
        _orderItems?.add(OrderItems.fromJson(v));
      });
    }
    _userAddress = json['user_address'] != null
        ? UserAddress.fromJson(json['user_address'])
        : null;
  }
  int? _id;
  String? _orderId;
  int? _vendorId;
  int? _userId;
  int? _deliveryPersonId;
  String? _date;
  String? _time;
  String? _paymentType;
  String? _paymentToken;
  String? _paymentStatus;
  dynamic _amount;
  dynamic _adminCommission;
  dynamic _vendorAmount;
  String? _deliveryType;
  dynamic _promocodeId;
  int? _promocodePrice;
  dynamic _vendorDiscountId;
  dynamic _vendorDiscountPrice;
  int? _addressId;
  int? _deliveryCharge;
  String? _orderStatus;
  dynamic _cancelBy;
  dynamic _cancelReason;
  String? _tax;
  String? _orderStartTime;
  String? _orderEndTime;
  dynamic _vendorPendingAmount;
  String? _createdAt;
  String? _updatedAt;
  Vendor? _vendor;
  User? _user;
  List<OrderItems>? _orderItems;
  UserAddress? _userAddress;
  CurrentOrderData copyWith({
    int? id,
    String? orderId,
    int? vendorId,
    int? userId,
    int? deliveryPersonId,
    String? date,
    String? time,
    String? paymentType,
    String? paymentToken,
    String? paymentStatus,
    dynamic amount,
    dynamic adminCommission,
    dynamic vendorAmount,
    String? deliveryType,
    dynamic promocodeId,
    int? promocodePrice,
    dynamic vendorDiscountId,
    dynamic vendorDiscountPrice,
    int? addressId,
    int? deliveryCharge,
    String? orderStatus,
    dynamic cancelBy,
    dynamic cancelReason,
    String? tax,
    String? orderStartTime,
    String? orderEndTime,
    dynamic vendorPendingAmount,
    String? createdAt,
    String? updatedAt,
    Vendor? vendor,
    User? user,
    List<OrderItems>? orderItems,
    UserAddress? userAddress,
  }) =>
      CurrentOrderData(
        id: id ?? _id,
        orderId: orderId ?? _orderId,
        vendorId: vendorId ?? _vendorId,
        userId: userId ?? _userId,
        deliveryPersonId: deliveryPersonId ?? _deliveryPersonId,
        date: date ?? _date,
        time: time ?? _time,
        paymentType: paymentType ?? _paymentType,
        paymentToken: paymentToken ?? _paymentToken,
        paymentStatus: paymentStatus ?? _paymentStatus,
        amount: amount ?? _amount,
        adminCommission: adminCommission ?? _adminCommission,
        vendorAmount: vendorAmount ?? _vendorAmount,
        deliveryType: deliveryType ?? _deliveryType,
        promocodeId: promocodeId ?? _promocodeId,
        promocodePrice: promocodePrice ?? _promocodePrice,
        vendorDiscountId: vendorDiscountId ?? _vendorDiscountId,
        vendorDiscountPrice: vendorDiscountPrice ?? _vendorDiscountPrice,
        addressId: addressId ?? _addressId,
        deliveryCharge: deliveryCharge ?? _deliveryCharge,
        orderStatus: orderStatus ?? _orderStatus,
        cancelBy: cancelBy ?? _cancelBy,
        cancelReason: cancelReason ?? _cancelReason,
        tax: tax ?? _tax,
        orderStartTime: orderStartTime ?? _orderStartTime,
        orderEndTime: orderEndTime ?? _orderEndTime,
        vendorPendingAmount: vendorPendingAmount ?? _vendorPendingAmount,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        vendor: vendor ?? _vendor,
        user: user ?? _user,
        orderItems: orderItems ?? _orderItems,
        userAddress: userAddress ?? _userAddress,
      );
  int? get id => _id;
  String? get orderId => _orderId;
  int? get vendorId => _vendorId;
  int? get userId => _userId;
  int? get deliveryPersonId => _deliveryPersonId;
  String? get date => _date;
  String? get time => _time;
  String? get paymentType => _paymentType;
  String? get paymentToken => _paymentToken;
  String? get paymentStatus => _paymentStatus;
  dynamic get amount => _amount;
  dynamic get adminCommission => _adminCommission;
  dynamic get vendorAmount => _vendorAmount;
  String? get deliveryType => _deliveryType;
  dynamic get promocodeId => _promocodeId;
  int? get promocodePrice => _promocodePrice;
  dynamic get vendorDiscountId => _vendorDiscountId;
  dynamic get vendorDiscountPrice => _vendorDiscountPrice;
  int? get addressId => _addressId;
  int? get deliveryCharge => _deliveryCharge;
  String? get orderStatus => _orderStatus;
  dynamic get cancelBy => _cancelBy;
  dynamic get cancelReason => _cancelReason;
  String? get tax => _tax;
  String? get orderStartTime => _orderStartTime;
  String? get orderEndTime => _orderEndTime;
  dynamic get vendorPendingAmount => _vendorPendingAmount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  Vendor? get vendor => _vendor;
  User? get user => _user;
  List<OrderItems>? get orderItems => _orderItems;
  UserAddress? get userAddress => _userAddress;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['order_id'] = _orderId;
    map['vendor_id'] = _vendorId;
    map['user_id'] = _userId;
    map['delivery_person_id'] = _deliveryPersonId;
    map['date'] = _date;
    map['time'] = _time;
    map['payment_type'] = _paymentType;
    map['payment_token'] = _paymentToken;
    map['payment_status'] = _paymentStatus;
    map['amount'] = _amount;
    map['admin_commission'] = _adminCommission;
    map['vendor_amount'] = _vendorAmount;
    map['delivery_type'] = _deliveryType;
    map['promocode_id'] = _promocodeId;
    map['promocode_price'] = _promocodePrice;
    map['vendor_discount_id'] = _vendorDiscountId;
    map['vendor_discount_price'] = _vendorDiscountPrice;
    map['address_id'] = _addressId;
    map['delivery_charge'] = _deliveryCharge;
    map['order_status'] = _orderStatus;
    map['cancel_by'] = _cancelBy;
    map['cancel_reason'] = _cancelReason;
    map['tax'] = _tax;
    map['order_start_time'] = _orderStartTime;
    map['order_end_time'] = _orderEndTime;
    map['vendor_pending_amount'] = _vendorPendingAmount;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_vendor != null) {
      map['vendor'] = _vendor?.toJson();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_orderItems != null) {
      map['orderItems'] = _orderItems?.map((v) => v.toJson()).toList();
    }
    if (_userAddress != null) {
      map['user_address'] = _userAddress?.toJson();
    }
    return map;
  }
}

class UserAddress {
  UserAddress({
    String? lat,
    String? lang,
    String? address,
  }) {
    _lat = lat;
    _lang = lang;
    _address = address;
  }

  UserAddress.fromJson(dynamic json) {
    _lat = json['lat'];
    _lang = json['lang'];
    _address = json['address'];
  }
  String? _lat;
  String? _lang;
  String? _address;
  UserAddress copyWith({
    String? lat,
    String? lang,
    String? address,
  }) =>
      UserAddress(
        lat: lat ?? _lat,
        lang: lang ?? _lang,
        address: address ?? _address,
      );
  String? get lat => _lat;
  String? get lang => _lang;
  String? get address => _address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lat'] = _lat;
    map['lang'] = _lang;
    map['address'] = _address;
    return map;
  }
}

class OrderItems {
  OrderItems({
    int? id,
    int? orderId,
    int? item,
    dynamic price,
    int? qty,
    dynamic custimization,
    String? createdAt,
    String? updatedAt,
    String? itemName,
  }) {
    _id = id;
    _orderId = orderId;
    _item = item;
    _price = price;
    _qty = qty;
    _custimization = custimization;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _itemName = itemName;
  }

  OrderItems.fromJson(dynamic json) {
    _id = json['id'];
    _orderId = json['order_id'];
    _item = json['item'];
    _price = json['price'];
    _qty = json['qty'];
    _custimization = json['custimization'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _itemName = json['itemName'];
  }
  int? _id;
  int? _orderId;
  int? _item;
  dynamic _price;
  int? _qty;
  dynamic _custimization;
  String? _createdAt;
  String? _updatedAt;
  String? _itemName;
  OrderItems copyWith({
    int? id,
    int? orderId,
    int? item,
    dynamic price,
    int? qty,
    dynamic custimization,
    String? createdAt,
    String? updatedAt,
    String? itemName,
  }) =>
      OrderItems(
        id: id ?? _id,
        orderId: orderId ?? _orderId,
        item: item ?? _item,
        price: price ?? _price,
        qty: qty ?? _qty,
        custimization: custimization ?? _custimization,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        itemName: itemName ?? _itemName,
      );
  int? get id => _id;
  int? get orderId => _orderId;
  int? get item => _item;
  dynamic get price => _price;
  int? get qty => _qty;
  dynamic get custimization => _custimization;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get itemName => _itemName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['order_id'] = _orderId;
    map['item'] = _item;
    map['price'] = _price;
    map['qty'] = _qty;
    map['custimization'] = _custimization;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['itemName'] = _itemName;
    return map;
  }
}

class User {
  User({
    int? id,
    String? name,
    String? image,
    String? emailId,
    dynamic emailVerifiedAt,
    String? deviceToken,
    String? phone,
    String? phoneCode,
    int? isVerified,
    int? status,
    dynamic otp,
    String? faviroute,
    dynamic vendorId,
    String? language,
    dynamic ifscCode,
    dynamic accountName,
    dynamic accountNumber,
    dynamic micrCode,
    dynamic providerType,
    dynamic providerToken,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _image = image;
    _emailId = emailId;
    _emailVerifiedAt = emailVerifiedAt;
    _deviceToken = deviceToken;
    _phone = phone;
    _phoneCode = phoneCode;
    _isVerified = isVerified;
    _status = status;
    _otp = otp;
    _faviroute = faviroute;
    _vendorId = vendorId;
    _language = language;
    _ifscCode = ifscCode;
    _accountName = accountName;
    _accountNumber = accountNumber;
    _micrCode = micrCode;
    _providerType = providerType;
    _providerToken = providerToken;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];
    _emailId = json['email_id'];
    _emailVerifiedAt = json['email_verified_at'];
    _deviceToken = json['device_token'];
    _phone = json['phone'];
    _phoneCode = json['phone_code'];
    _isVerified = json['is_verified'];
    _status = json['status'];
    _otp = json['otp'];
    _faviroute = json['faviroute'];
    _vendorId = json['vendor_id'];
    _language = json['language'];
    _ifscCode = json['ifsc_code'];
    _accountName = json['account_name'];
    _accountNumber = json['account_number'];
    _micrCode = json['micr_code'];
    _providerType = json['provider_type'];
    _providerToken = json['provider_token'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  int? _id;
  String? _name;
  String? _image;
  String? _emailId;
  dynamic _emailVerifiedAt;
  String? _deviceToken;
  String? _phone;
  String? _phoneCode;
  int? _isVerified;
  int? _status;
  dynamic _otp;
  String? _faviroute;
  dynamic _vendorId;
  String? _language;
  dynamic _ifscCode;
  dynamic _accountName;
  dynamic _accountNumber;
  dynamic _micrCode;
  dynamic _providerType;
  dynamic _providerToken;
  String? _createdAt;
  String? _updatedAt;
  User copyWith({
    int? id,
    String? name,
    String? image,
    String? emailId,
    dynamic emailVerifiedAt,
    String? deviceToken,
    String? phone,
    String? phoneCode,
    int? isVerified,
    int? status,
    dynamic otp,
    String? faviroute,
    dynamic vendorId,
    String? language,
    dynamic ifscCode,
    dynamic accountName,
    dynamic accountNumber,
    dynamic micrCode,
    dynamic providerType,
    dynamic providerToken,
    String? createdAt,
    String? updatedAt,
  }) =>
      User(
        id: id ?? _id,
        name: name ?? _name,
        image: image ?? _image,
        emailId: emailId ?? _emailId,
        emailVerifiedAt: emailVerifiedAt ?? _emailVerifiedAt,
        deviceToken: deviceToken ?? _deviceToken,
        phone: phone ?? _phone,
        phoneCode: phoneCode ?? _phoneCode,
        isVerified: isVerified ?? _isVerified,
        status: status ?? _status,
        otp: otp ?? _otp,
        faviroute: faviroute ?? _faviroute,
        vendorId: vendorId ?? _vendorId,
        language: language ?? _language,
        ifscCode: ifscCode ?? _ifscCode,
        accountName: accountName ?? _accountName,
        accountNumber: accountNumber ?? _accountNumber,
        micrCode: micrCode ?? _micrCode,
        providerType: providerType ?? _providerType,
        providerToken: providerToken ?? _providerToken,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  int? get id => _id;
  String? get name => _name;
  String? get image => _image;
  String? get emailId => _emailId;
  dynamic get emailVerifiedAt => _emailVerifiedAt;
  String? get deviceToken => _deviceToken;
  String? get phone => _phone;
  String? get phoneCode => _phoneCode;
  int? get isVerified => _isVerified;
  int? get status => _status;
  dynamic get otp => _otp;
  String? get faviroute => _faviroute;
  dynamic get vendorId => _vendorId;
  String? get language => _language;
  dynamic get ifscCode => _ifscCode;
  dynamic get accountName => _accountName;
  dynamic get accountNumber => _accountNumber;
  dynamic get micrCode => _micrCode;
  dynamic get providerType => _providerType;
  dynamic get providerToken => _providerToken;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['image'] = _image;
    map['email_id'] = _emailId;
    map['email_verified_at'] = _emailVerifiedAt;
    map['device_token'] = _deviceToken;
    map['phone'] = _phone;
    map['phone_code'] = _phoneCode;
    map['is_verified'] = _isVerified;
    map['status'] = _status;
    map['otp'] = _otp;
    map['faviroute'] = _faviroute;
    map['vendor_id'] = _vendorId;
    map['language'] = _language;
    map['ifsc_code'] = _ifscCode;
    map['account_name'] = _accountName;
    map['account_number'] = _accountNumber;
    map['micr_code'] = _micrCode;
    map['provider_type'] = _providerType;
    map['provider_token'] = _providerToken;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}

class Vendor {
  Vendor({
    int? id,
    int? userId,
    String? name,
    String? vendorLogo,
    String? emailId,
    String? image,
    String? password,
    String? contact,
    String? cuisineId,
    String? address,
    String? lat,
    String? lang,
    String? mapAddress,
    String? minOrderAmount,
    String? forTwoPerson,
    String? avgDeliveryTime,
    String? licenseNumber,
    String? adminComissionType,
    String? adminComissionValue,
    String? vendorType,
    String? timeSlot,
    String? tax,
    dynamic deliveryTypeTimeSlot,
    int? isExplorer,
    int? isTop,
    int? vendorOwnDriver,
    dynamic paymentOption,
    int? status,
    String? vendorLanguage,
    dynamic connectorType,
    dynamic connectorDescriptor,
    dynamic connectorPort,
    String? createdAt,
    String? updatedAt,
    List<Cuisine>? cuisine,
    int? rate,
    int? review,
  }) {
    _id = id;
    _userId = userId;
    _name = name;
    _vendorLogo = vendorLogo;
    _emailId = emailId;
    _image = image;
    _password = password;
    _contact = contact;
    _cuisineId = cuisineId;
    _address = address;
    _lat = lat;
    _lang = lang;
    _mapAddress = mapAddress;
    _minOrderAmount = minOrderAmount;
    _forTwoPerson = forTwoPerson;
    _avgDeliveryTime = avgDeliveryTime;
    _licenseNumber = licenseNumber;
    _adminComissionType = adminComissionType;
    _adminComissionValue = adminComissionValue;
    _vendorType = vendorType;
    _timeSlot = timeSlot;
    _tax = tax;
    _deliveryTypeTimeSlot = deliveryTypeTimeSlot;
    _isExplorer = isExplorer;
    _isTop = isTop;
    _vendorOwnDriver = vendorOwnDriver;
    _paymentOption = paymentOption;
    _status = status;
    _vendorLanguage = vendorLanguage;
    _connectorType = connectorType;
    _connectorDescriptor = connectorDescriptor;
    _connectorPort = connectorPort;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _cuisine = cuisine;
    _rate = rate;
    _review = review;
  }

  Vendor.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _name = json['name'];
    _vendorLogo = json['vendor_logo'];
    _emailId = json['email_id'];
    _image = json['image'];
    _password = json['password'];
    _contact = json['contact'];
    _cuisineId = json['cuisine_id'];
    _address = json['address'];
    _lat = json['lat'];
    _lang = json['lang'];
    _mapAddress = json['map_address'];
    _minOrderAmount = json['min_order_amount'];
    _forTwoPerson = json['for_two_person'];
    _avgDeliveryTime = json['avg_delivery_time'];
    _licenseNumber = json['license_number'];
    _adminComissionType = json['admin_comission_type'];
    _adminComissionValue = json['admin_comission_value'];
    _vendorType = json['vendor_type'];
    _timeSlot = json['time_slot'];
    _tax = json['tax'];
    _deliveryTypeTimeSlot = json['delivery_type_timeSlot'];
    _isExplorer = json['isExplorer'];
    _isTop = json['isTop'];
    _vendorOwnDriver = json['vendor_own_driver'];
    _paymentOption = json['payment_option'];
    _status = json['status'];
    _vendorLanguage = json['vendor_language'];
    _connectorType = json['connector_type'];
    _connectorDescriptor = json['connector_descriptor'];
    _connectorPort = json['connector_port'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    if (json['cuisine'] != null) {
      _cuisine = [];
      json['cuisine'].forEach((v) {
        _cuisine?.add(Cuisine.fromJson(v));
      });
    }
    _rate = json['rate'];
    _review = json['review'];
  }
  int? _id;
  int? _userId;
  String? _name;
  String? _vendorLogo;
  String? _emailId;
  String? _image;
  String? _password;
  String? _contact;
  String? _cuisineId;
  String? _address;
  String? _lat;
  String? _lang;
  String? _mapAddress;
  String? _minOrderAmount;
  String? _forTwoPerson;
  String? _avgDeliveryTime;
  String? _licenseNumber;
  String? _adminComissionType;
  String? _adminComissionValue;
  String? _vendorType;
  String? _timeSlot;
  String? _tax;
  dynamic _deliveryTypeTimeSlot;
  int? _isExplorer;
  int? _isTop;
  int? _vendorOwnDriver;
  dynamic _paymentOption;
  int? _status;
  String? _vendorLanguage;
  dynamic _connectorType;
  dynamic _connectorDescriptor;
  dynamic _connectorPort;
  String? _createdAt;
  String? _updatedAt;
  List<Cuisine>? _cuisine;
  int? _rate;
  int? _review;
  Vendor copyWith({
    int? id,
    int? userId,
    String? name,
    String? vendorLogo,
    String? emailId,
    String? image,
    String? password,
    String? contact,
    String? cuisineId,
    String? address,
    String? lat,
    String? lang,
    String? mapAddress,
    String? minOrderAmount,
    String? forTwoPerson,
    String? avgDeliveryTime,
    String? licenseNumber,
    String? adminComissionType,
    String? adminComissionValue,
    String? vendorType,
    String? timeSlot,
    String? tax,
    dynamic deliveryTypeTimeSlot,
    int? isExplorer,
    int? isTop,
    int? vendorOwnDriver,
    dynamic paymentOption,
    int? status,
    String? vendorLanguage,
    dynamic connectorType,
    dynamic connectorDescriptor,
    dynamic connectorPort,
    String? createdAt,
    String? updatedAt,
    List<Cuisine>? cuisine,
    int? rate,
    int? review,
  }) =>
      Vendor(
        id: id ?? _id,
        userId: userId ?? _userId,
        name: name ?? _name,
        vendorLogo: vendorLogo ?? _vendorLogo,
        emailId: emailId ?? _emailId,
        image: image ?? _image,
        password: password ?? _password,
        contact: contact ?? _contact,
        cuisineId: cuisineId ?? _cuisineId,
        address: address ?? _address,
        lat: lat ?? _lat,
        lang: lang ?? _lang,
        mapAddress: mapAddress ?? _mapAddress,
        minOrderAmount: minOrderAmount ?? _minOrderAmount,
        forTwoPerson: forTwoPerson ?? _forTwoPerson,
        avgDeliveryTime: avgDeliveryTime ?? _avgDeliveryTime,
        licenseNumber: licenseNumber ?? _licenseNumber,
        adminComissionType: adminComissionType ?? _adminComissionType,
        adminComissionValue: adminComissionValue ?? _adminComissionValue,
        vendorType: vendorType ?? _vendorType,
        timeSlot: timeSlot ?? _timeSlot,
        tax: tax ?? _tax,
        deliveryTypeTimeSlot: deliveryTypeTimeSlot ?? _deliveryTypeTimeSlot,
        isExplorer: isExplorer ?? _isExplorer,
        isTop: isTop ?? _isTop,
        vendorOwnDriver: vendorOwnDriver ?? _vendorOwnDriver,
        paymentOption: paymentOption ?? _paymentOption,
        status: status ?? _status,
        vendorLanguage: vendorLanguage ?? _vendorLanguage,
        connectorType: connectorType ?? _connectorType,
        connectorDescriptor: connectorDescriptor ?? _connectorDescriptor,
        connectorPort: connectorPort ?? _connectorPort,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        cuisine: cuisine ?? _cuisine,
        rate: rate ?? _rate,
        review: review ?? _review,
      );
  int? get id => _id;
  int? get userId => _userId;
  String? get name => _name;
  String? get vendorLogo => _vendorLogo;
  String? get emailId => _emailId;
  String? get image => _image;
  String? get password => _password;
  String? get contact => _contact;
  String? get cuisineId => _cuisineId;
  String? get address => _address;
  String? get lat => _lat;
  String? get lang => _lang;
  String? get mapAddress => _mapAddress;
  String? get minOrderAmount => _minOrderAmount;
  String? get forTwoPerson => _forTwoPerson;
  String? get avgDeliveryTime => _avgDeliveryTime;
  String? get licenseNumber => _licenseNumber;
  String? get adminComissionType => _adminComissionType;
  String? get adminComissionValue => _adminComissionValue;
  String? get vendorType => _vendorType;
  String? get timeSlot => _timeSlot;
  String? get tax => _tax;
  dynamic get deliveryTypeTimeSlot => _deliveryTypeTimeSlot;
  int? get isExplorer => _isExplorer;
  int? get isTop => _isTop;
  int? get vendorOwnDriver => _vendorOwnDriver;
  dynamic get paymentOption => _paymentOption;
  int? get status => _status;
  String? get vendorLanguage => _vendorLanguage;
  dynamic get connectorType => _connectorType;
  dynamic get connectorDescriptor => _connectorDescriptor;
  dynamic get connectorPort => _connectorPort;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  List<Cuisine>? get cuisine => _cuisine;
  int? get rate => _rate;
  int? get review => _review;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['name'] = _name;
    map['vendor_logo'] = _vendorLogo;
    map['email_id'] = _emailId;
    map['image'] = _image;
    map['password'] = _password;
    map['contact'] = _contact;
    map['cuisine_id'] = _cuisineId;
    map['address'] = _address;
    map['lat'] = _lat;
    map['lang'] = _lang;
    map['map_address'] = _mapAddress;
    map['min_order_amount'] = _minOrderAmount;
    map['for_two_person'] = _forTwoPerson;
    map['avg_delivery_time'] = _avgDeliveryTime;
    map['license_number'] = _licenseNumber;
    map['admin_comission_type'] = _adminComissionType;
    map['admin_comission_value'] = _adminComissionValue;
    map['vendor_type'] = _vendorType;
    map['time_slot'] = _timeSlot;
    map['tax'] = _tax;
    map['delivery_type_timeSlot'] = _deliveryTypeTimeSlot;
    map['isExplorer'] = _isExplorer;
    map['isTop'] = _isTop;
    map['vendor_own_driver'] = _vendorOwnDriver;
    map['payment_option'] = _paymentOption;
    map['status'] = _status;
    map['vendor_language'] = _vendorLanguage;
    map['connector_type'] = _connectorType;
    map['connector_descriptor'] = _connectorDescriptor;
    map['connector_port'] = _connectorPort;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_cuisine != null) {
      map['cuisine'] = _cuisine?.map((v) => v.toJson()).toList();
    }
    map['rate'] = _rate;
    map['review'] = _review;
    return map;
  }
}

class Cuisine {
  Cuisine({
    String? name,
    String? image,
  }) {
    _name = name;
    _image = image;
  }

  Cuisine.fromJson(dynamic json) {
    _name = json['name'];
    _image = json['image'];
  }
  String? _name;
  String? _image;
  Cuisine copyWith({
    String? name,
    String? image,
  }) =>
      Cuisine(
        name: name ?? _name,
        image: image ?? _image,
      );
  String? get name => _name;
  String? get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['image'] = _image;
    return map;
  }
}

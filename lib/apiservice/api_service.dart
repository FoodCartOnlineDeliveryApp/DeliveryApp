import 'package:dio/dio.dart' hide Headers;
import 'package:mealup_driver/apiservice/apis.dart';
import 'package:mealup_driver/model/current_order.dart';
import 'package:mealup_driver/model/deliveryzone.dart';
import 'package:mealup_driver/model/displaydriver.dart';
import 'package:mealup_driver/model/earninghistory.dart';
import 'package:mealup_driver/model/faq.dart';
import 'package:mealup_driver/model/notification.dart';
import 'package:mealup_driver/model/orderhistory.dart';
import 'package:mealup_driver/model/orderlistdata.dart';
import 'package:mealup_driver/model/orderwiseearning.dart';
import 'package:mealup_driver/model/register.dart';
import 'package:mealup_driver/model/setting.dart';
import 'package:retrofit/retrofit.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: 'https://foodcartonline.in/api/driver/')
// please don't remove "/api/driver".
abstract class RestClient {

  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @POST(Apis.login)
  @FormUrlEncoded()
  Future<String> driverLogin(@Field() String email_id, @Field() String password, @Field() String device_token);

  @POST(Apis.register)
  @FormUrlEncoded()
  Future<register> driverRegister(
    @Field() String first_name,
    @Field() String last_name,
    @Field() String email_id,
    @Field() String phone,
    @Field() String phone_code,
    @Field() String password,
    @Field() String address,
  );

  @POST(Apis.checkOTP)
  @FormUrlEncoded()
  Future<String?> driverCheckOtp(
    @Field() String driver_id,
    @Field() String otp,
  );

  @POST(Apis.resendOTP)
  @FormUrlEncoded()
  Future<String?> driverResendOtp(
    @Field() String email_id,
  );

  @GET(Apis.driverSetting)
  Future<setting> driverSetting();

  @POST(Apis.updateDocument)
  @FormUrlEncoded()
  Future<String?> driverUploadDocument(
    @Field() String? vehicle_type,
    @Field() String vehicle_number,
    @Field() String licence_number,
    @Field() String national_identity,
    @Field() String licence_doc,
  );

  @GET(Apis.deliveryZone)
  Future<deliveryzone> driverDeliveryZone();

  @POST(Apis.setLocation)
  @FormUrlEncoded()
  Future<String?> driverSetDeliveryZone(
    @Field() String delivery_zone_id,
  );

  @POST(Apis.updateDriver)
  @FormUrlEncoded()
  Future<String?> driverUpdateStatus(
    @Field() String is_online,
  );

  @GET(Apis.driver)
  Future<displaydriver> driverProfile();

  @POST(Apis.updateDriverImage)
  @FormUrlEncoded()
  Future<String?> driverUpdateImage(
    @Field() String image,
  );

  @POST(Apis.updateDriver)
  @FormUrlEncoded()
  Future<String?> driverEditProfile(
    @Field() String? first_name,
    @Field() String? last_name,
    @Field() String? phone_code,
    @Field() String email_id,
    @Field() String? phone,
  );

  @POST(Apis.deliveryPersonChangePassword)
  @FormUrlEncoded()
  Future<String?> driverChangePassword(
    @Field() String old_password,
    @Field() String password,
    @Field() String password_confirmation,
  );

  @GET(Apis.earning)
  Future<earninghistory> driverEarningHistory();

  @GET(Apis.driverOrder)
  Future<orderlistdata> driveOrderList();

  @GET(Apis.currentOrder)
  Future<CurrentOrder> currentOrderList();

  @GET(Apis.orderHistory)
  Future<orderhistory> driverOrderHistory();

  @GET(Apis.orderEarning)
  Future<orderwiseearning> driverOrderWiseEarning();

  @GET(Apis.notification)
  Future<notification> driverNotification();

  @GET(Apis.driverFaq)
  Future<faq> driverFaq();

  @POST(Apis.statusChange)
  @FormUrlEncoded()
  Future<String?> orderStatusChange1(
    @Field() String? order_id,
    @Field() String order_status,
  );

  @POST(Apis.statusChange)
  @FormUrlEncoded()
  Future<String?> cancelOrder(
    @Field() String? order_id,
    @Field() String order_status,
    @Field() String? cancel_reason,
  );

  @POST(Apis.updateLatLang)
  @FormUrlEncoded()
  Future<String?> driveUpdateLatLong(
    @Field() String lat,
    @Field() String lang,
  );

  @POST(Apis.forgotPasswordOtp)
  @FormUrlEncoded()
  Future<String?> driverForgotPassOtp(
    @Field() String email_id,
  );

  @POST(Apis.forgotPasswordCheckOtp)
  @FormUrlEncoded()
  Future<String?> driverForgotCheckOtp(
    @Field() String driver_id,
    @Field() String otp,
  );

  @POST(Apis.forgotPassword)
  @FormUrlEncoded()
  Future<String?> driverForgotPassword(
    @Field() String password,
    @Field() String password_confirmation,
    @Field() String user_id,
  );
  @POST("firebase/token")
  Future<Map<String, dynamic>> addRemoveFCMToken(@Body() Map<String, dynamic> map);
  
  @POST("auto_reject_order")
  Future<Map<String, dynamic>> autoRejectOrder(@Body() Map<String, dynamic> map);
}

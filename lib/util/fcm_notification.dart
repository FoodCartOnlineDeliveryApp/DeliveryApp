import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/util/constants.dart';

import '../apiservice/ApiHeader.dart';
import '../apiservice/base_model.dart';
import '../apiservice/server_error.dart';
import 'device_utils.dart';
import 'preferenceutils.dart';

class FCMNotification {
  static Future addRemoveFCMToken(BuildContext context, {int processType = 1,String? user}) async {
    try {
      // DeviceUtils.onLoading(context);
      final userId = user ?? PreferenceUtils.getString(
        Constants.driverid,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.deleteToken(); // deleting old token
      final fcmToken = await messaging.getToken(); // creating new token
      int platform;
      if (Platform.isAndroid) {
        platform = 1;
      } else {
        platform = 2;
      }

      Map<String, dynamic> body = {
        "user_id": userId,
        "user_type": "Driver",
        "user_platform": platform,
        "token": fcmToken,
        "process_type": processType
      };
      print("fcmRequestBody $body");

      final response =
          await RestClient(ApiHeader().dioData()).addRemoveFCMToken(body);
      print("fcmResponse $response");
      // DeviceUtils.hideDialog(context);
    } catch (error, stacktrace) {
      // DeviceUtils.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
  }
}

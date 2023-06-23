import 'package:dio/dio.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';

class ApiHeader {
  Dio dioData() {
    final dio = Dio();

    dio.options.headers["Authorization"] = "Bearer" +"  " + PreferenceUtils.getString(Constants.headertoken); // config your dio headers globally
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    return dio;
  }
}

import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' as geoCodingLib;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mealup_driver/util/preferenceutils.dart';

class Constants {

  static final String androidKey = 'AIzaSyBQFSSzQbEbSyiJEntQzGMSJltW_gBXhxM';
  static final String iosKey = 'Enter_Your_iOS_GoogleMap_Key';

  static Color color_black = Color(0xFF090E21);
  static Color color_gray = Color(0xFF999999);
  static Color color_red = Color(0xFFff6060);
  static Color color_hint = Color(0xFF999999);
  static Color light_black = Color(0xFF213741);
  static Color itembgcolor = Color(0xFF213741);
  static Color bgcolor = Color(0xFF132229);
  static Color greaytext = Color(0xFF999999);
  static Color whitetext = Color(0xFFffffff);
  static Color color_theme = Color(0xFF06C168);
  static Color dashline = Color(0xFFcccccc);


  static final String driverfirstname = "driverfirstname";
  static final String driverlastname = "driverlastname";
  static final String driverid = "driverid";
  static final String headertoken = "headertoken";
  static final String driveremail = "driveremail";
  static final String driverphone = "driverphone";
  static final String driverotp = "driverotp";
  static final String driverphonecode = "driverphonecode";
  static final String driverimage = "driverimage";
  static final String imagePath = "imagePath";
  static final String isLoggedIn = "isLoggedIn";
  static final String isonline = "isonline";
  static final String isverified = "isverified";
  static final String drivervehicletype = "drivervehicletype";
  static final String drivervehiclenumber = "drivervehiclenumber";
  static final String driverlicencenumber = "driverlicencenumber";
  static final String drivernationalidentity = "drivernationalidentity";
  static final String driverlicencedoc = "driverlicencedoc";
  static final String driverdeliveryzoneid = "driverdeliveryzoneid";
  static final String drivernotification = "drivernotification";
  static final String driverzone = "driverzone";
  static final String driverdevicetoken = "driverdevicetoken";
  static final String disclaimer = 'disclaimer';

  /*Setting data*/

  static final String driversetvehicaltype = "driversetvehicaltype";
  static final String driver_auto_refrese = "driver_auto_refrese";
  static final String cancel_reason = "cancel_reason";
  static final String one_signal_app_id = "one_signal_app_id";
  static final String languagecode = "languagecode";
  static final String currency = "currency";
  static final String currencySymbol = "currency_symbol";

  /*Lat Long*/

  static final String previos_order_status = "previos_order_status";
  static final String previos_order_orderid = "previos_order_orderid";
  static final String previos_order_id = "previos_order_id";
  static final String previos_order_vendor_name = "previos_order_vendor_name";
  static final String previos_order_vendor_address =
      "previos_order_vendor_address";
  static final String previos_order_distance = "previos_order_distance";
  static final String previos_order_vendor_lat = "previos_order_vendor_lat";
  static final String previos_order_vendor_lang = "previos_order_vendor_lang";
  static final String previos_order_vendor_image = "previos_order_vendor_image";
  static final String previos_order_user_lat = "previos_order_user_lat";
  static final String previos_order_user_lang = "previos_order_user_lang";
  static final String previos_order_user_address = "previos_order_user_address";
  static final String previos_order_user_name = "previos_order_user_name";
  static final String user_phone_no = "user_phone_no";
  static final String lat = "0.0";
  static final String long = "0.0";

  /*Chekc driver is golobaldriver or not*/
  static final String isGlobalDriver = 'isGlobalDriver';
  static final String notGlobalDriverSlogan =
      'Sorry, Restaurant Driver can\'t access this feature';


  static double currentlat = 0;
  static double currentlong = 0;
  static String currentaddress = "0";

  static String app_font = 'Proxima';
  static String app_font_bold = 'ProximaBold';

  static Future<bool> CheckNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Constants.toastMessage("No Internet Connection");
      return false;
    }
  }

  static var kAppLableWidget = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
      color: Colors.white,
      fontFamily: Constants.app_font_bold);

  static var kTextFieldInputDecoration = InputDecoration(
      hintStyle: TextStyle(color: Constants.color_hint),
      border: InputBorder.none,
      errorStyle:
          TextStyle(fontFamily: Constants.app_font_bold, color: Colors.red));

  static var kTextFieldInputDecoration1 = InputDecoration(
      hintStyle: TextStyle(color: Constants.color_hint),
      border: InputBorder.none,
      suffixIcon: Image.asset("images/search.png", width: 20, height: 20),
      errorStyle:
          TextStyle(fontFamily: Constants.app_font_bold, color: Colors.red));

  static toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String? kvalidateFullName(String? value) {
    if (value!.length == 0) {
      return 'Data is Required';
    } else
      return null;
  }

  static String? kvalidateFirstName(String? value) {
    if (value!.trim().length == 0) {
      return 'First Name is Required';
    } else
      return null;
  }

  static String? kvalidatelastName(String? value) {
    if (value!.trim().length == 0) {
      return 'Last Name is Required';
    } else
      return null;
  }

  static String? kvalidateCotactNum(String? value) {
    if (value!.trim().length == 0) {
      return 'Contact Number is Required';
    }else
      return null;
  }

  static String? kvalidatePassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = new RegExp(pattern as String);

    if (value!.length == 0) {
      return "Password is Required";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    else
      return null;
  }

  static String? kvalidateConfPassword(
      String? value,
      TextEditingController _text_Password,
      TextEditingController _text_confPassword) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return "Password is Required";
    } else if (_text_Password.text != _text_confPassword.text)
      return 'Password and Confirm Password does not match.';
    else if (!regex.hasMatch(value))
      return 'Password required';
    else
      return null;
  }

  static String? kvalidateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return "Email is Required";
    } else if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  static void createSnackBar(
      String message, BuildContext scaffoldContext, Color color) {
    final snackBar = new SnackBar(
        content: new Text(
          message,
          style: TextStyle(
              color: whitetext, fontFamily: app_font, fontSize: 16),
        ),
        backgroundColor: color);

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(snackBar);
  }
    static Future<String> cuttentlocation() async {
    Location location = new Location();
    LocationData _locationData = await location.getLocation();
    var places = await geoCodingLib.placemarkFromCoordinates(
        _locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0
    );
    if (places.isNotEmpty) {
      final geoCodingLib.Placemark place = places.first;
      print(place.locality);
      print(place.thoroughfare);
      final current_address = place.thoroughfare! + "," + place.locality!;

      Constants.currentlong = _locationData.longitude ?? 0.0;
      Constants.currentlat = _locationData.latitude ?? 0.0;
      Constants.currentaddress = current_address;

      return current_address;
    }
    return "No address available";
  }

  static Future<LatLng?> currentlatlong1() async {
    Location location = new Location();
    LocationData _locationData = await location.getLocation();
    PreferenceUtils.setString(Constants.lat, _locationData.latitude.toString());
    PreferenceUtils.setString(Constants.long, _locationData.longitude.toString());
    if(_locationData.latitude != null){
      return LatLng(_locationData.latitude!, _locationData.longitude!);
    }else
    {
      return null;
    }
  }


  static Future<LatLng?> currentlatlong() async {
    Location location = new Location();
    LocationData _locationData = await location.getLocation();
    PreferenceUtils.setString(Constants.lat, _locationData.latitude.toString());
    PreferenceUtils.setString(Constants.long, _locationData.longitude.toString());
    var places = await geoCodingLib.placemarkFromCoordinates(
      _locationData.latitude ?? 0.0,
      _locationData.longitude ?? 0.0,
    );
    if (places.isNotEmpty) {
      final geoCodingLib.Placemark place = places.first;
      final current_address = place.thoroughfare! + "," + place.locality!;
      Constants.currentlong = _locationData.longitude ?? 0.0;
      Constants.currentlat = _locationData.latitude ?? 0.0;
      return LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
    }
    return LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
  }

  static  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../apiservice/ApiHeader.dart';
import '../apiservice/api_service.dart';
import 'constants.dart';

class DeviceUtils {
  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }

  static onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(width: 20),
                new Text('Please wait...'),
              ],
            ),
          ),
        );
      },
    );
  }

  static updateDriverLocation() async {
    final position = await Constants.currentlatlong();
    final currentLat = position!.latitude;
    final currentLong = position.longitude;
    // print("currentLat $currentLat && currentLong $currentLong");
    // final res =
      await RestClient(ApiHeader().dioData())
        .driveUpdateLatLong(currentLat.toString(), currentLong.toString());
        // print(res);
  }
}

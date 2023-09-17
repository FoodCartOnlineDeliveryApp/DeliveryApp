import 'dart:async';

import 'package:flutter/material.dart';

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

}
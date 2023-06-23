import 'package:flutter/material.dart';
import 'package:mealup_driver/util/constants.dart';

class RoundedCornerAppButton extends StatelessWidget {
  RoundedCornerAppButton({required this.btn_lable, required this.onPressed});

  final btn_lable;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5.0,
        textStyle: TextStyle(color: Colors.white),
        backgroundColor: Constants.color_theme,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(15.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 15.0),
        child: Text(
          btn_lable,
          style: TextStyle(
              fontFamily: Constants.app_font,
              fontWeight: FontWeight.w900,
              fontSize: 16.0),
        ),
      ),
      onPressed: onPressed as void Function()?,
    );
  }
}

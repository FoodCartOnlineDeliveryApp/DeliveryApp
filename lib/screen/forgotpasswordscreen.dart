import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/forgototpscreen.dart';
import 'package:mealup_driver/util/app_toolbar.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:mealup_driver/widget/card_textfield.dart';
import 'package:mealup_driver/widget/hero_image_app_logo.dart';
import 'package:mealup_driver/widget/rounded_corner_app_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreen createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  TextEditingController _text_email = TextEditingController();

  FocusNode _focusNode = new FocusNode();

  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    _focusNode.addListener(() {
      print("Has focus: ${_focusNode.hasFocus}");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/back_img.png'),
          fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Constants.bgcolor,BlendMode.color)
        )),
        child: Scaffold(
          appBar: ApplicationToolbar(
              appbarTitle: Languages.of(context)!.forgotpasswordlabel1),
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator:
                SpinKitFadingCircle(color: Constants.color_theme),
            child: LayoutBuilder(
              builder:

                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          HeroImage(),
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                            child: SvgPicture.asset(
                              'images/email.svg',
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20),
                                right: ScreenUtil().setWidth(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppLableWidget(
                                  title: Languages.of(context)!.emaillabel,
                                ),
                                CardTextFieldWidget(
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                  textInputAction: TextInputAction.next,
                                  hintText:
                                      Languages.of(context)!.enteremaillabel,
                                  textInputType: TextInputType.emailAddress,
                                  textEditingController: _text_email,
                                  validator: Constants.kvalidateEmail,
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(20),
                                ),
                                RoundedCornerAppButton(
                                    btn_lable:
                                        Languages.of(context)!.submitlable,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();

                                        Constants.CheckNetwork().whenComplete(
                                            () => CallApiEndEmailOtp(
                                                  _text_email.text,
                                                  context,
                                                ));
                                      } else {
                                        setState(() {
                                          _autoValidate = true;
                                        });
                                      }
                                    }),
                                SizedBox(
                                  height: ScreenUtil().setHeight(15),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                            child: Text(
                              Languages.of(context)!.checkemailotplable,
                              style: TextStyle(
                                color: Constants.color_gray,
                                fontSize: ScreenUtil().setSp(10),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  CallApiEndEmailOtp(String email, BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData())
        .driverForgotPassOtp(email)
        .then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);

      if (sucess == true) {
        print(true);
        setState(() {
          showSpinner = false;
          PreferenceUtils.setString(Constants.driveremail, email);
        });
        var msg = body['msg'];
        Constants.createSnackBar(msg, this.context, Constants.color_theme);
        var driverId = body['data'];
        Navigator.push(this.context, MaterialPageRoute(builder: (context) => ForgotOTPScreen(driverId)),);
      } else if (sucess == false) {
        setState(() {
          showSpinner = false;
        });

        var msg = body['data'];
        print(msg);
        Constants.createSnackBar(msg, this.context, Constants.color_red);
      }
    }).catchError((Object obj) {
      setState(() {
        showSpinner = false;
      });

      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          print(res);

          var responsecode = res.statusCode;

          if (responsecode == 401) {
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
          }

          break;
        default:
      }
    });
  }
}

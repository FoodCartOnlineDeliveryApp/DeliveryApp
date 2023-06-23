import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/create_new_account.dart';
import 'package:mealup_driver/screen/forgotpasswordscreen.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/screen/otp_screen.dart';
import 'package:mealup_driver/screen/selectlocationscreen.dart';
import 'package:mealup_driver/screen/uploaddocumentscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:mealup_driver/widget/card_password_textfield.dart';
import 'package:mealup_driver/widget/card_textfield.dart';
import 'package:mealup_driver/widget/hero_image_app_logo.dart';
import 'package:mealup_driver/widget/rounded_corner_app_button.dart';
import 'package:mealup_driver/widget/transitions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isRememberMe = false;
  bool _passwordVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showSpinner = false;

  String devicetoken = "";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    PreferenceUtils.getBool(Constants.disclaimer) == true ? callApiForsetting() : null;

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    PreferenceUtils.getBool(Constants.disclaimer) == false ? Future.delayed(Duration.zero,(){
      Future.delayed(Duration(seconds: 0), () {
          showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                "Disclaimer",
                textAlign: TextAlign.center,
              ),
              content: Text(
                "MealUp driver App uses location data to share with customers for accurate food delivery, even when the app is in the background.",
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                      PreferenceUtils.setlogin(Constants.disclaimer,true);
                      callApiForsetting();
                      Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                  ),
                ),
              ],
            ),
          );

      });
    }) : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Constants.color_black,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator: SpinKitFadingCircle(color: Constants.color_theme),
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/back_img.png'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Constants.bgcolor, BlendMode.color))),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Positioned(
                              bottom: 0,
                              child: Image.asset(
                                'images/login_bottom_image.png',
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              )),
                          Center(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  HeroImage(),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
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
                                            hintText: Languages.of(context)!.enteremaillabel,
                                            textInputType: TextInputType.emailAddress,
                                            textEditingController: _textEmail,
                                            validator: Constants.kvalidateEmail,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppLableWidget(
                                                title: Languages.of(context)!.passwordlabel,
                                              ),
                                            ],
                                          ),
                                          CardPasswordTextFieldWidget(
                                              textEditingController: _textPassword,
                                              validator: Constants.kvalidatePassword,
                                              hintText: Languages.of(context)!.enterpasswordlabel,
                                              isPasswordVisible: _passwordVisible),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: ClipRRect(
                                                      clipBehavior: Clip.hardEdge,
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                                      child: SizedBox(
                                                        width: 30.0,
                                                        height: 29.0,
                                                        child: Card(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                          child: Container(
                                                            child: Theme(
                                                              data: ThemeData(
                                                                unselectedWidgetColor: Colors.transparent,
                                                              ),
                                                              child: Checkbox(
                                                                value: isRememberMe,
                                                                onChanged: (state) => setState(() => isRememberMe = !isRememberMe),
                                                                activeColor: Colors.transparent,
                                                                checkColor: Constants.color_theme,
                                                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    Languages.of(context)!.remembermelabel,
                                                    style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: Constants.app_font),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 15.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(Transitions(
                                                        transitionType: TransitionType.fade,
                                                        curve: Curves.bounceInOut,
                                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                        widget: ForgotPasswordScreen()));
                                                  },
                                                  child: Text(
                                                    Languages.of(context)!.forgotpasswordlabel,
                                                    style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: Constants.app_font),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: RoundedCornerAppButton(
                                              onPressed: () {
                                                final FormState? form = _formKey.currentState;
                                                if (form!.validate()) {
                                                  _formKey.currentState!.save();
                                                  Constants.CheckNetwork().whenComplete(() => callApiForLogin(_textEmail.text, _textPassword.text, this.context,
                                                      PreferenceUtils.getString(Constants.driverdevicetoken)));
                                                } else {
                                                  setState(() {
                                                    // _autoValidate = true;
                                                    // print(_autoValidate.toString());
                                                  });
                                                }
                                              },
                                              btn_lable: Languages.of(context)!.btnloginlabel,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(Transitions(
                                                  transitionType: TransitionType.slideUp,
                                                  curve: Curves.bounceInOut,
                                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                  widget: CreateNewAccount()));
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  Languages.of(context)!.donthaveaccountlabel,
                                                  style: TextStyle(color: Colors.white, fontFamily: Constants.app_font),
                                                ),
                                                Text(
                                                  Languages.of(context)!.createnowlabel,
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: Constants.app_font),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  callApiForLogin(String email, String password, BuildContext context, String devicetoken) {
    setState(() {
      showSpinner = true;
    });

    print(email);
    print(password);

    RestClient(ApiHeader().dioData()).driverLogin(email, password, devicetoken).then((response) {
      final body = json.decode(response);
      if (body['success'] == true) {
        if (mounted) {
          setState(() {
            showSpinner = false;
          });
        }
        Constants.toastMessage(
          Languages.of(context)!.msgloginsucesslabel,
        );
        if (body['data']['token'] != null) {
          var token = body['data']['token'];
          PreferenceUtils.setString(Constants.headertoken, token);
        }
        PreferenceUtils.setlogin(Constants.isLoggedIn, false);
        if (body['data']['id'] != null) {
          PreferenceUtils.setString(Constants.driverid, body['data']['id'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverid, '');
        }
        if (body['data']['first_name'] != null) {
          PreferenceUtils.setString(Constants.driverfirstname, body['data']['first_name'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverfirstname, '');
        }
        if (body['data']['last_name'] != null) {
          PreferenceUtils.setString(Constants.driverlastname, body['data']['last_name'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverlastname, '');
        }
        if (body['data']['email_id'] != null) {
          PreferenceUtils.setString(Constants.driveremail, body['data']['email_id'].toString());
        } else {
          PreferenceUtils.setString(Constants.driveremail, '');
        }

        if (body['data']['contact'] != null) {
          PreferenceUtils.setString(Constants.driverphone, body['data']['contact'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverphone, '');
        }
        if (body['data']['phone_code'] != null) {
          PreferenceUtils.setString(Constants.driverphonecode, body['data']['phone_code'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverphonecode, '');
        }
        if (body['data']['image'] != null) {
          PreferenceUtils.setString(Constants.driverimage, body['data']['image'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverimage, '');
        }
        if (body['data']['vehicle_type'] != null) {
          PreferenceUtils.setString(Constants.driversetvehicaltype, body['data']['vehicle_type'].toString());
        }

        if (body['data']['vehicle_number'] != null) {
          PreferenceUtils.setString(Constants.drivervehiclenumber, body['data']['vehicle_number'].toString());
        } else {
          PreferenceUtils.setString(Constants.drivervehiclenumber, '');
        }
        if (body['data']['licence_number'] != null) {
          PreferenceUtils.setString(Constants.driverlicencenumber, body['data']['licence_number'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverlicencenumber, '');
        }
        if (body['data']['national_identity'] != null) {
          PreferenceUtils.setString(Constants.drivernationalidentity, body['data']['national_identity'].toString());
        } else {
          PreferenceUtils.setString(Constants.drivernationalidentity, '');
        }
        if (body['data']['licence_doc'] != null) {
          PreferenceUtils.setString(Constants.driverlicencedoc, body['data']['licence_doc'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverlicencedoc, '');
        }
        if (body['data']['delivery_zone_id'] != null) {
          PreferenceUtils.setString(Constants.driverdeliveryzoneid, body['data']['delivery_zone_id'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverdeliveryzoneid, '');
        }
        if (body['data']['otp'] != null) {
          PreferenceUtils.setString(Constants.driverotp, body['data']['otp'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverotp, '');
        }
        if (body['data']['deliveryzone'] != null) {
          PreferenceUtils.setString(Constants.driverzone, body['data']['deliveryzone'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverzone, '');
        }
        if (body['data']['device_token'] != null) {
          PreferenceUtils.setString(Constants.driverdevicetoken, body['data']['device_token'].toString());
        } else {
          PreferenceUtils.setString(Constants.driverdevicetoken, '');
        }

        if (body['data']['is_verified'] == 1) {
          PreferenceUtils.setverify(Constants.isverified, true);
        } else {
          PreferenceUtils.setverify(Constants.isverified, false);
        }

        if (body['data']['notification'] == 1) {
          PreferenceUtils.setnotification(Constants.drivernotification, true);
        } else {
          PreferenceUtils.setnotification(Constants.drivernotification, false);
        }

        if (body['data']['is_online'] == 1) {
          PreferenceUtils.setstatus(Constants.isonline, true);
        } else {
          PreferenceUtils.setstatus(Constants.isonline, false);
        }
        Constants.createSnackBar("Login Successfully", this.context, Constants.color_theme);

        if (body['data']['is_verified'] == 1) {
          if (body['data']['vehicle_type'] == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadDocument()),
            );
          } else if (PreferenceUtils.getString(Constants.driverdeliveryzoneid) == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SelectLocation()),
            );
          } else {
            PreferenceUtils.setlogin(Constants.isLoggedIn, true);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(0)),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OTPScreen()),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            showSpinner = false;
          });
        }
        var msg = body['data'];
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
          var responseCode = res.statusCode;
          if (responseCode == 401) {
            print("Got error : ${res.statusCode} -> ${res.statusMessage}");
            setState(() {
              showSpinner = false;
            });
          } else if (responseCode == 422) {
            setState(() {
              showSpinner = false;
            });
          }
          break;
        default:
          setState(() {
            showSpinner = false;
          });
      }
    });
  }

  getOneSingleToken(String appId) async {
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    await OneSignal.shared.getDeviceState().then((value) => {
          if (value!.userId != null)
            {
              PreferenceUtils.setString(Constants.driverdevicetoken, value.userId!),
              print("device token is ${value.userId}")
            }
          else
            {
              getOneSingleToken(appId),
            }
        });
  }

  void callApiForsetting() {

    devicetoken = PreferenceUtils.getString(Constants.driverdevicetoken);

    RestClient(ApiHeader().dioData()).driverSetting().then((response) {
      if (response.success == true) {
        if (response.data!.globalDriver == "true") {
          PreferenceUtils.putBool(Constants.isGlobalDriver, true);
        }

        PreferenceUtils.setString(Constants.driversetvehicaltype, response.data!.driverVehicalType!);
        PreferenceUtils.setString(Constants.driver_auto_refrese, response.data!.driverAutoRefrese.toString());
        PreferenceUtils.setString(Constants.one_signal_app_id, response.data!.driverAppId.toString());
        PreferenceUtils.setString(Constants.cancel_reason, response.data!.cancelReason!);
        response.data!.currency != null
            ? PreferenceUtils.setString(Constants.currency, response.data!.currency!)
            : PreferenceUtils.setString(Constants.currency, 'USD');
        response.data!.currency_symbol != null
            ? PreferenceUtils.setString(Constants.currencySymbol, response.data!.currency_symbol!)
            : PreferenceUtils.setString(Constants.currencySymbol, '\$');

        if ( response.data!.driverAppId != '' || response.data!.driverAppId != null) {
          getOneSingleToken(response.data!.driverAppId);
        }
      } else {}
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
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

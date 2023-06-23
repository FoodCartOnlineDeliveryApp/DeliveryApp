import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/forgotpasswordscreen.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:mealup_driver/widget/card_password_textfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  String strCountryCode = '+91';
  String _birthvalue = "1";
  final _old_text_Password = TextEditingController();
  final _new_text_Password = TextEditingController();
  final _confirm_text_Password = TextEditingController();
  bool _passwordVisible = true;
  bool _autoValidate = false;

  // ProgressDialog pr;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
  }

  @override
  Widget build(BuildContext context) {

    dynamic screenheight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: new SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/back_img.png'),
                colorFilter: ColorFilter.mode(Constants.bgcolor,BlendMode.color),
            fit: BoxFit.cover,
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(
                  Languages.of(context)!.changepasswordlable,
                  maxLines: 1,
                  style: TextStyle(
                    color: Constants.whitetext,
                    fontFamily: Constants.app_font_bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                automaticallyImplyLeading: true,
              ),
              body: ModalProgressHUD(
                inAsyncCall: showSpinner,
                opacity: 1.0,
                color: Colors.transparent.withOpacity(0.2),
                progressIndicator:
                    SpinKitFadingCircle(color: Constants.color_theme),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return new Stack(
                    children: <Widget>[
                      new SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 60),
                          color: Colors.transparent,
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.always,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(8)),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 0, right: 5, bottom: 0, left: 5),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(0),
                                          right: ScreenUtil().setWidth(0)),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: AppLableWidget(
                                                title: Languages.of(context)!
                                                    .oldpasswordlable,
                                              ),
                                            ),
                                            CardPasswordTextFieldWidget(
                                                textEditingController: _old_text_Password,
                                                validator: Constants.kvalidatePassword,
                                                hintText: Languages.of(context)!.enterpasswordlabel,
                                                isPasswordVisible: _passwordVisible),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: AppLableWidget(
                                                title: 'New Password',
                                              ),
                                            ),
                                            CardPasswordTextFieldWidget(
                                                textEditingController: _new_text_Password,
                                                validator: Constants.kvalidatePassword,
                                                hintText: Languages.of(context)!.enterpasswordlabel,
                                                isPasswordVisible: _passwordVisible),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: AppLableWidget(
                                                title: Languages.of(context)!.confirmpasslable,
                                              ),
                                            ),
                                            CardPasswordTextFieldWidget(
                                                textEditingController:
                                                    _confirm_text_Password,
                                                validator: validateConfPassword,
                                                hintText: Languages.of(context)!.changepasswordlable,
                                                isPasswordVisible: _passwordVisible),
                                            SizedBox(
                                              height: 100,
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      new Container(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            child: GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              Constants.CheckNetwork().whenComplete(() =>
                                  CallChangePasswordApi(
                                      _old_text_Password.text,
                                      _new_text_Password.text,
                                      _confirm_text_Password.text,
                                      context));
                            } else {
                              setState(() {
                                _autoValidate = true;
                              });
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13.0),
                                color: Constants.color_theme,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 0.0), //(x,y)
                                    blurRadius: 0.0,
                                  ),
                                ],
                              ),
                              width: screenwidth,
                              height: screenheight * 0.08,
                              child: Center(
                                child: Container(
                                  color: Constants.color_theme,
                                  child: Text(
                                    Languages.of(context)!.changepasswordlable,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: Constants.app_font),
                                  ),
                                ),
                              )),
                        )),
                      )),
                      new Container(
                          margin: EdgeInsets.only(bottom: 40), child: Body1())
                    ],
                  );
                }),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }

  String? validateConfPassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.passwordrequiredlable;
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    } else if (_new_text_Password.text != _confirm_text_Password.text)
      return Languages.of(context)!.passwordnotmatchlable;
    else if (!regex.hasMatch(value))
      return Languages.of(context)!.passwordrequiredlable;
    else
      return null;
  }

  CallChangePasswordApi(String oldpassword, String newpassword,
      String confirmpassword, BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData())
        .driverChangePassword(oldpassword, newpassword, confirmpassword)
        .then((response) {
      if (mounted) {
        print(response.toString());
        final body = json.decode(response!);

        bool? sucess = body['success'];
        print(sucess);

        if (sucess == true) {
          setState(() {
            showSpinner = false;
          });

          var msg = body['data'];

          Constants.createSnackBar(msg, this.context, Constants.color_theme);

          Constants.toastMessage(msg);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(2)),
          );
        } else {
          setState(() {
            showSpinner = false;
          });

          var msg = body['data'];

          Constants.createSnackBar(msg, this.context, Constants.color_red);
        }
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      Fluttertoast.showToast(msg: snackBar.toString());
      // _scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {
        showSpinner = false;
      });

      print("error:$obj");
      print(obj.runtimeType);
    });
  }
}

class Body1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, right: 0, bottom: 60),
              child: Text(
                Languages.of(context)!.dontremembaroldpasswordlable,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    color: Constants.whitetext,
                    fontFamily: Constants.app_font_bold,
                    fontSize: 14),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => new ForgotPasswordScreen()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 0, right: 10, bottom: 60),
                child: SvgPicture.asset("images/white_right.svg"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

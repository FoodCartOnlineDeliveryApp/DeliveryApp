import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/otp_screen.dart';
import 'package:mealup_driver/screen/login_screen.dart';
import 'package:mealup_driver/util/app_toolbar.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:mealup_driver/widget/card_password_textfield.dart';
import 'package:mealup_driver/widget/card_textfield.dart';
import 'package:mealup_driver/widget/hero_image_app_logo.dart';
import 'package:mealup_driver/widget/rounded_corner_app_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CreateNewAccount extends StatefulWidget {
  @override
  _CreateNewAccountState createState() => _CreateNewAccountState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  // ProgressDialog pr;
  final _text_firstName = TextEditingController();
  final _text_lastName = TextEditingController();
  final _text_Email = TextEditingController();
  final _text_Password = TextEditingController();
  final _text_confPassword = TextEditingController();
  final _text_contactNo = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  String? strCountryCode = "+91";
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    if (mounted) {
      setState(() {
        PreferenceUtils.init();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _passwordVisible = true;
  bool _confirmpasswordVisible = true;

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
              appbarTitle: Languages.of(context)!.btncreatenewaccountlable),
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator:
                SpinKitFadingCircle(color: Constants.color_theme),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeroImage(),
                  SizedBox(
                    height: ScreenUtil().setHeight(1),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(20),
                          ScreenUtil().setHeight(20),
                          ScreenUtil().setWidth(20),
                          0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AppLableWidget(
                              title: Languages.of(context)!.firstnamelable,
                            ),
                            CardTextFieldWidget(
                              focus: (v) {
                                FocusScope.of(context).nextFocus();
                              },
                              textInputAction: TextInputAction.next,
                              hintText:
                                  Languages.of(context)!.enterfirstnamelable,
                              textInputType: TextInputType.text,
                              textEditingController: _text_firstName,
                              validator: Constants.kvalidateFirstName,
                            ),
                            AppLableWidget(
                              title: Languages.of(context)!.lastnamelable,
                            ),
                            CardTextFieldWidget(
                              focus: (v) {
                                FocusScope.of(context).nextFocus();
                              },
                              textInputAction: TextInputAction.next,
                              hintText:
                                  Languages.of(context)!.enterlastnamelable,
                              textInputType: TextInputType.text,
                              textEditingController: _text_lastName,
                              validator: Constants.kvalidatelastName,
                            ),
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
                              textEditingController: _text_Email,
                              validator: Constants.kvalidateEmail,
                            ),
                            AppLableWidget(
                              title: Languages.of(context)!.contactnolable,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5.0,
                                    child: Container(
                                      height: ScreenUtil().setHeight(50),
                                      child: CountryCodePicker(
                                        onChanged: (c) {
                                          setState(() {
                                            strCountryCode = c.dialCode;
                                          });
                                        },
                                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                        initialSelection: 'IN',
                                        favorite: ['+91', 'IN'],
                                        hideMainText: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Card(
                                    color: Constants.light_black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(15)),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            Text(
                                              strCountryCode!,
                                              style: TextStyle(
                                                  color:
                                                      Constants.whitetext),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  ScreenUtil().setHeight(10),
                                                  ScreenUtil().setWidth(10),
                                                  ScreenUtil().setHeight(10)),
                                              child: VerticalDivider(
                                                color: Colors.black54,
                                                width: ScreenUtil().setWidth(5),
                                                thickness: 1.0,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.next,
                                                controller: _text_contactNo,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 16,
                                                    fontFamily: Constants
                                                        .app_font_bold),
                                                validator: Constants
                                                    .kvalidateCotactNum,
                                                keyboardType:
                                                    TextInputType.number,
                                                onFieldSubmitted: (v) {
                                                  FocusScope.of(context)
                                                      .nextFocus();
                                                },
                                                decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                        fontFamily: Constants
                                                            .app_font_bold,
                                                        color: Colors.red),
                                                    hintText: '000 000 000',
                                                    hintStyle: TextStyle(
                                                        color: Constants
                                                            .color_hint),
                                                    border: InputBorder.none),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            AppLableWidget(
                              title: Languages.of(context)!.passwordlabel,
                            ),
                            CardPasswordTextFieldWidget(
                                textEditingController: _text_Password,
                                validator: Constants.kvalidatePassword,
                                hintText:
                                    Languages.of(context)!.enterpasswordlabel,
                                isPasswordVisible: _passwordVisible),
                            AppLableWidget(
                              title: Languages.of(context)!.confirmpasslable,
                            ),
                            CardPasswordTextFieldWidget(
                                textEditingController: _text_confPassword,
                                validator: validateConfPassword,
                                hintText:
                                    Languages.of(context)!.enterpasswordlabel,
                                isPasswordVisible: _confirmpasswordVisible),
                            SizedBox(
                              height: ScreenUtil().setHeight(20),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.all(ScreenUtil().setWidth(10)),
                              child: RoundedCornerAppButton(
                                onPressed: () {

                                  if (_formKey.currentState!.validate()) {
                                    if (strCountryCode != null) {
                                      Constants.CheckNetwork().whenComplete(
                                          () => callRegisterAPI(
                                              _text_firstName.text,
                                              _text_lastName.text,
                                              _text_Email.text,
                                              _text_contactNo.text,
                                              strCountryCode!,
                                              _text_Password.text,
                                              "address",
                                              context));
                                    } else {
                                      Constants.createSnackBar(
                                          Languages.of(context)!
                                              .selectcountrycodelable,
                                          this.context,
                                          Constants.color_theme);
                                    }
                                  } else {
                                    setState(() {
                                      _autoValidate = true;
                                    });
                                  }
                                },
                                btn_lable: Languages.of(context)!
                                    .btncreatenewaccountlable,
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(10),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Languages.of(context)!.alreadyaccountlable,
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    Languages.of(context)!.btnloginlabel,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.app_font,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(30),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateConfPassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.passwordrequiredlable;
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    } else if (_text_Password.text != _text_confPassword.text){
      return Languages.of(context)!.passwordnotmatchlable;}
    else if (!regex.hasMatch(value)){
      return Languages.of(context)!.passwordrequiredlable;}
    else{
      return null;}
  }

  void callRegisterAPI(
      String firstname,
      String lastname,
      String email,
      String contactNo,
      String strCountryCode,
      String password,
      String address,
      BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    print(
        "register_param:${firstname + lastname + email + contactNo + strCountryCode + password + address}");
    RestClient(ApiHeader().dioData())
        .driverRegister(firstname, lastname, email, contactNo, strCountryCode,
            password, address)
        .then((response) {
          print("response");
          print(response);
      if (response.success == true) {
        Constants.toastMessage(Languages.of(context)!.registersucesslable);
        setState(() {
          showSpinner = false;
        });

        PreferenceUtils.setlogin(Constants.isLoggedIn, true);
        if(response.data!.firstName != null){
          PreferenceUtils.setString(Constants.driverfirstname, response.data!.firstName!);
        }else{
          PreferenceUtils.setString(Constants.driverfirstname,'');
        }
        if(response.data!.lastName != null){
          PreferenceUtils.setString(Constants.driverlastname, response.data!.lastName!);
        }else{
          PreferenceUtils.setString(Constants.driverlastname,'');
        }
        if(response.data!.emailId != null){
          PreferenceUtils.setString(Constants.driveremail, response.data!.emailId!);
        }else{
          PreferenceUtils.setString(Constants.driveremail,'');
        }
        if(response.data!.contact != null){
          PreferenceUtils.setString(Constants.driverphone, response.data!.contact!);
        }else{
          PreferenceUtils.setString(Constants.driverphone,'');
        }
        if(response.data!.phoneCode != null){
          PreferenceUtils.setString(Constants.driverphonecode, response.data!.phoneCode!);
        }else{
          PreferenceUtils.setString(Constants.driverphonecode,'');
        }
        if(response.data!.image != null){
          PreferenceUtils.setString(Constants.driverimage, response.data!.image!);
        }else{
          PreferenceUtils.setString(Constants.driverimage,'');
        }
        if(response.data!.otp != null){
          PreferenceUtils.setString(Constants.driverotp, response.data!.otp.toString());
          print('123456 ${response.data!.otp.toString()}');
        }else{
          PreferenceUtils.setString(Constants.driverotp,'');
        }
        if(response.data!.id != null){
          PreferenceUtils.setString(Constants.driverid, response.data!.id.toString());
        }else{
          PreferenceUtils.setString(Constants.driverid,'');
        }

        if(response.data!.isVerified != null){
          if (response.data!.isVerified == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OTPScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OTPScreen()),
          );
        }

      } else {
        setState(() {
          showSpinner = false;
        });
        Constants.toastMessage("Error");
      }
    }).catchError((Object obj) {
      setState(() {
        showSpinner = false;
      });
print("obj");
print(obj);

      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;

          var responsecode = res?.statusCode;

          if (responsecode == 401) {
            setState(() {
              showSpinner = false;
            });
            print(responsecode);
            print(res?.statusMessage);
          } else if (responsecode == 422) {
            setState(() {
              showSpinner = false;
            });
            if(res?.data['errors']['phone'] != null){
              Constants.createSnackBar(res?.data['errors']['phone'][0], this.context,
                  Constants.color_theme);
            }
            else if (res?.data['errors']['email_id'] != null){
              Constants.createSnackBar(res?.data['errors']['email_id'][0], this.context,
                  Constants.color_theme);
            }
            else{
              Constants.createSnackBar(res?.data['message'], this.context,
                  Constants.color_theme);
            }
          }
          break;
        default:
          setState(() {
            showSpinner = false;
          });
      }
    });
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/deliveryzone.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocation createState() => _SelectLocation();
}

class _SelectLocation extends State<SelectLocation> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool showSpinner = false;
  final _formKey = new GlobalKey<FormState>();
  String strCountryCode = '+91';
  String _birthvalue = "1";
  List<ZoneData> zonedatalist = <ZoneData>[];
  ZoneData? zoneData;
  String? zondata = " ";
  String zonid = " ";


  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    setState(() {
      zondata = PreferenceUtils.getString(Constants.driverzone);
      zonid = PreferenceUtils.getString(Constants.driverdeliveryzoneid);

    });

    if (mounted) {
      Constants.CheckNetwork().whenComplete(() => CallApiForGetDeliveryZone());
    }
  }

  CallApiForGetDeliveryZone() {
    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData()).driverDeliveryZone().then((response) {
      if (mounted) {
        setState(() {
          if (response.success = true) {
            setState(() {
              showSpinner = false;
            });

            if (response.data!.length != 0) {
              zonedatalist.addAll(response.data!);

              if (zondata == null && zondata!.isEmpty) {
                zondata = response.data![0].name;
                zonid = response.data![0].id.toString();
              } else {
                zondata = PreferenceUtils.getString(Constants.driverzone);
                zonid =
                    PreferenceUtils.getString(Constants.driverdeliveryzoneid);
              }

              for (int i = 0; i< response.data!.length; i++) {
                zoneData = response.data![i];
              }
            } else {
              zondata = " ";
              zonid = "0";
            }
          } else {
            setState(() {
              showSpinner = false;
            });
          }
        });
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

  CallApiForSetDeliveryZone(
      String zonid, String? zondata, BuildContext context) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData())
        .driverSetDeliveryZone(zonid)
        .then((response) {
      if (mounted) {
        setState(() {
          final body = json.decode(response!);
          bool? sucess = body['success'];
          if (sucess = true) {
            setState(() {
              showSpinner = false;
            });
            var msg = body['data'];
            print(msg);
            Constants.createSnackBar(msg, this.context, Constants.color_theme);
            PreferenceUtils.setString(Constants.driverzone, zondata!);
            Navigator.push(
              this.context,
              MaterialPageRoute(builder: (context) => HomeScreen(0)),
            );
          } else if (sucess == false) {
            setState(() {
              showSpinner = false;
            });
            var msg = body['data'];
            print(msg);
            Constants.createSnackBar(msg, this.context, Constants.color_red);
          }
        });
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
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
            fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Constants.bgcolor,BlendMode.color)
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(
                  Languages.of(context)!.selectlocation,
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
                child: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return new Stack(
                      children: <Widget>[
                        new SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 60),
                            color: Colors.transparent,
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
                                                    .selectdeliveryzonelable,
                                              ),
                                            ),
                                            Container(
                                              width: screenwidth,
                                              height:
                                                  ScreenUtil().setHeight(55),
                                              child: Card(
                                                color: Constants.light_black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                elevation: 5.0,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 25.0,
                                                          right: 10),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                            ZoneData>(
                                                        hint: new Text(
                                                          zondata!,
                                                          style: TextStyle(
                                                              color:
                                                                  Constants
                                                                      .greaytext,
                                                              fontFamily:
                                                                  Constants
                                                                      .app_font,
                                                              fontSize: 12),
                                                        ),
                                                        icon: SvgPicture.asset(
                                                            "images/drop_dwon.svg"),
                                                        isDense: true,
                                                        items: zonedatalist
                                                            .map((user) {
                                                          return DropdownMenuItem<
                                                              ZoneData>(
                                                            value: user,
                                                            child: new Text(
                                                              user.name!,
                                                              style: TextStyle(
                                                                  color: Constants.greaytext,
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font_bold,
                                                                  fontSize: 14),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            zoneData = value;
                                                            zonid = value!.id
                                                                .toString();
                                                            zondata =
                                                                value.name;
                                                            print(zonid);
                                                            print(zondata);
                                                            PreferenceUtils
                                                                .setString(
                                                                    Constants
                                                                        .driverzone,
                                                                    zondata!);
                                                          });
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        new Container(
                            child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              child: GestureDetector(
                            onTap: () {
                              Constants.CheckNetwork().whenComplete(() =>
                                  CallApiForSetDeliveryZone(
                                      zonid, zondata, context));
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
                                      // blurRadius: 0.0,
                                    ),
                                  ],
                                ),
                                width: screenwidth,
                                height: screenheight * 0.08,
                                child: Center(
                                  child: Container(
                                    color: Constants.color_theme,
                                    child: Text(
                                      Languages.of(context)!
                                          .setthislocationlable,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: Constants.app_font),
                                    ),
                                  ),
                                )),
                          )),
                        ))
                      ],
                    );
                  },
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }
}

class Body extends StatelessWidget {
  final _formKey;

  Body(this._formKey);

  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
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
            height: screenHeight * 0.08,
            child: Center(
              child: Container(
                color: Constants.color_theme,
                child: Text(
                  Languages.of(context)!.setthislocationlable,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: Constants.app_font),
                ),
              ),
            )),
      )),
    );
  }
}

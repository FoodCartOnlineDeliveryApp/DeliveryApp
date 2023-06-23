import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/earninghistory.dart';
import 'package:mealup_driver/util/CustomRoundedBars.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Earninghistory extends StatefulWidget {
  @override
  _Earninghistory createState() => _Earninghistory();
}

class _Earninghistory extends State<Earninghistory> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  String _birthvalue = "1";

  String todayearning = "0";
  String weekearning = "0";
  String monthearning = "0";
  String yearearning = "0";
  String totalamount = "0";

  List<Graph> grapdata = <Graph>[];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();

    if (mounted) {
      Constants.CheckNetwork().whenComplete(() => CallApiForGetEarning());
    }
  }

  void CallApiForGetEarning() {

    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData()).driverEarningHistory().then((response) {
      if (response.success == true) {

        setState(() {
          showSpinner = false;
        });

        setState(() {
          todayearning = response.data!.todayEarning.toString();
          weekearning = response.data!.weekEarning.toString();
          monthearning = response.data!.currentMonth.toString();
          yearearning = response.data!.yearliyEarning.toString();
          totalamount = response.data!.totalAmount.toString();

          if (response.data!.graph!.length != 0) {
            grapdata.addAll(response.data!.graph!);
          } else {
            setState(() {
              showSpinner = false;
            });
          }
        });
      } else {
        setState(() {
          showSpinner = false;
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

  @override
  Widget build(BuildContext context) {

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
              // resizeToAvoidBottomPadding: false,
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              appBar: AppBar(
                title: AutoSizeText(
                  Languages.of(context)!.earninghistorylable,
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
                child: new Stack(
                  children: <Widget>[
                    new SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(ScreenUtil().setWidth(0)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 0, right: 20, bottom: 0, left: 20),
                                decoration: BoxDecoration(
                                    color: Constants.itembgcolor,
                                    border: Border.all(
                                      color: Constants.itembgcolor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(0),
                                      right: ScreenUtil().setWidth(0)),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 20,
                                        right: 10,
                                        bottom: 20,
                                        left: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            children: [
                                              Container(
                                                child: Text(
                                                  Languages.of(context)!
                                                      .totalbalancelable,
                                                  style: TextStyle(
                                                      color:
                                                          Constants.greaytext,
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 2),
                                                child: Text(
                                                  '${PreferenceUtils.getString(Constants.currencySymbol)} $totalamount',
                                                  style: TextStyle(
                                                      color: Constants.color_theme,
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: 22),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: Expanded(
                                            flex: 1,
                                            child: Container(
                                              height:
                                                  ScreenUtil().setHeight(45),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Constants.itembgcolor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(35)),
                                                gradient: LinearGradient(
                                                  colors: <Color>[
                                                    Color(0xFF6a7eff),
                                                    Color(0xFF3d6feb),
                                                    Color(0xFF1863db),
                                                  ],
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Transfer To The Bank",
                                                    style: TextStyle(
                                                        color: Constants.whitetext,
                                                        fontSize: 11,
                                                        fontFamily:
                                                            Constants.app_font),
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: SvgPicture.asset(
                                                          "images/white_right.svg"))
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 10, right: 10, top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin:EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          color: Constants.itembgcolor,
                                          border: Border.all(
                                            color: Constants.itembgcolor,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                              top: 30,
                                              left: 10,
                                              right: 5,
                                            ),
                                            child: Text("${PreferenceUtils.getString(Constants.currencySymbol)}" + todayearning,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 26,
                                                    fontFamily:Constants.app_font)),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                top: 5,
                                                left: 10,
                                                right: 5,
                                                bottom: 20),
                                            child: Text(
                                                Languages.of(context)!
                                                    .todayearninglable,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          color: Constants.itembgcolor,
                                          border: Border.all(
                                            color: Constants.itembgcolor,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                              top: 30,
                                              left: 10,
                                              right: 5,
                                            ),
                                            child: Text(
                                                '${PreferenceUtils.getString(Constants.currencySymbol)} $weekearning',
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 26,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                top: 5,
                                                left: 10,
                                                right: 5,
                                                bottom: 20),
                                            child: Text(
                                                Languages.of(context)!
                                                    .weaklyearninglable,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 10, right: 10, top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          color: Constants.itembgcolor,
                                          border: Border.all(
                                            color: Constants.itembgcolor,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                              top: 30,
                                              left: 10,
                                              right: 5,
                                            ),
                                            child: Text('${PreferenceUtils.getString(Constants.currencySymbol)} $monthearning',
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 26,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                top: 5,
                                                left: 10,
                                                right: 5,
                                                bottom: 20),
                                            child: Text(
                                                Languages.of(context)!
                                                    .monthlyearninglable,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          color: Constants.itembgcolor,
                                          border: Border.all(
                                            color: Constants.itembgcolor,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                              top: 30,
                                              left: 10,
                                              right: 5,
                                            ),
                                            child: Text("${PreferenceUtils.getString(Constants.currencySymbol)}" + yearearning,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 26,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                top: 5,
                                                left: 10,
                                                right: 5,
                                                bottom: 20),
                                            child: Text(
                                                Languages.of(context)!
                                                    .yearlyearninglable,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        Constants.app_font)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 20, left: 20, right: 20, bottom: 20),
                              decoration: BoxDecoration(
                                  color: Constants.itembgcolor,
                                  border: Border.all(
                                    color: Constants.itembgcolor,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),

                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topCenter,
                                    height: ScreenUtil().setHeight(40),
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 10, left: 10),
                                          child: Text(
                                            Languages.of(context)!.earninglable,
                                            style: TextStyle(
                                                color:
                                                    Constants.whitetext,
                                                fontFamily:
                                                    Constants.app_font_bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: Text(
                                            Languages.of(context)!.monthlylable,
                                            style: TextStyle(
                                                color:
                                                    Constants.whitetext,
                                                fontFamily:
                                                    Constants.app_font_bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(260),
                                    margin: EdgeInsets.only(
                                        top: 0, left: 10, bottom: 20),
                                    color: Colors.transparent,
                                    child: CustomRoundedBars(grapdata),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
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

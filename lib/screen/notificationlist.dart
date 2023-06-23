import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/notification.dart';
import 'package:mealup_driver/screen/notificationsettingscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NotificationList extends StatefulWidget {

  @override
  _NotificationList createState() => _NotificationList();
}

class _NotificationList extends State<NotificationList> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showSpinner = false;

  List<NotificationData> notificationlist = <NotificationData>[];

  bool nodata = true;
  bool showdata = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =  new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    if (mounted) {
      Constants.CheckNetwork()
          .whenComplete(() => CallApiForGetNotificationList());
    }
  }

  Future<void> CallApiForGetNotificationList() async {
    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData()).driverNotification().then((response) {
      if (response.success == true) {
        setState(() {
          showSpinner = false;
        });

        setState(() {
          if (response.data!.length != 0) {
            notificationlist.addAll(response.data!);
            nodata = false;
            showdata = true;
          }
        });
      } else {
        setState(() {
          showSpinner = false;
          nodata = true;
          showdata = false;
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
        nodata = true;
        showdata = false;
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
              key: _scaffoldKey,
              appBar: AppBar(
                title: AutoSizeText(
                  Languages.of(context)!.notificationlable,
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
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  Visibility(
                    visible: false,
                    child: Container(
                      margin: EdgeInsets.only(top: 1, right: 5, left: 5),
                      child: Container(
                        child: PopupMenuButton<String>(
                          color: Colors.transparent,
                          icon: SvgPicture.asset(
                            "images/setting_menu.svg",
                            width: 20,
                            height: 20,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18.0))),
                          offset: Offset(20, 45),
                          onSelected: handleClick,
                          itemBuilder: (BuildContext context) {
                            return {"Notification Settings"}
                                .map((String choice) {
                              return PopupMenuItem<String>(
                                value: "Notification Settings",
                                child: Text(
                                  "Notification Settings",
                                  style: TextStyle(
                                      color: Constants.whitetext,
                                      fontSize: 14,
                                      fontFamily: Constants.app_font_bold),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
              body: RefreshIndicator(
                color: Constants.color_theme,
                backgroundColor: Colors.transparent,
                onRefresh: CallApiForGetNotificationList,
                key: _refreshIndicatorKey,
                child: ModalProgressHUD(
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
                              Visibility(
                                visible: showdata,
                                child: ListView.builder(
                                  itemCount: notificationlist.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.all(
                                          ScreenUtil().setWidth(8)),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 5,
                                            right: 5,
                                            bottom: 0,
                                            left: 5),
                                        decoration: BoxDecoration(
                                            color: Constants.itembgcolor,
                                            border: Border.all(
                                              color:
                                                  Constants.itembgcolor,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(0),
                                              right: ScreenUtil().setWidth(0)),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      left: 5,
                                                      bottom: 10,
                                                      right: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0,
                                                                  left: 0,
                                                                  right: 5,
                                                                  bottom: 0),
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              SvgPicture.asset(
                                                            "images/notification_item.svg",
                                                            fit: BoxFit.cover,
                                                            width: screenwidth *
                                                                0.10,
                                                            height:
                                                                screenheight *
                                                                    0.07,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0,
                                                                  left: 0,
                                                                  right: 5,
                                                                  bottom: 0),
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: ListView(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            children: [
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Text(
                                                                  notificationlist[
                                                                          index]
                                                                      .title!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  style: TextStyle(
                                                                      color: Constants.whitetext,
                                                                      fontFamily:
                                                                          Constants
                                                                              .app_font_bold,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        left: 0,
                                                                        right:
                                                                            5,
                                                                        bottom:
                                                                            0),
                                                                color: Colors
                                                                    .transparent,
                                                                child: Text(
                                                                  notificationlist[
                                                                          index]
                                                                      .message!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  maxLines: 10,
                                                                  style: TextStyle(
                                                                      color: Constants.greaytext,
                                                                      fontFamily:
                                                                          Constants
                                                                              .app_font,
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible: nodata,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(top: 50),
                                          child: SvgPicture.asset(
                                            "images/no_job.svg",
                                            width: ScreenUtil().setHeight(200),
                                            height: ScreenUtil().setHeight(200),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 20.0,
                                              left: 15.0,
                                              right: 15,
                                              bottom: 0),
                                          child: Text(
                                            Languages.of(context)!.nodatalable,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    Constants.app_font_bold,
                                                fontSize: 20),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
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
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }

  void handleClick(String value) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => new NotificationSetting()));
  }
}

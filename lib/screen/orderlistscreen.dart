import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/current_order.dart' as currentOderLibrary;
import 'package:mealup_driver/model/orderlistdata.dart';
import 'package:mealup_driver/screen/getorderkitchenscreen.dart';
import 'package:mealup_driver/screen/pickupdeliverorderscreen.dart';
import 'package:mealup_driver/screen/selectlocationscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/transitions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:slide_to_act_reborn/slide_to_act_reborn.dart';

import '../widget/rounded_corner_app_button.dart';
import 'newGetOrderKitchenScreen.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<OrderList> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? _cancelReason = "0";
  bool isOnline = false;
  bool showSpinner = false;

  String? name;
  String? location;
  int? status;

  // ProgressDialog pr;
  bool showduty = false;
  bool hideduty = false;
  bool nojob = true;
  bool lastorder = false;
  late String cancel_reason;
  List can_reason = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<OrderData> orderdatalist = <OrderData>[];
  List<OrderItems> orderitemlist = <OrderItems>[];

  currentOderLibrary.CurrentOrderData currentOrderData =
      currentOderLibrary.CurrentOrderData();

  double current_lat = 0;
  double current_long = 0;

  final _text_cancel_reason_controller = TextEditingController();
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();

    if (mounted) {
      setState(() {
        name = PreferenceUtils.getString(Constants.driverfirstname) +
            " " +
            PreferenceUtils.getString(Constants.driverlastname);
        location = PreferenceUtils.getString(Constants.driverzone);
        cancel_reason = PreferenceUtils.getString(Constants.cancel_reason);
        var json = JsonDecoder().convert(cancel_reason);
        can_reason.addAll(json);
        print("name123:$name");
      });
    }
    if (PreferenceUtils.getBool(Constants.isLoggedIn) == true) {
      CurrentOrderApiCall();
      CallApiForGetOrderList();
    }
    // if (mounted) {
    if (PreferenceUtils.getstatus(Constants.isonline) == true) {
      // setState(() {
      isOnline = true;
      nojob = true;
      hideduty = false;
      showduty = false;
      // });
    } else {
      setState(() {
        isOnline = false;
        nojob = false;
        hideduty = true;
        showduty = false;
      });
    }
  }

  void _startBlinkingTimer() {
    setState(() {
      _counter = 30;
    });
    // Start a timer that triggers the callback every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        }
        if (_counter == 0) {
          _timer.cancel(); // Stop the timer when the counter reaches 0
          callRejectOrder();
        }
      });
    });
  }

  String getFormattedCounter() {
    // Use padLeft to ensure the counter is displayed as a two-digit number
    return _counter.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, CallApiForGetOrderList);
  }

  Future<void> callRejectOrder() async {
    print("autoRejectOrder API");
    final orderdatalistTemp = orderdatalist;
    if (orderdatalistTemp.isNotEmpty) {
      for (var element in orderdatalistTemp) {
        final rejectBody = {"order_id": element.id};
        print("rejectBody $rejectBody");
        await RestClient(ApiHeader().dioData()).autoRejectOrder(rejectBody);
      }
      await CallApiForGetOrderList();
    }
  }

  /// GET all oder
  Future<void> CallApiForGetOrderList() async {
    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData()).driveOrderList().then((response) {
      if (mounted) {
        print("OrderList:$response");
        print("OrderList:${response.success}");
        if (response.success = true) {
          if (response.data!.length != 0) {
            orderdatalist.clear();
            orderdatalist.addAll(response.data!);
            print("orderdatalistLength:${orderdatalist.length}");
            nojob = false;
            showduty = true;

            setState(() {
              showSpinner = false;
            });
            if (orderdatalist.isNotEmpty) {
              _startBlinkingTimer();
            }
          } else {
            print("orderdatalistLength:${orderdatalist.length}");
            setState(() {
              showSpinner = false;
            });

            nojob = true;
            showduty = false;
          }
        } else {
          setState(() {
            showSpinner = false;
          });

          nojob = true;
          showduty = false;

          // return false;
        }
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("error:$obj");
      print(obj.runtimeType);
      nojob = true;
      showduty = false;

      setState(() {
        showSpinner = false;
      });
    });
  }

  //check current order
  bool checkCurrentOrder() {
    bool isAssigned = false;
    final orderId = PreferenceUtils.getString(Constants.previos_order_orderid);
    if (orderId != null && orderId != '' && currentOrderData.orderId != null) {
      isAssigned = true;
      // setState(() {
      // });
    }
    print("isAssigned $isAssigned");
    return isAssigned;
  }

  /// current order
  Future<void> CurrentOrderApiCall() async {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).currentOrderList().then((response) {
      print('current order api call');
      currentOrderData = currentOderLibrary.CurrentOrderData();
      setState(() {
        showSpinner = false;
      });
      if (mounted) {
        print("OrderList:${response}");
        if (response.success == true) {
          if (response.data != null) {
            currentOrderData = response.data!;
            PreferenceUtils.setString(
                Constants.previos_order_orderid, response.data!.orderId!);
            PreferenceUtils.setString(
                Constants.previos_order_id, response.data!.id.toString());
            PreferenceUtils.setString(Constants.previos_order_user_lat,
                response.data!.userAddress!.lat!);
            PreferenceUtils.setString(Constants.previos_order_user_lang,
                response.data!.userAddress!.lang!);
            PreferenceUtils.setString(Constants.previos_order_user_address,
                response.data!.userAddress!.address.toString());
            PreferenceUtils.setString(Constants.previos_order_status,
                response.data!.orderStatus.toString());
            PreferenceUtils.setString(Constants.previos_order_vendor_name,
                response.data!.vendor!.name.toString());
            PreferenceUtils.setString(Constants.previos_order_pay_type,
                response.data!.paymentType.toString());
            PreferenceUtils.setString(Constants.previos_order_amount,
                response.data!.amount.toString());
            PreferenceUtils.setString(Constants.previos_order_delivery_charge,
                response.data!.deliveryCharge.toString());
            PreferenceUtils.setString(
                Constants.previos_order_items,
                jsonEncode(response.data!.orderItems!
                    .map((v) => v.toJson())
                    .toList())); // Adding order items to prefs
            if (response.data?.vendor != null) {
              PreferenceUtils.setString(Constants.previos_order_vendor_address,
                  response.data!.vendor!.address.toString());
              PreferenceUtils.setString(Constants.previos_order_vendor_image,
                  response.data!.vendor!.image.toString());
              PreferenceUtils.setString(Constants.previos_order_vendor_lat,
                  response.data!.vendor!.lat!);
              PreferenceUtils.setString(Constants.previos_order_vendor_lang,
                  response.data!.vendor!.lang!);
            } else {
              PreferenceUtils.setString(
                  Constants.previos_order_vendor_address, '');
              PreferenceUtils.setString(
                  Constants.previos_order_vendor_image, '');
            }
            PreferenceUtils.setString(
                Constants.previos_order_user_name, response.data!.user!.name!);
          }
        }
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("error:$obj");
      print(obj.runtimeType);

      setState(() {
        showSpinner = false;
      });
    });
  }

  void CallApiForUpdateStatus(bool isOnline) {
    setState(() {
      showSpinner = true;
      showSpinner = true;
    });

    print(isOnline);

    if (mounted) {
      if (isOnline == true) {
        status = 1;
        print(status);
      } else if (isOnline == false) {
        status = 0;
        print(status);
      }
      RestClient(ApiHeader().dioData())
          .driverUpdateStatus(status.toString())
          .then((response) {
        final body = json.decode(response!);
        bool? sucess = body['success'];
        if (sucess = true) {
          print("duty:$isOnline");

          setState(() {
            if (isOnline == true) {
              setState(() {
                showSpinner = false;
              });
              nojob = true;
              hideduty = false;
              showduty = false;

              PreferenceUtils.setstatus(Constants.isonline, true);

              Constants.CheckNetwork()
                  .whenComplete(() => CallApiForGetOrderList());
            } else if (isOnline == false) {
              nojob = false;
              hideduty = true;
              showduty = false;
              PreferenceUtils.setstatus(Constants.isonline, false);
              setState(() {
                showSpinner = false;
              });
            }
          });

          setState(() {
            showSpinner = false;
          });
          var msg = body['data'];
          Constants.createSnackBar(msg, this.context, Constants.color_theme);
        } else if (sucess == false) {
          setState(() {
            showSpinner = false;
          });
          var msg = body['data'];
          Constants.createSnackBar(msg, this.context, Constants.color_red);
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

  void CallApiForAcceptorder(
    String id,
    String orderId,
    String? vendorName,
    String? vendorAddress,
    String distance,
    String? vendorLat,
    String? vendorLang,
    String? userLat,
    String? userLang,
    String? userAddress,
    String? vendorImage,
    String? userName,
  ) {
    print(id);
    setState(() {
      showSpinner = true;
    });

    if (mounted) {
      RestClient(ApiHeader().dioData())
          .orderStatusChange1(id, "ACCEPT")
          .then((response) {
        print("order_response:$response");

        final body = json.decode(response!);
        bool? sucess = body['success'];
        // bool sucess =response.success;
        if (sucess == true) {
          setState(() {
            showSpinner = false;
          });
          var msg = "Order Accepted";
          Constants.createSnackBar(msg, this.context, Constants.color_theme);

          PreferenceUtils.setString(Constants.previos_order_status, "ACCEPT");
          PreferenceUtils.setString(Constants.previos_order_id, id);
          PreferenceUtils.setString(Constants.previos_order_orderid, orderId);
          PreferenceUtils.setString(
              Constants.previos_order_vendor_name, vendorName!);
          if (vendorAddress != null) {
            PreferenceUtils.setString(
                Constants.previos_order_vendor_address, vendorAddress);
          } else {
            PreferenceUtils.setString(
                Constants.previos_order_vendor_address, '');
          }

          PreferenceUtils.setString(Constants.previos_order_distance, distance);
          PreferenceUtils.setString(
              Constants.previos_order_vendor_lat, vendorLat!);
          PreferenceUtils.setString(
              Constants.previos_order_vendor_lang, vendorLang!);
          PreferenceUtils.setString(Constants.previos_order_user_lat, userLat!);
          PreferenceUtils.setString(
              Constants.previos_order_user_lang, userLang!);
          PreferenceUtils.setString(
              Constants.previos_order_user_address, userAddress!);
          PreferenceUtils.setString(
              Constants.previos_order_vendor_image, vendorImage!);
          PreferenceUtils.setString(
              Constants.previos_order_user_name, userName!);

          if (sucess == true) {
            Navigator.of(this.context).push(
                MaterialPageRoute(builder: (context) => NewGetOrderKitchen()));
          }
        } else if (sucess == false) {
          setState(() {
            showSpinner = false;
          });
          var msg = Languages.of(this.context)!.tryagainlable;
          // print(msg);
          Constants.createSnackBar(msg, this.context, Constants.color_red);
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
        //AppConstant.toastMessage("Internal Server Error");
      });
    }
  }

  void CallApiForCacelorder(String id, String? cancelReason) {
    print(id);

    setState(() {
      showSpinner = true;
    });

    if (mounted) {
      RestClient(ApiHeader().dioData())
          .cancelOrder(id, "CANCEL", cancelReason)
          .then((response) {
        print("order_response:$response");

        final body = json.decode(response!);
        bool? sucess = body['success'];
        if (sucess = true) {
          setState(() {
            showSpinner = false;
          });
          var msg = Languages.of(context)!.ordercancellable;
          Constants.createSnackBar(msg, this.context, Constants.color_theme);

          if (mounted) {
            setState(() {
              PreferenceUtils.setString(
                  Constants.previos_order_status, "CANCEL");
              lastorder = false;
              Constants.CheckNetwork()
                  .whenComplete(() => CallApiForGetOrderList());
            });
          }
        } else if (sucess == false) {
          setState(() {
            showSpinner = false;
          });
          var msg = Languages.of(context)!.tryagainlable;
          // print(msg);
          Constants.createSnackBar(msg, this.context, Constants.color_red);
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
        //AppConstant.toastMessage("Internal Server Error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants.currentlatlong().then((origin) {
      current_lat = origin!.latitude;
      current_long = origin.longitude;
    });

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
                  colorFilter:
                      ColorFilter.mode(Constants.bgcolor, BlendMode.color))),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              key: _scaffoldKey,
              body: RefreshIndicator(
                color: Constants.color_theme,
                backgroundColor: Colors.transparent,
                onRefresh: () async {
                  if (_counter == 0) {
                    CallApiForGetOrderList();
                    CurrentOrderApiCall();
                  }
                },
                key: _refreshIndicatorKey,
                child: ModalProgressHUD(
                  inAsyncCall: showSpinner,
                  opacity: 1.0,
                  color: Colors.transparent.withOpacity(0.2),
                  progressIndicator:
                      SpinKitFadingCircle(color: Constants.color_theme),
                  child: LayoutBuilder(builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return new Stack(
                      children: <Widget>[
                        new SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 0),
                            color: Colors.transparent,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(0)),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 0, right: 0, bottom: 0, left: 0),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(0),
                                          right: ScreenUtil().setWidth(0)),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        height: ScreenUtil().setHeight(55),
                                        color: Constants.bgcolor,
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (PreferenceUtils.getBool(
                                                            Constants
                                                                .isGlobalDriver) ==
                                                        true) {
                                                      Navigator.of(context)
                                                          .push(Transitions(
                                                              transitionType:
                                                                  TransitionType
                                                                      .slideLeft,
                                                              curve: Curves
                                                                  .slowMiddle,
                                                              reverseCurve: Curves
                                                                  .slowMiddle,
                                                              widget:
                                                                  SelectLocation()));
                                                    } else {
                                                      Constants.toastMessage(
                                                          Constants
                                                              .notGlobalDriverSlogan);
                                                    }
                                                  },
                                                  child: ListView(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    // mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 20, top: 10),
                                                        child: Text(
                                                          name != null
                                                              ? name!
                                                              : Languages.of(
                                                                      context)!
                                                                  .userlable,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Constants
                                                                  .app_font_bold,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 0),
                                                          child: RichText(
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textScaleFactor: 1,
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: location !=
                                                                            null
                                                                        ? location
                                                                        : Languages.of(context)!
                                                                            .setlocationlable,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          Constants
                                                                              .app_font,
                                                                    )),
                                                                WidgetSpan(
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        left: 5,
                                                                        top: 0,
                                                                        bottom:
                                                                            3),
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      "images/down_arrow.svg",
                                                                      width: 8,
                                                                      height: 8,
                                                                    ),
                                                                  ),
                                                                ),

                                                                //
                                                              ],
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 10,
                                                        top: 0,
                                                        right: 0),
                                                    child: Transform.scale(
                                                      scale: 0.6,
                                                      child: CupertinoSwitch(
                                                          trackColor: Constants
                                                              .color_black,
                                                          activeColor: Constants
                                                              .color_theme,
                                                          value: isOnline,
                                                          onChanged: (newval) {
                                                            setState(() {
                                                              isOnline =
                                                                  !isOnline;
                                                              Constants
                                                                      .CheckNetwork()
                                                                  .whenComplete(() =>
                                                                      CallApiForUpdateStatus(
                                                                          isOnline));
                                                            });
                                                          }),
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
                                ),
                                Visibility(
                                  visible: showduty,
                                  child: ListView.builder(
                                    itemCount: orderdatalist.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      String paymentstatus;
                                      String paymentType;
                                      Color paymentcolor;
                                      if (orderdatalist[index]
                                              .paymentStatus
                                              .toString() ==
                                          "0") {
                                        paymentstatus = "Pending";
                                        paymentcolor = Constants.color_red;
                                      } else {
                                        paymentstatus = "Completed";
                                        paymentcolor = Constants.color_theme;
                                      }

                                      if (orderdatalist[index]
                                              .paymentType
                                              .toString() ==
                                          "COD") {
                                        paymentType = Languages.of(context)!
                                            .cashondeliverylable;
                                      } else {
                                        paymentType = orderdatalist[index]
                                            .paymentType
                                            .toString();
                                      }

                                      double userLat = double.parse(
                                          orderdatalist[index]
                                              .userAddress!
                                              .lat!);
                                      double userLong = double.parse(
                                          orderdatalist[index]
                                              .userAddress!
                                              .lang!);

                                      double vendorLat = double.parse(
                                          orderdatalist[index].vendor!.lat!);
                                      double vendorLong = double.parse(
                                          orderdatalist[index].vendor!.lang!);

                                      assert(userLat is double);
                                      assert(userLong is double);

                                      String distance = "0";
                                      String str = Constants.calculateDistance(
                                              vendorLat,
                                              vendorLong,
                                              userLat,
                                              userLong)
                                          .toString();
                                      // print(str);
                                      // var distance12 = str.split('.');
                                      // distance = distance12[0];
                                      distance =
                                          double.parse(str).toStringAsFixed(2);

                                      return Padding(
                                        padding: EdgeInsets.all(
                                            ScreenUtil().setWidth(8)),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: 10,
                                              right: 5,
                                              bottom: 0,
                                              left: 5),
                                          decoration: BoxDecoration(
                                              color: Constants.itembgcolor,
                                              border: Border.all(
                                                color: Constants.itembgcolor,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(0),
                                                right:
                                                    ScreenUtil().setWidth(0)),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15,
                                                        left: 15,
                                                        right: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        // Container(
                                                        //   margin:
                                                        //       EdgeInsets.only(
                                                        //           top: 0,
                                                        //           left: 5,
                                                        //           right: 5,
                                                        //           bottom: 0),
                                                        //   alignment:
                                                        //       Alignment.center,
                                                        //   padding:
                                                        //       EdgeInsets.all(
                                                        //           13),
                                                        //   decoration:
                                                        //       BoxDecoration(
                                                        //           color: Colors
                                                        //               .white,
                                                        //           shape: BoxShape
                                                        //               .circle),
                                                        //   child: Text(
                                                        //     "${_counter}s",
                                                        //     style: TextStyle(
                                                        //         color:
                                                        //             Colors.red,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w700,
                                                        //         fontFamily:
                                                        //             Constants
                                                        //                 .app_font_bold,
                                                        //         fontSize: 16),
                                                        //   ),
                                                        // ),
                                                        if (_counter == 0)
                                                          SizedBox(),
                                                        if (_counter != 0)
                                                          Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(1),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            13),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Text(
                                                                  "${getFormattedCounter()}s",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        Constants
                                                                            .app_font_bold,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                              CircularProgressIndicator(
                                                                value: _counter /
                                                                    30, // Adjust this based on your max time
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .brown),
                                                                backgroundColor:
                                                                    Constants
                                                                        .color_red,
                                                                strokeWidth: 4,
                                                              ),
                                                            ],
                                                          ),
                                                        InkWell(
                                                          onTap: () {
                                                            _OpenCancelBottomSheet(
                                                                orderdatalist[
                                                                        index]
                                                                    .id
                                                                    .toString(),
                                                                context);
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0,
                                                                    left: 5,
                                                                    right: 5,
                                                                    bottom: 0),
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: SvgPicture
                                                                .asset(
                                                              "images/close.svg",
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15,
                                                        left: 15,
                                                        right: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          Languages.of(context)!
                                                                  .oidlable +
                                                              "    " +
                                                              orderdatalist[
                                                                      index]
                                                                  .orderId!,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Constants
                                                                  .app_font_bold,
                                                              fontSize: 16),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Text(
                                                            '${PreferenceUtils.getString(Constants.currencySymbol)} ${orderdatalist[index].amount.toString()}',
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .color_theme,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font_bold,
                                                                fontSize: 16),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                    itemCount:
                                                        orderdatalist[index]
                                                            .orderItems!
                                                            .length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, position) {
                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10, left: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              orderdatalist[
                                                                      index]
                                                                  .orderItems![
                                                                      position]
                                                                  .itemName!,
                                                              style: TextStyle(
                                                                  color: Constants
                                                                      .greaytext,
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "  x " +
                                                                  orderdatalist[
                                                                          index]
                                                                      .orderItems![
                                                                          position]
                                                                      .qty
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  color: Constants
                                                                      .color_theme,
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .transparent,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(8))),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 5,
                                                                      left: 0,
                                                                      right: 5,
                                                                      bottom:
                                                                          30),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child:
                                                                  CachedNetworkImage(
                                                                // imageUrl: imageurl,
                                                                imageUrl:
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .image!,
                                                                fit:
                                                                    BoxFit.fill,
                                                                width: ScreenUtil()
                                                                    .setWidth(
                                                                        180),
                                                                height:
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            55),

                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  child: Image(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitFadingCircle(
                                                                        color: Constants
                                                                            .color_theme),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                        "images/no_image.png"),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                            // width: screenwidth * 0.65,
                                                            height:
                                                                screenheight *
                                                                    0.15,
                                                            color: Constants
                                                                .itembgcolor,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 20,
                                                                    left: 5,
                                                                    right: 5,
                                                                    bottom: 0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          AutoSizeText(
                                                                        orderdatalist[index]
                                                                            .vendor!
                                                                            .name!,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Constants.whitetext,
                                                                            fontFamily: Constants.app_font_bold,
                                                                            fontSize: 16),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: 0,
                                                                              left: 0,
                                                                              right: 2,
                                                                              bottom: 0),
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/veg.svg",
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: 0,
                                                                              left: 2,
                                                                              right: 10,
                                                                              bottom: 0),
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/nonveg.svg",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              5,
                                                                          left:
                                                                              0,
                                                                          right:
                                                                              5,
                                                                          bottom:
                                                                              0),

                                                                  color: Colors
                                                                      .transparent,
                                                                  // height:screenheight * 0.03,
                                                                  child:
                                                                      AutoSizeText(
                                                                    orderdatalist[index]
                                                                            .vendor!
                                                                            .mapAddress ??
                                                                        '',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                    maxLines: 3,
                                                                    style: TextStyle(
                                                                        color: Constants
                                                                            .greaytext,
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
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 20,
                                                        right: 0,
                                                        left: 5),
                                                    width: screenwidth,
                                                    child: DottedLine(
                                                      direction:
                                                          Axis.horizontal,
                                                      lineLength:
                                                          double.infinity,
                                                      lineThickness: 1.0,
                                                      dashLength: 8.0,
                                                      dashColor:
                                                          Constants.dashline,
                                                      dashRadius: 0.0,
                                                      dashGapLength: 5.0,
                                                      dashGapColor:
                                                          Colors.transparent,
                                                      dashGapRadius: 0.0,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10,
                                                        left: 15,
                                                        right: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          orderdatalist[index]
                                                              .user!
                                                              .name!,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Constants
                                                                  .app_font_bold,
                                                              fontSize: 16),
                                                        ),
                                                        RichText(
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textScaleFactor: 1,
                                                          text: TextSpan(
                                                            children: [
                                                              WidgetSpan(
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5,
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          right:
                                                                              5),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "images/location.svg",
                                                                    width: 13,
                                                                    height: 13,
                                                                  ),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    distance +
                                                                        " " +
                                                                        Languages.of(context)!
                                                                            .kmfarawaylable,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Constants
                                                                          .whitetext,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          Constants
                                                                              .app_font,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 5,
                                                        left: 15,
                                                        right: 10),
                                                    child: Text(
                                                      orderdatalist[index]
                                                          .userAddress!
                                                          .address!,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      maxLines: 5,
                                                      style: TextStyle(
                                                          color: Constants
                                                              .greaytext,
                                                          fontFamily: Constants
                                                              .app_font,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 30,
                                                        bottom: 20,
                                                        right: 0,
                                                        left: 5),
                                                    width: screenwidth,
                                                    child: DottedLine(
                                                      direction:
                                                          Axis.horizontal,
                                                      lineLength:
                                                          double.infinity,
                                                      lineThickness: 1.0,
                                                      dashLength: 8.0,
                                                      dashColor:
                                                          Constants.dashline,
                                                      dashRadius: 0.0,
                                                      dashGapLength: 5.0,
                                                      dashGapColor:
                                                          Colors.transparent,
                                                      dashGapRadius: 0.0,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 2,
                                                        left: 15,
                                                        right: 10,
                                                        bottom: 20),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: ListView(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        Languages.of(context)!
                                                                            .paymentlable,
                                                                        style: TextStyle(
                                                                            color: Constants
                                                                                .whitetext,
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                Constants.app_font_bold),
                                                                      )),
                                                                  Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        "(" +
                                                                            paymentstatus +
                                                                            ")",
                                                                        style: TextStyle(
                                                                            color:
                                                                                paymentcolor,
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                Constants.app_font_bold),
                                                                      )),
                                                                ],
                                                              ),
                                                              Text(
                                                                paymentType,
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .greaytext,
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        Constants
                                                                            .app_font),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        // Expanded(
                                                        //   flex: 1,
                                                        //   child: Container(
                                                        //     child: Row(
                                                        //       mainAxisAlignment:
                                                        //           MainAxisAlignment
                                                        //               .start,
                                                        //       children: [
                                                        //         InkWell(
                                                        //           onTap: () {
                                                        //             _OpenCancelBottomSheet(
                                                        //                 orderdatalist[index]
                                                        //                     .id
                                                        //                     .toString(),
                                                        //                 context);
                                                        //           },
                                                        //           child:
                                                        //               Container(
                                                        //             margin: EdgeInsets.only(
                                                        //                 top: 0,
                                                        //                 left: 5,
                                                        //                 right:
                                                        //                     5,
                                                        //                 bottom:
                                                        //                     0),
                                                        //             alignment:
                                                        //                 Alignment
                                                        //                     .topRight,
                                                        //             child: SvgPicture
                                                        //                 .asset(
                                                        //               "images/close.svg",
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         InkWell(
                                                        //           onTap: () {
                                                        //             if (currentOrderData
                                                        //                 null) {
                                                        //               Constants
                                                        //                   .toastMessage(
                                                        //                       "Please Complete Previous Order");
                                                        //             } else {
                                                        //               Constants
                                                        //                       .CheckNetwork()
                                                        //                   .whenComplete(() =>
                                                        //                       CallApiForAcceptorder(
                                                        //                         orderdatalist[index].id.toString(),
                                                        //                         orderdatalist[index].orderId.toString(),
                                                        //                         orderdatalist[index].vendor!.name,
                                                        //                         orderdatalist[index].vendor!.mapAddress,
                                                        //                         distance,
                                                        //                         orderdatalist[index].vendor!.lat,
                                                        //                         orderdatalist[index].vendor!.lang,
                                                        //                         orderdatalist[index].userAddress!.lat,
                                                        //                         orderdatalist[index].userAddress!.lang,
                                                        //                         orderdatalist[index].userAddress!.address,
                                                        //                         orderdatalist[index].vendor!.image,
                                                        //                         orderdatalist[index].user!.name,
                                                        //                       ));
                                                        //             }
                                                        //           },
                                                        //           child:
                                                        //               Container(
                                                        //             margin: EdgeInsets.only(
                                                        //                 top: 0,
                                                        //                 left: 0,
                                                        //                 right:
                                                        //                     10,
                                                        //                 bottom:
                                                        //                     0),
                                                        //             alignment:
                                                        //                 Alignment
                                                        //                     .topRight,
                                                        //             child: SvgPicture
                                                        //                 .asset(
                                                        //               "images/right.svg",
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 30,
                                                        bottom: 20,
                                                        right: 0,
                                                        left: 5),
                                                    width: screenwidth,
                                                    child: DottedLine(
                                                      direction:
                                                          Axis.horizontal,
                                                      lineLength:
                                                          double.infinity,
                                                      lineThickness: 1.0,
                                                      dashLength: 8.0,
                                                      dashColor:
                                                          Constants.dashline,
                                                      dashRadius: 0.0,
                                                      dashGapLength: 5.0,
                                                      dashGapColor:
                                                          Colors.transparent,
                                                      dashGapRadius: 0.0,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 15),
                                                          child: Text(
                                                            "Expected delivery charge: ",
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .whitetext,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font_bold),
                                                          )),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Text(
                                                            '${PreferenceUtils.getString(Constants.currencySymbol)} 100',
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .whitetext,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font_bold),
                                                          )),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 30,
                                                        bottom: 20,
                                                        right: 0,
                                                        left: 5),
                                                    width: screenwidth,
                                                    child: DottedLine(
                                                      direction:
                                                          Axis.horizontal,
                                                      lineLength:
                                                          double.infinity,
                                                      lineThickness: 1.0,
                                                      dashLength: 8.0,
                                                      dashColor:
                                                          Constants.dashline,
                                                      dashRadius: 0.0,
                                                      dashGapLength: 5.0,
                                                      dashGapColor:
                                                          Colors.transparent,
                                                      dashGapRadius: 0.0,
                                                    ),
                                                  ),
                                                  Padding(
                                                    // height: 40,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 10),
                                                    child: SlideAction(
                                                      text: "Accept",
                                                      textStyle: TextStyle(
                                                          fontFamily: Constants
                                                              .app_font,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 22,
                                                          color: Colors.white),
                                                      // borderRadius: 10,
                                                      height: 50,
                                                      sliderButtonIconSize: 30,
                                                      outerColor:
                                                          Constants.color_theme,
                                                      sliderButtonIconPadding:
                                                          5,
                                                      onSubmit: () {
                                                        print("Accepted");
                                                        if (currentOrderData
                                                                .orderId !=
                                                            null) {
                                                          Constants.toastMessage(
                                                              "Please Complete Previous Order");
                                                        } else {
                                                          Constants
                                                                  .CheckNetwork()
                                                              .whenComplete(() =>
                                                                  CallApiForAcceptorder(
                                                                    orderdatalist[
                                                                            index]
                                                                        .id
                                                                        .toString(),
                                                                    orderdatalist[
                                                                            index]
                                                                        .orderId
                                                                        .toString(),
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .name,
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .mapAddress,
                                                                    distance,
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .lat,
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .lang,
                                                                    orderdatalist[
                                                                            index]
                                                                        .userAddress!
                                                                        .lat,
                                                                    orderdatalist[
                                                                            index]
                                                                        .userAddress!
                                                                        .lang,
                                                                    orderdatalist[
                                                                            index]
                                                                        .userAddress!
                                                                        .address,
                                                                    orderdatalist[
                                                                            index]
                                                                        .vendor!
                                                                        .image,
                                                                    orderdatalist[
                                                                            index]
                                                                        .user!
                                                                        .name,
                                                                  ));
                                                        }
                                                      },
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
                                  visible: hideduty,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(top: 50),
                                            child: SvgPicture.asset(
                                              "images/offline.svg",
                                              width:
                                                  ScreenUtil().setHeight(200),
                                              height:
                                                  ScreenUtil().setHeight(200),
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
                                              Languages.of(context)!
                                                  .youareofflinelable,
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
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0,
                                                left: 15.0,
                                                right: 15,
                                                bottom: 0),
                                            child: Text(
                                              Languages.of(context)!
                                                  .dutystatusofflinelable,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize: 16),
                                              maxLines: 4,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 30.0,
                                                  left: 15.0,
                                                  right: 15,
                                                  bottom: 20),
                                              child: InkWell(
                                                onTap: () {
                                                  isOnline = true;

                                                  Constants.CheckNetwork()
                                                      .whenComplete(() =>
                                                          CallApiForUpdateStatus(
                                                              isOnline));
                                                },
                                                child: RichText(
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                          text: Languages.of(
                                                                  context)!
                                                              .reconnectlable,
                                                          style: TextStyle(
                                                            color: Constants
                                                                .color_theme,
                                                            fontSize: 16,
                                                            fontFamily: Constants
                                                                .app_font_bold,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: nojob,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(top: 50),
                                            child: SvgPicture.asset(
                                              "images/no_job.svg",
                                              width:
                                                  ScreenUtil().setHeight(200),
                                              height:
                                                  ScreenUtil().setHeight(200),
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
                                              Languages.of(context)!
                                                  .nonewjoblable,
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
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0,
                                                left: 15.0,
                                                right: 15,
                                                bottom: 0),
                                            child: Text(
                                              Languages.of(context)!
                                                  .youhavenotnewjoblable,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize: 16),
                                              maxLines: 4,
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

                        /// last order
                        Visibility(
                            visible: checkCurrentOrder() && isOnline,
                            child: Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  // height: ScreenUtil().setHeight(180),
                                  color: const Color(0xFF42565f),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 20, top: 20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    Languages.of(context)!
                                                            .oidlable +
                                                        "  " +
                                                        PreferenceUtils
                                                            .getString(Constants
                                                                .previos_order_orderid),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontFamily: Constants
                                                            .app_font_bold,
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    PreferenceUtils.getString(
                                                        Constants
                                                            .previos_order_vendor_name),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: Constants
                                                            .app_font_bold,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    PreferenceUtils.getString(
                                                        Constants
                                                            .previos_order_vendor_address),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: Constants
                                                            .app_font_bold,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  RichText(
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor: 1,
                                                    text: TextSpan(
                                                      children: [
                                                        WidgetSpan(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5,
                                                                    top: 0,
                                                                    bottom: 0,
                                                                    right: 5),
                                                            child: SvgPicture
                                                                .asset(
                                                              "images/location.svg",
                                                              width: 13,
                                                              height: 13,
                                                            ),
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 0,
                                                                    top: 0,
                                                                    bottom: 0,
                                                                    right: 5),
                                                            child: Text(
                                                              PreferenceUtils.getString(
                                                                      Constants
                                                                          .previos_order_distance) +
                                                                  Languages.of(
                                                                          context)!
                                                                      .kmfarawaylable,
                                                              style: TextStyle(
                                                                color: Constants
                                                                    .whitetext,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  // Center(
                                                  //   child: ElevatedButton(
                                                  //     style:
                                                  //         ElevatedButton.styleFrom(
                                                  //       elevation: 5.0,
                                                  //       textStyle: TextStyle(
                                                  //           color: Colors.white),
                                                  //       backgroundColor:
                                                  //           Constants.color_theme,
                                                  //       shape:
                                                  //           new RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //             new BorderRadius
                                                  //                 .circular(15.0),
                                                  //       ),
                                                  //     ),
                                                  //     child: Padding(
                                                  //       padding: const EdgeInsets
                                                  //               .fromLTRB(
                                                  //           0.0, 15.0, 0, 15.0),
                                                  //       child: Text(
                                                  //         "Complete current order",
                                                  //         style: TextStyle(
                                                  //             fontFamily: Constants
                                                  //                 .app_font,
                                                  //             fontWeight:
                                                  //                 FontWeight.w900,
                                                  //             fontSize: 16.0),
                                                  //       ),
                                                  //     ),
                                                  //     onPressed: () {
                                                  //       // PreferenceUtils.setString(
                                                  //       //     'pickup_btn_status',
                                                  //       //     "pickup");
                                                  //       final status =
                                                  //           PreferenceUtils.getString(
                                                  //               'pickup_btn_status',
                                                  //               "pickup");
                                                  //       if (status ==
                                                  //           "place_order") {
                                                  //         Navigator.of(context).push(
                                                  //             MaterialPageRoute(
                                                  //                 builder: (context) =>
                                                  //                     PickUpOrder()));
                                                  //       } else {
                                                  //         Navigator.of(context).push(
                                                  //             MaterialPageRoute(
                                                  //                 builder: (context) =>
                                                  //                     NewGetOrderKitchen()));
                                                  //       }
                                                  //     },
                                                  //   ),
                                                  // ),
                                                  // SizedBox(
                                                  //   height: 15,
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(right: 20),
                                            child: CachedNetworkImage(
                                              imageUrl: PreferenceUtils
                                                  .getString(Constants
                                                      .previos_order_vendor_image),
                                              fit: BoxFit.fill,
                                              width: ScreenUtil().setWidth(55),
                                              height:
                                                  ScreenUtil().setHeight(55),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  SpinKitFadingCircle(
                                                      color: Constants
                                                          .color_theme),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "images/no_image.png"),
                                            ),
                                          )
                                        ],
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 5.0,
                                            textStyle:
                                                TextStyle(color: Colors.white),
                                            backgroundColor:
                                                Constants.color_theme,
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      15.0),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 15.0, 0, 15.0),
                                            child: Text(
                                              "Complete current order",
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            // PreferenceUtils.setString(
                                            //     'pickup_btn_status',
                                            //     "pickup");
                                            final status =
                                                PreferenceUtils.getString(
                                                    'pickup_btn_status',
                                                    "pickup");
                                            if (status == "place_order") {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PickUpOrder()));
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NewGetOrderKitchen()));
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),

                        // /// last order
                        // currentOrderData.orderId != null
                        //     ? Container(
                        //         child: Align(
                        //           alignment: Alignment.bottomCenter,
                        //           child: Container(
                        //             height: ScreenUtil().setHeight(100),
                        //             color: const Color(0xFF42565f),
                        //             child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Container(
                        //                   margin: EdgeInsets.only(
                        //                       left: 20, top: 20),
                        //                   child: Column(
                        //                     children: [
                        //                       Text(
                        //                         Languages.of(context)!
                        //                                 .oidlable +
                        //                             "  " +
                        //                             PreferenceUtils.getString(
                        //                                 Constants
                        //                                     .previos_order_orderid),
                        //                         style: TextStyle(
                        //                             color: Colors.white,
                        //                             fontFamily:
                        //                                 Constants.app_font_bold,
                        //                             fontSize: 16),
                        //                       ),
                        //                       Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.start,
                        //                         children: [
                        //                           InkWell(
                        //                             onTap: () {
                        //                               _OpenCancelBottomSheet(
                        //                                   PreferenceUtils
                        //                                       .getString(Constants
                        //                                           .previos_order_id
                        //                                           .toString()),
                        //                                   context);
                        //                             },
                        //                             child: Container(
                        //                               margin: EdgeInsets.only(
                        //                                   left: 10, top: 10),
                        //                               child: Text(
                        //                                 Languages.of(context)!
                        //                                     .canceldeliverylable,
                        //                                 style: TextStyle(
                        //                                     color: Constants
                        //                                         .color_red,
                        //                                     fontFamily:
                        //                                         Constants
                        //                                             .app_font,
                        //                                     fontSize: 14),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                           InkWell(
                        //                             onTap: () {
                        //                               PreferenceUtils.getString(
                        //                                           Constants
                        //                                               .previos_order_status) ==
                        //                                       'PICKUP'
                        //                                   ? Navigator.of(
                        //                                           context)
                        //                                       .push(MaterialPageRoute(
                        //                                           builder:
                        //                                               (context) =>
                        //                                                   PickUpOrder()))
                        //                                   : Navigator.of(
                        //                                           context)
                        //                                       .push(MaterialPageRoute(
                        //                                           builder:
                        //                                               (context) =>
                        //                                                   NewGetOrderKitchen()));
                        //                             },
                        //                             child: Container(
                        //                               margin: EdgeInsets.only(
                        //                                   left: 12, top: 10),
                        //                               child: Text(
                        //                                 Languages.of(context)!
                        //                                     .pickupanddeliverlable,
                        //                                 style: TextStyle(
                        //                                     color: Constants
                        //                                         .color_theme,
                        //                                     fontFamily:
                        //                                         Constants
                        //                                             .app_font,
                        //                                     fontSize: 14),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                           Container(
                        //                               margin: EdgeInsets.only(
                        //                                   left: 5, top: 12),
                        //                               child: SvgPicture.asset(
                        //                                   "images/right_arrow.svg")),
                        //                         ],
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Container(
                        //                   margin: EdgeInsets.only(right: 20),
                        //                   child: CachedNetworkImage(
                        //                     imageUrl: PreferenceUtils.getString(
                        //                         Constants
                        //                             .previos_order_vendor_image),
                        //                     fit: BoxFit.fill,
                        //                     width: ScreenUtil().setWidth(55),
                        //                     height: ScreenUtil().setHeight(55),
                        //                     imageBuilder:
                        //                         (context, imageProvider) =>
                        //                             ClipRRect(
                        //                       borderRadius:
                        //                           BorderRadius.circular(10.0),
                        //                       child: Image(
                        //                         image: imageProvider,
                        //                         fit: BoxFit.cover,
                        //                       ),
                        //                     ),
                        //                     placeholder: (context, url) =>
                        //                         SpinKitFadingCircle(
                        //                             color:
                        //                                 Constants.color_theme),
                        //                     errorWidget:
                        //                         (context, url, error) =>
                        //                             Image.asset(
                        //                                 "images/no_image.png"),
                        //                   ),
                        //                 )
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     : Container(),
                      ],
                    );
                  }),
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  void _OpenCancelBottomSheet(String id, BuildContext context) {
    dynamic screenwidth = MediaQuery.of(context).size.width;
    dynamic screenheight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Constants.itembgcolor,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, left: 20, bottom: 0, right: 10),
                        child: Text(
                          Languages.of(context)!.telluslable,
                          style: TextStyle(
                              color: Constants.whitetext,
                              fontSize: 18,
                              fontFamily: Constants.app_font),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 5, left: 20, bottom: 0, right: 10),
                        child: Text(
                          Languages.of(context)!.whycancellable,
                          style: TextStyle(
                              color: Constants.whitetext,
                              fontSize: 18,
                              fontFamily: Constants.app_font),
                        ),
                      ),
                      ListView.builder(
                          itemCount: can_reason.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, position) {
                            return Container(
                              width: screenwidth,
                              margin: EdgeInsets.only(
                                  top: 10, left: 20, bottom: 0, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 0, left: 0, bottom: 0, right: 0),
                                    child: Text(
                                      // can_reason[position],
                                      can_reason[position],
                                      overflow: TextOverflow.visible,
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: Constants.greaytext,
                                          fontSize: 12,
                                          fontFamily: Constants.app_font),
                                    ),
                                  ),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor:
                                          Constants.whitetext,
                                      disabledColor: Constants.whitetext,
                                    ),
                                    child: Radio<String>(
                                      activeColor: Constants.color_theme,
                                      value: can_reason[position],
                                      groupValue: _cancelReason,
                                      onChanged: (value) {
                                        setState(() {
                                          _cancelReason = value;

                                          // _handleRadioValueChange;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 10, bottom: 20, right: 20),
                        child: Card(
                          color: Constants.bgcolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          elevation: 5.0,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              validator: Constants.kvalidateFullName,
                              keyboardType: TextInputType.text,
                              controller: _text_cancel_reason_controller,
                              maxLines: 5,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: Constants.app_font_bold),
                              decoration: Constants.kTextFieldInputDecoration
                                  .copyWith(
                                      contentPadding: EdgeInsets.only(
                                          left: 20, top: 20, right: 20),
                                      hintText: Languages.of(context)!
                                          .cancelreasonlable,
                                      hintStyle: TextStyle(
                                          color: Constants.greaytext,
                                          fontFamily: Constants.app_font,
                                          fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          print("RadioValue:$_cancelReason");

                          if (_cancelReason == "0") {
                            Constants.toastMessage(
                                Languages.of(context)!.selectcancelreasonlable);
                          } else if (_cancelReason ==
                              Languages.of(context)!.otherreasonlable) {
                            if (_text_cancel_reason_controller.text.length ==
                                0) {
                              Constants.toastMessage(
                                  Languages.of(context)!.addreasonlable);
                            } else {
                              _cancelReason =
                                  _text_cancel_reason_controller.text;
                            }
                          } else {
                            Constants.CheckNetwork().whenComplete(
                                () => CallApiForCacelorder(id, _cancelReason));
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 10, bottom: 20, right: 20),
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
                            height: screenheight * 0.07,
                            child: Center(
                              child: Container(
                                color: Constants.color_theme,
                                child: Text(
                                  Languages.of(context)!.submitreviewlable,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: Constants.app_font),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}

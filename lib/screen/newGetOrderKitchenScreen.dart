import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/screen/pickupdeliverorderscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:slide_to_act_reborn/slide_to_act_reborn.dart';

import '../model/current_order.dart';

class NewGetOrderKitchen extends StatefulWidget {
  @override
  _NewGetOrderKitchen createState() => _NewGetOrderKitchen();
}

class _NewGetOrderKitchen extends State<NewGetOrderKitchen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  double heigntValue = 300;
  bool full = true;
  bool full1 = false;
  bool vi_address = true;
  String? _cancelReason = "0";
  String _result = "0";
  bool showSpinner = false;
  List can_reason = [];

  String driver_address = "Not Found";

  String? id;
  late String orderId;
  late String vendorname;
  late String vendorAddress;
  late String distance;

  Timer? timer;

  int second = 5;

  double? driver_lat = 0.0;
  double? driver_lang = 0.0;

  late double vendor_lat = 0.0;
  late double vendor_lang = 0.0;
  late String cancel_reason;
  final _text_cancel_reason_controller = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  Polyline? _mapPolyline;
  String? _currentAddress;

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  late LocationData currentLocation;
  Location? location;
  double CAMERA_ZOOM = 14.4746;
  double CAMERA_TILT = 80;
  double CAMERA_BEARING = 30;

  bool isViewMap = false;
  bool isAllLoader = false;

  @override
  void initState() {
    super.initState();

    second =
        int.parse(PreferenceUtils.getString(Constants.driver_auto_refrese));

    location = new Location();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    _getCurrentLocation();
    setCurrentLocation();
    if (mounted) {
      setState(() {
        cancel_reason = PreferenceUtils.getString(Constants.cancel_reason);
        var json = JsonDecoder().convert(cancel_reason);
        can_reason.addAll(json);
      });
    }

    Constants.CheckNetwork().whenComplete(
        () => timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
              _getCurrentLocation();
            }));

    if (Constants.currentlat != 0.0 && Constants.currentlong != 0.0) {
      setState(() {
        driver_lat = Constants.currentlat;
        driver_lang = Constants.currentlong;
        if (PreferenceUtils.getString(Constants.previos_order_vendor_lat) !=
            '') {
          vendor_lat = double.parse(
              PreferenceUtils.getString(Constants.previos_order_vendor_lat));
          vendor_lang = double.parse(
              PreferenceUtils.getString(Constants.previos_order_vendor_lang));
        }
        assert(vendor_lat is double);
        assert(vendor_lang is double);

        /// origin marker
        /// // make sure to initialize before map loading
        BitmapDescriptor customIcon;
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
                'images/driver_map_image_7.png')
            .then((d) {
          customIcon = d;
          addMarker(LatLng(driver_lat!, driver_lang!), "origin", customIcon);
        });

        /// destination marker
        BitmapDescriptor customIcon1;
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
                'images/food_map_image_4.png')
            .then((d) {
          customIcon1 = d;
          addMarker(
              LatLng(vendor_lat, vendor_lang), "destination", customIcon1);
        });

        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: second), (Timer t) {
                  _getCurrentLocation();
                  PostDriverLocation(driver_lat, driver_lang);
                }));
      });
    } else {}

    PreferenceUtils.init();

    if (mounted) {
      setState(() {
        id = PreferenceUtils.getString(Constants.previos_order_id);
        orderId = PreferenceUtils.getString(Constants.previos_order_orderid);
        vendorname =
            PreferenceUtils.getString(Constants.previos_order_vendor_name);
        vendorAddress =
            PreferenceUtils.getString(Constants.previos_order_vendor_address);
        distance = PreferenceUtils.getString(Constants.previos_order_distance);

        // if (Constants.currentaddress != "0") {
        //   driver_address = Constants.currentaddress;
        // } else {
        //   isAllLoader = true;
        //   Constants.cuttentlocation()
        //       .whenComplete(() => Constants.cuttentlocation().then((value) {
        //             driver_address = value;
        //             isAllLoader = false;
        //           }));
        // }
      });
    }
    // isAllLoader = true;
    // setState(() {
    //   Constants.cuttentlocation()
    //       .whenComplete(() => Constants.cuttentlocation().then((value) {
    //             driver_address = value;
    //             isAllLoader = false;
    //           }));
    // });

    location!.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
  }

  setCurrentLocation() async {
    if (Constants.currentaddress != "0") {
      driver_address = Constants.currentaddress;
    } else {
      setState(() {
        isAllLoader = true;
      });
      final tempAddress = await Constants.cuttentlocation();
      driver_address = tempAddress;
      setState(() {
        isAllLoader = false;
      });
    }
  }

  updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    final marker = markers.values
        .toList()
        .firstWhere((item) => item.markerId == MarkerId('origin'));

    Marker _marker = Marker(
      markerId: marker.markerId,
      position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      icon: marker.icon,
    );

    setState(() {
      markers[MarkerId('origin')] = _marker;
    });
  }

  _getCurrentLocation() {
    Constants.currentlatlong().then((value) {
      if (mounted) {
        setState(() {
          driver_lat = value!.latitude;
          driver_lang = value.longitude;
        });
      }
    });
  }

  void PostDriverLocation(double? currentlat, double? currentlang) {
    RestClient(ApiHeader().dioData())
        .driveUpdateLatLong(currentlat.toString(), currentlang.toString())
        .then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      if (sucess = true) {
      } else if (sucess == false) {}
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      Fluttertoast.showToast(msg: snackBar.toString());
      // _scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {});
      print(obj.runtimeType);
    });
  }

  void CallApiForPickUporder(BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    if (mounted) {
      RestClient(ApiHeader().dioData())
          .orderStatusChange1(id, "PICKUP")
          .then((response) {
        final body = json.decode(response!);
        bool? sucess = body['success'];
        if (sucess = true) {
          setState(() {
            showSpinner = false;
          });
          var msg = "Order Pickup";
          PreferenceUtils.setString(Constants.previos_order_status, "PICKUP");

          setState(() {
            timer?.cancel();
          });

          Navigator.of(this.context).push(MaterialPageRoute(
            builder: (context) => PickUpOrder(),
          ));
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
      });
    }
  }

  void CallApiForCacelorder(
      String? id, String? cancelReason, BuildContext context) {
    print(id);

    setState(() {
      showSpinner = true;
    });

    if (mounted) {
      RestClient(ApiHeader().dioData())
          .cancelOrder(id, "CANCEL", cancelReason)
          .then((response) {
        final body = json.decode(response!);
        bool? sucess = body['success'];
        if (sucess = true) {
          setState(() {
            showSpinner = false;
          });
          var msg = Languages.of(this.context)!.ordercancellable;
          Constants.createSnackBar(msg, this.context, Constants.color_theme);

          if (mounted) {
            setState(() {
              PreferenceUtils.setString(
                  Constants.previos_order_status, "CANCEL");
              timer?.cancel();
              Navigator.of(this.context)
                  .push(MaterialPageRoute(builder: (context) => HomeScreen(0)));
            });
          }
        } else if (sucess == false) {
          setState(() {
            showSpinner = false;
          });
          var msg = Languages.of(this.context)!.tryagainlable;
          Constants.createSnackBar(msg, this.context, Constants.color_red);
        }
      }).catchError((Object obj) {
        final snackBar = SnackBar(
          content: Text(Languages.of(this.context)!.servererrorlable),
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

  bool getReachBtnStatus() {
    bool showReach = false;
    final status = PreferenceUtils.getString('pickup_btn_status', "pickup");
    if (status == "pickup") {
      showReach = true;
    }
    return showReach;
  }

  bool getPickupBtnStatus() {
    bool showPickup = false;
    final status = PreferenceUtils.getString('pickup_btn_status', "pickup");
    if (status == "deliver") {
      showPickup = true;
    }
    return showPickup;
  }

  bool isBtnLoader = false;
  void setReachDestBtnStatus(bool completePickup) {
    if (completePickup) {
      PreferenceUtils.setString('pickup_btn_status', "place_order");
    } else {
      PreferenceUtils.setString('pickup_btn_status', "deliver");
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenheight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: new SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/background_image.png'),
            fit: BoxFit.cover,
          )),
          child: ModalProgressHUD(
            inAsyncCall: isAllLoader,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator:
                SpinKitFadingCircle(color: Constants.color_theme),
            child: Visibility(
              visible: !isAllLoader,
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: false,
                  key: _scaffoldKey,
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
                            Column(
                              children: <Widget>[
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Spacer(),
                                    Visibility(
                                      visible: !full1,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5.0,
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          backgroundColor:
                                              Constants.color_theme,
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isViewMap = !isViewMap;
                                          });
                                        },
                                        label: Text("Map View"),
                                        icon: Icon(isViewMap
                                            ? Icons.arrow_drop_up_outlined
                                            : Icons.arrow_drop_down_outlined),
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          full = false;
                                          full1 = true;
                                          vi_address = false;
                                        });
                                      },
                                      child: Visibility(
                                        visible: full && isViewMap,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 0, bottom: 0, right: 0),
                                          child: SvgPicture.asset(
                                              "images/map_zoom.svg"),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          full = true;
                                          full1 = false;
                                          vi_address = true;
                                        });
                                      },
                                      child: Visibility(
                                        visible: full1 && isViewMap,
                                        child: Container(
                                          alignment: Alignment.bottomRight,
                                          margin: EdgeInsets.only(
                                              left: 0, bottom: 0, right: 0),
                                          child: SvgPicture.asset(
                                              "images/map_zoom.svg"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isViewMap)
                                  Expanded(
                                    flex: 3,
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      height: screenheight * 0.7,
                                      child: Stack(
                                        children: [
                                          Container(
                                            child: GoogleMap(
                                                mapType: MapType.normal,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: LatLng(driver_lat!,
                                                      driver_lang!),
                                                  zoom: CAMERA_ZOOM,
                                                ),
                                                myLocationEnabled: true,
                                                tiltGesturesEnabled: true,
                                                compassEnabled: true,
                                                scrollGesturesEnabled: true,
                                                zoomGesturesEnabled: true,
                                                markers: Set<Marker>.of(
                                                    markers.values),
                                                polylines: Set<Polyline>.of(
                                                    polylines.values),
                                                onMapCreated: onMapCreated),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       full = true;
                                //       full1 = false;
                                //       vi_address = true;
                                //     });
                                //   },
                                //   child: Visibility(
                                //     visible: full1,
                                //     child: Container(
                                //       alignment: Alignment.bottomRight,
                                //       margin: EdgeInsets.only(
                                //           left: 0, bottom: 0, right: 0),
                                //       child:
                                //           SvgPicture.asset("images/map_zoom.svg"),
                                //     ),
                                //   ),
                                // ),
                                !isViewMap
                                    ? noMapOrderView()
                                    : SingleChildScrollView(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        child: Visibility(
                                          visible: vi_address,
                                          child: Container(
                                            height: ScreenUtil().setHeight(220),
                                            margin: EdgeInsets.only(
                                                left: 20, top: 10, bottom: 60),
                                            color: Colors.transparent,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Builder(
                                                            builder: (context) {
                                                          final newOrderId =
                                                              orderId;
                                                          // final prefixId  = newOrderId;
                                                          final prefixId =
                                                              newOrderId.substring(
                                                                  0,
                                                                  newOrderId
                                                                          .length -
                                                                      4);
                                                          final suffixId =
                                                              newOrderId.substring(
                                                                  newOrderId
                                                                          .length -
                                                                      4);

                                                          return RichText(
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textScaleFactor: 1,
                                                            text: TextSpan(
                                                              children: [
                                                                WidgetSpan(
                                                                  child:
                                                                      Container(
                                                                    child: Text(
                                                                      Languages.of(context)!
                                                                              .oidlable +
                                                                          "   " +
                                                                          prefixId,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              30,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                                WidgetSpan(
                                                                  child:
                                                                      Container(
                                                                    child: Text(
                                                                      suffixId,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .green,
                                                                          fontSize:
                                                                              30,
                                                                          fontWeight:
                                                                              FontWeight.w900),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                        // Container(
                                                        //   alignment:
                                                        //       Alignment.topLeft,
                                                        //   child: Text(
                                                        //     Languages.of(context)!
                                                        //             .oidlable +
                                                        //         "   " +
                                                        //         orderId,
                                                        //     style: TextStyle(
                                                        //       color: Colors.white,
                                                        //       fontSize: 18,
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        ////
                                                        // Row(
                                                        //   children: [
                                                        //     Icon(Icons.call,
                                                        //         color:
                                                        //             Colors.white),
                                                        //     SizedBox(width: 10),
                                                        //     Text(
                                                        //         PreferenceUtils
                                                        //             .getString(Constants
                                                        //                 .user_phone_no),
                                                        //         style: TextStyle(
                                                        //             color: Constants
                                                        //                 .whitetext,
                                                        //             fontSize: 16,
                                                        //             fontFamily:
                                                        //                 Constants
                                                        //                     .app_font_bold)),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                    // InkWell(
                                                    //   onTap: () {
                                                    //     setState(() {
                                                    //       full = false;
                                                    //       full1 = true;
                                                    //       vi_address = false;
                                                    //     });
                                                    //   },
                                                    //   child: Container(
                                                    //     margin: EdgeInsets.only(
                                                    //         left: 0, bottom: 0, right: 0),
                                                    //     child: SvgPicture.asset(
                                                    //         "images/map_zoom.svg"),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Container(
                                                  height: ScreenUtil()
                                                      .setHeight(150),
                                                  margin:
                                                      EdgeInsets.only(top: 20),
                                                  child: ListView.builder(
                                                      itemCount: 2,
                                                      itemBuilder:
                                                          (con, index) {
                                                        double linetop = 0;
                                                        double dottop = 0;
                                                        double statustop = 0;
                                                        Color? color;
                                                        Color dotcolor;

                                                        if (index == 0) {
                                                          dotcolor = Constants
                                                              .color_theme;
                                                        }

                                                        if (index == 1) {
                                                          linetop = -30.0;
                                                          dottop = -42.0;
                                                          statustop = -35.0;
                                                          color = Constants
                                                              .color_theme;
                                                          dotcolor = Constants
                                                              .color_theme;
                                                        }

                                                        return index != 0
                                                            ? Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                    Row(
                                                                        children: [
                                                                          Column(
                                                                            children:
                                                                                List.generate(
                                                                              4,
                                                                              (ii) => Padding(
                                                                                padding: EdgeInsets.only(left: 9, right: 10, top: 0, bottom: 0),
                                                                                child: Container(
                                                                                  transform: Matrix4.translationValues(1.0, linetop, 0.0),
                                                                                  height: 20,
                                                                                  width: 2,
                                                                                  color: color,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                              child: Container(
                                                                            color:
                                                                                Colors.transparent,
                                                                            height:
                                                                                0.5,
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              left: 10,
                                                                              right: 20,
                                                                            ),
                                                                          ))
                                                                        ]),
                                                                    Row(
                                                                        children: [
                                                                          Container(
                                                                            transform: Matrix4.translationValues(
                                                                                3.0,
                                                                                dottop,
                                                                                0.0),
                                                                            child:
                                                                                SvgPicture.asset("images/kitchen.svg"),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              height: 60,
                                                                              color: Colors.transparent,
                                                                              transform: Matrix4.translationValues(20.0, statustop, 0.0),
                                                                              child: ListView(
                                                                                shrinkWrap: true,
                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(vendorname, style: TextStyle(color: Constants.whitetext, fontSize: 16, fontFamily: Constants.app_font_bold)),
                                                                                      Container(
                                                                                        margin: EdgeInsets.only(right: 35),
                                                                                        child: RichText(
                                                                                          maxLines: 2,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          textScaleFactor: 1,
                                                                                          text: TextSpan(
                                                                                            children: [
                                                                                              WidgetSpan(
                                                                                                child: Container(
                                                                                                  margin: EdgeInsets.only(left: 5, top: 0, bottom: 0, right: 5),
                                                                                                  child: SvgPicture.asset(
                                                                                                    "images/location.svg",
                                                                                                    width: 13,
                                                                                                    height: 13,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              WidgetSpan(
                                                                                                child: Container(
                                                                                                  margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 5),
                                                                                                  child: Text(
                                                                                                    distance + Languages.of(context)!.kmfarawaylable,
                                                                                                    style: TextStyle(
                                                                                                      color: Constants.whitetext,
                                                                                                      fontSize: 12,
                                                                                                      fontFamily: Constants.app_font,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Container(
                                                                                    margin: EdgeInsets.only(top: 2),
                                                                                    child: Text(vendorAddress, maxLines: 3, overflow: TextOverflow.visible, style: TextStyle(color: Constants.whitetext, fontSize: 12, fontFamily: Constants.app_font)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ])
                                                                  ])
                                                            : Row(children: [
                                                                Container(
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          2.0,
                                                                          -12,
                                                                          0.0),
                                                                  child: SvgPicture.asset(
                                                                      "images/map.svg",
                                                                      width: 20,
                                                                      height:
                                                                          20),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    height: 55,
                                                                    color: Colors
                                                                        .transparent,
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            20,
                                                                        top: 0,
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        ListView(
                                                                      shrinkWrap:
                                                                          true,
                                                                      physics:
                                                                          NeverScrollableScrollPhysics(),
                                                                      children: [
                                                                        Text(
                                                                            Languages.of(context)!
                                                                                .yourlocationlable,
                                                                            style: TextStyle(
                                                                                color: Constants.whitetext,
                                                                                fontSize: 16,
                                                                                fontFamily: Constants.app_font_bold)),
                                                                        Text(
                                                                            driver_address,
                                                                            maxLines:
                                                                                3,
                                                                            overflow: TextOverflow
                                                                                .visible,
                                                                            style: TextStyle(
                                                                                color: Constants.whitetext,
                                                                                fontSize: 12,
                                                                                fontFamily: Constants.app_font)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ]);
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            Visibility(
                              visible: isBtnLoader,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  full && getPickupBtnStatus() && !isBtnLoader,
                              child: new Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 40),
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    // child: Text(
                                    //   "data",
                                    //   style: TextStyle(fontSize: 50),
                                    // ),
                                    child: SlideAction(
                                      text: "Pickup the order",
                                      textStyle: TextStyle(
                                          fontFamily: Constants.app_font,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: Colors.white),
                                      // borderRadius: 10,
                                      height: 50,
                                      alignment: Alignment.bottomCenter,
                                      sliderButtonIconSize: 30,
                                      outerColor: Constants.color_theme,
                                      sliderButtonIconPadding: 5,
                                      onSubmit: () {
                                        print("Picked Up");
                                        Constants.CheckNetwork().whenComplete(
                                            () =>
                                                CallApiForPickUporder(context));
                                        setReachDestBtnStatus(true);
                                      },
                                    )),
                              ),
                            ),
                            Visibility(
                              visible:
                                  full && getReachBtnStatus() && !isBtnLoader,
                              child: new Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 40),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  // child: Text(
                                  //   "data",
                                  //   style: TextStyle(fontSize: 50),
                                  // ),
                                  child: SlideAction(
                                    textStyle: TextStyle(
                                        fontFamily: Constants.app_font,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: Colors.white),
                                    text: "Reached pickup location",
                                    // borderRadius: 10,
                                    height: 50,
                                    alignment: Alignment.bottomCenter,
                                    sliderButtonIconSize: 30,
                                    outerColor: Constants.color_theme,
                                    sliderButtonIconPadding: 5,
                                    onSubmit: () {
                                      print("Reached At Shop");
                                      setReachDestBtnStatus(false);
                                      setState(() {
                                        isBtnLoader = true;
                                      });
                                      Future.delayed(
                                        Duration(seconds: 3),
                                        () {
                                          setState(() {
                                            isBtnLoader = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: false,
                                child: new Container(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        child: GestureDetector(
                                      onTap: () {
                                        _OpenCancelBottomSheet(id, context);
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                  color: Constants.color_red,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                          0.0, 0.0), //(x,y)
                                                      blurRadius: 0.0,
                                                    ),
                                                  ],
                                                ),
                                                height: screenheight * 0.08,
                                                child: Center(
                                                  child: Container(
                                                    color: Constants.color_red,
                                                    child: Text(
                                                      Languages.of(context)!
                                                          .canceldeliverylable,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily: Constants
                                                              .app_font),
                                                    ),
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                Constants.CheckNetwork()
                                                    .whenComplete(() =>
                                                        CallApiForPickUporder(
                                                            context));
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    color:
                                                        Constants.color_theme,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(
                                                            0.0, 0.0), //(x,y)
                                                        blurRadius: 0.0,
                                                      ),
                                                    ],
                                                  ),
                                                  height: screenheight * 0.08,
                                                  child: Center(
                                                    child: Container(
                                                      color:
                                                          Constants.color_theme,
                                                      child: Text(
                                                        Languages.of(context)!
                                                            .pickupanddeliverlable,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                Constants
                                                                    .app_font),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  void _OpenCancelBottomSheet(String? id, BuildContext context12) {
    dynamic screenwidth = MediaQuery.of(context).size.width;
    dynamic screenheight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Constants.itembgcolor,
        builder: (context1) {
          return StatefulBuilder(
            builder: (context1, setState) {
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
                              margin: EdgeInsets.only(
                                  top: 10, left: 10, bottom: 0, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    can_reason[position],
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        color: Constants.greaytext,
                                        fontSize: 12,
                                        fontFamily: Constants.app_font),
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
                          if (_cancelReason == "0") {
                            Constants.toastMessage(
                                Languages.of(context)!.selectcancelreasonlable);
                          } else if (_cancelReason ==
                              Languages.of(context)!.otherreasonlable) {
                            if (_text_cancel_reason_controller.text
                                    .trim()
                                    .length ==
                                0) {
                              Constants.toastMessage(
                                  Languages.of(context)!.addreasonlable);
                            } else {
                              _cancelReason =
                                  _text_cancel_reason_controller.text;
                            }
                          } else {
                            Constants.CheckNetwork().whenComplete(() =>
                                CallApiForCacelorder(
                                    id, _cancelReason, context12));
                            Navigator.pop(context12);
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void onMapCreated(GoogleMapController googleMapController) {
    check().then((intenet) async {
      if (intenet) {
        setState(() {
          showSpinner = true;
        });

        try {
          _controller.complete(googleMapController);

          PolylinePoints polylinePoints = PolylinePoints();
          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
                  Constants.androidKey,
                  PointLatLng(driver_lat!, driver_lang!),
                  PointLatLng(vendor_lat, vendor_lang));
          print(result.points);
          if (result.points.isNotEmpty) {
            result.points.forEach((PointLatLng point) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            });
          }

          PolylineId id = PolylineId("poly");
          Polyline polyline = Polyline(
              polylineId: id, color: Colors.green, points: polylineCoordinates);
          polylines[id] = polyline;
        } catch (e) {
          print(e.toString());
        }

        setState(() {
          showSpinner = false;
        });
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text(Languages.of(context)!.checkinternetlable),
            content: Text(Languages.of(context)!.internetconnectionlable),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewGetOrderKitchen(),
                      ));
                },
                child: Text(Languages.of(context)!.oklable),
              )
            ],
          ),
          context: context,
        );
      }
    });
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Widget noMapOrderView() {
    final newOrderId = orderId;
    // final prefixId  = newOrderId;
    final prefixId = newOrderId.substring(0, newOrderId.length - 4);
    final suffixId = newOrderId.substring(newOrderId.length - 4);

    return Visibility(
      visible: vi_address,
      child: Container(
        height: MediaQuery.of(context).size.height * .75,
        margin: EdgeInsets.only(left: 20, top: 10, bottom: 60),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
            ),
            // Spacer(),
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Container(
                      child: Text(
                        Languages.of(context)!.oidlable + "   " + prefixId,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  WidgetSpan(
                    child: Container(
                      child: Text(
                        suffixId,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 50,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Spacer(),
            Expanded(
              child: Container(
                height: ScreenUtil().setHeight(150),
                margin: EdgeInsets.only(top: 20),
                child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (con, index) {
                      double linetop = 0;
                      double dottop = 0;
                      double statustop = 0;
                      Color? color;
                      Color dotcolor;

                      if (index == 0) {
                        dotcolor = Constants.color_theme;
                      }

                      if (index == 1) {
                        linetop = -30.0;
                        dottop = -42.0;
                        statustop = -35.0;
                        color = Constants.color_theme;
                        dotcolor = Constants.color_theme;
                      }

                      return index != 0
                          ? Column(mainAxisSize: MainAxisSize.min, children: [
                              Row(children: [
                                Column(
                                  children: List.generate(
                                    4,
                                    (ii) => Padding(
                                      padding: EdgeInsets.only(
                                          left: 9,
                                          right: 10,
                                          top: 0,
                                          bottom: 0),
                                      child: Container(
                                        transform: Matrix4.translationValues(
                                            1.0, linetop, 0.0),
                                        height: 20,
                                        width: 2,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  color: Colors.transparent,
                                  height: 0.5,
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 20,
                                  ),
                                ))
                              ]),
                              Row(children: [
                                Container(
                                  transform: Matrix4.translationValues(
                                      3.0, dottop, 0.0),
                                  child: SvgPicture.asset("images/kitchen.svg"),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 60,
                                    color: Colors.transparent,
                                    transform: Matrix4.translationValues(
                                        20.0, statustop, 0.0),
                                    child: ListView(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(vendorname,
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 16,
                                                    fontFamily: Constants
                                                        .app_font_bold)),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 35),
                                              child: RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textScaleFactor: 1,
                                                text: TextSpan(
                                                  children: [
                                                    WidgetSpan(
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5,
                                                            top: 0,
                                                            bottom: 0,
                                                            right: 5),
                                                        child: SvgPicture.asset(
                                                          "images/location.svg",
                                                          width: 13,
                                                          height: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    WidgetSpan(
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 0,
                                                            top: 0,
                                                            bottom: 0,
                                                            right: 5),
                                                        child: Text(
                                                          distance +
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
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 2,right: 30),
                                          child: Text(vendorAddress,
                                              maxLines: 3,
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                  color: Constants.whitetext,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      Constants.app_font)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                              Builder(builder: (context) {
                                final encode = PreferenceUtils.getString(
                                    Constants.previos_order_items);
                                final decode = jsonDecode(encode);
                                List<OrderItems> orderItems = <OrderItems>[];
                                decode.forEach((v) {
                                  orderItems.add(OrderItems.fromJson(v));
                                });

                                return ListView.builder(
                                  itemCount: orderItems.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, position) {
                                    return Container(
                                      margin:
                                          EdgeInsets.only(top: 10, left: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            orderItems[position].itemName!,
                                            style: TextStyle(
                                              color: Constants.greaytext,
                                              fontFamily: Constants.app_font,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "  x " +
                                                orderItems[position]
                                                    .qty
                                                    .toString(),
                                            style: TextStyle(
                                              color: Constants.color_theme,
                                              fontFamily: Constants.app_font,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ])
                          : Row(children: [
                              Container(
                                transform:
                                    Matrix4.translationValues(2.0, -12, 0.0),
                                child: SvgPicture.asset("images/map.svg",
                                    width: 20, height: 20),
                              ),
                              Expanded(
                                child: Container(
                                  height: 55,
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(
                                      left: 20, top: 0, right: 10),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Text(
                                          Languages.of(context)!
                                              .yourlocationlable,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.app_font_bold)),
                                      Text(driver_address,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontSize: 12,
                                              fontFamily: Constants.app_font)),
                                    ],
                                  ),
                                ),
                              )
                            ]);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0.0),
                    color: Constants.color_red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0), //(x,y)
                        blurRadius: 0.0,
                      ),
                    ],
                  ),
                  height: screenHeight * 0.08,
                  child: Center(
                    child: Container(
                      color: Constants.color_red,
                      child: Text(
                        Languages.of(context)!.canceldeliverylable,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: Constants.app_font),
                      ),
                    ),
                  )),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PickUpOrder()));
                },
                child: Container(
                    margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.0),
                      color: Constants.color_theme,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0), //(x,y)
                          blurRadius: 0.0,
                        ),
                      ],
                    ),
                    height: screenHeight * 0.08,
                    child: Center(
                      child: Container(
                        color: Constants.color_theme,
                        child: Text(
                          Languages.of(context)!.pickupanddeliverlable,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: Constants.app_font),
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

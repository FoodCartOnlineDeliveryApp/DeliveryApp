import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/orderdeliverdscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:slide_to_act_reborn/slide_to_act_reborn.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/current_order.dart';

class PickUpOrder extends StatefulWidget {
  @override
  _PickUpOrder createState() => _PickUpOrder();
}

class _PickUpOrder extends State<PickUpOrder> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  double heigntValue = 300;
  bool vi_footer = true;
  bool vi_combtn = false;
  bool vi_address = true;
  bool showSpinner = false;
  String driver_address = "Not Found";
  String? id;
  late String orderId;
  late String vendorname;
  late String vendorAddress;
  String? distance;
  late String username;
  String user_distance = "0";
  late String useraddress;

  Timer? timer;

  int second = 10;
  double? driver_lat;
  double? driver_lang;

  double? user_lat;
  double? user_lang;

  Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  late LocationData currentLocation;
  Location? location;
  double CAMERA_ZOOM = 14.4746;
  double CAMERA_TILT = 80;
  double CAMERA_BEARING = 30;
  bool cashCollected = false;

  @override
  void initState() {
    super.initState();

    location = new Location();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    _getCurrentLocation();

    if (Constants.currentlat != 0.0 && Constants.currentlong != 0.0) {
      setState(() {
        if (PreferenceUtils.getString(Constants.previos_order_user_lat) != '') {
          user_lat = double.parse(
              PreferenceUtils.getString(Constants.previos_order_user_lat));
          user_lang = double.parse(
              PreferenceUtils.getString(Constants.previos_order_user_lang));
        } else {
          user_lat = 0.0;
          user_lang = 0.0;
        }

        assert(user_lat is double);
        assert(user_lang is double);

        driver_lat = Constants.currentlat;
        driver_lang = Constants.currentlong;

        String str = Constants.calculateDistance(
                driver_lat!, driver_lang!, user_lat!, user_lang!)
            .toString();
        var distance12 = str.split('.');
        user_distance = distance12[0];

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
          addMarker(LatLng(user_lat!, user_lang!), "destination", customIcon1);
        });

        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
                  _getCurrentLocation();
                }));

        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: second), (Timer t) {
                  _getCurrentLocation();
                  PostDriverLocation(driver_lat, driver_lang);
                }));
      });
    } else {}
    if (mounted) {
      setState(() {
        id = PreferenceUtils.getString(Constants.previos_order_id);
        orderId = PreferenceUtils.getString(Constants.previos_order_orderid);
        vendorname =
            PreferenceUtils.getString(Constants.previos_order_vendor_name);
        vendorAddress =
            PreferenceUtils.getString(Constants.previos_order_vendor_address);
        distance = PreferenceUtils.getString(Constants.previos_order_distance);
        username = PreferenceUtils.getString(Constants.previos_order_user_name);
        useraddress =
            PreferenceUtils.getString(Constants.previos_order_user_address);
        if (PreferenceUtils.getString(Constants.previos_order_user_lat) != '') {
          user_lat = double.parse(
              PreferenceUtils.getString(Constants.previos_order_user_lat));
          user_lang = double.parse(
              PreferenceUtils.getString(Constants.previos_order_user_lang));
        } else {
          user_lat = 0.0;
          user_lang = 0.0;
        }
        assert(user_lat is double);
        assert(user_lang is double);
      });
    }

    setState(() {
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {
                driver_address = value;
              }));
    });
    location!.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
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

  void CallApiForDeliverorder(BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    if (mounted) {
      RestClient(ApiHeader().dioData())
          .orderStatusChange1(id, "COMPLETE")
          .then((response) {
        final body = json.decode(response!);
        bool? sucess = body['success'];
        if (sucess = true) {
          setState(() {
            showSpinner = false;
          });
          setState(() {
            PreferenceUtils.setString(
                Constants.previos_order_status, "COMPLETE");
          });

          setState(() {
            timer?.cancel();
          });

          Navigator.of(this.context)
              .push(MaterialPageRoute(builder: (context) => OrderDeliverd()));
        } else if (sucess == false) {
          var msg = Languages.of(context)!.tryagainlable;
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
        print(obj.runtimeType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;

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
                        Container(
                          margin: EdgeInsets.only(bottom: 00),
                          child: Column(
                            children: <Widget>[
                              // Expanded(
                              //   flex: 3,
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: screenHeight * 0.3,
                                child: Stack(
                                  children: [
                                    Container(
                                      child: GoogleMap(
                                          mapType: MapType.normal,
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                                driver_lat!, driver_lang!),
                                            zoom: 14.4746,
                                          ),
                                          myLocationEnabled: true,
                                          tiltGesturesEnabled: true,
                                          compassEnabled: true,
                                          scrollGesturesEnabled: true,
                                          zoomGesturesEnabled: true,
                                          markers:
                                              Set<Marker>.of(markers.values),
                                          polylines: Set<Polyline>.of(
                                              polylines.values),
                                          onMapCreated: onMapCreated),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      margin:
                                          EdgeInsets.only(right: 20, top: 10),
                                      child: ElevatedButton(
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
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 10.0, 10.0, 10.0),
                                          child: Text(
                                            'Go To Map',
                                            style: TextStyle(
                                                fontFamily: Constants.app_font,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (user_lat != null &&
                                              user_lang != null) {
                                            openMap(user_lat, user_lang);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    vi_footer = true;
                                    vi_combtn = false;
                                    vi_address = true;
                                  });
                                },
                                child: Visibility(
                                  visible: vi_combtn,
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    margin: EdgeInsets.only(
                                        left: 0, bottom: 5, right: 10),
                                    child:
                                        SvgPicture.asset("images/map_zoom.svg"),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                child: Visibility(
                                  visible: vi_address,
                                  child: Container(
                                    // height: ScreenUtil().setHeight(220),
                                    margin: EdgeInsets.only(
                                        left: 20, top: 10, bottom: 0),
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Builder(builder: (context) {
                                                  final newOrderId = orderId;
                                                  final prefixId =
                                                      newOrderId.substring(
                                                          0,
                                                          newOrderId.length -
                                                              4);
                                                  final suffixId =
                                                      newOrderId.substring(
                                                          newOrderId.length -
                                                              4);
                                                  return RichText(
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor: 1,
                                                    text: TextSpan(
                                                      children: [
                                                        WidgetSpan(
                                                          child: Container(
                                                            child: Text(
                                                              Languages.of(
                                                                          context)!
                                                                      .oidlable +
                                                                  "   " +
                                                                  prefixId,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                          child: Container(
                                                            child: Text(
                                                              suffixId,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                // Container(
                                                //   alignment: Alignment.topLeft,
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
                                                // Row(
                                                //   children: [
                                                //     Icon(Icons.call,
                                                //         color: Colors.white),
                                                //     SizedBox(width: 10),
                                                //     Text(
                                                //         PreferenceUtils
                                                //             .getString(Constants
                                                //                 .user_phone_no),
                                                //         style: TextStyle(
                                                //             color: Constants
                                                //                 .whitetext,
                                                //             fontSize: 16,
                                                //             fontFamily: Constants
                                                //                 .app_font_bold)),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              height: 30,
                                              child: Text(
                                                "${PreferenceUtils.getString(Constants.currencySymbol)}${PreferenceUtils.getString(Constants.previos_order_amount)}",
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w800,
                                                    fontFamily: Constants
                                                        .app_font_bold),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  vi_footer = false;
                                                  vi_combtn = true;
                                                  vi_address = false;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 10,
                                                ),
                                                child: SvgPicture.asset(
                                                    "images/map_zoom.svg"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.color_theme,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              child: Text(
                                                PreferenceUtils.getString(
                                                    Constants
                                                        .previos_order_pay_type),
                                                style: TextStyle(
                                                    color: Constants.whitetext,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    fontFamily: Constants
                                                        .app_font_bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: ScreenUtil().setHeight(130),
                                          margin: EdgeInsets.only(top: 20),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: 2,
                                              itemBuilder: (con, index) {
                                                double linetop = 0;
                                                double dottop = 0;
                                                double statustop = 0;
                                                Color? color;
                                                Color dotcolor;

                                                if (index == 0) {
                                                  dotcolor =
                                                      Constants.color_theme;
                                                }

                                                if (index == 1) {
                                                  linetop = -30.0;
                                                  dottop = -42.0;
                                                  statustop = -35.0;
                                                  color = Constants.color_theme;
                                                  dotcolor =
                                                      Constants.color_theme;
                                                }

                                                return index != 0
                                                    ? Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                            Row(children: [
                                                              Column(
                                                                children: List
                                                                    .generate(
                                                                  4,
                                                                  (ii) =>
                                                                      Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 9,
                                                                        right:
                                                                            10,
                                                                        top: 0,
                                                                        bottom:
                                                                            0),
                                                                    child:
                                                                        Container(
                                                                      transform: Matrix4.translationValues(
                                                                          1.0,
                                                                          linetop,
                                                                          0.0),
                                                                      height:
                                                                          20,
                                                                      width: 2,
                                                                      color:
                                                                          color,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      Container(
                                                                color: Colors
                                                                    .transparent,
                                                                height: 0.5,
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 10,
                                                                  right: 20,
                                                                ),
                                                              ))
                                                            ]),
                                                            Row(children: [
                                                              Container(
                                                                transform: Matrix4
                                                                    .translationValues(
                                                                        3.0,
                                                                        dottop,
                                                                        0.0),
                                                                child: SvgPicture
                                                                    .asset(
                                                                        "images/kitchen.svg"),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  color: Colors
                                                                      .transparent,
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          20.0,
                                                                          statustop,
                                                                          0.0),
                                                                  child:
                                                                      ListView(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              username,
                                                                              style: TextStyle(color: Constants.whitetext, fontSize: 16, fontFamily: Constants.app_font_bold)),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(right: 35),
                                                                            child:
                                                                                RichText(
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
                                                                                        user_distance + " " + Languages.of(context)!.kmfarawaylable,
                                                                                        maxLines: 4,
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
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2),
                                                                        child: Text(
                                                                            useraddress,
                                                                            maxLines:
                                                                                3,
                                                                            overflow: TextOverflow
                                                                                .visible,
                                                                            style: TextStyle(
                                                                                color: Constants.whitetext,
                                                                                fontSize: 12,
                                                                                fontFamily: Constants.app_font)),
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
                                                              height: 20),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 55,
                                                            color: Colors
                                                                .transparent,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    top: 0,
                                                                    right: 10),
                                                            child: ListView(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              children: [
                                                                Text(vendorname,
                                                                    style: TextStyle(
                                                                        color: Constants
                                                                            .whitetext,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            Constants.app_font_bold)),
                                                                Text(
                                                                    vendorAddress,
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                    style: TextStyle(
                                                                        color: Constants
                                                                            .whitetext,
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            Constants.app_font)),
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
                              Expanded(
                                child: Builder(builder: (context) {
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
                                    physics: AlwaysScrollableScrollPhysics(),
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
                                                fontSize: 22,
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
                                                fontSize: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                              // if (PreferenceUtils.getString(
                              //             Constants.previos_order_pay_type)
                              //         .toUpperCase() ==
                              //     "COD")
                              //   SizedBox(
                              //     height: 15,
                              //   ),
                              if (PreferenceUtils.getString(
                                          Constants.previos_order_pay_type)
                                      .toUpperCase() ==
                                  "COD")
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Cash collected",
                                        style: TextStyle(
                                            fontFamily: Constants.app_font,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 26.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Checkbox(
                                            activeColor: Colors.transparent,
                                            fillColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) =>
                                                        Constants.color_theme),
                                            checkColor: Constants.whitetext,
                                            overlayColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) => Colors.white),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.padded,
                                            value: cashCollected,
                                            onChanged: (val) {
                                              setState(() {
                                                cashCollected = val!;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              if (PreferenceUtils.getString(
                                          Constants.previos_order_pay_type)
                                      .toUpperCase() ==
                                  "COD")
                                SizedBox(
                                  height: 25,
                                ),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: vi_footer,
                            child: new Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 20),
                                  child: IgnorePointer(
                                    ignoring: !cashCollected,
                                    child: SlideAction(
                                      text: Languages.of(context)!
                                          .completeorderlable,
                                      textStyle: TextStyle(
                                          fontFamily: Constants.app_font,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: Colors.white),
                                      // borderRadius: 10,
                                      height: 50,
                                      alignment: Alignment.bottomCenter,
                                      sliderButtonIconSize: 30,
                                      outerColor: cashCollected
                                          ? Constants.color_theme
                                          : Colors.grey,
                                      sliderButtonIconPadding: 5,
                                      onSubmit: () {
                                        if (cashCollected) {
                                          print("Picked Up");
                                          Constants.CheckNetwork().whenComplete(
                                              () => CallApiForDeliverorder(
                                                  this.context));
                                          PreferenceUtils.setString(
                                              'pickup_btn_status', "pickup");
                                        } else {
                                          print("Collect cash");
                                        }
                                        // Constants.CheckNetwork().whenComplete(
                                        //     () => CallApiForPickUporder(context));
                                        // setReachDestBtnStatus(true);
                                      },
                                    ),
                                  ),
                                  // child: InkWell(
                                  //   onTap: () {
                                  //     Constants.CheckNetwork().whenComplete(
                                  //         () => CallApiForDeliverorder(
                                  //             this.context));
                                  //   },
                                  //   child: Container(
                                  //       margin: EdgeInsets.only(
                                  //           left: 0, right: 0, bottom: 0),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(0.0),
                                  //         color: Constants.color_theme,
                                  //         boxShadow: [
                                  //           BoxShadow(
                                  //             color: Colors.grey,
                                  //             offset: Offset(0.0, 0.0),
                                  //             //(x,y)
                                  //             blurRadius: 0.0,
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       height: screenHeight * 0.08,
                                  //       child: Center(
                                  //         child: Container(
                                  //           color: Constants.color_theme,
                                  //           child: Text(
                                  //             Languages.of(context)!
                                  //                 .completeorderlable,
                                  //             style: TextStyle(
                                  //                 color: Colors.white,
                                  //                 fontSize: 16,
                                  //                 fontFamily:
                                  //                     Constants.app_font),
                                  //           ),
                                  //         ),
                                  //       )),
                                  // ),
                                ),
                              ),
                            )),
                      ],
                    );
                  },
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void onMapCreated(GoogleMapController googleMapController) async {
    check().then((intenet) async {
      if (intenet) {
        setState(() {
          showSpinner = true;
        });

        String platform = 'android';
        if (Platform.isAndroid) {
          platform = Constants.androidKey;
        } else if (Platform.isIOS) {
          platform = Constants.iosKey;
        }
        try {
          _controller.complete(googleMapController);

          PolylinePoints polylinePoints = PolylinePoints();
          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
                  platform,
                  PointLatLng(driver_lat!, driver_lang!),
                  PointLatLng(user_lat!, user_lang!));
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
                        builder: (context) => PickUpOrder(),
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

  _getCurrentLocation() {
    Constants.currentlatlong().then((value) {
      setState(() {
        driver_lat = value!.latitude;
        driver_lang = value.longitude;
      });
    });
  }

  static Future<void> openMap(double? latitude, double? longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    String urlAppleMaps = "https://maps.apple.com/?query=$latitude,$longitude";
    if (Platform.isAndroid) {
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    } else {
      if (await canLaunch(urlAppleMaps)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }
  }
}

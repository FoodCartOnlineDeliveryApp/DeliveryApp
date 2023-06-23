import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/orderhistory.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class History extends StatefulWidget {

  @override
  _History createState() => _History();

}

class _History extends State<History> with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool showSpinner = false;
  TabController? controller;

  TextEditingController com_controller = new TextEditingController();
  TextEditingController can_controller = new TextEditingController();

  Color seltabtext = Constants.color_theme;
  Color seltanindicator = Constants.color_theme;

  int seltabindex = 0;
  List<Complete> comsearchlist = <Complete>[];
  List<Cancel> cansearchlist = <Cancel>[];

  List<Complete> comporderdatalist = <Complete>[];
  List<Cancel> canorderdatalist = <Cancel>[];

  double current_lat = 0;
  double current_long = 0;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    controller = TabController(length: 2, vsync: this);

    if (mounted) {
      setState(() {
        Constants.currentlatlong()
            .whenComplete(() => Constants.currentlatlong().then((origin) {
                  PreferenceUtils.setString(Constants.lat, origin!.latitude.toString());
                  PreferenceUtils.setString(Constants.long, origin.longitude.toString());
                }));
      });
    }
    current_lat = double.parse(PreferenceUtils.getString(Constants.lat));
    current_long = double.parse(PreferenceUtils.getString(Constants.long));

    if (mounted) {
      Constants.CheckNetwork().whenComplete(() => CallApiForGetOrderHistory());
    }
  }

  Future<void> CallApiForGetOrderHistory() async {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).driverOrderHistory().then((response) {
      if (mounted) {
        setState(() {
          if (response.success = true) {
            if (response.data!.complete != 0) {
              comporderdatalist.addAll(response.data!.complete!);
              setState(() {
                showSpinner = false;
              });
            } else {
              setState(() {
                showSpinner = false;
                Constants.toastMessage(Languages.of(context)!.nodatalable);
                Constants.createSnackBar(Languages.of(context)!.nodatalable,
                    this.context, Constants.color_theme);
              });
            }

            if (response.data!.cancel != 0) {
              canorderdatalist.addAll(response.data!.cancel!);
              setState(() {
                showSpinner = false;
              });
            } else {
              setState(() {
                showSpinner = false;
              });
            }
          } else {
            final snackBar = SnackBar(
              content: Text(Languages.of(context)!.servererrorlable),
              backgroundColor: Constants.color_red,
            );
            Fluttertoast.showToast(msg: snackBar.toString());
            // _scaffoldKey.currentState!.showSnackBar(snackBar);

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
      Fluttertoast.showToast(msg:snackBar.toString());
      // _scaffoldKey.currentState!.showSnackBar(snackBar);

      print("error:$obj");
      print(obj.runtimeType);

      setState(() {
        showSpinner = false;
      });
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
            image: AssetImage('images/background_image.png'),
            fit: BoxFit.cover,
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              // resizeToAvoidBottomPadding: true,
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(
                  Languages.of(context)!.historylable,
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
              body: RefreshIndicator(
                color: Constants.color_theme,
                backgroundColor: Colors.transparent,
                onRefresh: CallApiForGetOrderHistory,
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
                        physics: NeverScrollableScrollPhysics(),
                        child: Container(
                          height: screenheight,
                          margin: EdgeInsets.only(bottom: 00),
                          color: Colors.transparent,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: ScreenUtil().setHeight(40),
                                color: Colors.transparent,
                                child: Container(
                                  height: ScreenUtil().setHeight(30),
                                  transform:
                                      Matrix4.translationValues(0.0, -0.0, 0.0),
                                  color: Colors.transparent,
                                  child: TabBar(
                                    onTap: (tabIndex) {
                                      setState(() {
                                        seltabindex = tabIndex;
                                        if (tabIndex == 0) {
                                          seltabindex = tabIndex;
                                          seltabtext =
                                              Constants.color_theme;
                                          seltanindicator =
                                              Constants.color_theme;
                                        } else {
                                          seltabindex = tabIndex;
                                          seltabtext = Constants.color_red;
                                          seltanindicator =
                                              Constants.color_red;
                                        }
                                      });
                                    },
                                    labelColor: seltabtext,
                                    unselectedLabelColor: Colors.white,
                                    labelStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Constants.app_font),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicatorPadding:
                                        EdgeInsets.only(left: 5, right: 5),
                                    indicatorColor: seltanindicator,
                                    indicatorWeight: 5.0,
                                    tabs: [
                                      Tab(
                                        text: Languages.of(context)!
                                            .completedtablable,
                                      ),
                                      new Tab(
                                        text: Languages.of(context)!
                                            .canceltablable,
                                      ),
                                    ],
                                    controller: controller,
                                  ),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: Card(
                                  color: Constants.light_black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.name,
                                      onChanged: seltabindex == 0
                                          ? ComSearchTextChanged
                                          : CanSearchTextChanged,
                                      controller: seltabindex == 0
                                          ? com_controller
                                          : can_controller,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: Constants.app_font_bold),
                                      decoration: Constants
                                          .kTextFieldInputDecoration1
                                          .copyWith(
                                              hintText: Languages.of(context)!
                                                  .searchorderidlable),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 10, right: 5, bottom: 90, left: 5),
                                  child: TabBarView(
                                      controller: controller,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: <Widget>[

                                        Container(
                                            child: com_controller.text.isNotEmpty
                                                    ? comsearchlist.length > 0 ?  ListView.builder(
                                                        itemCount: comsearchlist
                                                            .length,
                                                        shrinkWrap: true,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemBuilder:
                                                            (context, index) {
                                                          String paymentstatus;
                                                          Color paymentcolor;
                                                          if (comsearchlist[
                                                                      index]
                                                                  .paymentStatus
                                                                  .toString() ==
                                                              "0") {
                                                            paymentstatus =
                                                                "Pending";
                                                            paymentcolor =
                                                                Constants
                                                                    .color_red;
                                                          } else {
                                                            paymentstatus =
                                                                "Completed";
                                                            paymentcolor =
                                                                Constants
                                                                    .color_theme;
                                                          }

                                                          double user_lat =
                                                              double.parse(
                                                                  comsearchlist[
                                                                          index]
                                                                      .userAddress!
                                                                      .lat!);
                                                          double user_long =
                                                              double.parse(
                                                                  comsearchlist[
                                                                          index]
                                                                      .userAddress!
                                                                      .lang!);

                                                          double vendorlat = double.parse(comsearchlist[index].vendor!.lat!);
                                                          double vendorlong = double.parse(comsearchlist[index].vendor!.lang!);
                                                          assert(user_lat
                                                              is double);
                                                          assert(user_long
                                                              is double);
                                                          String distance = "0";
                                                          String str = Constants.calculateDistance(vendorlat,vendorlong, user_lat, user_long).toString();
                                                          var distance12 = str.split('.');
                                                          distance = distance12[0];

                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .all(ScreenUtil()
                                                                    .setWidth(
                                                                        8)),
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      right: 5,
                                                                      bottom: 0,
                                                                      left: 5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: 
                                                                          Constants
                                                                              .itembgcolor,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: 
                                                                            Constants.itembgcolor,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(12))),
                                                              child: Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil()
                                                                        .setWidth(
                                                                            0),
                                                                    right: ScreenUtil()
                                                                        .setWidth(
                                                                            0)),
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              Languages.of(context)!.oidlable + "   " + comsearchlist[index].orderId!,
                                                                              style: TextStyle(color: Colors.white, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            ),
                                                                            Text(
                                                                                '${PreferenceUtils.getString(Constants.currencySymbol)} ${comsearchlist[index].amount.toString()}',
                                                                              style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        itemCount: comsearchlist[index]
                                                                            .orderItems!
                                                                            .length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        itemBuilder:
                                                                            (context,
                                                                                position) {
                                                                          return Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 10, left: 10),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  comsearchlist[index].orderItems![position].itemName!,
                                                                                  style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "  x " + comsearchlist[index].orderItems![position].qty.toString(),
                                                                                  style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font, fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                      color: Colors.transparent,
                                                                                      border: Border.all(
                                                                                        color: Colors.transparent,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                                  margin: EdgeInsets.only(top: 5, left: 0, right: 5, bottom: 30),
                                                                                  alignment: Alignment.center,
                                                                                  child: CachedNetworkImage(
                                                                                    // imageUrl: imageurl,

                                                                                    imageUrl: comsearchlist[index].vendor!.image!,
                                                                                    fit: BoxFit.fill,
                                                                                    width: screenwidth * 0.15,
                                                                                    height: screenheight * 0.09,

                                                                                    imageBuilder: (context, imageProvider) => ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                                      child: Image(
                                                                                        image: imageProvider,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Constants.color_theme),
                                                                                    errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 4,
                                                                              child: Container(
                                                                                height: screenheight * 0.15,
                                                                                color: Constants.itembgcolor,
                                                                                margin: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          alignment: Alignment.topLeft,
                                                                                          child: AutoSizeText(
                                                                                            comsearchlist[index].vendor!.name!,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.visible,
                                                                                            style: TextStyle(color: Constants.whitetext, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                                          ),
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Container(
                                                                                              margin: EdgeInsets.only(top: 0, left: 5, right: 10, bottom: 0),
                                                                                              alignment: Alignment.topRight,
                                                                                              child: SvgPicture.asset(
                                                                                                "images/veg.svg",
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              margin: EdgeInsets.only(top: 0, left: 0, right: 10, bottom: 0),
                                                                                              alignment: Alignment.topRight,
                                                                                              child: SvgPicture.asset(
                                                                                                "images/nonveg.svg",
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Container(
                                                                                      alignment: Alignment.topLeft,
                                                                                      margin: EdgeInsets.only(top: 10, left: 0, right: 5, bottom: 0),
                                                                                      color: Colors.transparent,
                                                                                      child: AutoSizeText(
                                                                                        comsearchlist[index].vendor!.mapAddress!,
                                                                                        overflow: TextOverflow.visible,
                                                                                        maxLines: 3,
                                                                                        style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 14),
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
                                                                            top:
                                                                                0,
                                                                            bottom:
                                                                                20,
                                                                            right:
                                                                                0,
                                                                            left:
                                                                                5),
                                                                        width:
                                                                            screenwidth,
                                                                        child:
                                                                            DottedLine(
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          lineLength:
                                                                              double.infinity,
                                                                          lineThickness:
                                                                              1.0,
                                                                          dashLength:
                                                                              8.0,
                                                                          dashColor:
                                                                              Constants.dashline,
                                                                          dashRadius:
                                                                              0.0,
                                                                          dashGapLength:
                                                                              5.0,
                                                                          dashGapColor:
                                                                              Colors.transparent,
                                                                          dashGapRadius:
                                                                              0.0,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              comsearchlist[index].user!.name!,
                                                                              style: TextStyle(color: Colors.white, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            ),
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
                                                                                        distance + " " + Languages.of(context)!.kmfarawaylable,
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
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          comsearchlist[index]
                                                                              .userAddress!
                                                                              .address!,
                                                                          overflow:
                                                                              TextOverflow.visible,
                                                                          maxLines:
                                                                              5,
                                                                          style: TextStyle(
                                                                              color: Constants.greaytext,
                                                                              fontFamily: Constants.app_font,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30,
                                                                            bottom:
                                                                                20,
                                                                            right:
                                                                                0,
                                                                            left:
                                                                                5),
                                                                        width:
                                                                            screenwidth,
                                                                        child:
                                                                            DottedLine(
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          lineLength:
                                                                              double.infinity,
                                                                          lineThickness:
                                                                              1.0,
                                                                          dashLength:
                                                                              8.0,
                                                                          dashColor:
                                                                              Constants.dashline,
                                                                          dashRadius:
                                                                              0.0,
                                                                          dashGapLength:
                                                                              5.0,
                                                                          dashGapColor:
                                                                              Colors.transparent,
                                                                          dashGapRadius:
                                                                              0.0,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            bottom:
                                                                                20),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: ListView(
                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                shrinkWrap: true,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                          margin: EdgeInsets.only(left: 0),
                                                                                          child: Text(
                                                                                            Languages.of(context)!.paymentlable,
                                                                                            style: TextStyle(color: Constants.whitetext, fontSize: 16, fontFamily: Constants.app_font_bold),
                                                                                          )),
                                                                                      Container(
                                                                                          margin: EdgeInsets.only(left: 5),
                                                                                          child: Text(
                                                                                            "(" + paymentstatus + ")",
                                                                                            style: TextStyle(color: paymentcolor, fontSize: 16, fontFamily: Constants.app_font_bold),
                                                                                          )),
                                                                                    ],
                                                                                  ),
                                                                                  Text(
                                                                                    Languages.of(context)!.cashondeliverylable,
                                                                                    style: TextStyle(color: Constants.greaytext, fontSize: 14, fontFamily: Constants.app_font),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: Container(
                                                                                    margin: EdgeInsets.only(top: 0, left: 0, right: 5, bottom: 0),
                                                                                    alignment: Alignment.topRight,
                                                                                    child: Text(
                                                                                      Languages.of(context)!.ordercompletesucesslable,
                                                                                      maxLines: 3,
                                                                                      overflow: TextOverflow.visible,
                                                                                      style: TextStyle(color: Constants.color_theme, fontSize: 14, fontFamily: Constants.app_font),
                                                                                    )),
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
                                                      ):Container(margin: EdgeInsets.only(top:30),alignment: Alignment.topCenter,child: Text('No Data Found',style: TextStyle(color: Colors.white),),)
                                                    : comporderdatalist.length > 0 ? ListView.builder(
                                                        itemCount:
                                                            comporderdatalist
                                                                .length,
                                                        shrinkWrap: true,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemBuilder:
                                                            (context, index) {
                                                          String paymentstatus;
                                                          Color paymentcolor;
                                                          if (comporderdatalist[
                                                                      index]
                                                                  .paymentStatus
                                                                  .toString() ==
                                                              "0") {
                                                            paymentstatus =
                                                                "Pending";
                                                            paymentcolor =
                                                                Constants
                                                                    .color_red;
                                                          } else {
                                                            paymentstatus =
                                                                "Completed";
                                                            paymentcolor =
                                                                Constants
                                                                    .color_theme;
                                                          }

                                                          double user_lat =
                                                              double.parse(
                                                                  comporderdatalist[
                                                                          index]
                                                                      .userAddress!
                                                                      .lat!);
                                                          double user_long =
                                                              double.parse(
                                                                  comporderdatalist[
                                                                          index]
                                                                      .userAddress!
                                                                      .lang!);
                                                          double vendorlat = double.parse(comporderdatalist[index].vendor!.lat!);
                                                          double vendorlong = double.parse(comporderdatalist[index].vendor!.lang!);
                                                          assert(user_lat
                                                              is double);
                                                          assert(user_long
                                                              is double);
                                                          String distance = "0";
                                                          String str = Constants.calculateDistance(vendorlat, vendorlong, user_lat, user_long).toString();
                                                          var distance12 = str.split('.');
                                                          distance = distance12[0];
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .all(ScreenUtil()
                                                                    .setWidth(
                                                                        8)),
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      right: 5,
                                                                      bottom: 0,
                                                                      left: 5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color:
                                                                          Constants
                                                                              .itembgcolor,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color:
                                                                            Constants.itembgcolor,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(12))),
                                                              child: Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil()
                                                                        .setWidth(
                                                                            0),
                                                                    right: ScreenUtil()
                                                                        .setWidth(
                                                                            0)),
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              Languages.of(context)!.oidlable + "  " + comporderdatalist[index].orderId!,
                                                                              style: TextStyle(color: Colors.white, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            ),
                                                                            Text(
                                                                              '${PreferenceUtils.getString(Constants.currencySymbol)} ${comporderdatalist[index].amount.toString()}',
                                                                              style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        itemCount: comporderdatalist[index]
                                                                            .orderItems!
                                                                            .length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        itemBuilder:
                                                                            (context,
                                                                                position) {
                                                                          return Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 10, left: 10),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  comporderdatalist[index].orderItems![position].itemName!,
                                                                                  style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "  x " + comporderdatalist[index].orderItems![position].qty.toString(),
                                                                                  style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font, fontSize: 12),
                                                                                ),

                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                      color: Colors.transparent,
                                                                                      border: Border.all(
                                                                                        color: Colors.transparent,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                                  margin: EdgeInsets.only(top: 5, left: 0, right: 5, bottom: 30),
                                                                                  alignment: Alignment.center,
                                                                                  child: CachedNetworkImage(

                                                                                    imageUrl: comporderdatalist[index].vendor!.image!,
                                                                                    fit: BoxFit.fill,
                                                                                    width: screenwidth * 0.15,
                                                                                    height: screenheight * 0.09,

                                                                                    imageBuilder: (context, imageProvider) => ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                                      child: Image(
                                                                                        image: imageProvider,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Constants.color_theme),
                                                                                    errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 4,
                                                                              child: Container(
                                                                                height: screenheight * 0.15,
                                                                                color: Constants.itembgcolor,
                                                                                margin: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          alignment: Alignment.topLeft,
                                                                                          child: AutoSizeText(
                                                                                            comporderdatalist[index].vendor!.name!,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.visible,
                                                                                            style: TextStyle(color: Constants.whitetext, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                                          ),
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Container(
                                                                                              margin: EdgeInsets.only(top: 0, left: 5, right: 10, bottom: 0),
                                                                                              alignment: Alignment.topRight,
                                                                                              child: SvgPicture.asset(
                                                                                                "images/veg.svg",
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              margin: EdgeInsets.only(top: 0, left: 0, right: 10, bottom: 0),
                                                                                              alignment: Alignment.topRight,
                                                                                              child: SvgPicture.asset(
                                                                                                "images/nonveg.svg",
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Container(
                                                                                      alignment: Alignment.topLeft,
                                                                                      margin: EdgeInsets.only(top: 10, left: 0, right: 5, bottom: 0),

                                                                                      color: Colors.transparent,
                                                                                      child: AutoSizeText(
                                                                                        comporderdatalist[index].vendor!.mapAddress ?? '',
                                                                                        overflow: TextOverflow.visible,
                                                                                        maxLines: 3,
                                                                                        style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 14),
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
                                                                            top:
                                                                                0,
                                                                            bottom:
                                                                                20,
                                                                            right:
                                                                                0,
                                                                            left:
                                                                                5),
                                                                        width:
                                                                            screenwidth,
                                                                        child:
                                                                            DottedLine(
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          lineLength:
                                                                              double.infinity,
                                                                          lineThickness:
                                                                              1.0,
                                                                          dashLength:
                                                                              8.0,
                                                                          dashColor:
                                                                              Constants.dashline,
                                                                          dashRadius:
                                                                              0.0,
                                                                          dashGapLength:
                                                                              5.0,
                                                                          dashGapColor:
                                                                              Colors.transparent,
                                                                          dashGapRadius:
                                                                              0.0,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              comporderdatalist[index].user!.name!,
                                                                              style: TextStyle(color: Colors.white, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                            ),
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
                                                                                        distance + " " + Languages.of(context)!.kmfarawaylable,
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
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          comporderdatalist[index]
                                                                              .userAddress!
                                                                              .address!,
                                                                          overflow:
                                                                              TextOverflow.visible,
                                                                          maxLines:
                                                                              5,
                                                                          style: TextStyle(
                                                                              color: Constants.greaytext,
                                                                              fontFamily: Constants.app_font,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30,
                                                                            bottom:
                                                                                20,
                                                                            right:
                                                                                0,
                                                                            left:
                                                                                5),
                                                                        width:
                                                                            screenwidth,
                                                                        child:
                                                                            DottedLine(
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          lineLength:
                                                                              double.infinity,
                                                                          lineThickness:
                                                                              1.0,
                                                                          dashLength:
                                                                              8.0,
                                                                          dashColor:
                                                                              Constants.dashline,
                                                                          dashRadius:
                                                                              0.0,
                                                                          dashGapLength:
                                                                              5.0,
                                                                          dashGapColor:
                                                                              Colors.transparent,
                                                                          dashGapRadius:
                                                                              0.0,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            bottom:
                                                                                20),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: ListView(
                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                shrinkWrap: true,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                          margin: EdgeInsets.only(left: 0),
                                                                                          child: Text(
                                                                                            Languages.of(context)!.paymentlable,
                                                                                            style: TextStyle(color: Constants.whitetext, fontSize: 16, fontFamily: Constants.app_font_bold),
                                                                                          )),
                                                                                      Container(
                                                                                          margin: EdgeInsets.only(left: 5),
                                                                                          child: Text(
                                                                                            "(" + paymentstatus + ")",
                                                                                            style: TextStyle(color: paymentcolor, fontSize: 16, fontFamily: Constants.app_font_bold),
                                                                                          )),
                                                                                    ],
                                                                                  ),
                                                                                  Text(
                                                                                    Languages.of(context)!.cashondeliverylable,
                                                                                    style: TextStyle(color: Constants.greaytext, fontSize: 14, fontFamily: Constants.app_font),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: Container(
                                                                                    margin: EdgeInsets.only(top: 0, left: 0, right: 5, bottom: 0),
                                                                                    alignment: Alignment.topRight,
                                                                                    child: Text(
                                                                                      Languages.of(context)!.ordercompletesucesslable,
                                                                                      maxLines: 3,
                                                                                      overflow: TextOverflow.visible,
                                                                                      style: TextStyle(color: Constants.color_theme, fontSize: 14, fontFamily: Constants.app_font),
                                                                                    )),
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
                                                      ) : Container(margin: EdgeInsets.only(top:30),alignment: Alignment.topCenter,child: Text('No Data Found',style: TextStyle(color: Colors.white),),

                                            ),),

                                        /*  Cancel List*/

                                        Container(
                                          child: can_controller.text.isNotEmpty
                                                  ? cansearchlist.length > 0 ? ListView.builder(
                                                      itemCount:
                                                          cansearchlist.length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        String paymentstatus;
                                                        Color paymentcolor;
                                                        if (cansearchlist[index]
                                                                .paymentStatus
                                                                .toString() ==
                                                            "0") {
                                                          paymentstatus =
                                                              "Pending";
                                                          paymentcolor =
                                                              Constants
                                                                  .color_red;
                                                        } else {
                                                          paymentstatus =
                                                              "Completed";
                                                          paymentcolor =
                                                              Constants
                                                                  .color_theme;
                                                        }

                                                        double user_lat =
                                                            double.parse(
                                                                cansearchlist[
                                                                        index]
                                                                    .userAddress!
                                                                    .lat!);
                                                        double user_long =
                                                            double.parse(
                                                                cansearchlist[
                                                                        index]
                                                                    .userAddress!
                                                                    .lang!);
                                                        double vendorlat = double.parse(cansearchlist[index].vendor!.lat!);
                                                        double vendorlong = double.parse(cansearchlist[index].vendor!.lang!);
                                                        assert(
                                                            user_lat is double);
                                                        assert(user_long
                                                            is double);
                                                        String distance = "0";
                                                        double distanceInMeters =  Constants.calculateDistance(vendorlat, vendorlong, user_lat, user_long);

                                                        double distanceinkm =
                                                            distanceInMeters /
                                                                1000;
                                                        String str =
                                                            distanceinkm
                                                                .toString();
                                                        var distance12 =
                                                            str.split('.');
                                                        distance =
                                                            distance12[0];
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .all(ScreenUtil()
                                                                  .setWidth(8)),
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    right: 5,
                                                                    bottom: 0,
                                                                    left: 5),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color:
                                                                        Constants
                                                                            .itembgcolor,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color:
                                                                          Constants
                                                                              .itembgcolor,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(12))),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: ScreenUtil()
                                                                      .setWidth(
                                                                          0),
                                                                  right: ScreenUtil()
                                                                      .setWidth(
                                                                          0)),
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            Languages.of(context)!.oidlable +
                                                                                "   " +
                                                                                cansearchlist[index].orderId!,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          ),
                                                                          Text(
                                                                            '${PreferenceUtils.getString(Constants.currencySymbol)} ${cansearchlist[index].amount.toString()}',
                                                                            style: TextStyle(
                                                                                color: Constants.color_theme,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    ListView
                                                                        .builder(
                                                                      itemCount: cansearchlist[
                                                                              index]
                                                                          .orderItems!
                                                                          .length,
                                                                      shrinkWrap:
                                                                          true,
                                                                      physics:
                                                                          NeverScrollableScrollPhysics(),
                                                                      itemBuilder:
                                                                          (context,
                                                                              position) {
                                                                        return Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: 10,
                                                                              left: 10),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                cansearchlist[index].orderItems![position].itemName!,
                                                                                style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 12),
                                                                              ),
                                                                              Text(
                                                                                "  x " + cansearchlist[index].orderItems![position].qty.toString(),
                                                                                style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font, fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                    color: Colors.transparent,
                                                                                    border: Border.all(
                                                                                      color: Colors.transparent,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                                margin: EdgeInsets.only(top: 5, left: 0, right: 5, bottom: 30),
                                                                                alignment: Alignment.center,
                                                                                child: CachedNetworkImage(
                                                                                  // imageUrl: imageurl,

                                                                                  imageUrl: cansearchlist[index].vendor!.image!,
                                                                                  fit: BoxFit.fill,
                                                                                  width: screenwidth * 0.15,
                                                                                  height: screenheight * 0.09,

                                                                                  imageBuilder: (context, imageProvider) => ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                    child: Image(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  placeholder: (context, url) => SpinKitFadingCircle(color: Constants.color_theme),
                                                                                  errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child:
                                                                                Container(
                                                                              height: screenheight * 0.15,
                                                                              color: Constants.itembgcolor,
                                                                              margin: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        alignment: Alignment.topLeft,
                                                                                        child: AutoSizeText(
                                                                                          cansearchlist[index].vendor!.name!,
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.visible,
                                                                                          style: TextStyle(color: Constants.whitetext, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Container(
                                                                                            margin: EdgeInsets.only(top: 0, left: 5, right: 2, bottom: 0),
                                                                                            alignment: Alignment.topRight,
                                                                                            child: SvgPicture.asset(
                                                                                              "images/veg.svg",
                                                                                            ),
                                                                                          ),
                                                                                          Container(
                                                                                            margin: EdgeInsets.only(top: 0, left: 2, right: 10, bottom: 0),
                                                                                            alignment: Alignment.topRight,
                                                                                            child: SvgPicture.asset(
                                                                                              "images/nonveg.svg",
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Container(
                                                                                    alignment: Alignment.topLeft,
                                                                                    margin: EdgeInsets.only(top: 10, left: 0, right: 5, bottom: 0),

                                                                                    color: Colors.transparent,
                                                                                    child: AutoSizeText(
                                                                                      cansearchlist[index].vendor!.mapAddress!,
                                                                                      overflow: TextOverflow.visible,
                                                                                      maxLines: 3,
                                                                                      style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 14),
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
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              20,
                                                                          right:
                                                                              0,
                                                                          left:
                                                                              5),
                                                                      width:
                                                                          screenwidth,
                                                                      child:
                                                                          DottedLine(
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        lineLength:
                                                                            double.infinity,
                                                                        lineThickness:
                                                                            1.0,
                                                                        dashLength:
                                                                            8.0,
                                                                        dashColor:
                                                                            Constants.dashline,
                                                                        dashRadius:
                                                                            0.0,
                                                                        dashGapLength:
                                                                            5.0,
                                                                        dashGapColor:
                                                                            Colors.transparent,
                                                                        dashGapRadius:
                                                                            0.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            cansearchlist[index].user!.name!,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          ),
                                                                          RichText(
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textScaleFactor:
                                                                                1,
                                                                            text:
                                                                                TextSpan(
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
                                                                                      distance + " " + Languages.of(context)!.kmfarawaylable,
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
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              5,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        cansearchlist[index]
                                                                            .userAddress!
                                                                            .address!,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        maxLines:
                                                                            5,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Constants.greaytext,
                                                                            fontFamily: Constants.app_font,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              30,
                                                                          bottom:
                                                                              20,
                                                                          right:
                                                                              0,
                                                                          left:
                                                                              5),
                                                                      width:
                                                                          screenwidth,
                                                                      child:
                                                                          DottedLine(
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        lineLength:
                                                                            double.infinity,
                                                                        lineThickness:
                                                                            1.0,
                                                                        dashLength:
                                                                            8.0,
                                                                        dashColor:
                                                                            Constants.dashline,
                                                                        dashRadius:
                                                                            0.0,
                                                                        dashGapLength:
                                                                            5.0,
                                                                        dashGapColor:
                                                                            Colors.transparent,
                                                                        dashGapRadius:
                                                                            0.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              2,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              20),
                                                                      child:
                                                                          ListView(
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        shrinkWrap:
                                                                            true,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              if (mounted) {
                                                                                setState(() {
                                                                                  cansearchlist[index].arrowdown = !cansearchlist[index].arrowdown;
                                                                                  cansearchlist[index].arrowup = !cansearchlist[index].arrowup;
                                                                                  cansearchlist[index].reason = !cansearchlist[index].reason;
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                    margin: EdgeInsets.only(left: 0),
                                                                                    child: Text(
                                                                                      Languages.of(context)!.seereasoncancellable,
                                                                                      style: TextStyle(color: Constants.color_red, fontSize: 16, fontFamily: Constants.app_font),
                                                                                    )),
                                                                                Visibility(
                                                                                  visible: cansearchlist[index].arrowdown,
                                                                                  child: Container(
                                                                                    margin: EdgeInsets.only(left: 5),
                                                                                    child: SvgPicture.asset("images/red_down.svg"),
                                                                                  ),
                                                                                ),
                                                                                Visibility(
                                                                                  visible: cansearchlist[index].arrowup,
                                                                                  child: Container(
                                                                                    margin: EdgeInsets.only(left: 5),
                                                                                    child: SvgPicture.asset("images/red_up.svg"),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Visibility(
                                                                              visible: cansearchlist[index].reason,
                                                                              child: Container(
                                                                                margin: EdgeInsets.only(top: 5),
                                                                                child: Text(
                                                                                  cansearchlist[index].cancelReason == null ? Languages.of(context)!.noreasonavailblelable : cansearchlist[index].cancelReason!,
                                                                                  maxLines: 20,
                                                                                  overflow: TextOverflow.visible,
                                                                                  style: TextStyle(color: Constants.whitetext, fontSize: 14, fontFamily: Constants.app_font),
                                                                                ),
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ) :  Container(margin: EdgeInsets.only(top:30),alignment: Alignment.topCenter,child: Text('No Data Found',style: TextStyle(color: Colors.white)),)
                                                  : canorderdatalist.length > 0 ? ListView.builder(
                                                      itemCount:
                                                          canorderdatalist
                                                              .length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        String paymentstatus;
                                                        Color paymentcolor;
                                                        if (canorderdatalist[
                                                                    index]
                                                                .paymentStatus
                                                                .toString() ==
                                                            "0") {
                                                          paymentstatus =
                                                              "Pending";
                                                          paymentcolor =
                                                              Constants
                                                                  .color_red;
                                                        } else {
                                                          paymentstatus =
                                                              "Completed";
                                                          paymentcolor =
                                                              Constants
                                                                  .color_theme;
                                                        }

                                                        double user_lat =
                                                            double.parse(
                                                                canorderdatalist[
                                                                        index]
                                                                    .userAddress!
                                                                    .lat!);
                                                        double user_long =
                                                            double.parse(
                                                                canorderdatalist[
                                                                        index]
                                                                    .userAddress!
                                                                    .lang!);
                                                        double vendorlat = double.parse(canorderdatalist[index].vendor!.lat!);
                                                        double vendorlong = double.parse(canorderdatalist[index].vendor!.lang!);
                                                        assert(
                                                            user_lat is double);
                                                        assert(user_long
                                                            is double);
                                                        String distance = "0";
                                                        String str = Constants.calculateDistance(vendorlat, vendorlong, user_lat, user_long).toString();
                                                        var distance12 =
                                                            str.split('.');
                                                        distance =
                                                            distance12[0];
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .all(ScreenUtil()
                                                                  .setWidth(8)),
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    right: 5,
                                                                    bottom: 0,
                                                                    left: 5),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color:
                                                                        Constants
                                                                            .itembgcolor,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color:
                                                                          Constants
                                                                              .itembgcolor,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(12))),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: ScreenUtil()
                                                                      .setWidth(
                                                                          0),
                                                                  right: ScreenUtil()
                                                                      .setWidth(
                                                                          0)),
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            Languages.of(context)!.oidlable +
                                                                                "   " +
                                                                                canorderdatalist[index].orderId!,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          ),
                                                                          Text('${PreferenceUtils.getString(Constants.currencySymbol)} ${canorderdatalist[index].amount.toString()}',
                                                                            style: TextStyle(
                                                                                color: Constants.color_theme,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    ListView.builder(
                                                                      itemCount: canorderdatalist[
                                                                              index]
                                                                          .orderItems!
                                                                          .length,
                                                                      shrinkWrap:
                                                                          true,
                                                                      physics:
                                                                          NeverScrollableScrollPhysics(),
                                                                      itemBuilder:
                                                                          (context,
                                                                              position) {
                                                                        return Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: 10,
                                                                              left: 10),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                canorderdatalist[index].orderItems![position].itemName!,
                                                                                style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 12),
                                                                              ),
                                                                              Text(
                                                                                "  x " + canorderdatalist[index].orderItems![position].qty.toString(),
                                                                                style: TextStyle(color: Constants.color_theme, fontFamily: Constants.app_font, fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                    color: Colors.transparent,
                                                                                    border: Border.all(
                                                                                      color: Colors.transparent,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                                margin: EdgeInsets.only(top: 5, left: 0, right: 5, bottom: 30),
                                                                                alignment: Alignment.center,
                                                                                child: CachedNetworkImage(
                                                                                  // imageUrl: imageurl,

                                                                                  imageUrl: canorderdatalist[index].vendor!.image!,
                                                                                  fit: BoxFit.fill,
                                                                                  width: screenwidth * 0.15,
                                                                                  height: screenheight * 0.09,

                                                                                  imageBuilder: (context, imageProvider) => ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                    child: Image(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  placeholder: (context, url) => SpinKitFadingCircle(color: Constants.color_theme),
                                                                                  errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child:
                                                                                Container(
                                                                              height: screenheight * 0.15,
                                                                              color: Constants.itembgcolor,
                                                                              margin: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        alignment: Alignment.topLeft,
                                                                                        child: AutoSizeText(
                                                                                          canorderdatalist[index].vendor!.name!,
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.visible,
                                                                                          style: TextStyle(color: Constants.whitetext, fontFamily: Constants.app_font_bold, fontSize: 16),
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Container(
                                                                                            margin: EdgeInsets.only(top: 0, left: 5, right: 2, bottom: 0),
                                                                                            alignment: Alignment.topRight,
                                                                                            child: SvgPicture.asset(
                                                                                              "images/veg.svg",
                                                                                            ),
                                                                                          ),
                                                                                          Container(
                                                                                            margin: EdgeInsets.only(top: 0, left: 2, right: 10, bottom: 0),
                                                                                            alignment: Alignment.topRight,
                                                                                            child: SvgPicture.asset(
                                                                                              "images/nonveg.svg",
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Container(
                                                                                    alignment: Alignment.topLeft,
                                                                                    margin: EdgeInsets.only(top: 10, left: 0, right: 5, bottom: 0),
                                                                                    color: Colors.transparent,
                                                                                    child: AutoSizeText(
                                                                                      canorderdatalist[index].vendor!.mapAddress ?? '',
                                                                                      overflow: TextOverflow.visible,
                                                                                      maxLines: 3,
                                                                                      style: TextStyle(color: Constants.greaytext, fontFamily: Constants.app_font, fontSize: 14),
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
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              20,
                                                                          right:
                                                                              0,
                                                                          left:
                                                                              5),
                                                                      width:
                                                                          screenwidth,
                                                                      child:
                                                                          DottedLine(
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        lineLength:
                                                                            double.infinity,
                                                                        lineThickness:
                                                                            1.0,
                                                                        dashLength:
                                                                            8.0,
                                                                        dashColor:
                                                                            Constants.dashline,
                                                                        dashRadius:
                                                                            0.0,
                                                                        dashGapLength:
                                                                            5.0,
                                                                        dashGapColor:
                                                                            Colors.transparent,
                                                                        dashGapRadius:
                                                                            0.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            canorderdatalist[index].user!.name!,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontFamily: Constants.app_font_bold,
                                                                                fontSize: 16),
                                                                          ),
                                                                          RichText(
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textScaleFactor:
                                                                                1,
                                                                            text:
                                                                                TextSpan(
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
                                                                                      distance + " " + Languages.of(context)!.kmfarawaylable,
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
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              5,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        canorderdatalist[index]
                                                                            .userAddress!
                                                                            .address!,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        maxLines:
                                                                            5,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Constants.greaytext,
                                                                            fontFamily: Constants.app_font,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              30,
                                                                          bottom:
                                                                              20,
                                                                          right:
                                                                              0,
                                                                          left:
                                                                              5),
                                                                      width:
                                                                          screenwidth,
                                                                      child:
                                                                          DottedLine(
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        lineLength:
                                                                            double.infinity,
                                                                        lineThickness:
                                                                            1.0,
                                                                        dashLength:
                                                                            8.0,
                                                                        dashColor:
                                                                            Constants.dashline,
                                                                        dashRadius:
                                                                            0.0,
                                                                        dashGapLength:
                                                                            5.0,
                                                                        dashGapColor:
                                                                            Colors.transparent,
                                                                        dashGapRadius:
                                                                            0.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              2,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              20),
                                                                      child:
                                                                          ListView(
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        shrinkWrap:
                                                                            true,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              if (mounted) {
                                                                                setState(() {
                                                                                  canorderdatalist[index].arrowdown = !canorderdatalist[index].arrowdown;
                                                                                  canorderdatalist[index].arrowup = !canorderdatalist[index].arrowup;
                                                                                  canorderdatalist[index].reason = !canorderdatalist[index].reason;
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                    margin: EdgeInsets.only(left: 0),
                                                                                    child: Text(
                                                                                      Languages.of(context)!.seereasoncancellable,
                                                                                      style: TextStyle(color: Constants.color_red, fontSize: 16, fontFamily: Constants.app_font),
                                                                                    )),
                                                                                Visibility(
                                                                                  visible: canorderdatalist[index].arrowdown,
                                                                                  child: Container(
                                                                                    margin: EdgeInsets.only(left: 5),
                                                                                    child: SvgPicture.asset("images/red_down.svg"),
                                                                                  ),
                                                                                ),
                                                                                Visibility(
                                                                                  visible: canorderdatalist[index].arrowup,
                                                                                  child: Container(
                                                                                    margin: EdgeInsets.only(left: 5),
                                                                                    child: SvgPicture.asset("images/red_up.svg"),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Visibility(
                                                                              visible: canorderdatalist[index].reason,
                                                                              child: Container(
                                                                                margin: EdgeInsets.only(top: 5),
                                                                                child: Text(
                                                                                  canorderdatalist[index].cancelReason == null ? Languages.of(context)!.noreasonavailblelable : canorderdatalist[index].cancelReason!,
                                                                                  maxLines: 20,
                                                                                  overflow: TextOverflow.visible,
                                                                                  style: TextStyle(color: Constants.whitetext, fontSize: 14, fontFamily: Constants.app_font),
                                                                                ),
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ) : Container(margin: EdgeInsets.only(top:30),alignment: Alignment.topCenter,child: Text('No Data Found',style: TextStyle(color: Colors.white)),),
                                        ),
                                      ]),
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

  ComSearchTextChanged(String text) async {
    comsearchlist.clear();

    setState(() {
      if (text != null && text.isNotEmpty) {

        comporderdatalist.forEach((comsearchdata) {
          if (comsearchdata.orderId!.contains(text))
            comsearchlist.add(comsearchdata);
        });
      } else {
        return;
      }
    });

    setState(() {});
  }

  CanSearchTextChanged(String text) async {
    cansearchlist.clear();

    setState(() {
      if (text != null && text.isNotEmpty) {

        canorderdatalist.forEach((cansearchdata) {
          if (cansearchdata.orderId!.contains(text) ||
              cansearchdata.orderId!.contains(text))
            cansearchlist.add(cansearchdata);
        });
      } else {
        return;
      }
    });

    setState(() {});
  }
}

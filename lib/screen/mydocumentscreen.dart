import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
// import 'package:image_downloader/image_downloader.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MyDocument extends StatefulWidget {
  @override
  _MyDocument createState() => _MyDocument();
}

class _MyDocument extends State<MyDocument> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _radioValue = -1;
  String _result = "0";
  bool showSpinner = false;

  String lino = "Licence Number";
  String vehicleType = "Vehicle Type";
  String vehicleNo = "Vehicle Number";
  String liimage = "Licence Image";
  String naimage = "NationalId Image";

  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File? _imageFile;
  // int _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    // ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
    //   setState(() {
    //     _progress = progress;
    //   });
    // });

    setState(() {
      lino = PreferenceUtils.getString(Constants.driverlicencenumber);
      vehicleType = PreferenceUtils.getString(Constants.drivervehicletype);
      vehicleNo = PreferenceUtils.getString(Constants.drivervehiclenumber);
      liimage = PreferenceUtils.getString(Constants.driverlicencedoc);
      naimage = PreferenceUtils.getString(Constants.drivernationalidentity);
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
                  title: Text(
                    Languages.of(context)!.mydocumentlable,
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
                  actions: <Widget>[
                    InkWell(
                      onTap: () {
                        _OpenInformationBottomSheet();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 1, right: 10, left: 5),
                        child: SvgPicture.asset("images/information.svg"),
                      ),
                    )
                  ]),
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
                            margin: EdgeInsets.only(bottom: 0),
                            color: Colors.transparent,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  alignment: Alignment.topLeft,
                                  child: AppLableWidget(
                                    title:
                                        Languages.of(context)!.vehicletypelable,
                                  ),
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    decoration: BoxDecoration(
                                        color: Constants.itembgcolor,
                                        border: Border.all(
                                          color: Constants.itembgcolor,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    width: screenwidth,
                                    height: ScreenUtil().setHeight(40),
                                    child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 15, top: 10),
                                        child: Text(
                                          vehicleType,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontFamily:
                                                  Constants.app_font_bold,
                                              fontSize: 16),
                                        ))),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  alignment: Alignment.topLeft,
                                  child: AppLableWidget(
                                    title: Languages.of(context)!
                                        .vehiclenumberlable,
                                  ),
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    decoration: BoxDecoration(
                                        color: Constants.itembgcolor,
                                        border: Border.all(
                                          color: Constants.itembgcolor,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    width: screenwidth,
                                    height: ScreenUtil().setHeight(40),
                                    child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 15, top: 10),
                                        child: Text(
                                          vehicleNo,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontFamily:
                                                  Constants.app_font_bold,
                                              fontSize: 16),
                                        ))),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  alignment: Alignment.topLeft,
                                  child: AppLableWidget(
                                    title: Languages.of(context)!
                                        .licencenumberlable,
                                  ),
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                        color: Constants.itembgcolor,
                                        border: Border.all(
                                          color: Constants.itembgcolor,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    width: screenwidth,
                                    height: ScreenUtil().setHeight(40),
                                    child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 15, top: 10),
                                        child: Text(
                                          lino,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontFamily:
                                                  Constants.app_font_bold,
                                              fontSize: 16),
                                        ))),
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(8)),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 10, right: 5, bottom: 0, left: 5),
                                    decoration: BoxDecoration(
                                        color: Constants.itembgcolor,
                                        border: Border.all(
                                          color: Constants.itembgcolor,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, left: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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
                                                                    Border.all(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                        margin: EdgeInsets.only(
                                                            top: 5,
                                                            left: 0,
                                                            right: 5,
                                                            bottom: 10),
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: liimage,
                                                          fit: BoxFit.fill,
                                                          width: screenwidth *
                                                              0.15,
                                                          height: screenheight *
                                                              0.09,

                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child: Image(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          placeholder: (context,
                                                                  url) =>
                                                              SpinKitFadingCircle(
                                                                  color: Constants.color_theme),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                                  "images/no_image.png"),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      color: Constants.itembgcolor,
                                                      margin: EdgeInsets.only(
                                                          top: 10,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 10),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: AutoSizeText(
                                                              liimage,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              style: TextStyle(
                                                                  color: Constants.whitetext,
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font_bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      left: 0,
                                                                      right: 5,
                                                                      bottom:
                                                                          0),
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  _downloadImage(
                                                                      liimage,
                                                                      context);
                                                                },
                                                                child: RichText(
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textScaleFactor:
                                                                      1,
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      WidgetSpan(
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 0,
                                                                              top: 0,
                                                                              bottom: 0,
                                                                              right: 5),
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/download_file.svg",
                                                                            width:
                                                                                15,
                                                                            height:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      WidgetSpan(
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 10,
                                                                              top: 0,
                                                                              bottom: 0,
                                                                              right: 5),
                                                                          child:
                                                                              Text(
                                                                            Languages.of(context)!.downloaddocumentlable,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Constants.greaytext,
                                                                              fontSize: 12,
                                                                              fontFamily: Constants.app_font,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
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
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(8)),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 10, right: 5, bottom: 0, left: 5),
                                    decoration: BoxDecoration(
                                        color: Constants.itembgcolor,
                                        border: Border.all(
                                          color: Constants.itembgcolor,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, left: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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
                                                                    Border.all(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                        margin: EdgeInsets.only(
                                                            top: 5,
                                                            left: 0,
                                                            right: 5,
                                                            bottom: 10),
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: naimage,
                                                          fit: BoxFit.fill,
                                                          width: screenwidth *
                                                              0.15,
                                                          height: screenheight *
                                                              0.09,
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child: Image(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          placeholder: (context,
                                                                  url) =>
                                                              SpinKitFadingCircle(
                                                                  color: Constants.color_theme),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                                  "images/no_image.png"),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      color: Constants.itembgcolor,
                                                      margin: EdgeInsets.only(
                                                          top: 10,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 10),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: AutoSizeText(
                                                              naimage,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              style: TextStyle(
                                                                  color: Constants.whitetext,
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font_bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      left: 0,
                                                                      right: 5,
                                                                      bottom:
                                                                          0),
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  _downloadImage(
                                                                      naimage,
                                                                      context);
                                                                },
                                                                child: RichText(
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textScaleFactor:
                                                                      1,
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      WidgetSpan(
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 0,
                                                                              top: 0,
                                                                              bottom: 0,
                                                                              right: 5),
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/download_file.svg",
                                                                            width:
                                                                                15,
                                                                            height:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      WidgetSpan(
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 10,
                                                                              top: 0,
                                                                              bottom: 0,
                                                                              right: 5),
                                                                          child:
                                                                              Text(
                                                                            Languages.of(context)!.downloaddocumentlable,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Constants.greaytext,
                                                                              fontSize: 12,
                                                                              fontFamily: Constants.app_font,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
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
                                ),
                              ],
                            ),
                          ),
                        ),
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

  void _OpenInformationBottomSheet() {

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Constants.itembgcolor,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Wrap(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: 20, left: 20, bottom: 0, right: 10),
                      child: Text(
                        Languages.of(context)!.whyprovidelicencelable,
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
                        Languages.of(context)!.licencedeataillable,
                        maxLines: 10,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                            color: Constants.whitetext,
                            fontSize: 14,
                            fontFamily: Constants.app_font),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 20, left: 20, bottom: 0, right: 10),
                      child: Text(
                        Languages.of(context)!.mustcarethislable,
                        style: TextStyle(
                            color: Constants.whitetext,
                            fontSize: 18,
                            fontFamily: Constants.app_font),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 20, bottom: 0, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: SvgPicture.asset("images/white_dot.svg"),
                              ),

                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textScaleFactor: 1,
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Text(
                                            Languages.of(context)!
                                                .yourfiletypelable,
                                            style: TextStyle(
                                                color:
                                                    Constants.whitetext,
                                                fontSize: 13,
                                                fontFamily:
                                                    Constants.app_font)),
                                      ),

                                      WidgetSpan(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 0,
                                              top: 0,
                                              bottom: 0,
                                              right: 5),
                                          child: Text(
                                            Languages.of(context)!
                                                .jpegandpnglable,
                                            style: TextStyle(
                                              color: Constants.color_theme,
                                              fontSize: 13,
                                              fontFamily: Constants.app_font,
                                            ),
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
                                            Languages.of(context)!.formatlable,
                                            style: TextStyle(
                                              color: Constants.whitetext,
                                              fontSize: 13,
                                              fontFamily: Constants.app_font,
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ])),
                    Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 20, bottom: 50, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: SvgPicture.asset("images/white_dot.svg"),
                              ),

                              Expanded(
                                child: Container(
                                  height: 30,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                      Languages.of(context)!.makesurefilelable,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Constants.whitetext,
                                          fontSize: 13,
                                          fontFamily: Constants.app_font)),
                                ),
                              ),
                            ])),
                  ],
                ),
              );
            },
          );
        });
  }

  void _downloadImage(String url, BuildContext context) async {

    String path = url;
    GallerySaver.saveImage(path).then((bool? success) {
      setState(() {
        Constants.createSnackBar(Languages.of(context)!.dowloaddocsucesslable,
            this.context, Constants.color_theme);
      });
    });
  }
}

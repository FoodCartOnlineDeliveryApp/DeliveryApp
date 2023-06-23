import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/model/faq.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class FAQs extends StatefulWidget {
  @override
  _FAQs createState() => _FAQs();
}

class _FAQs extends State<FAQs> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool showSpinner = false;

  bool showdata = false;
  bool nodata = true;

  List<FaqData> fqdatalist = <FaqData>[];
  List<FaqData> searchlist = <FaqData>[];
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    Constants.CheckNetwork().whenComplete(() => CallApiForGetFaq());
  }

  void CallApiForGetFaq() {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).driverFaq().then((response) {
      if (mounted) {
        if (response.success = true) {
          if (response.data!.length != 0) {
            fqdatalist.clear();
            fqdatalist.addAll(response.data!);
            nodata = false;
            showdata = true;
            setState(() {
              showSpinner = false;
            });
          } else {
            setState(() {
              showSpinner = false;
            });
            nodata = true;
            showdata = false;
          }
        } else {
          setState(() {
            showSpinner = false;
          });

          nodata = true;
          showdata = false;
        }
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      Fluttertoast.showToast(msg: snackBar.toString());
      // _scaffoldKey.currentState!.showSnackBar(snackBar);

      print("error:$obj");
      print(obj.runtimeType);
      nodata = true;
      showdata = false;

      setState(() {
        showSpinner = false;
      });
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
              backgroundColor: Constants.bgcolor,
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(
                  Languages.of(context)!.faqlable,
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
                        margin: EdgeInsets.only(bottom: 20),
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.only(left: 20, right: 20, top: 5),
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
                                    controller: controller,
                                    onChanged: onSearchTextChanged,
                                    validator: Constants.kvalidateEmail,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: Constants.app_font_bold),

                                    decoration: Constants
                                        .kTextFieldInputDecoration1
                                        .copyWith(
                                            hintText: Languages.of(context)!
                                                .searchissuelable),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: showdata,
                              child: searchlist.length != 0 ||
                                      controller.text.isNotEmpty
                                  ? new ListView.builder(
                                      itemCount: searchlist.length,
                                      shrinkWrap: true,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      Languages.of(context)!
                                                              .questionlable +
                                                          "  " +
                                                          (index + 1)
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Constants.whitetext,
                                                          fontFamily: Constants
                                                              .app_font_bold,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 0),
                                                      child: Text(
                                                        searchlist[index]
                                                            .question!,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Constants.whitetext,
                                                            fontFamily: Constants
                                                                .app_font_bold,
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: searchlist[index]
                                                        .arrowdown,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (mounted) {
                                                          setState(() {
                                                            searchlist[index]
                                                                    .arrowdown =
                                                                !searchlist[
                                                                        index]
                                                                    .arrowdown;
                                                            searchlist[index]
                                                                    .arrowup =
                                                                !searchlist[
                                                                        index]
                                                                    .arrowup;
                                                            searchlist[index]
                                                                    .reason =
                                                                !searchlist[
                                                                        index]
                                                                    .reason;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/white_down.svg"),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: searchlist[index]
                                                        .arrowup,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (mounted) {
                                                          setState(() {
                                                            searchlist[index]
                                                                    .arrowdown =
                                                                !searchlist[
                                                                        index]
                                                                    .arrowdown;
                                                            searchlist[index]
                                                                    .arrowup =
                                                                !searchlist[
                                                                        index]
                                                                    .arrowup;
                                                            searchlist[index]
                                                                    .reason =
                                                                !searchlist[
                                                                        index]
                                                                    .reason;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/white_up.svg"),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Visibility(
                                                      visible: false,
                                                      maintainSize: true,
                                                      maintainAnimation: true,
                                                      maintainState: true,
                                                      child: Container(
                                                        child: Text(
                                                          "Q. 1",
                                                          style: TextStyle(
                                                              color: Constants.whitetext,
                                                              fontFamily: Constants
                                                                  .app_font_bold,
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Visibility(
                                                        visible:
                                                            searchlist[index]
                                                                .reason,
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 5),
                                                          child: Text(
                                                            searchlist[index]
                                                                .answer!,
                                                            maxLines: 10,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                                color: Constants.whitetext,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font,
                                                                fontSize: 13),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      maintainSize: true,
                                                      maintainAnimation: true,
                                                      maintainState: true,
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/red_down.svg"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: fqdatalist.length,
                                      shrinkWrap: true,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Q. " +
                                                          (index + 1)
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Constants.whitetext,
                                                          fontFamily: Constants
                                                              .app_font_bold,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 0),
                                                      child: Text(
                                                        fqdatalist[index]
                                                            .question!,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Constants.whitetext,
                                                            fontFamily: Constants
                                                                .app_font_bold,
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: fqdatalist[index]
                                                        .arrowdown,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (mounted) {
                                                          setState(() {
                                                            fqdatalist[index]
                                                                    .arrowdown =
                                                                !fqdatalist[
                                                                        index]
                                                                    .arrowdown;
                                                            fqdatalist[index]
                                                                    .arrowup =
                                                                !fqdatalist[
                                                                        index]
                                                                    .arrowup;
                                                            fqdatalist[index]
                                                                    .reason =
                                                                !fqdatalist[
                                                                        index]
                                                                    .reason;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/white_down.svg"),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: fqdatalist[index]
                                                        .arrowup,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (mounted) {
                                                          setState(() {
                                                            fqdatalist[index]
                                                                    .arrowdown =
                                                                !fqdatalist[
                                                                        index]
                                                                    .arrowdown;
                                                            fqdatalist[index]
                                                                    .arrowup =
                                                                !fqdatalist[
                                                                        index]
                                                                    .arrowup;
                                                            fqdatalist[index]
                                                                    .reason =
                                                                !fqdatalist[
                                                                        index]
                                                                    .reason;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/white_up.svg"),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Visibility(
                                                      visible: false,
                                                      maintainSize: true,
                                                      maintainAnimation: true,
                                                      maintainState: true,
                                                      child: Container(
                                                        child: Text(
                                                          "Q. 1",
                                                          style: TextStyle(
                                                              color: Constants.whitetext,
                                                              fontFamily: Constants
                                                                  .app_font_bold,
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Visibility(
                                                        visible:
                                                            fqdatalist[index]
                                                                .reason,
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 5),
                                                          child: Text(
                                                            fqdatalist[index]
                                                                .answer!,
                                                            maxLines: 10,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                                color: Constants.whitetext,
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font,
                                                                fontSize: 13),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      maintainSize: true,
                                                      maintainAnimation: true,
                                                      maintainState: true,
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                            "images/red_down.svg"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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

  onSearchTextChanged(String text) async {
    searchlist.clear();

    setState(() {
      if (text != null && text.isNotEmpty) {

        fqdatalist.forEach((fqdatalist) {
          if (fqdatalist.question!.contains(text) ||
              fqdatalist.question!.contains(text)) searchlist.add(fqdatalist);
        });
      } else {
        return;
      }
    });
  }
}
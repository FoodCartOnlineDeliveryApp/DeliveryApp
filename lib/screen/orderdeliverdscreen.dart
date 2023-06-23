import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/util/constants.dart';

class OrderDeliverd extends StatefulWidget {
  @override
  _OrderDeliverd createState() => _OrderDeliverd();
}

class _OrderDeliverd extends State<OrderDeliverd> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
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
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              body: new Stack(
                children: <Widget>[
                  new SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 80),
                              child: SvgPicture.asset(
                                "images/order_suces.svg",
                                width: ScreenUtil().setHeight(200),
                                height: ScreenUtil().setHeight(200),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 40.0, left: 15.0, right: 15, bottom: 20),
                              child: Text(
                                Languages.of(context)!.orderdeliveredsuceelable,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Constants.app_font,
                                    fontSize: 24),
                                maxLines: 2,
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
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen(0)));
                                  },
                                  child: RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: Languages.of(context)!
                                                .findothertasklable,
                                            style: TextStyle(
                                              color:
                                                  Constants.color_theme,
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.app_font_bold,
                                            )),
                                        WidgetSpan(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 10, top: 0, bottom: 0),
                                            child: SvgPicture.asset(
                                              "images/right_arrow.svg",
                                              width: 13,
                                              height: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }
}

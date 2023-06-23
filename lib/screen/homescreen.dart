import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/myprofilescreen.dart';
import 'package:mealup_driver/screen/notificationlist.dart';
import 'package:mealup_driver/screen/orderlistscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';

class HomeScreen extends StatefulWidget {

  int initalindex;

  HomeScreen(this.initalindex);

  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {

  String name = "User";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    setState(() {
      Constants.CheckNetwork().whenComplete(() => callApiForsetting());
    });
  }

  final GlobalKey<ScaffoldState> _drawerscaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: new SafeArea(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/background_image.png'),
                  fit: BoxFit.cover,
                )),
            child: Scaffold(
              // resizeToAvoidBottomPadding: true,
              key: _drawerscaffoldkey,
              bottomNavigationBar: BottomBar(widget.initalindex),
            ),
          )),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(Languages.of(context)!.areyousurelable),
        content: new Text(Languages.of(context)!.wanttoexitlable),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text(Languages.of(context)!.nolable),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text(Languages.of(context)!.yeslable),
          ),
        ],
      ),
    ).then((value) => value as bool);
  }

  void callApiForsetting() {
    RestClient(ApiHeader().dioData()).driverSetting().then((response) {
      if (response.success == true) {

        if (response.data!.globalDriver == "true") {
          setState(() {
            PreferenceUtils.putBool(Constants.isGlobalDriver, true);
          });
        }

        response.data!.driverAutoRefrese != null
            ? PreferenceUtils.setString(
            Constants.driver_auto_refrese, response.data!.driverAutoRefrese.toString())
            : PreferenceUtils.setString(Constants.driver_auto_refrese, '');

        response.data!.driverAppId != null
            ? PreferenceUtils.setString(
            Constants.one_signal_app_id, response.data!.driverAppId.toString())
            : PreferenceUtils.setString(Constants.one_signal_app_id, '');

        response.data!.cancelReason != null
            ? PreferenceUtils.setString(
            Constants.cancel_reason, response.data!.cancelReason.toString())
            : PreferenceUtils.setString(Constants.cancel_reason, '');

        response.data!.currency != null
            ? PreferenceUtils.setString(Constants.currency, response.data!.currency!)
            : PreferenceUtils.setString(Constants.currency, 'USD');
        response.data!.currency_symbol != null
            ? PreferenceUtils.setString(Constants.currencySymbol, response.data!.currency_symbol!)
            : PreferenceUtils.setString(Constants.currencySymbol, '\$');

      } else {}
    }).catchError((Object obj) {

      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          print(res);

          var responsecode = res.statusCode;

          if (responsecode == 401) {
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
          }
          break;
        default:
      }
    });
  }
}

class BottomBar extends StatefulWidget {


  int _currentIndex;

  BottomBar(this._currentIndex);

  @override
  State<StatefulWidget> createState() {
    return BottomBar1();
  }
}

class BottomBar1 extends State<BottomBar> {

  final List<Widget> _children = [
    OrderList(),
    NotificationList(),
    MyProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: new Scaffold(
        body: _children[widget._currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          selectedItemColor: Constants.color_theme,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(
              color: Constants.color_theme, fontSize: 12, fontFamily: Constants.app_font),
          unselectedLabelStyle:
          TextStyle(color: Constants.whitetext, fontSize: 12, fontFamily: Constants.app_font),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Constants.itembgcolor,
          currentIndex: widget._currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset("images/orders.svg"),
                activeIcon: SvgPicture.asset("images/order_green.svg"),
                label: Languages.of(context)!.orderslable),
            BottomNavigationBarItem(
                icon: SvgPicture.asset("images/notification.svg"),
                activeIcon: SvgPicture.asset("images/notification_green.svg"),
                label: Languages.of(context)!.notificationlable),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 15.0,
                  backgroundImage: NetworkImage(PreferenceUtils.getString(Constants.driverimage)),
                  backgroundColor: Colors.transparent,
                ),
                activeIcon: CircleAvatar(
                  radius: 15.0,
                  backgroundImage: NetworkImage(PreferenceUtils.getString(Constants.driverimage)),
                  backgroundColor: Constants.color_theme,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Constants.color_theme),
                    ),
                  ),
                ),
                label: Languages.of(context)!.profilelable)
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      widget._currentIndex = index;
    });
  }

}

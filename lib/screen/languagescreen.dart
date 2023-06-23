import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/localization/locale_constant.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';

class Language extends StatefulWidget {
  @override
  _Language createState() => _Language();
}

class _Language extends State<Language> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> languageData = <String>[];

  bool arrowdown = true;
  bool arrowup = false;
  bool reason = false;
  int? value = 0;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    languageData.add('English');
    languageData.add('Spanish');
    languageData.add('Arabic');
    PreferenceUtils.init();


    if (PreferenceUtils.getString(Constants.languagecode) == "en") {
      value = 0;
    } else if (PreferenceUtils.getString(Constants.languagecode) == "es") {
      value = 1;
    }else if (PreferenceUtils.getString(Constants.languagecode) == "ar") {
      value = 2;
    }

    if (PreferenceUtils.getString(Constants.languagecode).isEmpty) {}
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
              appBar: AppBar(
                title: Text(
                  Languages.of(context)!.languagelable,
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
              body: new Stack(
                children: <Widget>[
                  new SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      color: Colors.transparent,
                      child: Column(
                        children: <Widget>[
                          ListView.builder(
                            itemCount: languageData.length,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, position) {
                              bool divider = true;

                              if (position == languageData.length - 1) {
                                divider = false;
                              } else {
                                divider = true;
                              }

                              return Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 0, bottom: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20, right: 20, top: 0),
                                          child: Text(
                                            languageData[position],
                                            maxLines: 2,
                                            style: TextStyle(
                                                color:
                                                    Constants.whitetext,
                                                fontFamily:
                                                    Constants.app_font_bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                            child: Theme(
                                          data: Theme.of(context).copyWith(
                                            unselectedWidgetColor:
                                                Constants.whitetext,
                                            disabledColor:
                                                Constants.whitetext,
                                          ),
                                          child: Transform.scale(
                                            scale: 1.2,
                                            child: Radio(
                                              activeColor: Constants.color_theme,
                                              value: position,
                                              groupValue: value,
                                              onChanged: (dynamic ind) {
                                                setState(() {
                                                  value = ind;
                                                  if (languageData[position] == "English") {
                                                    changeLanguage(context, "en");
                                                    PreferenceUtils.setString(Constants.languagecode, "en");
                                                  } else if (languageData[position] == "Spanish") {
                                                    changeLanguage(context, "es");
                                                    PreferenceUtils.setString(Constants.languagecode, "es");
                                                  }else if (languageData[position] == "Arabic") {
                                                    changeLanguage(context, "ar");
                                                    PreferenceUtils.setString(Constants.languagecode, "ar");
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                    Visibility(
                                      visible: divider,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 0,
                                            left: 5,
                                            bottom: 5,
                                            right: 5),
                                        child: Divider(
                                          height: 1,
                                          thickness: 0.5,
                                          color: Constants.dashline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
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

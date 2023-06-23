import 'package:flutter/material.dart';

abstract class Languages {

  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }


  /*Login Screen*/

  String get appName;
  String get emaillabel;
  String get enteremaillabel;
  String get passwordlabel;
  String get enterpasswordlabel;
  String get forgotpasswordlabel;
  String get forgotpasswordlabel1;
  String get remembermelabel;
  String get btnloginlabel;
  String get donthaveaccountlabel;
  String get createnowlabel;
  String get msgloginsucesslabel;
  String get languagelable;


/*Register Screen*/
  String get firstnamelable;
  String get enterfirstnamelable;
  String get lastnamelable;
  String get enterlastnamelable;
  String get contactnolable;
  String get confirmpasslable;
  String get enterconfirmpasslable;
  String get btncreatenewaccountlable;
  String get selectcountrycodelable;
  String get alreadyaccountlable;
  String get passwordrequiredlable;
  String get passwordnotmatchlable;
  String get registersucesslable;
  String get emailalreadytakenlable;

  /*OTP Screen*/

  String get otplable;
  String get enterotplable;
  String get verifynowlable;
  String get entervalidotplable;
  String get dontrecivecodelable ;
  String get resendotplable ;
  String get willshareotplable ;
  String get otpsendsucesslable ;

    /*CASHBALANCE  Screen*/

  String get zerolable;
  String get mycachebalancelable;
  String get totalbalancelable;
  String get searchorderidlable;
  String get oidlable;
  String get nodatalable;

  /* CHANGEPASSWORD    Screen*/

  String get changepasswordlable;
  String get newpasswordlable;
  String get changemypasswordlable;
  String get dontremembaroldpasswordlable;
  String get oldpasswordlable;
  String get passwordsixcharlable;
  String get enternewpasswordlable;
  String get checkemailotplable;

  /*earning history    Screen*/


  String get earninghistorylable;
  String get todayearninglable;
  String get weaklyearninglable;
  String get monthlyearninglable;
  String get yearlyearninglable;
  String get earninglable;
  String get monthlylable;



  /*edit profile Screen*/

  String get editprofilelable;
  String get selectprofilepiclable;
  String get changepiclable;
  String get removepiclable;
  String get changeinfolable;
  String get photoliblable;
  String get cameralable;
  String get submitlable;

  /*faq Screen*/

  String get faqlable;
  String get searchissuelable;
  String get questionlable;



  /*get order from kitch  Screen*/

  String get allowlocationlable;
  String get tryagainlable;
  String get ordercancellable;
  String get kmfarawaylable;
  String get yourlocationlable;
  String get canceldeliverylable;
  String get pickupanddeliverlable;



  /*Cancel order screen*/

  String get telluslable;
  String get whycancellable;
  String get selectcancelreasonlable;
  String get otherreasonlable;
  String get addreasonlable;
  String get submitreviewlable;
  String get cancelreasonlable;
  String get oklable;

  /*History screen*/

  String get historylable;
  String get paymentlable;
  String get cashondeliverylable;
  String get ordercompletesucesslable;
  String get seereasoncancellable;
  String get noreasonavailblelable;
  String get completedtablable;
  String get canceltablable;


  /*Home screen*/

  String get areyousurelable;
  String get wanttoexitlable;
  String get nolable;
  String get yeslable;
  String get orderslable;
  String get notificationlable;
  String get profilelable;


  /*My Document screen*/

  String get mydocumentlable;
  String get vehicletypelable;
  String get vehiclenumberlable;
  String get licencenumberlable;
  String get downloaddocumentlable;
  String get whyprovidelicencelable;
  String get licencedeataillable;
  String get mustcarethislable;
  String get yourfiletypelable;
  String get jpegandpnglable;
  String get formatlable;
  String get makesurefilelable;
  String get dowloaddocsucesslable;



  /*My Document screen*/

  String get myprofilelable;
  String get taptoviewinfolable;
  String get changemylanguagelable;
  String get logoutlable;
  String get versionlable;
  String get locationlable;


  /*Orderlist screen*/

  String get userlable;
  String get setlocationlable;
  String get orderacceptedlable;
  String get youareofflinelable;
  String get dutystatusofflinelable;
  String get reconnectlable;
  String get nonewjoblable;
  String get youhavenotnewjoblable;

  String get orderdeliveredsuceelable;
  String get findothertasklable;





  String get completeorderlable;
  String get selectdeliveryzonelable;
  String get setthislocationlable;



  String get doneletsgolable;
  String get selectnastionalidlable;
  String get selectlicencelable;
  String get pancardlable;
  String get aadharcardlable;
  String get nationalidcardlable;
  String get voteridcardlable;
  String get selectanyofthemlable;
  String get uploadoneofnatinallable;
  String get uploadyourdrivinglicencelable;
  String get enterlicencenumberlable;
  String get entervehiclenumberlable;
  String get selectvehicletypelable;
  String get uploaddocumentlable;




  String get foruploadfilelable;
  String get selectlocation;


  /*Comman lable*/
  String get servererrorlable;
  String get internetconnectionlable;
  String get checkinternetlable;

}

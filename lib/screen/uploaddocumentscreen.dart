import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup_driver/apiservice/ApiHeader.dart';
import 'package:mealup_driver/apiservice/api_service.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/selectlocationscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadDocument extends StatefulWidget {
  @override
  _UploadDocument createState() => _UploadDocument();
}

class _UploadDocument extends State<UploadDocument> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  final _formKey = new GlobalKey<FormState>();
  final _text_vehicle_number = TextEditingController();
  final _text_licence_number = TextEditingController();
  File? _Licenceimage, _NationalIdImage;
  final picker = ImagePicker();

  String liname = "license_image";
  String naname = "nationalid_image";

  String? strvehicletype = "";
  List? vtdata;

  List<Vehicletype>? _vehicletype = [];

  String liimageB64 = " ";
  String naimageB64 = " ";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    if (mounted) {
      setState(() {
        String vehicleType = PreferenceUtils.getString(Constants.driversetvehicaltype);
        if (vehicleType != '') {
          var json = JsonDecoder().convert(vehicleType);
          _vehicletype = (json).map<Vehicletype>((item) => Vehicletype.fromJson(item)).toList();
          strvehicletype = _vehicletype![0].vehical_type;
        }
      });
    }
  }

  void callApiForUploadDocument(String liimageB64, String naimageB64, BuildContext context) {

    setState(() {
      showSpinner = true;
    });

    RestClient(ApiHeader().dioData())
        .driverUploadDocument(strvehicletype, _text_vehicle_number.text, _text_licence_number.text,
        naimageB64, liimageB64).then((response) {
      if (mounted) {
        print(response.toString());
        final body = json.decode(response!);

        bool? sucess = body['success'];
        print(sucess);

        if (sucess == true) {
          setState(() {
            showSpinner = false;
          });

          PreferenceUtils.setString(Constants.driverlicencenumber, _text_licence_number.text);
          PreferenceUtils.setString(Constants.drivervehicletype, strvehicletype!);
          PreferenceUtils.setString(Constants.drivervehiclenumber, _text_vehicle_number.text);
          var msg = body['data'];
          Constants.createSnackBar(msg, this.context, Constants.color_theme);
          Navigator.push(
            this.context,
            MaterialPageRoute(builder: (context) => SelectLocation()),
          );
        } else {

          setState(() {
            showSpinner = false;
          });

          var msg = body['data'];

          Constants.createSnackBar(msg, this.context, Constants.color_red);

        }
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(this.context)!.servererrorlable),
        backgroundColor: Constants.color_red,
      );
      Fluttertoast.showToast(msg:snackBar.toString());
      // _scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
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
                    colorFilter: ColorFilter.mode(Constants.bgcolor, BlendMode.color))),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              key: _scaffoldKey,
              appBar: AppBar(
                  title: Text(
                    Languages.of(context)!.uploaddocumentlable,
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
                    ),
                  ]),
              body: ModalProgressHUD(
                inAsyncCall: showSpinner,
                opacity: 1.0,
                color: Colors.transparent.withOpacity(0.2),
                progressIndicator: SpinKitFadingCircle(color: Constants.color_theme),
                child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints viewportConstraints) {
                      return new Stack(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 130),
                            child: new SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.always,
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Hero(
                                          tag: 'App_logo',
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'images/small_logo.svg',
                                              width: 80.0,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        alignment: Alignment.topLeft,
                                        child: AppLableWidget(
                                          title: Languages.of(context)!.vehicletypelable,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10),
                                        width: screenwidth,
                                        height: ScreenUtil().setHeight(55),
                                        child: Card(
                                          color: Constants.light_black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          elevation: 5.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 25.0, right: 15),
                                            child: DropdownButtonHideUnderline(
                                              child: new DropdownButton<String>(
                                                  hint: Text(
                                                    Languages.of(context)!.selectvehicletypelable,
                                                    style: TextStyle(
                                                        color: Constants.greaytext,
                                                        fontFamily: Constants.app_font,
                                                        fontSize: 14),
                                                  ),
                                                  icon: SvgPicture.asset("images/drop_dwon.svg"),
                                                  isDense: true,
                                                  value: strvehicletype,
                                                  items: _vehicletype!.map((Vehicletype map) {
                                                    return new DropdownMenuItem<String>(
                                                      value: map.vehical_type,
                                                      child: new Text(
                                                        map.vehical_type!,
                                                        style: TextStyle(
                                                            color: Constants.greaytext,
                                                            fontFamily: Constants.app_font_bold,
                                                            fontSize: 16),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      strvehicletype = value;
                                                      print(strvehicletype);
                                                    });
                                                  }),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        alignment: Alignment.topLeft,
                                        child: AppLableWidget(
                                          title: Languages.of(context)!.vehiclenumberlable,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10),
                                        child: Card(
                                          color: Constants.itembgcolor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          elevation: 5.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 25.0),
                                            child: TextFormField(
                                              textInputAction: TextInputAction.next,
                                              validator: Constants.kvalidateFullName,
                                              controller: _text_vehicle_number,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: Constants.app_font_bold),
                                              decoration: Constants.kTextFieldInputDecoration.copyWith(
                                                  hintText:
                                                  Languages.of(context)!.entervehiclenumberlable),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        alignment: Alignment.topLeft,
                                        child: AppLableWidget(
                                          title: Languages.of(context)!.licencenumberlable,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10),
                                        child: Card(
                                          color: Constants.itembgcolor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          elevation: 5.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 25.0),
                                            child: TextFormField(
                                              textInputAction: TextInputAction.done,
                                              validator: Constants.kvalidateFullName,
                                              controller: _text_licence_number,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: Constants.app_font_bold),
                                              decoration: Constants.kTextFieldInputDecoration.copyWith(
                                                  hintText:
                                                  Languages.of(context)!.enterlicencenumberlable),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        alignment: Alignment.topLeft,
                                        child: AppLableWidget(
                                          title: Languages.of(context)!.uploadyourdrivinglicencelable,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                                        child: InkWell(
                                          onTap: () {
                                            _ChooseLicenceImage();
                                          },
                                          child: Container(
                                            margin:
                                            EdgeInsets.only(top: 0, right: 10, bottom: 0, left: 10),
                                            decoration: BoxDecoration(
                                                color: Constants.itembgcolor,
                                                border: Border.all(
                                                  color: Constants.itembgcolor,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 20, bottom: 20, left: 10, right: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 0, bottom: 0, left: 5, right: 10),
                                                        child: Text(
                                                          liname,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              color: Constants.greaytext,
                                                              fontSize: 14,
                                                              fontFamily: Constants.app_font),
                                                        )),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 0, bottom: 0, left: 0, right: 5),
                                                    child: SvgPicture.asset("images/camera.svg"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        alignment: Alignment.topLeft,
                                        child: AppLableWidget(
                                          title: Languages.of(context)!.uploadoneofnatinallable,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                                        child: InkWell(
                                          onTap: () {
                                            _ChooseNationIdImage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 0, right: 5, bottom: 0, left: 5),
                                            decoration: BoxDecoration(
                                                color: Constants.itembgcolor,
                                                border: Border.all(
                                                  color: Constants.itembgcolor,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 20, bottom: 20, left: 10, right: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 0, bottom: 0, left: 5, right: 10),
                                                        child: Text(
                                                          naname,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              color: Constants.greaytext,
                                                              fontSize: 14,
                                                              fontFamily: Constants.app_font),
                                                        )),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 0, bottom: 0, left: 0, right: 5),
                                                    child: SvgPicture.asset("images/camera.svg"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, left: 30),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          Languages.of(context)!.selectanyofthemlable,
                                          style: TextStyle(
                                              color: Constants.whitetext,
                                              fontFamily: Constants.app_font,
                                              fontSize: 11),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, left: 30),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset("images/grey_dot.svg"),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                Languages.of(context)!.voteridcardlable,
                                                style: TextStyle(
                                                    color: Constants.greaytext,
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, left: 30),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset("images/grey_dot.svg"),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                Languages.of(context)!.nationalidcardlable,
                                                style: TextStyle(
                                                    color: Constants.greaytext,
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, left: 30),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset("images/grey_dot.svg"),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                Languages.of(context)!.aadharcardlable,
                                                style: TextStyle(
                                                    color: Constants.greaytext,
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, left: 30),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset("images/grey_dot.svg"),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                Languages.of(context)!.pancardlable,
                                                style: TextStyle(
                                                    color: Constants.greaytext,
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          new Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_formKey.currentState!.validate()) {
                                          print(strvehicletype);

                                          if (_Licenceimage == null) {
                                            Constants.createSnackBar(Languages.of(context)!.selectlicencelable,
                                                this.context, Constants.color_red);
                                          } else if (_NationalIdImage == null) {
                                            Constants.createSnackBar(
                                                Languages.of(context)!.selectnastionalidlable,
                                                this.context,
                                                Constants.color_red);
                                          } else {
                                            List<int> liimageBytes = _Licenceimage!.readAsBytesSync();
                                            liimageB64 = base64Encode(liimageBytes);

                                            List<int> naimageBytes = _NationalIdImage!.readAsBytesSync();
                                            naimageB64 = base64Encode(naimageBytes);
                                            Constants.CheckNetwork().whenComplete(() =>
                                                callApiForUploadDocument(liimageB64, naimageB64, context));
                                          }

                                        } else {
                                          print("false");
                                          setState(() {
                                          });
                                        }
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                                          height: screenheight * 0.065,
                                          child: Center(
                                            child: Container(
                                              color: Constants.color_theme,
                                              child: Text(
                                                Languages.of(context)!.doneletsgolable,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: Constants.app_font),
                                              ),
                                            ),
                                          )),
                                    )),
                              )),

                          new Container(margin: EdgeInsets.only(bottom: 30), child: Body1())
                        ],
                      );
                    }),
              ),
            ),
          ),
        ));
  }

  Future<bool> _onWillPop() async {
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
                      margin: EdgeInsets.only(top: 20, left: 20, bottom: 0, right: 10),
                      child: Text(
                        Languages.of(context)!.whyprovidelicencelable,
                        style: TextStyle(
                            color: Constants.whitetext,
                            fontSize: 18,
                            fontFamily: Constants.app_font),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, left: 20, bottom: 0, right: 10),
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
                      margin: EdgeInsets.only(top: 20, left: 20, bottom: 0, right: 10),
                      child: Text(
                        Languages.of(context)!.mustcarethislable,
                        style: TextStyle(
                            color: Constants.whitetext,
                            fontSize: 18,
                            fontFamily: Constants.app_font),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10, left: 20, bottom: 0, right: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                                    child: Text(Languages.of(context)!.yourfiletypelable,
                                        style: TextStyle(
                                            color: Constants.whitetext,
                                            fontSize: 13,
                                            fontFamily: Constants.app_font)),
                                  ),

                                  WidgetSpan(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 5),
                                      child: Text(
                                        Languages.of(context)!.jpegandpnglable,
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
                                      margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 5),
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
                        margin: EdgeInsets.only(top: 10, left: 20, bottom: 50, right: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Container(
                            child: SvgPicture.asset("images/white_dot.svg"),
                          ),

                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(Languages.of(context)!.makesurefilelable,
                                style: TextStyle(
                                    color: Constants.whitetext,
                                    fontSize: 13,
                                    fontFamily: Constants.app_font)),
                          ),
                        ])),
                  ],
                ),
              );
            },
          );
        });
  }

  void _ChooseLicenceImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      Languages.of(context)!.photoliblable,
                      style: TextStyle(fontFamily: Constants.app_font),
                    ),
                    onTap: () {
                      _LiimgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    Languages.of(context)!.cameralable,
                    style: TextStyle(fontFamily: Constants.app_font),
                  ),
                  onTap: () {
                    _LiimgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    print("Licence");
  }

  void _ChooseNationIdImage() {
    print("NationalId");

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      Languages.of(context)!.photoliblable,
                      style: TextStyle(fontFamily: Constants.app_font),
                    ),
                    onTap: () {
                      _NaimgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    Languages.of(context)!.cameralable,
                    style: TextStyle(fontFamily: Constants.app_font),
                  ),
                  onTap: () {
                    _NaimgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    print("Licence");

  }

  _LiimgFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _Licenceimage = File(pickedFile.path);
        try {
          String string = _Licenceimage!.path.toString();
          int lastIndex;
          lastIndex = string.lastIndexOf('/');

          String s = string.substring(lastIndex);

          String t = s.replaceAll(RegExp('/'), '');
          String finalName = t.replaceAll(RegExp('image_picker'), '');

          if (mounted) {
            setState(() {
              liname = finalName;
            });
          }
        } catch (e) {}
      } else {
        print('No image selected.');
      }
    });
  }

  Future _LiimgFromCamera() async {

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _Licenceimage = File(pickedFile.path);
        try {
          String string = _Licenceimage!.path.toString();
          int lastIndex;
          lastIndex = string.lastIndexOf('/');

          String s = string.substring(lastIndex);
          String t = s.replaceAll(RegExp('/'), '');
          String finalName = t.replaceAll(RegExp('image_picker'), '');

          if (mounted) {
            setState(() {
              liname = finalName;
            });
          }
        } catch (e) {}
      } else {
        print('No image selected.');
      }
    });
  }

  _NaimgFromGallery() async {

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _NationalIdImage = File(pickedFile.path);

        try {
          String string = _NationalIdImage!.path.toString();
          int lastIndex;
          lastIndex = string.lastIndexOf('/');

          String s = string.substring(lastIndex);

          String t = s.replaceAll(RegExp('/'), '');
          String finalName = t.replaceAll(RegExp('image_picker'), '');

          if (mounted) {
            setState(() {
              naname = finalName;
            });
          }
        } catch (e) {}
      } else {
        print('No image selected.');
      }
    });
  }

  Future _NaimgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _NationalIdImage = File(pickedFile.path);

        try {
          String string = _NationalIdImage!.path.toString();
          int lastIndex;
          lastIndex = string.lastIndexOf('/');

          String s = string.substring(lastIndex);

          String t = s.replaceAll(RegExp('/'), '');
          String finalName = t.replaceAll(RegExp('image_picker'), '');

          if (mounted) {
            setState(() {
              naname = finalName;
            });
          }
        } catch (e) {}
      } else {
        print('No image selected.');
      }
    });
  }
}

class Body1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Wrap(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 0, bottom: 0),
                child: Text(
                  Languages.of(context)!.foruploadfilelable,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Constants.greaytext,
                      fontFamily: Constants.app_font_bold,
                      fontSize: 12),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 0, bottom: 40),
                child: Text(
                  Languages.of(context)!.jpegandpnglable,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Constants.color_theme,
                      fontFamily: Constants.app_font_bold,
                      fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Vehicletype {

  final String? vehical_type;
  final String? license;

  Vehicletype({this.vehical_type, this.license});

  factory Vehicletype.fromJson(Map<String, dynamic> json) {
    return new Vehicletype(vehical_type: json['vehical_type'], license: json['license']);
  }

}
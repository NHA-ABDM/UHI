import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/access_token_controller.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/view.dart';

class SplashScreenPage extends StatefulWidget {
  String? fcmToken;

  SplashScreenPage({Key? key, this.fcmToken}) : super(key: key);

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  ///SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();
  final ThemeModeController _themeModeController =
      Get.put(ThemeModeController());
  final accessTokenController = Get.put(AccessTokenController());
  String? accessToken;
  bool? getAutoLoginFlag;
  var width;
  var height;

  @override
  void initState() {
    super.initState();

    //callApi();
    startTime();

    SharedPreferencesHelper.getAutoLoginFlag().then((value) => setState(() {
          setState(() {
            debugPrint(
                "Printing the shared preference getAutoLoginFlag : $value");
            getAutoLoginFlag = value;
          });
        }));

    log("${widget.fcmToken}", name: "FCM TOKEN SPLASHSCREEN");
  }

  callApi() async {
    await accessTokenController.postAccessTokenAPI();
  }

  startTime() async {
    var _duration = const Duration(milliseconds: 1500);
    return Timer(_duration, authenticate);
  }

  Future<void> authenticate() async {
    Navigator.of(context).pushReplacement(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      settings: RouteSettings(
          name: getAutoLoginFlag == true ? "/HomePage" : "/BaseLoginPage"),
      pageBuilder: (context, animation, secondaryAnimation) =>
          getAutoLoginFlag == true
              ? HomePage(
                  fcmToken: widget.fcmToken,
                )
              : BaseLoginPage(
                  fcmToken: widget.fcmToken,
                ),
      transitionDuration: const Duration(milliseconds: 1400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings().welcomeToText,
              style: AppTextStyle.textNormalStyle(
                  color: AppColors.doctorNameColor, fontSize: 20),
            ),
            SizedBox(
              height: 300,
              width: 400,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_logo.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

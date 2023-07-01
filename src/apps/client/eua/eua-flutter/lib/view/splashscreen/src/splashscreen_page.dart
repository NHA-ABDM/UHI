import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/common/src/get_pages.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/access_token_controller.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({
    Key? key,
  }) : super(key: key);

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
  bool getAutoLoginFlag = false;

  var width;
  var height;

  @override
  void initState() {
    super.initState();
    startTime();
    SharedPreferencesHelper.getAutoLoginFlag().then((value) => setState(() {
          setState(() {
            debugPrint(
                "Printing the shared preference getAutoLoginFlag : $value");
            getAutoLoginFlag = value ?? false;
          });
        }));
  }

  startTime() async {
    var _duration = const Duration(milliseconds: 1500);
    return Timer(_duration, authenticate);
  }

  // Future<void> authenticate() async {
  //   Navigator.of(context).pushReplacement(_createRoute());
  // }

  Future<void> authenticate() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      debugPrint('getInitialMessage message is ${message?.toMap()}');

      String nextRoute = AppRoutes.baseLoginPage;
      // if (_isLocalAuth) {
      //   if (getAutoLoginFlag) {
      //     nextRoute = AppRoutes.localAuthPage;
      //   } else {
      //     nextRoute = AppRoutes.baseLoginPage;
      //   }
      // } else {
      //   if (getAutoLoginFlag) {
      //     nextRoute = AppRoutes.homePage;
      //   } else {
      //     nextRoute = AppRoutes.baseLoginPage;
      //   }
      // }
      if (getAutoLoginFlag) {
        nextRoute = AppRoutes.homePage;
      } else {
        nextRoute = AppRoutes.baseLoginPage;
      }

      if (message != null) {
        checkMessageTypeAndOpenPage(message, nextRoute: nextRoute);
      } else {
        Get.offAllNamed(nextRoute);
      }
    });
  }

  // Route _createRoute() {
  //   return PageRouteBuilder(
  //     settings: _isLocalAuth
  //         ? RouteSettings(
  //             name: getAutoLoginFlag == true
  //                 ? AppRoutes.localAuthPage
  //                 : AppRoutes.baseLoginPage,
  //           )
  //         : RouteSettings(
  //             name: getAutoLoginFlag == true
  //                 ? AppRoutes.homePage
  //                 : AppRoutes.baseLoginPage,
  //           ),
  //     pageBuilder: (context, animation, secondaryAnimation) => _isLocalAuth
  //         ? getAutoLoginFlag == true
  //             ? LocalAuthPage()
  //             : BaseLoginPage()
  //         : getAutoLoginFlag == true
  //             ? HomePage()
  //             : BaseLoginPage(),
  //     transitionDuration: const Duration(milliseconds: 1400),
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       const begin = Offset(0.0, 1.0);
  //       const end = Offset.zero;
  //       const curve = Curves.ease;
  //       var tween =
  //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //       return SlideTransition(
  //         position: animation.drive(tween),
  //         child: child,
  //       );
  //     },
  //   );
  // }

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

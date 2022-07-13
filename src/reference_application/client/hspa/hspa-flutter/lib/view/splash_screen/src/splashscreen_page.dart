import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/view/dashboard/src/dashboard_page.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../role/src/user_role_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  ///SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = const Duration(milliseconds: 1500);
    return Timer(_duration, authenticate);
  }

  Future<void> authenticate() async {
    Widget screenToOpen = const UserRolePage();
    DoctorProfile? profile = await DoctorProfile.getSavedProfile();
    if(profile != null && profile.uuid != null) {
      screenToOpen = const DashboardPage();
    }
    Navigator.of(context).pushReplacement(_createRoute(screenToOpen : screenToOpen));
    // Get.offAll(_createRoute(screenToOpen: UserRolePage()));
  }

  Route _createRoute({required Widget screenToOpen}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          screenToOpen,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
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
            Center(
              child: Image.asset(
                AssetImages.splashLogo,
                height: 250,
                width: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

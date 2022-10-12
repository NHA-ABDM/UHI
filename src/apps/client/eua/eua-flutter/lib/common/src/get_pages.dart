import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/utils/src/check_internet.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/base_login_page.dart';
import 'package:uhi_flutter_app/view/chat/src/show_selected_media_page.dart';
import 'package:uhi_flutter_app/view/view.dart';

import '../../webrtc/src/video_call/group_video_call.dart';
import '../../webrtc/src/video_call/video_call.dart';

class AppRoutes {
  static const String splashPage = '/splash';
  static const String baseLoginPage = '/base_login_page';
  static const String homePage = '/home_page';
  static const String chatPage = '/chat_page';
  static const String localAuthPage = '/local_auth_page';
  static const String showSelectedMediaPage = '/show_selected_media_page';
  static const String upcomingAppointmentsPage = '/upcoming_appointments_page';
  static const String videoCallPage = '/video_call_page';
  static const String groupVideoCallPage = '/group_video_call_page';

  static void toNamed(
    String route, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    Get.toNamed(route, arguments: arguments, preventDuplicates: false);
  }
}

appRoutes() => [
      GetPage(
        name: AppRoutes.splashPage,
        page: () => const SplashScreenPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.baseLoginPage,
        page: () => const BaseLoginPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.homePage,
        page: () => const HomePage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.localAuthPage,
        page: () => const LocalAuthPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.chatPage,
        page: () => const ChatPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.showSelectedMediaPage,
        page: () => const ShowSelectedMediaPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.upcomingAppointmentsPage,
        page: () => const UpcomingAppointmentPage(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.videoCallPage,
        page: () => const VideoCall(),
        transition: CheckInternet.pageTransition,
      ),
      GetPage(
        name: AppRoutes.groupVideoCallPage,
        page: () => const GroupVideoCall(),
        transition: CheckInternet.pageTransition,
      ),
    ];

void checkMessageTypeAndOpenPage(RemoteMessage? message, {String? nextRoute}) {
  if (message != null) {
    Map<String, dynamic> data = message.data;
    if (data.containsKey('type') && data['type'] == 'chat') {
      String? patientABHAId = data['receiverAbhaAddress'];
      String? doctorHprId = data['senderAbhaAddress'];
      String? doctorGender = data['gender'];
      String? doctorName = data['senderName'];
      String? providerUri = data['providerUri'];
      String? transId = data['transId'];
      debugPrint('App current route is ${Get.currentRoute}');
      if (Get.currentRoute == AppRoutes.chatPage) {
        String? chatDoctorHprId = Get.arguments['doctorHprId'];
        String? chatPatientAbhaId = Get.arguments['patientAbhaId'];
        if (doctorHprId == chatDoctorHprId &&
            patientABHAId != chatPatientAbhaId) {
          AppRoutes.toNamed(AppRoutes.chatPage, arguments: {
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'doctorName': doctorName,
            'doctorGender': doctorGender,
            'providerUri': providerUri,
            'allowSendMessage': true,
            'transactionId': transId,
          });
        }
      } else {
        if (Get.currentRoute == AppRoutes.splashPage) {
          // Get.offAllNamed(AppRoutes.chatPage, arguments: {
          //   'doctorHprId': doctorHprId,
          //   'patientAbhaId': patientABHAId,
          //   'patientName': doctorName,
          //   'patientGender': doctorGender,
          //   'allowSendMessage': true
          // });
          Get.offAllNamed(AppRoutes.chatPage, arguments: <String, dynamic>{
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'doctorName': doctorName,
            'doctorGender': doctorGender,
            'providerUri': providerUri,
            'allowSendMessage': true,
          });
        } else {
          AppRoutes.toNamed(AppRoutes.chatPage, arguments: {
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'doctorName': doctorName,
            'doctorGender': doctorGender,
            'providerUri': providerUri,
            'allowSendMessage': true,
          });
        }
      }
    } else {
      if (Get.currentRoute == AppRoutes.splashPage && nextRoute != null) {
        Get.offAllNamed(nextRoute);
      } else {
        Get.toNamed(AppRoutes.homePage);
      }
    }
  }
}

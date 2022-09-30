import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/view/dashboard/src/consultation_details.dart';
import 'package:hspa_app/view/dashboard/src/dashboard_page.dart';
import 'package:hspa_app/view/doctor_setup/src/days_time_selection_page.dart';
import 'package:hspa_app/view/role/role.dart';
import 'package:hspa_app/view/splash_screen/splashscreen.dart';
import 'package:hspa_app/webRTC/src/video_call/group_video_call_primary.dart';
import 'package:hspa_app/webRTC/src/video_call/group_video_call_secondary.dart';
import 'package:hspa_app/webRTC/src/video_call/video_call.dart';

import '../../utils/src/utility.dart';
import '../../view/account_statement/src/account_statement_page.dart';
import '../../view/appointments/src/appointment_details_page.dart';
import '../../view/appointments/src/appointment_ongoing_page.dart';
import '../../view/appointments/src/appointments_page.dart';
import '../../view/appointments/src/cancel_appointment_page.dart';
import '../../view/appointments/src/consultation_completed_page.dart';
import '../../view/appointments/src/reschedule_appointments_page.dart';
import '../../view/appointments/src/share_physical_prescription_page.dart';
import '../../view/authentication/src/aadhaar_otp_auth_page.dart';
import '../../view/authentication/src/complete_provider_profile_page.dart';
import '../../view/authentication/src/login_provider_page.dart';
import '../../view/authentication/src/mobile_number_auth_page.dart';
import '../../view/authentication/src/otp_auth_page.dart';
import '../../view/authentication/src/register_provider_page.dart';
import '../../view/authentication/src/select_hpr_id_page.dart';
import '../../view/authentication/src/sign_up_with_aadhaar.dart';
import '../../view/chat/src/chat_page.dart';
import '../../view/chat/src/show_selected_media_page.dart';
import '../../view/dashboard/src/change_language_page.dart';
import '../../view/dashboard/src/notification_settings_page.dart';
import '../../view/dashboard/src/settings_page.dart';
import '../../view/dashboard/src/update_consultation_details_page.dart';
import '../../view/doctor_setup/src/add_upi_page.dart';
import '../../view/doctor_setup/src/calendar_with_slots_page.dart';
import '../../view/doctor_setup/src/fees_page.dart';
import '../../view/doctor_setup/src/setup_services.dart';
import '../../view/doctor_setup/src/take_upload_photo.dart';
import '../../view/local_auth/src/local_auth_page.dart';
import '../../view/profile/src/doctor_profile_page.dart';
import '../../view/profile/src/edit_profile_page.dart';
import '../../view/profile/src/profile_not_found_page.dart';
import '../../webRTC/src/call_sample/call_sample.dart';

class AppRoutes {
  static const String splashPage = '/splash';
  static const String userRolePage = '/user_role_page';
  static const String dashboardPage = '/dashboard';
  static const String consultationDetailsPage = '/consultation_details_page';
  static const String updateConsultationDetailsPage = '/update_consultation_details_page';
  static const String dayTimeSelectionPage = '/day_time_selection_page';
  static const String appointmentsPage = '/appointments_page';
  static const String appointmentDetailsPage = '/appointment_details_page';
  static const String appointmentOngoingPage = '/appointment_ongoing_page';
  static const String cancelAppointmentPage = '/cancel_appointment_page';
  static const String consultationCompletedPage = '/consultation_completed_page';
  static const String rescheduleAppointmentPage = '/reschedule_appointment_page';
  static const String sharePhysicalPrescriptionPage = '/share_physical_prescription_page';
  static const String aadhaarOTPAuthenticationPage = '/aadhaar_otp_authentication_page';
  static const String completeProviderProfilePage = '/complete_provider_profile_page';
  static const String loginProviderPage = '/login_provider_page';
  static const String mobileNumberAuthPage = '/mobile_number_auth_page';
  static const String otpAuthenticationPage = '/otp_authentication_page';
  static const String registerProviderPage = '/register_provider_page';
  static const String selectHprIdPage = '/select_hpr_id_page';
  static const String signUpWithAadhaarPage = '/sign_up_with_aadhaar_page';
  static const String chatPage = '/chat_page';
  static const String changeLanguagePage = '/change_language_page';
  static const String notificationSettingsPage = '/notification_settings_page';
  static const String settingsPage = '/settings_page';
  static const String addUpiPage = '/add_upi_page';
  static const String feesPage = '/fees_page';
  static const String setUpServicesPage = '/set_up_services_page';
  static const String takeUploadPhotoPage = '/take_upload_photo_page';
  static const String doctorProfilePage = '/doctor_profile_page';
  static const String editProfilePage = '/edit_profile_page';
  static const String profileNotFoundPage = '/profile_not_found_page';
  static const String callSample = '/call_sample';
  static const String videoCall = '/video_call';
  static const String groupVideoCallPrimary = '/group_video_call_primary';
  static const String groupVideoCallSecondary = '/group_video_call_secondary';
  static const String localAuthPage = '/local_auth_page';
  static const String showSelectedMediaPage = '/show_selected_media_page';
  static const String accountStatementPage = '/account_statement_page';
  static const String calendarWithSlotsPage = '/calendar_with_slots_page';

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
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.userRolePage,
        page: () => const UserRolePage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.dashboardPage,
        page: () => const DashboardPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.consultationDetailsPage,
        page: () => const ConsultationDetailsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.updateConsultationDetailsPage,
        page: () => const UpdateConsultationDetailsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.dayTimeSelectionPage,
        page: () => const DayTimeSelectionPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.appointmentsPage,
        page: () => const AppointmentsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.appointmentDetailsPage,
        page: () => const AppointmentDetailsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.appointmentOngoingPage,
        page: () => const AppointmentOngoingPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.cancelAppointmentPage,
        page: () => const CancelAppointmentPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.consultationCompletedPage,
        page: () => const ConsultationCompletedPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.rescheduleAppointmentPage,
        page: () => const RescheduleAppointmentPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.sharePhysicalPrescriptionPage,
        page: () => const SharePhysicalPrescriptionPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.aadhaarOTPAuthenticationPage,
        page: () => const AadhaarOTPAuthenticationPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.completeProviderProfilePage,
        page: () => const CompleteProviderProfilePage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.loginProviderPage,
        page: () => const LoginProviderPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.mobileNumberAuthPage,
        page: () => const MobileNumberAuthPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.otpAuthenticationPage,
        page: () => const OTPAuthenticationPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.registerProviderPage,
        page: () => const RegisterProviderPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.selectHprIdPage,
        page: () => const SelectHprIdPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.signUpWithAadhaarPage,
        page: () => const SignUpWithAadhaarPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.chatPage,
        page: () => const ChatPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.changeLanguagePage,
        page: () => const ChangeLanguagePage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.notificationSettingsPage,
        page: () => const NotificationSettingsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.addUpiPage,
        page: () => const AddUpiPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.feesPage,
        page: () => const FeesPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.setUpServicesPage,
        page: () => const SetUpServicesPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.takeUploadPhotoPage,
        page: () => const TakeUploadPhotoPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.doctorProfilePage,
        page: () => const DoctorProfilePage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.editProfilePage,
        page: () => const EditProfilePage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.profileNotFoundPage,
        page: () => const ProfileNotFoundPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.callSample,
        page: () => const CallSample(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.videoCall,
        page: () => const VideoCall(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.groupVideoCallPrimary,
        page: () => const GroupVideoCallPrimary(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.groupVideoCallSecondary,
        page: () => const GroupVideoCallSecondary(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.localAuthPage,
        page: () => const LocalAuthPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.settingsPage,
        page: () => const SettingsPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.showSelectedMediaPage,
        page: () => const ShowSelectedMediaPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.accountStatementPage,
        page: () => const AccountStatementPage(),
        transition: Utility.pageTransition,
      ),
      GetPage(
        name: AppRoutes.calendarWithSlotsPage,
        page: () => const CalendarWithSlotsPage(),
        transition: Utility.pageTransition,
      ),
    ];

void checkMessageTypeAndOpenPage(RemoteMessage? message, {String? nextRoute}) {
  if(message != null){
    Map<String, dynamic> data = message.data;
    if(data.containsKey('type') && data['type'] == 'chat') {
      String? doctorHprId = data['ReceiverabhaAddress'];
      String? patientABHAId = data['SenderabhaAddress'];
      String? patientGender = data['gender'];
      String? patientName = data['senderName'];
      debugPrint('App current route is ${Get.currentRoute}');
      if(Get.currentRoute == AppRoutes.chatPage) {
        String? chatDoctorHprId = Get.arguments['doctorHprId'];
        String? chatPatientAbhaId = Get.arguments['patientAbhaId'];
        if(doctorHprId == chatDoctorHprId && patientABHAId != chatPatientAbhaId) {
          AppRoutes.toNamed(AppRoutes.chatPage, arguments: {
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'patientName': patientName,
            'patientGender': patientGender,
            'allowSendMessage': true
          });
        }
      } else {
        if(Get.currentRoute == AppRoutes.splashPage) {
          Get.offAllNamed(AppRoutes.chatPage, arguments: {
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'patientName': patientName,
            'patientGender': patientGender,
            'allowSendMessage': true
          });
        } else {
          AppRoutes.toNamed(AppRoutes.chatPage, arguments: {
            'doctorHprId': doctorHprId,
            'patientAbhaId': patientABHAId,
            'patientName': patientName,
            'patientGender': patientGender,
            'allowSendMessage': true
          });
        }
      }
    } else {
      if(Get.currentRoute == AppRoutes.splashPage && nextRoute != null) {
        Get.offAllNamed(nextRoute);
      } else {
        Get.toNamed(AppRoutes.dashboardPage);
      }
    }
  }
}
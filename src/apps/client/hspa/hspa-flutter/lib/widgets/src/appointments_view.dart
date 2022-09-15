import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';

import '../../common/common.dart';
import '../../constants/src/asset_images.dart';
import '../../constants/src/strings.dart';
import '../../model/response/src/provider_appointments_response.dart';
import '../../model/src/doctor_profile.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';
import '../../utils/src/utility.dart';
import '../../view/appointments/src/appointment_details_page.dart';
import '../../view/appointments/src/cancel_appointment_page.dart';
import '../../view/appointments/src/reschedule_appointments_page.dart';
import '../../view/chat/src/chat_page.dart';
import '../../webRTC/src/call_sample/call_sample.dart';
import 'alert_dialog_with_single_action.dart';
import 'spacing.dart';
import 'square_rounded_button.dart';

class AppointmentsView extends StatelessWidget {
  AppointmentsView(
      {Key? key,
      required this.providerAppointment,
      required this.isTeleconsultation,
      required this.cancelAppointment,
      this.isPrevious = false})
      : super(key: key);
  final ProviderAppointments providerAppointment;
  final bool isTeleconsultation;
  final Function() cancelAppointment;
  bool isPrevious;

  @override
  Widget build(BuildContext context) {
    return (providerAppointment.status == 'SCHEDULED')
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(top: 2, left: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              providerAppointment.patient!.person!.display!,
                              style: AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.testColor, fontSize: 16),
                            ),
                            Spacing(),
                            Text(
                              Utility.getAppointmentDisplayDate(
                                  date: DateTime.parse(providerAppointment
                                      .timeSlot!.startDate!)),
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 16),
                            ),
                          ],
                        ),
                        VerticalSpacing(
                          size: 6,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              providerAppointment.reason ?? '',
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 12),
                            ),
                            Spacing(),
                            Text(
                              Utility.getAppointmentDisplayTimeRange(
                                  startDateTime: DateTime.parse(
                                      providerAppointment.timeSlot!.startDate!
                                          .split('.')
                                          .first),
                                  endDateTime: DateTime.parse(
                                      providerAppointment.timeSlot!.endDate!
                                          .split('.')
                                          .first)),
                              //Utility.getAppointmentDisplayTime(startDateTime:providerAppointment.timeSlot!.startDate!, endDateTime: providerAppointment.timeSlot!.endDate!),
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 12),
                            ),
                          ],
                        ),
                        Spacing(isWidth: false, size: 10),
                        if (!isPrevious)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: isTeleconsultation
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                if (!isTeleconsultation)
                                  SquareRoundedButton(
                                    text: AppStrings().btnStartConsultation,
                                    textStyle: AppTextStyle.textBoldStyle(
                                        color: AppColors.white, fontSize: 14),
                                    onPressed: () {
                                      //showAlertDialog(appointment: listAppointments[index]);
                                    },
                                  ),
                                IconButton(
                                  onPressed: () async {
                                    //DialogHelper.showComingSoonView();
                                    DoctorProfile? doctorProfile =
                                        await DoctorProfile.getSavedProfile();
                                    String? doctorHprId =
                                        doctorProfile?.hprAddress;
                                    String? patientABHAId = providerAppointment
                                        .patient?.abhaAddress;
                                    String? patientName = providerAppointment
                                        .patient?.person?.display;
                                    String? patientGender = providerAppointment
                                        .patient?.person?.gender;
                                    /*Get.to(
                                      () => ChatPage(
                                        doctorHprId: doctorHprId,
                                        patientAbhaId: patientABHAId,
                                        patientName: patientName,
                                        patientGender: patientGender,
                                        allowSendMessage: true,
                                      ),
                                      transition: Utility.pageTransition,
                                    );*/
                                    Get.toNamed(AppRoutes.chatPage, arguments: {
                                      'doctorHprId': doctorHprId,
                                      'patientAbhaId': patientABHAId,
                                      'patientName': patientName,
                                      'patientGender': patientGender,
                                      'allowSendMessage': true
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  icon: Image.asset(
                                    AssetImages.chat,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                                if (isTeleconsultation)
                                  IconButton(
                                    onPressed: () {
                                      DialogHelper.showComingSoonView();
                                    },
                                    visualDensity: VisualDensity.compact,
                                    icon: Image.asset(
                                      AssetImages.audio,
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                if (isTeleconsultation)
                                  IconButton(
                                    onPressed: () {
                                      /*Get.to(() => CallSample(host: '34.224.99.221'),
                                transition: Utility.pageTransition,);*/
                                      /*Get.to(
                                        () => const CallSample(
                                            host: '121.242.73.119'),
                                        transition: Utility.pageTransition,
                                      );*/
                                      Get.toNamed(AppRoutes.callSample, arguments: {'host': '121.242.73.119'});
                                    },
                                    visualDensity: VisualDensity.compact,
                                    icon: Image.asset(
                                      AssetImages.video,
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F3F4),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: showDoctorActionView(
                              assetImage: AssetImages.view,
                              color: AppColors.infoIconColor,
                              actionText: AppStrings().labelViewDetails,
                              onTap: () {
                                /*Get.to(
                                    () => AppointmentDetailsPage(
                                          isTeleconsultation:
                                              isTeleconsultation,
                                          providerAppointment:
                                              providerAppointment,
                                          isPrevious: isPrevious,
                                        ),
                                    transition: Utility.pageTransition);*/
                                Get.toNamed(AppRoutes.appointmentDetailsPage,
                                    arguments: <String, dynamic>{
                                      'isTeleconsultation': isTeleconsultation,
                                      'providerAppointment':
                                          providerAppointment,
                                      'isPrevious': isPrevious,
                                    });
                              }),
                        ),
                        //Spacing(isWidth: true),
                        if (!isPrevious)
                          Container(
                            color: const Color(0xFFF0F3F4),
                            height: 60,
                            width: 1,
                          ),
                        if (!isPrevious)
                          Expanded(
                            child: showDoctorActionView(
                                assetImage: AssetImages.cancel,
                                color: AppColors.infoIconColor,
                                actionText: AppStrings().labelCancel,
                                onTap: () async {
                                  bool isCancelled = /*await Get.to(
                                      () => CancelAppointmentPage(
                                          providerAppointment:
                                              providerAppointment),
                                      transition: Utility.pageTransition);*/
                                  await Get.toNamed(AppRoutes.cancelAppointmentPage, arguments: {'providerAppointment':
                                  providerAppointment});
                                  if (isCancelled) {
                                    cancelAppointment();
                                  }
                                }),
                          ),
                        if (!isPrevious)
                          Container(
                            color: const Color(0xFFF0F3F4),
                            height: 60,
                            width: 1,
                          ),
                        if (!isPrevious)
                          Expanded(
                            child: showDoctorActionView(
                                assetImage: AssetImages.reschedule,
                                color: AppColors.infoIconColor,
                                actionText: AppStrings().labelReschedule,
                                onTap: () {
                                  AlertDialogWithSingleAction(
                                    context: context,
                                    title:
                                        AppStrings().labelRescheduleAlertTitle,
                                    showIcon: true,
                                    iconAssetImage: AssetImages.appointments,
                                    onCloseTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    submitButtonText: AppStrings().close,
                                  ).showAlertDialog();
                                  /*Get.to(() => RescheduleAppointmentPage(appointment: providerAppointment),
                          transition: Utility.pageTransition,);*/
                                }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  showDoctorActionView(
      {required String assetImage,
      required Color color,
      required String actionText,
      required Function() onTap}) {
    return SizedBox(
      height: 60,
      child: InkWell(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.pressed)
              ? color.withAlpha(50)
              : null;
        }),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetImage,
              height: 20,
              width: 20,
            ),
            Spacing(size: 5),
            Text(
              actionText,
              style: AppTextStyle.textNormalStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/src/appointment_status.dart';
import '../../constants/src/get_pages.dart';
import '../../constants/src/request_urls.dart';
import '../../model/response/src/hspa_appointments_response.dart';
import 'vertical_spacing.dart';

import '../../common/common.dart';
import '../../constants/src/asset_images.dart';
import '../../constants/src/strings.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';
import '../../utils/src/utility.dart';
import 'alert_dialog_with_single_action.dart';
import 'spacing.dart';
import 'square_rounded_button.dart';

class HSPAAppointmentsView extends StatelessWidget {
  const HSPAAppointmentsView(
      {Key? key,
      required this.providerAppointment,
      required this.isTeleconsultation,
      required this.cancelAppointment,
      this.isPrevious = false})
      : super(key: key);
  final HSPAAppointments providerAppointment;
  final bool isTeleconsultation;
  final Function() cancelAppointment;
  final bool isPrevious;

  @override
  Widget build(BuildContext context) {
    return (providerAppointment.isServiceFulfilled == AppointmentStatus.confirmed)
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
                              providerAppointment.patientName!,
                              style: AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.testColor, fontSize: 16),
                            ),
                            Spacing(),
                            Text(
                              Utility.getAppointmentDisplayDate(
                                  date: DateTime.parse(providerAppointment
                                      .serviceFulfillmentStartTime!)),
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
                              providerAppointment.healthcareServiceName ?? '',
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 12),
                            ),
                            Spacing(),
                            Text(
                              Utility.getAppointmentDisplayTimeRange(
                                  startDateTime: DateTime.parse(
                                      providerAppointment.serviceFulfillmentStartTime!),
                                  endDateTime: DateTime.parse(
                                      providerAppointment.serviceFulfillmentEndTime!)),
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
                                    String? doctorHprId =
                                        providerAppointment.healthcareProfessionalId;
                                    String? patientABHAId = providerAppointment
                                        .abhaId;
                                    String? patientName = providerAppointment
                                        .patientName;
                                    //TODO this needs to be changed as we would required patient gender from API end
                                    String? patientGender = providerAppointment
                                        .healthcareProfessionalGender;
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
                                      'appointmentTransactionId': providerAppointment.transId ?? '',
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
                                    onPressed: () async{
                                      /*Get.to(() => CallSample(host: '34.224.99.221'),
                                      transition: Utility.pageTransition,);*/
                                      /*bool isShowChat = await Get.toNamed(AppRoutes.callSample, arguments: {'host': '121.242.73.119'});
                                      debugPrint('isShowChat $isShowChat');
                                      if(isShowChat) {*/
                                        String? doctorHprId =
                                            providerAppointment.healthcareProfessionalId;
                                        String? patientABHAId = providerAppointment
                                            .abhaId;
                                        String? patientName = providerAppointment
                                            .patientName;
                                        String? patientGender = providerAppointment
                                            .healthcareProfessionalGender;

                                        /*Get.toNamed(AppRoutes.chatPage, arguments: {
                                          'doctorHprId': doctorHprId,
                                          'patientAbhaId': patientABHAId,
                                          'patientName': patientName,
                                          'patientGender': patientGender,
                                          'appointmentTransactionId': providerAppointment.transId ?? '',
                                          'allowSendMessage': true
                                        });
                                      }*/

                                        /// Latest Code shared by Airesh for Group Consultation

                                        /// To initiate one to one call
                                        if (providerAppointment.groupConsultStatus == null
                                            || !providerAppointment.groupConsultStatus!) {
                                          Get.toNamed(AppRoutes.videoCall,
                                              arguments: {
                                                'initiator': {
                                                  'address': doctorHprId,
                                                  'uri': providerAppointment.healthcareProviderUrl
                                                },
                                                'remoteParticipant': {
                                                  'name': patientName,
                                                  'gender': patientGender,
                                                  'address': patientABHAId,
                                                  'uri': providerAppointment.patientConsumerUri,
                                                  // 'uri': RequestUrls.consumerUri,
                                                },
                                                'appointmentTransactionId': providerAppointment.transId,
                                              },
                                          );
                                        }
                                        if (providerAppointment.groupConsultStatus != null
                                            && providerAppointment.groupConsultStatus!) {
                                          /// To initiate group call and if user is primary doctor
                                          if(providerAppointment.primaryDoctorHprAddress == doctorHprId) {
                                            Get.toNamed(AppRoutes.groupVideoCallPrimary,
                                                arguments: {
                                                  'host': '121.242.73.119',
                                                  'initiator': {
                                                    'address': doctorHprId,
                                                    'uri': providerAppointment.primaryDoctorProviderUri
                                                  },
                                                  'remotePatient': {
                                                    'name': patientName,
                                                    'gender': patientGender,
                                                    'address': patientABHAId,
                                                    'uri': providerAppointment.patientConsumerUri,
                                                    // 'uri': RequestUrls.consumerUri,
                                                  },
                                                  'remoteDoctor': {
                                                    'name': providerAppointment.secondaryDoctorName,
                                                    'gender': providerAppointment.secondaryDoctorGender,
                                                    'address': providerAppointment.secondaryDoctorHprAddress,
                                                    'uri': providerAppointment.secondaryDoctorProviderUri,
                                                    // 'uri': 'http://100.96.9.171:8084/api/v1',
                                                  },
                                                  'appointmentTransactionId': providerAppointment.transId,
                                                });
                                          } else {
                                            /// To initiate group call and if user is secondary doctor
                                            Get.toNamed(
                                                AppRoutes.groupVideoCallSecondary,
                                                arguments: {
                                                  'host': '121.242.73.119',
                                                  'initiator': {
                                                    'address': doctorHprId,
                                                    'uri': providerAppointment.secondaryDoctorProviderUri
                                                  },
                                                  'remotePatient': {
                                                    'name': patientName,
                                                    'gender': patientGender,
                                                    'address': patientABHAId,
                                                    'uri': providerAppointment.patientConsumerUri,
                                                    // 'uri': RequestUrls.consumerUri,
                                                  },
                                                  'remoteDoctor': {
                                                    'name': providerAppointment.primaryDoctorName,
                                                    'gender': providerAppointment.primaryDoctorGender,
                                                    'address': providerAppointment.primaryDoctorHprAddress,
                                                    'uri': providerAppointment.primaryDoctorProviderUri,
                                                    // 'uri': 'http://100.96.9.171:8084/api/v1',
                                                  },
                                                  'appointmentTransactionId': providerAppointment.transId,
                                                });
                                          }
                                        }
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
                                Get.toNamed(AppRoutes.appointmentDetailsPage,
                                    arguments: <String, dynamic>{
                                      'isTeleconsultation': isTeleconsultation,
                                      'providerAppointment':
                                          providerAppointment,
                                      'isPrevious': isPrevious,
                                      'isOpenMrsAppointment': false,
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
                                  bool isCancelled = await Get.toNamed(
                                      AppRoutes.cancelAppointmentPage,
                                      arguments: {
                                        'providerAppointment': providerAppointment,
                                        'isOpenMrsAppointment': false,}
                                  );
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

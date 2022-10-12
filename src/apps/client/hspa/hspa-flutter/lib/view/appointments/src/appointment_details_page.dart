import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/appointments_controller.dart';
import '../../../model/response/src/appointment_details_response.dart';
import '../../../model/src/appointment_updates.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/vertical_spacing.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  List<AppointmentUpdates> listAppointmentUpdates = <AppointmentUpdates>[];
  List<Widget> children = <Widget>[];
  late DateFormat _dateFormat;
  bool _isLoading = false;

  /// Arguments
  dynamic providerAppointment;
  // late final ProviderAppointments providerAppointment;
  late final bool isTeleconsultation;
  late final bool isPrevious;
  late final bool isOpenMrsAppointment;

  @override
  void initState() {

    /// Get Arguments
    providerAppointment = Get.arguments['providerAppointment'];
    isTeleconsultation = Get.arguments['isTeleconsultation'];
    isPrevious = Get.arguments['isPrevious'];
    isOpenMrsAppointment = Get.arguments['isOpenMrsAppointment'];

    _dateFormat = DateFormat('dd MMMM, hh:mm aa');
    listAppointmentUpdates.add(AppointmentUpdates(
        updateDateTime: isOpenMrsAppointment
            ? DateTime.parse(providerAppointment.timeSlot!.startDate!.split('.').first)
            : DateTime.parse(providerAppointment.serviceFulfillmentStartTime!),
        updateDetails: isOpenMrsAppointment
            ? providerAppointment.status!
            : providerAppointment.isServiceFulfilled!),
    );
    generateListChildren();
    getAppointmentDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            AppStrings().labelViewDetails,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpacing(
              size: 8,
            ),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin:
                  const EdgeInsets.only(top: 2, left: 10, right: 10, bottom: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOpenMrsAppointment
                                  ? providerAppointment.patient!.person!.display!
                                  : providerAppointment.patientName!,
                              style: AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.testColor, fontSize: 16),
                            ),
                            Spacing(),
                            Text(
                              isOpenMrsAppointment
                                  ? Utility.getAppointmentDisplayDate(
                                      date: DateTime.parse(providerAppointment
                                          .timeSlot!.startDate!))
                                  : Utility.getAppointmentDisplayDate(
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
                              isOpenMrsAppointment
                                  ? providerAppointment.reason ?? ''
                              : providerAppointment.healthcareServiceName ?? '',
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 12),
                            ),
                            Spacing(),
                            Text(
                              isOpenMrsAppointment
                                  ? Utility.getAppointmentDisplayTimeRange(
                                      startDateTime: DateTime.parse(
                                          providerAppointment
                                              .timeSlot!.startDate!
                                              .split('.')
                                              .first),
                                      endDateTime: DateTime.parse(
                                          providerAppointment.timeSlot!.endDate!
                                              .split('.')
                                              .first))
                                  : Utility.getAppointmentDisplayTimeRange(
                                      startDateTime: DateTime.parse(
                                          providerAppointment
                                              .serviceFulfillmentStartTime!),
                                      endDateTime: DateTime.parse(
                                          providerAppointment
                                              .serviceFulfillmentEndTime!)),
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.testColor, fontSize: 12),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  //DialogHelper.showComingSoonView();
                                  DoctorProfile? doctorProfile =
                                      await DoctorProfile.getSavedProfile();
                                  String? doctorHprId =
                                      doctorProfile?.hprAddress;
                                  String? patientABHAId = isOpenMrsAppointment
                                      ? providerAppointment.patient?.abhaAddress
                                      : providerAppointment.abhaId;
                                  String? patientName = isOpenMrsAppointment
                                      ? providerAppointment
                                          .patient?.person?.display
                                      : providerAppointment.patientName;
                                  String? patientGender = isOpenMrsAppointment
                                      ? providerAppointment
                                          .patient?.person?.gender
                                      : providerAppointment
                                          .healthcareProfessionalGender;
                                  String? appointmentTransactionId = isOpenMrsAppointment
                                      ? providerAppointment.uuid
                                      : providerAppointment.transId;

                                  Get.toNamed(AppRoutes.chatPage, arguments: {
                                    'doctorHprId': doctorHprId,
                                    'patientAbhaId': patientABHAId,
                                    'patientName': patientName,
                                    'patientGender': patientGender,
                                    'appointmentTransactionId': appointmentTransactionId,
                                    'allowSendMessage': !isPrevious
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
                                  onPressed: () {},
                                  visualDensity: VisualDensity.compact,
                                  icon: Image.asset(
                                    AssetImages.audio,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              if (isTeleconsultation && !isPrevious)
                                IconButton(
                                  onPressed: () async{
                                    bool isShowChat = await Get.toNamed(AppRoutes.callSample, arguments: {'host': '121.242.73.119'});

                                    if (isShowChat) {
                                      DoctorProfile? doctorProfile =
                                          await DoctorProfile.getSavedProfile();
                                      String? doctorHprId =
                                          doctorProfile?.hprAddress;
                                      String? patientABHAId =
                                          isOpenMrsAppointment
                                              ? providerAppointment
                                                  .patient?.abhaAddress
                                              : providerAppointment.abhaId;
                                      String? patientName = isOpenMrsAppointment
                                          ? providerAppointment
                                              .patient?.person?.display
                                          : providerAppointment.patientName;
                                      String? patientGender =
                                          isOpenMrsAppointment
                                              ? providerAppointment
                                                  .patient?.person?.gender
                                              : providerAppointment
                                                  .healthcareProfessionalGender;
                                      String? appointmentTransactionId = isOpenMrsAppointment
                                          ? providerAppointment.uuid
                                          : providerAppointment.transId;

                                      Get.toNamed(AppRoutes.chatPage,
                                          arguments: {
                                            'doctorHprId': doctorHprId,
                                            'patientAbhaId': patientABHAId,
                                            'patientName': patientName,
                                            'patientGender': patientGender,
                                            'appointmentTransactionId': appointmentTransactionId,
                                            'allowSendMessage': !isPrevious
                                          });
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
                ],
              ),
            ),
            VerticalSpacing(
              size: 24,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Text(
                AppStrings().labelAppointmentUpdates,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.black, fontSize: 18),
              ),
            ),
            VerticalSpacing(
              size: 20,
            ),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: children,
              /*[
                  generateDetailRow(firstKey: DateFormat('dd MMMM, HH:MM aa').format(listAppointmentUpdates[0].updateDateTime), firstValue: listAppointmentUpdates[0].updateDetails, secondKey: DateFormat('dd MMMM, HH:MM aa').format(listAppointmentUpdates[1].updateDateTime), secondValue: listAppointmentUpdates[1].updateDetails),
                  generateDetailRow(firstKey: DateFormat('dd MMMM, HH:MM aa').format(listAppointmentUpdates[2].updateDateTime), firstValue: listAppointmentUpdates[0].updateDetails, secondKey: DateFormat('dd MMMM, HH:MM aa').format(listAppointmentUpdates[3].updateDateTime), secondValue: listAppointmentUpdates[1].updateDetails),
              ],*/
            ),
          ],
        ),
      ),
    );
  }

  generateUpdateDetailRow(
      {required AppointmentUpdates firstAppointmentUpdates,
      required AppointmentUpdates? secondAppointmentUpdates}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: generateUpdateDetailsView(
                      appointmentUpdates: firstAppointmentUpdates)),
              const VerticalDivider(
                color: AppColors.dividerColor,
                thickness: 1,
              ),
              Expanded(
                  child: secondAppointmentUpdates != null
                      ? generateUpdateDetailsView(
                          appointmentUpdates: secondAppointmentUpdates)
                      : Container()),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child:
              Divider(thickness: 1, color: AppColors.dividerColor, height: 1),
        ),
      ],
    );
  }

  generateUpdateDetailsView({required AppointmentUpdates appointmentUpdates}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appointmentUpdates.status == null
                ? _dateFormat.format(appointmentUpdates.updateDateTime)
                : appointmentUpdates.status!,
            style: AppTextStyle.textSemiBoldStyle(
                fontSize: 13,
                color: appointmentUpdates.status == null
                    ? AppColors.drNameTextColor
                    : AppColors.requestedStatusColor),
          ),
          Spacing(
            isWidth: false,
            size: 6,
          ),
          Text(
            appointmentUpdates.updateDetails.capitalizeFirst!,
            style: AppTextStyle.textNormalStyle(
                fontSize: 13, color: AppColors.drDetailsTextColor),
          ),
        ],
      ),
    );
  }

  void generateListChildren() {
    if (listAppointmentUpdates.length % 2 == 0) {
      for (int i = 0; i < listAppointmentUpdates.length; i = i + 2) {
        children.add(generateUpdateDetailRow(
            firstAppointmentUpdates: listAppointmentUpdates[i],
            secondAppointmentUpdates: listAppointmentUpdates[i + 1]));
      }
    } else {
      AppointmentUpdates lastUpdate =
          listAppointmentUpdates[listAppointmentUpdates.length - 1];
      for (int i = 0; i < listAppointmentUpdates.length - 1; i = i + 2) {
        children.add(generateUpdateDetailRow(
            firstAppointmentUpdates: listAppointmentUpdates[i],
            secondAppointmentUpdates: listAppointmentUpdates[i + 1]));
      }
      children.add(generateUpdateDetailRow(
          firstAppointmentUpdates: lastUpdate, secondAppointmentUpdates: null));
    }
  }

  Future<void> getAppointmentDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });
      AppointmentsController appointmentsController = AppointmentsController();
      AppointmentDetailsResponse? appointmentDetailsResponse =
          await appointmentsController.getAppointmentDetails(
              appointmentUUID: isOpenMrsAppointment ? providerAppointment.uuid! : providerAppointment.appointmentId!);

      debugPrint(
          'Get appointment details response is ${appointmentDetailsResponse?.results}');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Get appointment details exception is ${e.toString()}');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/appointments_controller.dart';
import '../../../model/response/src/appointment_details_response.dart';
import '../../../model/response/src/provider_appointments_response.dart';
import '../../../model/src/appointment_updates.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/vertical_spacing.dart';
import '../../chat/src/chat_page.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({Key? key}) : super(key: key);

/*  const AppointmentDetailsPage({
    Key? key,
    required this.isTeleconsultation,
    required this.providerAppointment,
    required this.isPrevious,
  }) : super(key: key);
  final ProviderAppointments providerAppointment;
  final bool isTeleconsultation;
  final bool isPrevious;*/

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  List<AppointmentUpdates> listAppointmentUpdates = <AppointmentUpdates>[];
  List<Widget> children = <Widget>[];
  late DateFormat _dateFormat;
  bool _isLoading = false;

  /// Arguments
  late final ProviderAppointments providerAppointment;
  late final bool isTeleconsultation;
  late final bool isPrevious;

  @override
  void initState() {

    /// Get Arguments
    providerAppointment = Get.arguments['providerAppointment'];
    isTeleconsultation = Get.arguments['isTeleconsultation'];
    isPrevious = Get.arguments['isPrevious'];

    _dateFormat = DateFormat('dd MMMM, hh:mm aa');
    listAppointmentUpdates.add(AppointmentUpdates(
        updateDateTime: DateTime.parse(
            providerAppointment.timeSlot!.startDate!.split('.').first),
        updateDetails: providerAppointment.status!));
    // listAppointmentUpdates.add(AppointmentUpdates(updateDateTime: DateTime(2022, 4, 13, 16, 10), updateDetails: 'Reschedule Requested'));
    // listAppointmentUpdates.add(AppointmentUpdates(updateDateTime: DateTime(2022, 4, 13, 17, 20), updateDetails: 'Reschedule Accepted'));
    // listAppointmentUpdates.add(AppointmentUpdates(updateDateTime: DateTime(2022, 4, 13, 17, 30), updateDetails: 'Appointment Status', status: 'In Progress'));
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
                              providerAppointment.patient!.person!
                                  .display!,
                              style: AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.testColor, fontSize: 16),
                            ),
                            Spacing(),
                            Text(
                              Utility.getAppointmentDisplayDate(
                                  date: DateTime.parse(providerAppointment
                                      .timeSlot!
                                      .startDate!)),
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
                                  endDateTime: DateTime.parse(providerAppointment.timeSlot!.endDate!
                                      .split('.')
                                      .first)),
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
                                  String? patientABHAId = providerAppointment.patient?.abhaAddress;
                                  String? patientName = providerAppointment
                                      .patient
                                      ?.person
                                      ?.display;
                                  String? patientGender = providerAppointment
                                      .patient
                                      ?.person
                                      ?.gender;
                                  /*Get.to(
                                    () => ChatPage(
                                      doctorHprId: doctorHprId,
                                      patientAbhaId: patientABHAId,
                                      patientName: patientName,
                                      patientGender: patientGender,
                                      allowSendMessage: !isPrevious,
                                    ),
                                    transition: Utility.pageTransition,
                                  );*/
                                  Get.toNamed(AppRoutes.chatPage, arguments: {
                                    'doctorHprId': doctorHprId,
                                    'patientAbhaId': patientABHAId,
                                    'patientName': patientName,
                                    'patientGender': patientGender,
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
                                  onPressed: () {
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
              appointmentUUID: providerAppointment.uuid!);

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

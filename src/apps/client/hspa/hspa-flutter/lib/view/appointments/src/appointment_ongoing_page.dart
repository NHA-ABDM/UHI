import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';

import '../../../constants/src/strings.dart';
import '../../../model/src/appointments.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button.dart';
import '../../../widgets/src/vertical_spacing.dart';

class AppointmentOngoingPage extends StatefulWidget {
  const AppointmentOngoingPage({Key? key}) : super(key: key);

/*  const AppointmentOngoingPage({Key? key, required this.appointment, required this.isTeleconsultation}) : super(key: key);
  final Appointments appointment;
  final bool isTeleconsultation;*/

  @override
  State<AppointmentOngoingPage> createState() => _AppointmentOngoingPageState();
}

class _AppointmentOngoingPageState extends State<AppointmentOngoingPage> {

  /// Arguments
  late final Appointments appointment;
  late final bool isTeleconsultation;

  @override
  void initState() {
    /// Get Arguments
    appointment = Get.arguments['appointment'];
    isTeleconsultation = Get.arguments['isTeleconsultation'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().labelAppointments,
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
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Your appointment with ${appointment.name} is ongoing.', style: AppTextStyle.textSemiBoldStyle(fontSize: 18, color: AppColors.titleTextColor),),
          VerticalSpacing(size: 16,),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appointment.name,
                            style: AppTextStyle.textSemiBoldStyle(
                                color: AppColors.testColor, fontSize: 16),
                          ),
                          const Spacing(),
                          Text(
                            appointment.appointmentDate,
                            style: AppTextStyle
                                .textNormalStyle(
                                color: AppColors.testColor, fontSize: 16),
                          ),
                        ],
                      ),
                      VerticalSpacing(size: 6,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appointment.visitType,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.testColor, fontSize: 12),
                          ),
                          const Spacing(),
                          Text(
                            appointment.appointmentTime,
                            style: AppTextStyle
                                .textNormalStyle(
                                color: AppColors.testColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalSpacing(size: 36,),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              child: SquareRoundedButton(
                  text: AppStrings().btnEndConsultation,
                  textStyle: AppTextStyle.textBoldStyle(fontSize: 14, color: AppColors.white),
                  onPressed: (){
                    /*Get.to(() => ConsultationCompletedPage(
                      appointment: appointment,
                      isTeleconsultation: isTeleconsultation,
                    ),
                      transition: Utility.pageTransition,
                    );*/
                    Get.toNamed(AppRoutes.consultationCompletedPage,
                        arguments: {'appointment': appointment,
                      'isTeleconsultation': isTeleconsultation,
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

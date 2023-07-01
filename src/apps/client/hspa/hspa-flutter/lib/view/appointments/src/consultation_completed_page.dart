import 'package:flutter/material.dart';import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';

import '../../../constants/src/strings.dart';
import '../../../model/src/appointments.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';

class ConsultationCompletedPage extends StatefulWidget {
  const ConsultationCompletedPage({Key? key}) : super(key: key);

/*  const ConsultationCompletedPage({Key? key, required this.appointment, required this.isTeleconsultation}) : super(key: key);
  final Appointments appointment;
  final bool isTeleconsultation;*/
  
  @override
  State<ConsultationCompletedPage> createState() => _ConsultationCompletedPageState();
}

class _ConsultationCompletedPageState extends State<ConsultationCompletedPage> {

  /// Arguments
  late final Appointments appointment;
  late final bool isTeleconsultation;

  @override
  void initState() {
    /// Get arguments
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
          isTeleconsultation ? AppStrings().labelTeleconsultationAppointment : AppStrings().labelPhysicalConsultationAppointment,
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            confirmStatusView(),
            const Spacing(isWidth: false, size: 8),
            Container(
              padding: const EdgeInsets.only(left: 12.0, right: 4),
              child: Text(
                isTeleconsultation ?
                '${AppStrings().labelTeleconsultationCompleted} ${appointment.name}'
                    : '${AppStrings().labelPhysicalConsultationCompleted} ${appointment.name}',
                style: AppTextStyle.textNormalStyle(fontSize: 12, color: AppColors.testColor),
              ),
            ),
            //Spacing(size: 20, isWidth: false),
            doctorCardView(),
          ],
        ),
      ),
    );
  }


  confirmStatusView() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            AssetImages.checked,
            height: 20,
            width: 20,
            color: AppColors.appointmentStatusColor,
          ),
          const Spacing(size: 8),
          Text(
            AppStrings().labelConsultationCompleted,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.appointmentStatusColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  doctorCardView() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35.0),
                          child: FadeInImage(
                              width: 70,
                              height: 70,
                              fit: BoxFit.fill,
                              image:  Image.network(
                                AppStrings.getProfilePhoto(gender: null),
                              ).image,
                              imageErrorBuilder: (context, obj, stackTrace) {
                                return Image.asset(AssetImages.doctorPlaceholder);
                              },
                              placeholder: const AssetImage(AssetImages.doctorPlaceholder)),
                        )
                    ),

                    const Spacing(size: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.name,
                          style: AppTextStyle
                              .textSemiBoldStyle(
                              fontSize: 16,
                              color: AppColors.testColor),
                        ),
                        Text(
                          appointment.visitType,
                          style: AppTextStyle
                              .textNormalStyle(
                              color: AppColors.testColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacing(isWidth: false, size: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appointment.appointmentDate,
                        style: AppTextStyle.textSemiBoldStyle(
                            fontSize: 18, color: AppColors.testColor),
                      ),
                      const Spacing(),
                      Text(
                        appointment.appointmentTime,
                        style: AppTextStyle.textSemiBoldStyle(
                            fontSize: 18, color: AppColors.testColor),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                showDoctorActionView(
                    assetImage: AssetImages.prescription,
                    color: AppColors.tileColors,
                    actionText: AppStrings().btnSharePrescription,
                    onTap: () {
                      if(!isTeleconsultation){
                        /*Get.to(() => SharePhysicalPrescriptionPage(appointment: appointment,),
                          transition: Utility.pageTransition,);*/
                        Get.toNamed(AppRoutes.sharePhysicalPrescriptionPage, arguments: {'appointment': appointment});
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showDoctorActionView(
      {required String assetImage,
        required Color color,
        required String actionText,
        required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetImage,
            height: 24,
            width: 24,
            color: color,
          ),
          const Spacing(size: 5),
          Text(
            actionText,
            style: AppTextStyle.textLightStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

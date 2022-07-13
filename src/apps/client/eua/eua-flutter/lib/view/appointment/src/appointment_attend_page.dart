import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

class AppointmentAttendPage extends StatefulWidget {
  BookingConfirmResponseModel? bookingConfirmResponse;
  String? consultationType;

  AppointmentAttendPage({
    Key? key,
    required this.bookingConfirmResponse,
    required this.consultationType,
  }) : super(key: key);

  @override
  State<AppointmentAttendPage> createState() => _AppointmentAttendPageState();
}

class _AppointmentAttendPageState extends State<AppointmentAttendPage> {
  ///SCREEN WIDTH
  var width;

  ///SCREEN HEIGHT
  var height;

  ///SCREEN ORIENTATION
  var isPortrait;

  ///POST APPOINTMENT COMPLETED API
  postAppointmentStatusAPI() {}

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.darkGrey323232,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        titleSpacing: 0,
        title: Text(
          AppStrings().appointmentStatusConfirmPagePhysicalConsultationTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                "Did you attend your appointment with Dr.Bhatt at Fortis Hospital Vasant Kunj?",
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.black, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Spacing(
              isWidth: false,
              size: 20,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      postAppointmentStatusAPI();
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(50, 12, 50, 12),
                      decoration: BoxDecoration(
                        color: AppColors.amountColor,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColors.amountColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        AppStrings().yes.toUpperCase(),
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  Spacing(
                    size: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      postAppointmentStatusAPI();
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(50, 12, 50, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColors.primaryLightBlue007BFF,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        AppStrings().no.toUpperCase(),
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.primaryLightBlue007BFF,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacing(
              isWidth: false,
              size: 20,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 8, top: 8),
                    child: Text(
                      AppStrings().appointmentEventTimeline,
                      style: AppTextStyle.appointmentConfirmedBold14TextStyle(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 8),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              endIndent: 7,
                              color: Color(0xFFF0F3F4)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                appointmentTimelineTitle(
                                    title: AppStrings().appointmentConfirmed),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       left: 24.0, right: 8, top: 4),
                                //   child: Text(
                                //     '10th April 13:10pm',
                                //     style: AppTextStyle
                                //         .appointmentConfirmedBold14TextStyle(
                                //             color: AppColors.doctorNameColor),
                                //   ),
                                // ),
                                // appointmentConfirmKey(
                                //     text: AppStrings().sendAMessagetodoctor),
                                // appointmentConfirmValue(text: '10th April 13:10pm'),
                                // appointmentConfirmKey(
                                //     text: AppStrings().doctorSendMessage),
                                // appointmentConfirmValue(text: '11th April 13:10pm'),
                                // appointmentConfirmKey(
                                //     text: AppStrings().canJoinTheCallPrior),
                                // appointmentConfirmValue(text: '12th April 11:00am'),
                                // appointmentTimelineTitle(
                                //     title: AppStrings().appointmentInProgress,
                                //     color: AppColors
                                //         .appointmentConfirmDoctorActionsTextColor),
                                // appointmentTimelineTitle(
                                //     title: AppStrings().appointmentCompleted,
                                //     color: AppColors
                                //         .appointmentConfirmDoctorActionsTextColor),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  appointmentTimelineTitle(
      {required String title, Color color = AppColors.doctorNameColor}) {
    return Padding(
      padding: const EdgeInsets.only(left: 00.0, top: 16),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            color: Color(0xFFF0F3F4),
            width: 20,
            height: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 8),
              child: Text(
                title,
                style: AppTextStyle.appointmentConfirmedBold14TextStyle(
                    color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

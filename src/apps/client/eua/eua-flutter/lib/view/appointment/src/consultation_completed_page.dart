import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/chat/src/chat_page.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import 'package:get/get.dart';

class ConsultationCompletedPage extends StatefulWidget {
  BookingConfirmResponseModel? bookingConfirmResponseModel;
  String? startDateTime;
  String? endDateTime;
  String? doctorName;
  String? gender;
  ConsultationCompletedPage(
      {Key? key,
      this.bookingConfirmResponseModel,
      this.startDateTime,
      this.endDateTime,
      this.doctorName,
      this.gender})
      : super(key: key);

  @override
  State<ConsultationCompletedPage> createState() =>
      _ConsultationCompletedPageState();
}

class _ConsultationCompletedPageState extends State<ConsultationCompletedPage> {
  ///SIZE
  late double width;
  BookingConfirmResponseModel? _bookingConfirmResponseModel;
  String? userAbhaAddress;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            userAbhaAddress = value;
          });
        }));
    _bookingConfirmResponseModel = widget.bookingConfirmResponseModel;
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;

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
          AppStrings().appointmentStatusConfirmPageTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            confirmStatusView(),
            Spacing(isWidth: false, size: 8),
            Center(
              child: Text(
                AppStrings().teleconsultationAppointmentConfirm,
                style: AppTextStyle.appointmentConfirmedLightTextStyle(),
              ),
            ),
            //Spacing(size: 20, isWidth: false),
            doctorCardView(),

            // Padding(
            //   padding: const EdgeInsets.only(left: 20.0, right: 8, top: 8),
            //   child: Text(
            //     AppStrings().appointmentEventTimeline,
            //     style: AppTextStyle.appointmentConfirmedBold14TextStyle(),
            //   ),
            // ),

            // Padding(
            //   padding: const EdgeInsets.only(left: 20.0, top: 8),
            //   child: IntrinsicHeight(
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.stretch,
            //       children: [
            //         const VerticalDivider(
            //             width: 1,
            //             thickness: 1,
            //             endIndent: 7,
            //             color: Color(0xFFF0F3F4)),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               appointmentTimelineTitle(
            //                   title: AppStrings().appointmentConfirmed),
            //               Padding(
            //                 padding: const EdgeInsets.only(
            //                     left: 24.0, right: 8, top: 4),
            //                 child: Text(
            //                   '10th April 13:10pm',
            //                   style: AppTextStyle
            //                       .appointmentConfirmedBold14TextStyle(
            //                           color: AppColors.doctorNameColor),
            //                 ),
            //               ),
            //               appointmentConfirmKey(
            //                   text: AppStrings().sendAMessagetodoctor),
            //               appointmentConfirmValue(text: '10th April 13:10pm'),
            //               appointmentConfirmKey(
            //                   text: AppStrings().sendAMessagetodoctor),
            //               appointmentConfirmValue(text: '11th April 13:10pm'),
            //               appointmentConfirmKey(
            //                   text: AppStrings().canJoinTheCallPrior),
            //               appointmentConfirmValue(text: '12th April 11:00am'),
            //               appointmentTimelineTitle(
            //                   title: AppStrings().appointmentInProgress,
            //                   color: AppColors.doctorNameColor),
            //               appointmentConfirmKey(
            //                   text: AppStrings().youCanJoinTheCall),
            //               appointmentConfirmValue(text: '12th April 11:30pm'),
            //               appointmentTimelineTitle(
            //                   title: AppStrings().consultationCompleted,
            //                   color: AppColors.doctorNameColor),
            //               appointmentConfirmKey(
            //                   text: AppStrings().drConcludedCall),
            //               appointmentConfirmValue(text: '12th April 12:30pm'),
            //             ],
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  confirmStatusView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/Tick-Square.png',
          height: 20,
          width: 20,
          color: AppColors.appointmentStatusColor,
        ),
        Spacing(size: 8),
        Text(
          AppStrings().appointmentStatusCompleted,
          style: AppTextStyle.appointmentConfirmedBoldTextStyle(),
        ),
      ],
    );
  }

  doctorCardView() {
    String doctorName;
    String appointmentDate;
    String appointmentStartTime;
    String appointmentEndTime;
    String appointmentTime;
    String doctorEducation;
    var tmpDate;
    String hprId = "";
    String? gender;

    doctorName = _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.agent?.name ??
        widget.doctorName!;
    gender = _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.agent?.gender ??
        widget.gender!;
    tmpDate = _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.start?.time?.timestamp ??
        widget.startDateTime;
    appointmentDate = DateFormat("dd MMM y").format(DateTime.parse(tmpDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    tmpDate = _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.end?.time?.timestamp ??
        widget.endDateTime;
    appointmentEndTime = DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    appointmentTime = appointmentStartTime + "-" + appointmentEndTime;
    doctorEducation = _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.agent?.tags?.education ??
        "";

    var StringArray = doctorName.split("-");
    doctorName = StringArray[1].replaceFirst(" ", "");
    hprId = StringArray[0];
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: width * 0.2,
                            height: width * 0.2,
                            margin: EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: Image.network(gender == "M"
                                          ? AppStrings().maleDoctorImage
                                          : AppStrings().femaleDoctorImage)
                                      .image),
                            ),
                          ),
                          Spacing(size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 'Dr. Sana Bhatt',
                                doctorName,
                                style: AppTextStyle
                                    .appointmentConfirmedBoldTextStyle(
                                        color: AppColors.doctorNameColor),
                              ),
                              Text(
                                hprId,
                                style: AppTextStyle.textBoldStyle(
                                    color: AppColors.doctorNameColor,
                                    fontSize: 12),
                              ),
                              Text(
                                // 'MBBS/MS Cardiology',
                                doctorEducation,
                                style: AppTextStyle
                                    .appointmentConfirmedLightTextStyle(
                                        color: AppColors.doctorNameColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded,
                          color: AppColors.doctorExperienceColor),
                    ),
                  ],
                ),
                Spacing(isWidth: false, size: 10),
                Spacing(isWidth: false, size: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 0, right: 12, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // '17th April 2022',
                        appointmentDate,
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 16, color: AppColors.infoIconColor),
                      ),
                      Text(
                        // '10am - 10:30am',
                        appointmentTime,
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 16, color: AppColors.infoIconColor),
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
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  child: showDoctorActionView(
                      assetImage: 'assets/images/Chat.png',
                      color: AppColors
                          .appointmentConfirmDoctorActionsEnabledTextColor,
                      actionText: AppStrings().startChat,
                      onTap: () {
                        Get.to(() => ChatPage(
                              doctorHprId: hprId.trim(),
                              patientAbhaId: userAbhaAddress,
                              doctorName: doctorName,
                              doctorGender: gender,
                              providerUri: _bookingConfirmResponseModel!
                                  .context!.providerUrl,
                            ));
                      }),
                ),
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
            height: 16,
            width: 16,
            color: color,
          ),
          Spacing(size: 5),
          Text(
            actionText,
            style: AppTextStyle.appointmentDoctorActionsTextStyle(color: color),
          ),
        ],
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

  appointmentConfirmKey({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8, top: 4),
      child: Text(
        text,
        style: AppTextStyle.textMediumStyle(
            color: AppColors.doctorNameColor, fontSize: 12),
      ),
    );
  }

  appointmentConfirmValue({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8, top: 2),
      child: Text(
        text,
        style: AppTextStyle.appointmentDoctorActionsTextStyle(
            color: AppColors.doctorNameColor),
      ),
    );
  }
}

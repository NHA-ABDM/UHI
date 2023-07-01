import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import 'package:get/get.dart';

class BookAppointmentAgain extends StatefulWidget {
  Fulfillment? discoveryFulfillments;
  String? consultationType;
  String? providerUri;
  BookAppointmentAgain(
      {Key? key,
      this.discoveryFulfillments,
      this.consultationType,
      this.providerUri})
      : super(key: key);

  @override
  State<BookAppointmentAgain> createState() => _BookAppointmentAgainPageState();
}

class _BookAppointmentAgainPageState extends State<BookAppointmentAgain> {
  ///SIZE
  late double width;
  late double height;

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amountColor,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () {
            Get.to(DoctorsDetailPage(
              doctorAbhaId: widget.discoveryFulfillments!.agent!.id!,
              doctorName: widget.discoveryFulfillments!.agent!.name!,
              doctorProviderUri: widget.providerUri!,
              discoveryFulfillments: widget.discoveryFulfillments!,
              consultationType: widget.consultationType!,
              isRescheduling: false,
            ));
          },
          child: Text(
            "BOOK AGAIN",
            style: AppTextStyle.textSemiBoldStyle(
                color: AppColors.white, fontSize: 12),
          ),
        ),
      ),
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
          AppStrings().appointmentDetails,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    String? amount =
        widget.discoveryFulfillments!.agent!.tags!.firstConsultation!;
    String appointmentStartDate = "";
    String appointmentStartTime = "";
    var tmpStartDate;
    tmpStartDate = widget.discoveryFulfillments!.start!.time!.timestamp;
    appointmentStartDate =
        DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));

    return SizedBox(
      height: height,
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  DoctorDetailsView(
                    doctorAbhaId: widget.discoveryFulfillments!.agent!.id!,
                    doctorName: widget.discoveryFulfillments!.agent!.name!,
                    tags: widget.discoveryFulfillments!.agent!.tags!,
                    gender: widget.discoveryFulfillments!.agent!.gender!,
                    profileImage: widget.discoveryFulfillments!.agent?.image,
                  ),
                  Spacing(isWidth: false, size: 8),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 8, 10),
                    child: Text(
                      AppStrings().selectedTimeForConsultation,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // "Monday April 17th 5pm",
                          appointmentStartDate + " at " + appointmentStartTime,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                        Row(
                          children: [
                            Text(
                              AppStrings().paid,
                              style: AppTextStyle.textNormalStyle(
                                  color: AppColors.amountColor, fontSize: 14),
                            ),
                            Text(
                              "₹ $amount/-",
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.amountColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 8, top: 8),
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0, right: 8, top: 4),
                                  child: Text(
                                    //'10th April 13:10pm',
                                    appointmentStartDate +
                                        " at " +
                                        appointmentStartTime,
                                    style: AppTextStyle
                                        .appointmentConfirmedBold14TextStyle(
                                            color: AppColors.doctorNameColor),
                                  ),
                                ),
                                // appointmentConfirmKey(
                                //     text: AppStrings().sendAMessagetodoctor),
                                // appointmentConfirmValue(
                                //     text: '10th April 13:10pm'),
                                // appointmentConfirmKey(
                                //     text: AppStrings().doctorSendMessage),
                                // appointmentConfirmValue(
                                //     text: '11th April 13:10pm'),
                                // appointmentConfirmKey(
                                //     text: AppStrings().canJoinTheCallPrior),
                                // appointmentConfirmValue(
                                //     text: '12th April 11:00am'),
                                // appointmentTimelineTitle(
                                //     title: AppStrings().appointmentInProgress,
                                //     color: AppColors.doctorNameColor),
                                // appointmentConfirmKey(
                                //     text: AppStrings().youCanJoinTheCall),
                                // appointmentConfirmValue(
                                //     text: '12th April 11:30pm'),
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
          style: AppTextStyle.textBoldStyle(
              color: AppColors.appointmentStatusColor, fontSize: 16),
        ),
      ],
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: Image.network(
                                          AppStrings().femaleDoctorImage)
                                      .image),
                            ),
                          ),
                          Spacing(size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. Sana Bhatt',
                                style: AppTextStyle
                                    .appointmentConfirmedBoldTextStyle(
                                        color: AppColors.doctorNameColor),
                              ),
                              Text(
                                'MBBS/MS Cardiology',
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
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '17th April 2022',
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 18, color: AppColors.infoIconColor),
                      ),
                      Text(
                        '10am - 10:30am',
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 18, color: AppColors.infoIconColor),
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
                        Get.to(ChatPage());
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

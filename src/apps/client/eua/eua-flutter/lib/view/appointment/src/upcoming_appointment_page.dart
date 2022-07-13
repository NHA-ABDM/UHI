import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uhi_flutter_app/constants/src/data_strings.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/home_screen_controller.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/appointment/src/appointment_status_confirm_page.dart';
import 'package:uhi_flutter_app/view/appointment/src/cancel_appointment_page.dart';
import 'package:uhi_flutter_app/view/doctor/src/doctors_detail_page.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

import '../../chat/src/chat_page.dart';

class UpcomingAppointmentPage extends StatefulWidget {
  const UpcomingAppointmentPage({Key? key}) : super(key: key);

  @override
  State<UpcomingAppointmentPage> createState() =>
      _UpcomingAppointmentPageState();
}

class _UpcomingAppointmentPageState extends State<UpcomingAppointmentPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final homeScreenController = Get.put(HomeScreenController());
  List<UpcomingAppointmentResponseModal?> upcomingAppointmentList = [];
  List<BookingConfirmResponseModel> bookingConfirmResponseModel = [];

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool _loading = false;
  String? abhaAddress;

  ///DATA VARIABLES

  void showProgressDialog() {
    setState(() {
      _loading = true;
    });
  }

  void hideProgressDialog() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            debugPrint(
                "Printing the shared preference getABhaAddress : $value");
            abhaAddress = value;
            showProgressDialog();
            getUpcomingAppointments();
          });
        }));
  }

  getUpcomingAppointments() async {
    await homeScreenController.getUpcomingAppointment(abhaAddress!);
    if (homeScreenController.upcomingAppointmentResponseModal.isNotEmpty) {
      for (int i = 0;
          i < homeScreenController.upcomingAppointmentResponseModal.length;
          i++) {
        if (homeScreenController.upcomingAppointmentResponseModal[i]!
            .serviceFulfillmentStartTime!.isNotEmpty) {
          String startDate = homeScreenController
              .upcomingAppointmentResponseModal[i]!
              .serviceFulfillmentStartTime!;
          var now = new DateTime.now();
          var formatter = new DateFormat('y-MM-ddTHH:mm');
          String formattedDate = formatter.format(now);
          DateTime currentDate =
              DateFormat("y-MM-ddTHH:mm").parse(formattedDate);
          DateTime tempStartDate = DateFormat("y-MM-ddTHH:mm").parse(startDate);
          int duration = currentDate.difference(tempStartDate).inMinutes;
          if (duration < 0 &&
              homeScreenController.upcomingAppointmentResponseModal[i]!
                      .isServiceFulfilled ==
                  "CONFIRMED") {
            upcomingAppointmentList
                .add(homeScreenController.upcomingAppointmentResponseModal[i]!);

            bookingConfirmResponseModel.add(
                BookingConfirmResponseModel.fromJson(jsonDecode(
                    homeScreenController
                        .upcomingAppointmentResponseModal[i]!.message!)));
          }
        }
      }
    }
    hideProgressDialog();

    debugPrint("TotalLength:${upcomingAppointmentList.length}");
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
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
            AppStrings().upcomingAppointment,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          dismissible: false,
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: AppColors.DARK_PURPLE,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
          ),
          child: buildWidgets(),
        ));
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [buildDoctorsList()],
          ),
        ),
      ),
    );
  }

  buildDoctorsList() {
    return upcomingAppointmentList.isNotEmpty
        ? Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            width: width,
            height: height * 0.81,
            child: ListView.separated(
              itemCount: upcomingAppointmentList.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return buildNewDoctorTile(index);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 20,
                );
              },
            ),
          )
        : Container(
            child: Center(
              child: Text(
                AppStrings().noUpcomingAppointmentsFound,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.appointmentConfirmDoctorActionsTextColor,
                    fontSize: 15),
              ),
            ),
          );
  }

  buildNewDoctorTile(int index) {
    String appointmentStartDate = "";
    String appointmentEndDate = "";
    String appointmentStartTime = "";
    String appointmentEndTime = "";
    String doctorName = "";
    String hprId = "";
    int duration = 0;
    var tmpStartDate;
    var tmpEndDate;
    String gender = "";
    if (upcomingAppointmentList.isNotEmpty) {
      gender = upcomingAppointmentList[index]!.healthcareProfessionalGender!;
      tmpStartDate =
          upcomingAppointmentList[index]!.serviceFulfillmentStartTime!;
      appointmentStartDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
      appointmentStartTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));

      tmpEndDate = upcomingAppointmentList[index]!.serviceFulfillmentEndTime!;
      appointmentEndDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpEndDate));
      appointmentEndTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpEndDate));

      var StringArray = upcomingAppointmentList[index]!
          .healthcareProfessionalName!
          .split("-");
      doctorName = StringArray[1].replaceFirst(" ", "");
      hprId = StringArray[0];

      DateTime tempStartDate = DateFormat("HH:mm").parse(appointmentStartTime);
      DateTime tempEndDate = new DateFormat("HH:mm").parse(appointmentEndTime);
      duration = tempEndDate.difference(tempStartDate).inMinutes;
    }
    return Container(
      width: width * 0.9,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 10,
            color: Color(0x1B1C204D),
          )
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(AppointmentStatusConfirmPage(
                bookingConfirmResponseModel: bookingConfirmResponseModel[index],
                startDateTime: upcomingAppointmentList[index]!
                    .serviceFulfillmentStartTime!,
                endDateTime:
                    upcomingAppointmentList[index]!.serviceFulfillmentEndTime!,
                doctorName:
                    upcomingAppointmentList[index]!.healthcareProfessionalName!,
                consultationType:
                    upcomingAppointmentList[index]!.serviceFulfillmentType ==
                            DataStrings.teleconsultation
                        ? DataStrings.teleconsultation
                        : DataStrings.physicalConsultation,
                gender: gender,
                navigateToHomeAndRefresh: false,
              ));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: width * 0.5,
                              child: Text(
                                doctorName,
                                style: AppTextStyle.textBoldStyle(
                                    color: AppColors.testColor, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          hprId,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.doctorNameColor, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          //"Tomorrow at 8:42 AM",
                          appointmentStartDate + " at " + appointmentStartTime,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "$duration minutes",
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          upcomingAppointmentList[index]!
                                      .serviceFulfillmentType ==
                                  DataStrings.teleconsultation
                              ? DataStrings.teleconsultation
                              : AppStrings().physicalConsultationString,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacing(isWidth: false),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              width: 1,
              color: Color(0xFFF0F3F4),
              // color: Colors.green,
            ))),
          ),
          //Spacing(isWidth: false),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           //Get.to(const CancelAppointment());
          //         },
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Image.asset(
          //               'assets/images/cross.png',
          //               height: 16,
          //               width: 16,
          //             ),
          //             Spacing(size: 5),
          //             Text(
          //               AppStrings().cancel,
          //               style: AppTextStyle.textLightStyle(
          //                   color: AppColors.tileColors, fontSize: 12),
          //             ),
          //           ],
          //         ),
          //       ),
          //       //Spacing(isWidth: true),
          //       Container(
          //         color: Color(0xFFF0F3F4),
          //         height: 60,
          //         width: 1,
          //       ),
          //       //Spacing(isWidth: true),
          //       GestureDetector(
          //         onTap: () {
          //           //rescheduleAppointment(index);
          //         },
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Image.asset(
          //               'assets/images/Calendar.png',
          //               height: 16,
          //               width: 16,
          //             ),
          //             Spacing(size: 5),
          //             Text(
          //               AppStrings().reschedule,
          //               style: AppTextStyle.textLightStyle(
          //                   color: AppColors.tileColors, fontSize: 12),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         color: Color(0xFFF0F3F4),
          //         height: 60,
          //         width: 1,
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           Get.to(() => ChatPage(
          //                 doctorHprId: upcomingAppointmentList[index]
          //                     ?.healthcareProfessionalId,
          //                 patientAbhaId: upcomingAppointmentList[index]?.abhaId,
          //                 doctorName: doctorName,
          //                 doctorGender: gender,
          //                 providerUri:
          //                     upcomingAppointmentList[0]?.healthcareProviderUrl,
          //               ));
          //         },
          //         child: Padding(
          //           padding: const EdgeInsets.only(left: 8),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Image.asset(
          //                 'assets/images/Chat.png',
          //                 height: 16,
          //                 width: 16,
          //               ),
          //               Spacing(size: 5),
          //               Text(
          //                 AppStrings().startChat,
          //                 style: AppTextStyle.textLightStyle(
          //                     color: AppColors.tileColors, fontSize: 12),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: showDoctorActionView(
                      assetImage: 'assets/images/cross.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().cancel,
                      onTap: () {
                        Get.to(CancelAppointment(
                            discoveryFulfillments:
                                bookingConfirmResponseModel[index]
                                    .message!
                                    .order!
                                    .fulfillment));
                      }),
                ),
                Container(
                  color: Color(0xFFF0F3F4),
                  height: 60,
                  width: 1,
                ),
                Expanded(
                  child: showDoctorActionView(
                      assetImage: 'assets/images/Calendar.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().reschedule,
                      onTap: () async {
                        //rescheduleAppointment();
                      }),
                ),
                Container(
                  color: Color(0xFFF0F3F4),
                  height: 60,
                  width: 1,
                ),
                Expanded(
                  child: showDoctorActionView(
                      assetImage: 'assets/images/Chat.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().startChat,
                      onTap: () async {
                        Get.to(() => ChatPage(
                              doctorHprId: upcomingAppointmentList[index]
                                  ?.healthcareProfessionalId,
                              patientAbhaId:
                                  upcomingAppointmentList[index]?.abhaId,
                              doctorName: doctorName,
                              doctorGender: gender,
                              providerUri: upcomingAppointmentList[0]
                                  ?.healthcareProviderUrl,
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
              height: 16,
              width: 16,
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

  rescheduleAppointment(int index) {
    Get.to(() => DoctorsDetailPage(
          doctorAbhaId: bookingConfirmResponseModel[index]
              .message!
              .order!
              .fulfillment!
              .agent!
              .id!,
          doctorName: bookingConfirmResponseModel[index]
              .message!
              .order!
              .fulfillment!
              .agent!
              .name!,
          doctorProviderUri:
              bookingConfirmResponseModel[index].context!.providerUrl!,
          discoveryFulfillments:
              bookingConfirmResponseModel[index].message!.order!.fulfillment!,
          consultationType:
              upcomingAppointmentList[0]!.serviceFulfillmentType ==
                      DataStrings.teleconsultation
                  ? DataStrings.teleconsultation
                  : DataStrings.physicalConsultation,
          isRescheduling: true,
          bookingConfirmResponseModel: bookingConfirmResponseModel[index],
        ));
  }
}

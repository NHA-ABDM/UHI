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
import 'package:uhi_flutter_app/view/appointment/src/book_appointment_again.dart';
import 'package:uhi_flutter_app/view/appointment/src/consultation_completed_page.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({Key? key}) : super(key: key);

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  final homeScreenController = Get.put(HomeScreenController());
  List<UpcomingAppointmentResponseModal?> appointmentHistoryList = [];
  BookingConfirmResponseModel bookingConfirmResponseModel =
      BookingConfirmResponseModel();

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
          if (duration > 0 &&
              homeScreenController.upcomingAppointmentResponseModal[i]!
                      .isServiceFulfilled ==
                  "CONFIRMED") {
            appointmentHistoryList
                .add(homeScreenController.upcomingAppointmentResponseModal[i]!);
          }
        }
      }
    }
    hideProgressDialog();
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
          AppStrings().appointmentsHistory,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
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
      ),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildDoctorsList()],
        ),
      ),
    );
  }

  buildDoctorsList() {
    return appointmentHistoryList.isNotEmpty
        ? Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            width: width,
            height: height * 0.81,
            child: ListView.separated(
              itemCount: appointmentHistoryList.length,
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
                AppStrings().noHistoryFound,
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
    String gender = "";
    var tmpStartDate;
    var tmpEndDate;
    if (appointmentHistoryList.isNotEmpty) {
      gender = appointmentHistoryList[index]!.healthcareProfessionalGender!;
      tmpStartDate =
          appointmentHistoryList[index]!.serviceFulfillmentStartTime!;
      appointmentStartDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
      appointmentStartTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));

      tmpEndDate = appointmentHistoryList[index]!.serviceFulfillmentEndTime!;
      appointmentEndDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpEndDate));
      appointmentEndTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpEndDate));

      var StringArray =
          appointmentHistoryList[index]!.healthcareProfessionalName!.split("-");
      doctorName = StringArray[1].replaceFirst(" ", "");
      hprId = StringArray[0];

      DateTime tempStartDate = DateFormat("HH:mm").parse(appointmentStartTime);
      DateTime tempEndDate = new DateFormat("HH:mm").parse(appointmentEndTime);
      duration = tempEndDate.difference(tempStartDate).inMinutes;

      String? orderDetailUpComingMessage =
          appointmentHistoryList[index]!.message;

      bookingConfirmResponseModel = BookingConfirmResponseModel.fromJson(
          jsonDecode(orderDetailUpComingMessage!));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.shadow3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
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
                Padding(
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
                        margin:
                            const EdgeInsets.only(left: 10, top: 10, right: 10),
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
                                        color: AppColors.testColor,
                                        fontSize: 15),
                                  ),
                                ),
                                // Spacing(),
                                // Text(
                                //   "Cardiologist",
                                //   style: AppTextStyle.textNormalStyle(
                                //       color: AppColors.testColor, fontSize: 15),
                                // ),
                              ],
                            ),
                            Text(
                              hprId,
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Text(
                              //"Tomorrow at 8:42 AM",
                              appointmentStartDate +
                                  " at " +
                                  appointmentStartTime,
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
                              appointmentHistoryList[index]!
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
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.appointmentStatusColor,
                        ),
                        height: 20,
                        width: 20,
                      ),
                      Container(
                        color: AppColors.appointmentStatusColor,
                        height: 2,
                        width: 90,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.appointmentStatusColor,
                        ),
                        height: 20,
                        width: 20,
                      ),
                      Container(
                        color: AppColors.appointmentStatusColor,
                        height: 2,
                        width: 90,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.appointmentStatusColor,
                        ),
                        height: 20,
                        width: 20,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            //"19 April 22\n  8:00pm",
                            appointmentStartDate + "\n " + appointmentStartTime,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                          Text(
                            AppStrings().appointmentBooked,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            appointmentStartDate + "\n " + appointmentStartTime,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                          Text(
                            AppStrings().appointmentInProgressOnHomeScreen,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            appointmentEndDate + "\n " + appointmentEndTime,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                          Text(
                            AppStrings().appointmentInCompletedOnHomeScreen,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorExperienceColor,
                                fontSize: 10),
                          ),
                        ],
                      )
                    ],
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
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: showDoctorActionView(
                            assetImage: 'assets/images/Show.png',
                            color: AppColors.infoIconColor,
                            actionText: AppStrings().viewDetails,
                            onTap: () {
                              Get.to(ConsultationCompletedPage(
                                startDateTime: appointmentHistoryList[index]!
                                    .serviceFulfillmentStartTime!,
                                endDateTime: appointmentHistoryList[index]!
                                    .serviceFulfillmentEndTime!,
                                doctorName: appointmentHistoryList[index]!
                                    .healthcareProfessionalName!,
                                gender: gender,
                              ));
                            }),
                      ),
                      Container(
                        color: Color(0xFFF0F3F4),
                        height: 60,
                        width: 1,
                      ),
                      Expanded(
                        child: showDoctorActionView(
                            assetImage: 'assets/images/Tick-Square.png',
                            color: AppColors.infoIconColor,
                            actionText: AppStrings().bookAgain,
                            onTap: () async {
                              Get.to(BookAppointmentAgain(
                                discoveryFulfillments:
                                    bookingConfirmResponseModel
                                        .message!.order!.fulfillment,
                                consultationType: appointmentHistoryList[index]!
                                            .serviceFulfillmentType ==
                                        DataStrings.teleconsultation
                                    ? DataStrings.teleconsultation
                                    : DataStrings.physicalConsultation,
                                providerUri: bookingConfirmResponseModel
                                    .context!.providerUrl!,
                              ));
                            }),
                      ),
                    ],
                  ),
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
}

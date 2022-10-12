import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uhi_flutter_app/common/src/get_pages.dart';
import 'package:uhi_flutter_app/constants/src/data_strings.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/home_screen_controller.dart';
import 'package:uhi_flutter_app/model/common/src/doctor_image_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';
import 'package:uhi_flutter_app/model/response/src/group_consult_upcoming_appointment_response_model.dart';
import 'package:uhi_flutter_app/observer/home_page_obsevable.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uhi_flutter_app/view/appointment/src/appointment_status_confirm_page.dart';
import 'package:uhi_flutter_app/view/appointment/src/cancel_appointment_page.dart';
import 'package:uhi_flutter_app/view/doctor/src/doctors_detail_page.dart';
import 'package:uhi_flutter_app/view/group-consultation/src/multiple_doctor_appointment_status_page.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../../observer/home_page_observer.dart';
import '../../chat/src/chat_page.dart';

class UpcomingAppointmentPage extends StatefulWidget {
  const UpcomingAppointmentPage({Key? key}) : super(key: key);

  @override
  State<UpcomingAppointmentPage> createState() =>
      _UpcomingAppointmentPageState();
}

class _UpcomingAppointmentPageState extends State<UpcomingAppointmentPage>
    implements HomePageObserver {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final homeScreenController = Get.put(HomeScreenController());
  List<UpcomingAppointmentResponseModal?> upcomingAppointmentList = [];
  List<BookingConfirmResponseModel> bookingConfirmResponseModel = [];
  late HomeScreenObservable observable;
  List<GroupConsultAppointment?> _groupConsultAppointmentList = [];

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool _loading = false;
  String? abhaAddress;

  ///DATA VARIABLES
  List<String> _doctorImages = List.empty(growable: true);

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
    observable = HomeScreenObservable();
    observable.register(this);
    callAPI();
    SharedPreferencesHelper.getDoctorImages().then((value) => setState(() {
          debugPrint("Printing the shared preference getDoctorImages : $value");
          if (value != null && value.isNotEmpty) {
            _doctorImages.addAll(value);
          }
        }));
  }

  callAPI() {
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

  @override
  void dispose() {
    observable.unRegister(this);
    super.dispose();
  }

  getUpcomingAppointments() async {
    List<UpcomingAppointmentResponseModal?> groupAppointmentList = [];
    List tmpListTransId = List.empty(growable: true);
    List toRemoveList = List.empty(growable: true);

    upcomingAppointmentList.clear();
    await homeScreenController.getUpcomingAppointment(abhaAddress!);

    if (homeScreenController.upcomingAppointmentResponseModal.isNotEmpty) {
      for (int i = 0;
          i < homeScreenController.upcomingAppointmentResponseModal.length;
          i++) {
        if (homeScreenController.upcomingAppointmentResponseModal[i]!
            .serviceFulfillmentStartTime!.isNotEmpty) {
          String endDate = homeScreenController
              .upcomingAppointmentResponseModal[i]!.serviceFulfillmentEndTime!;
          var now = new DateTime.now();
          var formatter = new DateFormat('y-MM-ddTHH:mm');
          String formattedDate = formatter.format(now);
          DateTime currentDate =
              DateFormat("y-MM-ddTHH:mm").parse(formattedDate);
          DateTime tempStartDate = DateFormat("y-MM-ddTHH:mm").parse(endDate);
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

    upcomingAppointmentList = upcomingAppointmentList.toSet().toList();

    upcomingAppointmentList.forEach(
      (element) {
        if (element?.groupConsultStatus == "true") {
          groupAppointmentList.add(element);
        }

        if (tmpListTransId.contains(element?.transId)) {
          toRemoveList.add(element);
        } else {
          tmpListTransId.add(element?.transId);
        }
      },
    );

    upcomingAppointmentList.removeWhere((e) => toRemoveList.contains(e));

    var groupConsultMap = groupBy(groupAppointmentList,
        (UpcomingAppointmentResponseModal? obj) => obj?.transId);

    _groupConsultAppointmentList = groupConsultMap.entries
        .map(
          (e) => GroupConsultAppointment(e.key, e.value),
        )
        .toList();

    log("${jsonEncode(_groupConsultAppointmentList.length)}", name: "NEW LIST");
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);

        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.white,
            shadowColor: Colors.black.withOpacity(0.1),
            leading: IconButton(
              onPressed: () {
                Get.back(result: true);
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
          )),
    );
  }

  buildWidgets() {
    return Container(
      width: width,
      height: height,
      color: AppColors.backgroundWhiteColorFBFCFF,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [buildDoctorsList()],
      ),
    );
  }

  buildDoctorsList() {
    return upcomingAppointmentList.isNotEmpty
        ? Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: upcomingAppointmentList.length,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
              itemBuilder: (context, index) {
                UpcomingAppointmentResponseModal
                    upcomingAppointmentResponseModal =
                    upcomingAppointmentList[index]!;

                log("${jsonEncode(upcomingAppointmentResponseModal.transId)}");

                if (upcomingAppointmentResponseModal.groupConsultStatus ==
                    "true") {
                  if (_groupConsultAppointmentList != null &&
                      _groupConsultAppointmentList.isNotEmpty) {
                    GroupConsultAppointment? groupConsultAppointment =
                        _groupConsultAppointmentList.singleWhere(
                      (element) =>
                          element?.transId ==
                          upcomingAppointmentResponseModal.transId,
                    );
                    return buildGroupConsultNewDoctorTile(
                        groupConsultAppointment!);
                  }
                }
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

  buildNewDoctorTile(
    int index,
  ) {
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
    Uint8List? doctorImage;

    _doctorImages.forEach((element) {
      DoctorImageModel image = DoctorImageModel.fromJson(jsonDecode(element));
      if (image.doctorHprAddress ==
          upcomingAppointmentList[index]?.healthcareProfessionalId) {
        doctorImage = base64Decode(image.doctorImage ?? "");
      }
    });

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
      DateTime tempStartDate =
          DateFormat("y-MM-ddTHH:mm:ss").parse(tmpStartDate);
      DateTime tempEndDate = DateFormat("y-MM-ddTHH:mm:ss").parse(tmpEndDate);
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
              int elementIndex = upcomingAppointmentList.indexWhere((element) =>
                  element!.healthcareProfessionalId ==
                      upcomingAppointmentList[index]!
                          .healthcareProfessionalId &&
                  element.orderId == upcomingAppointmentList[index]!.orderId);

              int newElementIndex = bookingConfirmResponseModel.indexWhere(
                  (element) =>
                      element.message!.order!.id ==
                      upcomingAppointmentList[elementIndex]!.orderId);
              Get.to(AppointmentStatusConfirmPage(
                bookingConfirmResponseModel:
                    bookingConfirmResponseModel[newElementIndex],
                startDateTime: upcomingAppointmentList[elementIndex]!
                    .serviceFulfillmentStartTime!,
                endDateTime: upcomingAppointmentList[elementIndex]!
                    .serviceFulfillmentEndTime!,
                doctorName: upcomingAppointmentList[elementIndex]!
                    .healthcareProfessionalName!,
                consultationType: upcomingAppointmentList[elementIndex]!
                            .serviceFulfillmentType ==
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
                        image: doctorImage != null && doctorImage!.isNotEmpty
                            ? Image.memory(doctorImage!).image
                            : Image.network(gender == "M"
                                    ? AppStrings().maleDoctorImage
                                    : AppStrings().femaleDoctorImage)
                                .image,
                        fit: BoxFit.fill,
                      ),
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
                          style: AppTextStyle.textMediumStyle(
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
                      onTap: () async {
                        final result = await Get.to(() => CancelAppointment(
                            isRescheduleAppointment: false,
                            upcomingAppointmentResponseModal:
                                upcomingAppointmentList[index],
                            discoveryFulfillments:
                                bookingConfirmResponseModel[index]
                                    .message!
                                    .order!
                                    .fulfillment));

                        if (result != null && result == true) {
                          showProgressDialog();
                          getUpcomingAppointments();
                        }
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
                        Get.to(() => CancelAppointment(
                            isRescheduleAppointment: true,
                            upcomingAppointmentResponseModal:
                                upcomingAppointmentList[index],
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
                      assetImage: 'assets/images/Chat.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().startChat,
                      onTap: () async {
                        // Get.to(() => ChatPage(
                        //       doctorHprId: upcomingAppointmentList[index]
                        //           ?.healthcareProfessionalId,
                        //       patientAbhaId:
                        //           upcomingAppointmentList[index]?.abhaId,
                        //       doctorName: doctorName,
                        //       doctorGender: gender,
                        //       providerUri: upcomingAppointmentList[0]
                        //           ?.healthcareProviderUrl,
                        //     ));
                        Get.toNamed(AppRoutes.chatPage,
                            arguments: <String, dynamic>{
                              'doctorHprId': upcomingAppointmentList[index]
                                  ?.healthcareProfessionalId,
                              'patientAbhaId':
                                  upcomingAppointmentList[index]?.abhaId,
                              'doctorName': doctorName,
                              'doctorGender': gender,
                              'providerUri': upcomingAppointmentList[index]
                                  ?.healthcareProviderUrl,
                              'allowSendMessage': true,
                              'transactionId':
                                  upcomingAppointmentList[index]?.transId
                            });
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String minBetween(
    DateTime s1Start,
    DateTime s1End,
    DateTime s2Start,
    DateTime s2End,
  ) {
    if ((s2Start.isAfter(s1Start) || s2Start.isAtSameMomentAs(s1Start)) &&
        (s2End.isBefore(s1End) || s2End.isAtSameMomentAs(s1End))) {
      return "s2";
    } else if ((s1Start.isAfter(s2Start) ||
            s2Start.isAtSameMomentAs(s1Start)) &&
        (s1End.isBefore(s2End) || s2End.isAtSameMomentAs(s1End))) {
      return "s1";
    }
    return "";
  }

  buildGroupConsultNewDoctorTile(GroupConsultAppointment response) {
    UpcomingAppointmentResponseModal? docOneResponse;
    UpcomingAppointmentResponseModal? docTwoResponse;
    UpcomingAppointmentResponseModal? tempDocOneResponse;
    UpcomingAppointmentResponseModal? tempDocTwoResponse;

    // if (response.listOfResponses != null &&
    //     response.listOfResponses!.isNotEmpty) {
    //   for (UpcomingAppointmentResponseModal? model
    //       in response.listOfResponses!) {
    //     if (model != null && model.primaryDoctorHprAddress != null) {
    //       if (model.healthcareProfessionalId == model.primaryDoctorHprAddress) {
    //         docOneResponse = model;
    //       } else {
    //         docTwoResponse = model;
    //       }
    //     } else {
    //       docTwoResponse = response.listOfResponses?[1];
    //       docOneResponse = response.listOfResponses?[0];
    //       break;
    //     }
    //   }
    // }

    tempDocOneResponse = response.listOfResponses![0];
    // int index = upcomingAppointmentList.indexWhere((element) =>
    //     element!.transId == tempDocOneResponse!.transId &&
    //     element.healthcareProfessionalId !=
    //         tempDocOneResponse.healthcareProfessionalId);
    tempDocTwoResponse = response.listOfResponses![1];

    if (tempDocOneResponse!.healthcareProfessionalId ==
        tempDocOneResponse.primaryDoctorHprAddress) {
      docOneResponse = tempDocOneResponse;
      docTwoResponse = tempDocTwoResponse;
    } else {
      docOneResponse = tempDocTwoResponse;
      docTwoResponse = tempDocOneResponse;
    }

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
    Uint8List? doctorImage;
    String minSlotStartDateAndTime = "";
    String minSlotEndDateAndTime = "";

    String doctorNameDocTwo = "";
    String hprIdDocTwo = "";
    String genderDocTwo = "";
    Uint8List? doctorImageTwo;

    if (docOneResponse != null && docTwoResponse != null) {
      _doctorImages.forEach((element) {
        DoctorImageModel image = DoctorImageModel.fromJson(jsonDecode(element));
        if (image.doctorHprAddress ==
            docOneResponse?.healthcareProfessionalId) {
          doctorImage = base64Decode(image.doctorImage ?? "");
        }
      });

      DateTime s1Start =
          DateTime.parse(docOneResponse.serviceFulfillmentStartTime!);
      DateTime s1End =
          DateTime.parse(docOneResponse.serviceFulfillmentEndTime!);
      DateTime s2Start =
          DateTime.parse(docTwoResponse.serviceFulfillmentStartTime!);
      DateTime s2End =
          DateTime.parse(docTwoResponse.serviceFulfillmentEndTime!);

      String slotName = minBetween(s1Start, s1End, s2Start, s2End);

      if (slotName == "s1") {
        minSlotStartDateAndTime = docOneResponse.serviceFulfillmentStartTime!;
        minSlotEndDateAndTime = docOneResponse.serviceFulfillmentEndTime!;
      } else {
        minSlotStartDateAndTime = docTwoResponse.serviceFulfillmentStartTime!;
        minSlotEndDateAndTime = docTwoResponse.serviceFulfillmentEndTime!;
      }

      tmpStartDate = minSlotStartDateAndTime;
      appointmentStartDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
      appointmentStartTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));
      tmpEndDate = minSlotEndDateAndTime;
      appointmentEndDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpEndDate));
      appointmentEndTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpEndDate));
      var StringArray = docOneResponse.healthcareProfessionalName!.split("-");

      gender = docOneResponse.healthcareProfessionalGender!;
      doctorName = StringArray[1].replaceFirst(" ", "");
      hprId = docOneResponse.healthcareProfessionalId ?? "";
      DateTime tempStartDate =
          DateFormat("y-MM-ddTHH:mm:ss").parse(tmpStartDate);
      DateTime tempEndDate = DateFormat("y-MM-ddTHH:mm:ss").parse(tmpEndDate);
      duration = tempEndDate.difference(tempStartDate).inMinutes;

      doctorNameDocTwo =
          docTwoResponse.healthcareProfessionalName!.split("-")[1].trim();
      hprIdDocTwo = docTwoResponse.healthcareProfessionalId ?? "";
      genderDocTwo = docTwoResponse.healthcareProfessionalGender ?? "";
      genderDocTwo = docTwoResponse.healthcareProfessionalGender ?? "";
      doctorImage =
          base64Decode(docTwoResponse.healthcareProfessionalImage ?? "");
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
              Get.to(MultipleDoctorAppointmentStatusPage(
                consultationType: docOneResponse?.serviceFulfillmentType ==
                        DataStrings.teleconsultation
                    ? DataStrings.teleconsultation
                    : DataStrings.physicalConsultation,
                docOneConfirmResponse: BookingConfirmResponseModel.fromJson(
                    jsonDecode(docOneResponse!.message!)),
                docTwoConfirmResponse: BookingConfirmResponseModel.fromJson(
                    jsonDecode(docTwoResponse!.message!)),
                navigateToHomeAndRefresh: false,
                appointmentStartDateAndTime: minSlotStartDateAndTime,
                appointmentEndDateAndTime: minSlotEndDateAndTime,
              ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width * 0.2,
                        height: width * 0.2,
                        padding: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image:
                                doctorImage != null && doctorImage!.isNotEmpty
                                    ? Image.memory(doctorImage!).image
                                    : Image.network(gender == "M"
                                            ? AppStrings().maleDoctorImage
                                            : AppStrings().femaleDoctorImage)
                                        .image,
                            fit: BoxFit.fill,
                          ),
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
                              ],
                            ),
                            Text(
                              hprId,
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing(
                  isWidth: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width * 0.2,
                        height: width * 0.2,
                        padding: EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: doctorImageTwo != null &&
                                    doctorImageTwo.isNotEmpty
                                ? Image.memory(doctorImageTwo).image
                                : Image.network(genderDocTwo == "M"
                                        ? AppStrings().maleDoctorImage
                                        : AppStrings().femaleDoctorImage)
                                    .image,
                            fit: BoxFit.fill,
                          ),
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
                                    doctorNameDocTwo,
                                    style: AppTextStyle.textBoldStyle(
                                        color: AppColors.testColor,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              hprIdDocTwo,
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing(
                  isWidth: false,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25.0, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          //"Tomorrow at 8:42 AM",
                          "$appointmentStartDate at $appointmentStartTime · $duration minutes",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing(
                  isWidth: false,
                ),
                docOneResponse != null
                    ? Container(
                        padding: const EdgeInsets.only(left: 25.0, right: 25),
                        child: Text(
                          docOneResponse.serviceFulfillmentType ==
                                  DataStrings.teleconsultation
                              ? DataStrings.teleconsultation
                              : AppStrings().physicalConsultationString,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                      )
                    : Container(),
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
                    color: AppColors.appointmentConfirmDoctorActionsTextColor,
                    actionText: AppStrings().cancel,
                    onTap: () async {
                      //   final result = await Get.to(() => CancelAppointment(
                      //       isRescheduleAppointment: false,
                      //       upcomingAppointmentResponseModal:
                      //           upcomingAppointmentList[index],
                      //       discoveryFulfillments:
                      //           bookingConfirmResponseModel[index]
                      //               .message!
                      //               .order!
                      //               .fulfillment));

                      //   if (result != null && result == true) {
                      //     showProgressDialog();
                      //     getUpcomingAppointments();
                      //   }
                    },
                  ),
                ),
                Container(
                  color: Color(0xFFF0F3F4),
                  height: 60,
                  width: 1,
                ),
                Expanded(
                  child: showDoctorActionView(
                      assetImage: 'assets/images/Calendar.png',
                      color: AppColors.appointmentConfirmDoctorActionsTextColor,
                      actionText: AppStrings().reschedule,
                      onTap: () async {
                        //rescheduleAppointment();
                        // Get.to(() => CancelAppointment(
                        //     isRescheduleAppointment: true,
                        //     upcomingAppointmentResponseModal:
                        //         upcomingAppointmentList[index],
                        //     discoveryFulfillments:
                        //         bookingConfirmResponseModel[index]
                        //             .message!
                        //             .order!
                        //             .fulfillment));
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
                      color: AppColors.appointmentConfirmDoctorActionsTextColor,
                      actionText: AppStrings().startChat,
                      onTap: () async {
                        // Get.toNamed(AppRoutes.chatPage,
                        //     arguments: <String, dynamic>{
                        //       'doctorHprId': upcomingAppointmentList[index]
                        //           ?.healthcareProfessionalId,
                        //       'patientAbhaId':
                        //           upcomingAppointmentList[index]?.abhaId,
                        //       'doctorName': doctorName,
                        //       'doctorGender': gender,
                        //       'providerUri': upcomingAppointmentList[0]
                        //           ?.healthcareProviderUrl,
                        //       'allowSendMessage': true,
                        //     });
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
              color: color,
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
          uniqueId: Uuid().v1(),
        ));
  }

  @override
  void updateAppointmentData() {
    callAPI();
  }
}

class GroupConsultAppointment {
  String? transId;
  List<UpcomingAppointmentResponseModal?>? listOfResponses;

  GroupConsultAppointment(
    this.transId,
    this.listOfResponses,
  );
}

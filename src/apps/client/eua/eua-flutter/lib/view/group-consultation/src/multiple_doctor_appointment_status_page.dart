import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/common/src/get_pages.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/common/src/doctor_image_model.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/request/src/appointment_status_request_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/appointment/appointment.dart';
import 'package:uhi_flutter_app/view/appointment/src/consultation_completed_page.dart';
import 'package:uhi_flutter_app/webRTC/src/call_sample/call_sample.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../constants/src/data_strings.dart';
import '../../../observer/home_page_obsevable.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/utils.dart';

class MultipleDoctorAppointmentStatusPage extends StatefulWidget {
  // BookingConfirmResponseModel? bookingConfirmResponseModel;
  // String? startDateTime;
  // String? endDateTime;
  // String? doctorName;

  BookingConfirmResponseModel? docOneConfirmResponse;
  BookingConfirmResponseModel? docTwoConfirmResponse;

  String? consultationType;
  // String? gender;
  bool? navigateToHomeAndRefresh;
  String? doctorImage;
  String appointmentStartDateAndTime;
  String appointmentEndDateAndTime;

  MultipleDoctorAppointmentStatusPage({
    Key? key,
    // this.bookingConfirmResponseModel,
    // this.startDateTime,
    // this.endDateTime,
    // this.doctorName,
    this.docOneConfirmResponse,
    this.docTwoConfirmResponse,
    this.consultationType,
    // this.gender,
    this.navigateToHomeAndRefresh,
    this.doctorImage,
    required this.appointmentStartDateAndTime,
    required this.appointmentEndDateAndTime,
  }) : super(key: key);

  @override
  State<MultipleDoctorAppointmentStatusPage> createState() =>
      _MultipleDoctorAppointmentStatusPageState();
}

class _MultipleDoctorAppointmentStatusPageState
    extends State<MultipleDoctorAppointmentStatusPage> {
  ///CONTROLLERS
  final _postAppointmentStatusController =
      Get.put(PostAppointmentStatusController());
  final _postSharedKeyController = Get.put(PostSharedKeyController());
  final _getSharedKeyController = Get.put(GetSharedKeyController());

  ///SIZE
  late double width;
  DateTime appointmentTime = DateTime.now().add(Duration(hours: 2));
  DateTime appointmentEndTime = DateTime.now().add(Duration(hours: 2));
  DateTime appointmentTimerEndTime = DateTime.now();
  DateTime currentTime = DateTime.now();
  bool isAppointmentTime = true;
  Timer? _timer;
  BookingConfirmResponseModel? _bookingConfirmResponseModel;
  BookingConfirmResponseModel? _docOneConfirmResponse;
  BookingConfirmResponseModel? _docTwoConfirmResponse;
  String? _consultationType;
  String? _orderId;
  String _uniqueId = "";
  StompSocketConnection stompSocketConnection = StompSocketConnection();
  String? userAbhaAddress;
  String? _doctorImage;
  List<String> _doctorImages = List.empty(growable: true);
  DoctorImageModel doctorImageModel = DoctorImageModel();
  String? _doctorHprAddress;
  String? _appointmentStartDateAndTime;

  Future<GetSharedKeyResponseModel?>? futureOfGetSharedKey;

  // Generate a key pair.
  final encryptionAlgorithm = X25519();

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            userAbhaAddress = value;
          });
          // futureOfGetSharedKey = getSharedKey();
        }));

    // _bookingConfirmResponseModel = widget.bookingConfirmResponseModel;
    _docOneConfirmResponse = widget.docOneConfirmResponse;
    _docTwoConfirmResponse = widget.docTwoConfirmResponse;
    _consultationType = widget.consultationType;
    _doctorImage = widget.doctorImage;
    _doctorHprAddress =
        _bookingConfirmResponseModel?.message?.order?.fulfillment?.agent?.id;
    _appointmentStartDateAndTime = widget.appointmentStartDateAndTime;

    appointmentTime = DateTime.parse(_appointmentStartDateAndTime ??
        "${DateTime.now().add(Duration(minutes: 30))}");

    appointmentTimerEndTime = DateTime.parse(_appointmentStartDateAndTime ??
        "${DateTime.now().add(Duration(minutes: 30))}");

    if (appointmentTime.difference(currentTime).inMinutes <= 120) {
      isAppointmentAvailable();
    }

    saveDoctorImage();
  }

  saveDoctorImage() async {
    doctorImageModel.doctorHprAddress = _doctorHprAddress;
    doctorImageModel.doctorImage = _doctorImage;

    List<String>? images = await SharedPreferencesHelper.getDoctorImages();

    if (images != null && images.isEmpty) {
      images.add(jsonEncode(doctorImageModel));
    } else {
      images?.forEach((element) {
        log("in 1");
        DoctorImageModel image = DoctorImageModel.fromJson(jsonDecode(element));

        if (image.doctorHprAddress == _doctorHprAddress) {
          log("in 2");

          if (image.doctorImage != null && image.doctorImage != "") {
            log("in 3");

            images.add(jsonEncode(doctorImageModel));
          }
        }
      });
    }

    SharedPreferencesHelper.setDoctorImages(images ?? []);
  }

  isAppointmentAvailable() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      currentTime = DateTime.now();
      //if (appointmentTime.isAfter(currentTime)) {
      var tempVar = appointmentTime.difference(currentTime).inMinutes;
      if (tempVar < 30 && currentTime.isBefore(appointmentTimerEndTime)) {
        setState(() {
          isAppointmentTime = true;
        });
        _timer?.cancel();
      }
      // }
    });
  }

  isPhysicalConsultationOver() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      currentTime = DateTime.now();
      if (currentTime.isAfter(appointmentEndTime)) {
        var tempVar = currentTime.difference(appointmentEndTime).inMinutes;
        log("$tempVar", name: "END COMPARISON");
        if (tempVar >= 10) {
          Get.to(() => AppointmentAttendPage(
                bookingConfirmResponse: _bookingConfirmResponseModel!,
                consultationType: _consultationType!,
              ));
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ///SAVE SHARED KEY API
  Future<bool> saveSharedKey() async {
    try {
      String doctorKey = _bookingConfirmResponseModel
              ?.message?.order?.fulfillment?.initTimeSlotTags?.doctorKey ??
          "";

      log("${jsonEncode(_bookingConfirmResponseModel?.message?.order?.fulfillment?.initTimeSlotTags)}");
      // List<int> bytes = (jsonDecode(doctorKey) as List)
      //     .map((e) => int.parse(e.toString()))
      //     .toList();

      // final keyPair = await encryptionAlgorithm.newKeyPair();
      // final doctorPublicKey = SimplePublicKey(bytes, type: KeyPairType.x25519);

      // final sharedSecretKey = await encryptionAlgorithm.sharedSecretKey(
      //     keyPair: keyPair, remotePublicKey: doctorPublicKey);

      // final sharedSecretBytes = await sharedSecretKey.extractBytes();

      SavePublicKeyModel savePublicKeyModel = SavePublicKeyModel();
      savePublicKeyModel.userName =
          _bookingConfirmResponseModel?.message?.order?.fulfillment?.agent?.id;
      savePublicKeyModel.privateKey = null;
      savePublicKeyModel.publicKey = "$doctorKey";

      log("${jsonEncode(savePublicKeyModel)}", name: "PUBLIC KEY MODEL");

      await _postSharedKeyController.postSharedKeyDetails(
          sharedKeyDetails: savePublicKeyModel);

      if (_postSharedKeyController.sharedKeyAckDetails["status"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    // return false;
  }

  Future<GetSharedKeyResponseModel?> getSharedKey() async {
    GetSharedKeyResponseModel? getSharedKeyResponseModel;

    await _getSharedKeyController.getSharedKeyDetails(
        doctorId: _bookingConfirmResponseModel
            ?.message?.order?.fulfillment?.agent?.id,
        patientId: userAbhaAddress);

    await Future.delayed(Duration(milliseconds: 1000));

    if (_getSharedKeyController.sharedKeyDetails == null ||
        _getSharedKeyController.sharedKeyDetails.isEmpty) {
      bool isKeySaved = await saveSharedKey();
      if (isKeySaved) {
        await _getSharedKeyController.getSharedKeyDetails(
            doctorId: _bookingConfirmResponseModel
                ?.message?.order?.fulfillment?.agent?.id,
            patientId: userAbhaAddress);
        await Future.delayed(Duration(milliseconds: 1000));

        getSharedKeyResponseModel = GetSharedKeyResponseModel.fromJson(
            _getSharedKeyController.sharedKeyDetails[0]);
      } else {
        getSharedKeyResponseModel = null;
      }
    } else {
      getSharedKeyResponseModel = GetSharedKeyResponseModel.fromJson(
          _getSharedKeyController.sharedKeyDetails[0]);
    }

    return getSharedKeyResponseModel;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureOfGetSharedKey = getSharedKey();
  }

  // Future<BookingOnInitResponseModel?> getInitResponse() async {
  //   BookingOnInitResponseModel? bookingOnInitResponseModel;
  //   _timer =
  //       await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

  //   _uniqueId = const Uuid().v1();

  //   stompSocketConnection.connect(uniqueId: _uniqueId, api: postStatusAPI);
  //   stompSocketConnection.onResponse = (response) {
  //     if (response == null) {
  //       _timer?.cancel();
  //     } else {
  //       bookingOnInitResponseModel = BookingOnInitResponseModel.fromJson(
  //           json.decode(response.response!));
  //       _timer?.cancel();

  //       log("${json.encode(bookingOnInitResponseModel)}", name: "RESPONSE");
  //     }
  //   };

  //   // stompSocketConnection.disconnect();

  //   // await Future.delayed(Duration(milliseconds: 3000));

  //   while (_timer!.isActive) {
  //     // log("${_timer?.tick}");
  //     await Future.delayed(Duration(milliseconds: 100));
  //   }

  //   stompSocketConnection.disconnect();

  //   return bookingOnInitResponseModel;
  // }

  // Future<void> onRefresh() async {
  //   setState(() {});
  //   futureInitResponse = getInitResponse();
  // }

  ///STATUS API
  postStatusAPI() async {
    String? userData;

    await SharedPreferencesHelper.getUserData().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference userData : $value");
            userData = value;
          });
        }));

    GetUserDetailsResponse? getUserDetailsResponseModel =
        GetUserDetailsResponse.fromJson(jsonDecode(userData!));
    String? deviceId = await _getId();
    _orderId = _bookingConfirmResponseModel?.message?.order?.id;

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString(AppStrings().bookingOrderId, _orderId!);

    AppointmentStatusRequestModel appoinmentStatusRequestModel =
        AppointmentStatusRequestModel();

    ContextModel contextModel = ContextModel();
    AppointmentStatusMessage appoinmentStatusMessage =
        AppointmentStatusMessage();
    AppointmentStatusOrder appoinmentStatusOrder = AppointmentStatusOrder();
    AppointmentStatusCustomer appointmentStatusCustomer =
        AppointmentStatusCustomer();
    AppointmentStatusPerson appointmentStatusPerson = AppointmentStatusPerson();
    AppointmentStatusContact appointmentStatusContact =
        AppointmentStatusContact();

    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "status";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "https://exampleapp.io/";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.timestamp = DateTime.now()
        .add(Duration(days: 4))
        .toLocal()
        .toUtc()
        .toIso8601String();
    contextModel.transactionId = _uniqueId;
    contextModel.providerUrl =
        _bookingConfirmResponseModel?.context?.providerUrl;

    appointmentStatusPerson.name = getUserDetailsResponseModel.fullName;
    appointmentStatusPerson.gender = getUserDetailsResponseModel.gender;

    appointmentStatusContact.email = getUserDetailsResponseModel.email;
    appointmentStatusContact.phone = getUserDetailsResponseModel.mobile;

    appointmentStatusCustomer.person = appointmentStatusPerson;
    appointmentStatusCustomer.contact = appointmentStatusContact;
    appointmentStatusCustomer.id = getUserDetailsResponseModel.id;
    appointmentStatusCustomer.cred = getUserDetailsResponseModel.healthId;

    appoinmentStatusOrder.customer = appointmentStatusCustomer;
    appoinmentStatusOrder.id = _orderId;
    appoinmentStatusOrder.refId = _orderId;

    appoinmentStatusMessage.order = appoinmentStatusOrder;

    appoinmentStatusRequestModel.message = appoinmentStatusMessage;
    appoinmentStatusRequestModel.context = contextModel;

    log("${jsonEncode(appoinmentStatusRequestModel)}",
        name: "APPOINTMENT STATUS MODEL");

    // await _postAppointmentStatusController.postAppointmentStatusDetails(
    //     appointmentStatusDetails: appoinmentStatusRequestModel);
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (widget.navigateToHomeAndRefresh!) {
          Get.until((route) {
            if (Get.currentRoute == "/home_page" ||
                Get.currentRoute == "/HomePage" ||
                Get.currentRoute == "/" ||
                Get.currentRoute == "") {
              return true;
            } else {
              final HomeScreenObservable observable = HomeScreenObservable();
              observable.notifyUpdateAppointmentData();
              return false;
            }
          });
        } else {
          final HomeScreenObservable observable = HomeScreenObservable();
          observable.notifyUpdateAppointmentData();
          Get.back();
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            onPressed: () {
              _timer?.cancel();
              // Get.until((route) {
              //   if (Get.currentRoute == "/HomePage" ||
              //       Get.currentRoute == "/" ||
              //       Get.currentRoute == "")
              //     return true;
              //   else
              //     return false;
              // });
              if (widget.navigateToHomeAndRefresh!) {
                Get.until((route) {
                  if (Get.currentRoute == "/home_page" ||
                      Get.currentRoute == "/HomePage" ||
                      Get.currentRoute == "/" ||
                      Get.currentRoute == "")
                    return true;
                  else {
                    final HomeScreenObservable observable =
                        HomeScreenObservable();
                    observable.notifyUpdateAppointmentData();
                    return false;
                  }
                });
              } else {
                final HomeScreenObservable observable = HomeScreenObservable();
                observable.notifyUpdateAppointmentData();
                Get.back();
              }
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
            "Group Consultation Appointment",
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 18),
          ),
        ),
        body: buildWidgets(),
        // body: FutureBuilder(
        //   future: futureOfGetSharedKey,
        //   builder: (context, loadingData) {
        //     switch (loadingData.connectionState) {
        //       case ConnectionState.waiting:
        //         return CommonLoadingIndicator();

        //       case ConnectionState.active:
        //         return Text(AppStrings().loadingData);

        //       case ConnectionState.done:
        //         return loadingData.data != null
        //             ? buildWidgets(loadingData.data)
        //             : RefreshIndicator(
        //                 onRefresh: onRefresh,
        //                 child: Stack(
        //                   children: [
        //                     ListView(),
        //                     Container(
        //                       padding: EdgeInsets.all(15),
        //                       child: Center(
        //                         child: Text(
        //                           AppStrings().serverBusyErrorMsg,
        //                           style: TextStyle(
        //                               fontFamily: "Poppins",
        //                               fontStyle: FontStyle.normal,
        //                               fontWeight: FontWeight.w500,
        //                               fontSize: 16.0),
        //                           textAlign: TextAlign.center,
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               );
        //       default:
        //         return loadingData.data != null
        //             ? buildWidgets(loadingData.data)
        //             : RefreshIndicator(
        //                 onRefresh: onRefresh,
        //                 child: Stack(
        //                   children: [
        //                     ListView(),
        //                     Container(
        //                       padding: EdgeInsets.all(15),
        //                       child: Center(
        //                         child: Text(
        //                           AppStrings().serverBusyErrorMsg,
        //                           style: TextStyle(
        //                               fontFamily: "Poppins",
        //                               fontStyle: FontStyle.normal,
        //                               fontWeight: FontWeight.w500,
        //                               fontSize: 16.0),
        //                           textAlign: TextAlign.center,
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               );
        //     }
        //   },
        // ),
      ),
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
                "Your group consultation appointment is confirmed.",
                style: AppTextStyle.appointmentConfirmedLightTextStyle(),
              ),
            ),
            //Spacing(size: 20, isWidth: false),
            buildDoctorsCard(),

            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 8, top: 8),
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
            )
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
          AppStrings().appointmentStatusConfirm,
          style: AppTextStyle.textBoldStyle(
              color: AppColors.appointmentStatusColor, fontSize: 16),
        ),
      ],
    );
  }

  String minBetween(
    DateTime s1Start,
    DateTime s1End,
    DateTime s2Start,
    DateTime s2End,
  ) {
    log("${s1Start}");
    log("${s1End}");
    log("${s2Start}");
    log("${s2End}");

    if ((s2Start.isAfter(s1Start) || s2Start.isAtSameMomentAs(s1Start)) &&
        (s2End.isBefore(s1End) || s2End.isAtSameMomentAs(s1End))) {
      return "s2";
    } else if ((s1Start.isAfter(s2Start) ||
            s2Start.isAtSameMomentAs(s1Start)) &&
        (s1End.isBefore(s2End) || s2End.isAtSameMomentAs(s1End))) {
      return "s1";
    }
    return "s2";
  }

  buildDoctorsCard() {
    String appointmentDate;
    String appointmentStartTime;
    String appointmentEndTime;
    String appointmentTime;
    String minSlotStartDateAndTime;
    String minSlotEndDateAndTime;

    var tmpDate;

    DateTime s1Start = DateTime.parse(_docOneConfirmResponse
            ?.message?.order?.fulfillment?.start?.time?.timestamp ??
        "");
    DateTime s1End = DateTime.parse(_docOneConfirmResponse
            ?.message?.order?.fulfillment?.end?.time?.timestamp ??
        "");
    DateTime s2Start = DateTime.parse(_docTwoConfirmResponse
            ?.message?.order?.fulfillment?.start?.time?.timestamp ??
        "");
    DateTime s2End = DateTime.parse(_docTwoConfirmResponse
            ?.message?.order?.fulfillment?.end?.time?.timestamp ??
        "");

    String slotName = minBetween(s1Start, s1End, s2Start, s2End);

    if (slotName == "s1") {
      minSlotStartDateAndTime = s1Start.toString();
      minSlotEndDateAndTime = s1End.toString();
    } else if (slotName == "s2") {
      minSlotStartDateAndTime = s2Start.toString();
      minSlotEndDateAndTime = s2End.toString();
    } else {
      minSlotStartDateAndTime = "";
      minSlotEndDateAndTime = "";
    }

    tmpDate = minSlotStartDateAndTime;
    appointmentDate = DateFormat("dd MMM y").format(DateTime.parse(tmpDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    tmpDate = minSlotEndDateAndTime;
    appointmentEndTime = DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    appointmentTime = appointmentStartTime + "-" + appointmentEndTime;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      child: Column(
        children: [
          buildDoctorTile(_docOneConfirmResponse!),
          buildDoctorTile(_docTwoConfirmResponse!),
          Padding(
            padding:
                const EdgeInsets.only(left: 15, top: 0, right: 15, bottom: 16),
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
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF0F3F4),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _consultationType == DataStrings.teleconsultation
                    ? showDoctorActionView(
                        assetImage: 'assets/images/video.png',
                        color: isAppointmentTime
                            ? AppColors
                                .appointmentConfirmDoctorActionsEnabledTextColor
                            : AppColors
                                .appointmentConfirmDoctorActionsTextColor,
                        actionText: AppStrings().videoCall,
                        onTap: () async {
                          ///NAVIGATE TO VIDEO CALL
                          if (isAppointmentTime) {
                            // final result = await Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => CallSample(
                            //             host: '121.242.73.119',
                            //             doctorsHPRAdd: doctorHPRAdd,
                            //           )),
                            // );
                            // log("$result");

                            ///this is for group consultation
                            log("Doctor 2 provider Url:${_docTwoConfirmResponse!.context!.providerUrl}");
                            log("Doctor 1 provider Url:${_docOneConfirmResponse!.context!.providerUrl}");
                            final result = Get.toNamed(
                                AppRoutes.groupVideoCallPage,
                                arguments: <String, dynamic>{
                                  'initiator': {'address': userAbhaAddress},
                                  'transactionId': _docTwoConfirmResponse!
                                      .context!.transactionId,
                                  'primaryDoctor': {
                                    'name': _docOneConfirmResponse!.message!
                                        .order!.fulfillment!.agent!.name,
                                    'gender': _docOneConfirmResponse!.message!
                                        .order!.fulfillment!.agent!.gender,
                                    'address': _docOneConfirmResponse!
                                        .message!.order!.fulfillment!.agent!.id,
                                    'uri': _docOneConfirmResponse!
                                        .context!.providerUrl,
                                  },
                                  'secondaryDoctor': {
                                    'name': _docTwoConfirmResponse!.message!
                                        .order!.fulfillment!.agent!.name,
                                    'gender': _docTwoConfirmResponse!.message!
                                        .order!.fulfillment!.agent!.gender,
                                    'address': _docTwoConfirmResponse!
                                        .message!.order!.fulfillment!.agent!.id,
                                    'uri': _docTwoConfirmResponse!
                                        .context!.providerUrl,
                                  },
                                });

                            if (result != null && result == true) {
                              Get.to(() => ConsultationCompletedPage(
                                    bookingConfirmResponseModel:
                                        _bookingConfirmResponseModel,
                                  ));
                            }
                          }
                        },
                      )
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? Spacing(size: 10)
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? Container(
                        color: Color(0xFFF0F3F4),
                        height: 60,
                        width: 1,
                      )
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? Spacing(size: 10)
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? showDoctorActionView(
                        assetImage: 'assets/images/audio.png',
                        color:
                            AppColors.appointmentConfirmDoctorActionsTextColor,
                        actionText: AppStrings().audioCall,
                        onTap: () {})
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? Spacing(size: 10)
                    : Container(),
                _consultationType == DataStrings.teleconsultation
                    ? Container(
                        color: Color(0xFFF0F3F4),
                        height: 60,
                        width: 1,
                      )
                    : Container(
                        height: 60,
                      ),
                _consultationType == DataStrings.teleconsultation
                    ? Spacing(size: 10)
                    : Container(),
                showDoctorActionView(
                    assetImage: 'assets/images/Chat.png',
                    color: AppColors.appointmentConfirmDoctorActionsTextColor,
                    actionText: AppStrings().startChat,
                    onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildDoctorTile(BookingConfirmResponseModel confirmResponseModel) {
    String doctorName;
    String appointmentDate;
    String appointmentStartTime;
    String appointmentEndTime;
    String appointmentTime;
    String doctorEducation;
    String doctorHPRAdd;
    var tmpDate;
    String gender = "";

    doctorName =
        confirmResponseModel.message?.order?.fulfillment?.agent?.name ?? "";
    doctorName = doctorName != "" ? (doctorName.split("-")[1].trim()) : "";
    gender =
        confirmResponseModel.message?.order?.fulfillment?.agent?.gender ?? "";
    doctorHPRAdd =
        confirmResponseModel.message?.order?.fulfillment?.agent?.id ?? "";
    tmpDate = confirmResponseModel
            .message?.order?.fulfillment?.start?.time?.timestamp ??
        DateTime.now().toString();
    appointmentDate = DateFormat("dd MMM y").format(DateTime.parse(tmpDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    tmpDate = confirmResponseModel
            .message?.order?.fulfillment?.end?.time?.timestamp ??
        DateTime.now().toString();
    appointmentEndTime = DateFormat("hh:mm a").format(DateTime.parse(tmpDate));
    appointmentTime = appointmentStartTime + "-" + appointmentEndTime;
    doctorEducation = confirmResponseModel
            .message?.order?.fulfillment?.agent?.tags?.education ??
        "";

    return Padding(
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
                          style: AppTextStyle.appointmentConfirmedBoldTextStyle(
                              color: AppColors.doctorNameColor),
                        ),
                        Text(
                          doctorHPRAdd,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.doctorNameColor, fontSize: 12),
                        ),
                        // Text(
                        //   // 'MBBS/MS Cardiology',
                        //   doctorEducation,
                        //   style:
                        //       AppTextStyle.appointmentConfirmedLightTextStyle(
                        //           color: AppColors.doctorNameColor),
                        // ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.56,
                          child: Text(
                            doctorEducation,
                            style:
                                AppTextStyle.appointmentConfirmedLightTextStyle(
                                    color: AppColors.doctorNameColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.more_horiz_rounded,
              //       color: AppColors.doctorExperienceColor),
              // ),
            ],
          ),
          Spacing(isWidth: false, size: 10),
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
      child: Container(
        padding: EdgeInsets.all(8),
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
              style:
                  AppTextStyle.appointmentDoctorActionsTextStyle(color: color),
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

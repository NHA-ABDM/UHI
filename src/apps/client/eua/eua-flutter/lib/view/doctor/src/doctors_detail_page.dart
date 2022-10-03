import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/discovery/src/post_professional_details_controller.dart';
import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/common/src/time_slot_model.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/services/src/stomp_socket_connection.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uhi_flutter_app/view/appointment/src/appointment_details_page.dart';
import 'package:uhi_flutter_app/view/appointment/src/appointment_status_confirm_page.dart';
import 'package:uhi_flutter_app/widgets/src/calendar_date_range_picker.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uuid/uuid.dart';

import '../../../observer/home_page_obsevable.dart';

class DoctorsDetailPage extends StatefulWidget {
  Fulfillment discoveryFulfillments;
  DiscoveryItems? discoveryItems;
  DiscoveryProviders? discoveryProviders;
  String doctorAbhaId;
  String doctorName;
  String doctorProviderUri;
  String consultationType;
  bool isRescheduling;
  BookingConfirmResponseModel? bookingConfirmResponseModel;
  String? uniqueId;

  DoctorsDetailPage({
    Key? key,
    required this.doctorAbhaId,
    required this.doctorName,
    required this.doctorProviderUri,
    required this.discoveryFulfillments,
    required this.consultationType,
    required this.isRescheduling,
    this.bookingConfirmResponseModel,
    required this.uniqueId,
  }) : super(key: key);

  @override
  State<DoctorsDetailPage> createState() => _DiscoveryResultsPageState();
}

class _DiscoveryResultsPageState extends State<DoctorsDetailPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final _postProfessionalDetailsController =
      Get.put(PostProfessionalDetailsController());
  // final _postInitBookingDetailsController =
  //     Get.put(PostInitBookingDetailsController());

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  String? _selectedDate;
  int? _selectedTimeSlotIndex;
  TimeSlotModel? _selectedTimeSlot;
  List<String> startEndTime = [];
  String _uniqueId = "";
  String city = "";
  String? startTimeInString;
  String? endTimeInString;
  bool _loading = false;
  StompClient? stompClient;
  DiscoveryResponseModel? discoveryResponseModel;
  List<TimeSlotModel> _timeSlotList = List<TimeSlotModel>.empty(growable: true);
  BookingOnInitResponseModel? bookingOnInitResponseModel;
  int messageQueueNum = 0;
  String? _slotsStartTime =
      DateFormat("y-MM-ddTHH:mm:ss").format(DateTime.now());

  String? abhaAddress;
  String? _orderId;

  DiscoveryResponseModel? _discoveryResponse;
  Future<DiscoveryResponseModel?>? futureDiscoveryResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();

  String? _consultationType;

  Timer? _timer;

  bool _isRescheduling = false;

  // String? _slotsEndTime = DateFormat("y-MM-ddThh:mm:ss").format(DateTime.now());

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference abhaAddress : $value");
            abhaAddress = value;
          });
        }));
    _selectedDate = getForm(DateTime.now());
    _consultationType = widget.consultationType;
    _isRescheduling = widget.isRescheduling;
    _uniqueId = widget.uniqueId ?? const Uuid().v1();

    if (mounted) {
      futureDiscoveryResponse = getDiscoveryResponse();
    }
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  Future<DiscoveryResponseModel?> getDiscoveryResponse() async {
    DiscoveryResponseModel? discoveryResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(uniqueId: _uniqueId, api: postSearch2API);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        discoveryResponseModel =
            DiscoveryResponseModel.fromJson(json.decode(response.response!));
        _timer?.cancel();

        log("${json.encode(discoveryResponseModel)}", name: "RESPONSE");
      }
    };

    // stompSocketConnection.disconnect();

    // await Future.delayed(Duration(milliseconds: 3000));

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return discoveryResponseModel;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureDiscoveryResponse = getDiscoveryResponse();
  }

  ///SEARCH 2 API
  postSearch2API() async {
    // _uniqueId = const Uuid().v1();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "search";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.timestamp = DateTime.now()
        .add(Duration(days: 4))
        .toLocal()
        .toUtc()
        .toIso8601String();
    contextModel.transactionId = _uniqueId;
    contextModel.providerUrl = widget.doctorProviderUri;

    DoctorNameRequestModel professionalNameRequestModel =
        DoctorNameRequestModel();

    professionalNameRequestModel.context = contextModel;
    DoctorNameMessage message = DoctorNameMessage();
    DoctorNameIntent intent = DoctorNameIntent();
    DoctorNameFulfillment fulfillment = DoctorNameFulfillment();
    DoctorNameAgent agent = DoctorNameAgent();
    agent.cred = widget.doctorAbhaId;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();

    start.time = startTime;
    end.time = endTime;
    startTime.timestamp = _slotsStartTime;
    // var tmpDate = DateFormat("y-MM-dd")
    //     .format(DateTime.parse(_slotsStartTime!).add(Duration(days: 1)));
    endTime.timestamp = DateFormat("y-MM-ddT23:59:59")
        .format(DateTime.parse(_slotsStartTime!))
        .toString();

    fulfillment.startTime = start;
    fulfillment.endTime = end;
    fulfillment.type = _consultationType;
    fulfillment.agent = agent;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("==> ${jsonEncode(professionalNameRequestModel)}");

    await _postProfessionalDetailsController.postProfessionalDetails(
        professionalDetails: professionalNameRequestModel);
  }

  setTimeSlots() {
    _timeSlotList.clear();
    _discoveryResponse?.message?.catalog?.fulfillments?.forEach((element) {
      TimeSlotModel timeSlotModel = TimeSlotModel();
      TimeSlotStart timeSlotStart = TimeSlotStart();
      TimeSlotStart timeSlotEnd = TimeSlotStart();
      TimeSlotTags timeSlotTags = TimeSlotTags();
      TimeSlotStartTime timeSlotStartTime = TimeSlotStartTime();
      TimeSlotStartTime timeSlotEndTime = TimeSlotStartTime();

      if (Jiffy(DateTime.parse(element.start!.time!.timestamp!).toUtc())
          .isSameOrAfter(DateTime.now().toUtc())) {
        timeSlotStartTime.timestamp = element.start?.time?.timestamp;
        timeSlotStart.time = timeSlotStartTime;

        timeSlotEndTime.timestamp = element.end?.time?.timestamp;
        timeSlotEnd.time = timeSlotEndTime;

        timeSlotTags.abdmGovInSlot = element.initTimeSlotTags?.slotId;
        timeSlotModel.start = timeSlotStart;
        timeSlotModel.end = timeSlotEnd;
        timeSlotModel.tags = timeSlotTags;
        _timeSlotList.add(timeSlotModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async {
        if (_isRescheduling) {
          Get.until((route) {
            if (Get.currentRoute == "/home_page" ||
                Get.currentRoute == "/HomePage" ||
                Get.currentRoute == "/" ||
                Get.currentRoute == "")
              return true;
            else {
              final HomeScreenObservable observable = HomeScreenObservable();
              observable.notifyUpdateAppointmentData();
              return false;
            }
          });
        } else {
          Get.back();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            onPressed: () {
              if (_isRescheduling) {
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
            AppStrings().doctorDetails,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
        ),
        body: buildWidgets(),
        bottomSheet: GestureDetector(
          onTap: () async {
            log("${json.encode(_selectedTimeSlot)}", name: "TIME SLOT");
            if (_selectedTimeSlot == "" || _selectedTimeSlot == null) {
              DialogHelper.showErrorDialog(
                  title: AppStrings().errorString,
                  description: AppStrings().selectTimeSlot);
            } else {
              if (widget.isRescheduling) {
                // Get.to(() => AppointmentStatusConfirmPage(
                //       bookingConfirmResponseModel:
                //           widget.bookingConfirmResponseModel,
                //       consultationType: _consultationType,
                //       navigateToHomeAndRefresh: true,
                //     ));
                print("Done");
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings:
                          RouteSettings(name: "/AppointmentDetailsDetailPage"),
                      builder: (context) => AppointmentDetailsPage(
                            discoveryFulfillments: widget.discoveryFulfillments,
                            doctorProviderUri: widget.doctorProviderUri,
                            discoveryItems: widget.discoveryItems,
                            discoveryProviders: widget.discoveryProviders,
                            timeSlot: _selectedTimeSlot!,
                            consultationType: _consultationType,
                          )),
                );
                if (result != null && result == true) {
                  onRefresh();
                }
              } else {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings:
                          RouteSettings(name: "/AppointmentDetailsDetailPage"),
                      builder: (context) => AppointmentDetailsPage(
                            discoveryFulfillments: widget.discoveryFulfillments,
                            doctorProviderUri: widget.doctorProviderUri,
                            discoveryItems: widget.discoveryItems,
                            discoveryProviders: widget.discoveryProviders,
                            timeSlot: _selectedTimeSlot!,
                            consultationType: _consultationType,
                          )),
                );
                if (result != null && result == true) {
                  onRefresh();
                }
              }

              // Get.to(() => AppointmentDetailsDetailPage(
              //       discoveryFulfillments: widget.discoveryFulfillments,
              //       doctorProviderUri: widget.doctorProviderUri,
              //       discoveryItems: widget.discoveryItems,
              //       discoveryProviders: widget.discoveryProviders,
              //       timeSlot: _selectedTimeSlot!,
              //       consultationType: _consultationType,
              //     ));
            }
          },
          child: Container(
            margin: const EdgeInsets.all(20),
            height: 50,
            width: width * 0.89,
            decoration: const BoxDecoration(
              color: AppColors.amountColor,
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: Center(
              child: Text(
                AppStrings().bookNow,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildWidgets() {
    String consultationPrice =
        (widget.discoveryFulfillments.agent!.tags!.firstConsultation ?? "00") +
            " /-";
    return Container(
      width: width,
      height: height,
      color: AppColors.backgroundWhiteColorFBFCFF,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorDetailsView(
                  doctorName: widget.doctorName,
                  doctorAbhaId: widget.doctorAbhaId,
                  tags: widget.discoveryFulfillments.agent!.tags,
                  gender: widget.discoveryFulfillments.agent!.gender,
                  profileImage: widget.discoveryFulfillments.agent?.image,
                ),
                const SizedBox(
                  height: 5,
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(30, 0, 16, 16),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       RichText(
                //         text: TextSpan(
                //           text: AppStrings.teleconsultVaue,
                //           style: AppTextStyle.textSemiBoldStyle(
                //               color: AppColors.black, fontSize: 14),
                //           children: [
                //             TextSpan(
                //               text: AppStrings.teleconsultText,
                //               style: AppTextStyle.textLightStyle(
                //                   color: AppColors.infoIconColor, fontSize: 12),
                //             ),
                //           ],
                //         ),
                //       ),
                //       RichText(
                //         text: TextSpan(
                //           text: AppStrings.onTimePercentage,
                //           style: AppTextStyle.textSemiBoldStyle(
                //               color: AppColors.black, fontSize: 14),
                //           children: [
                //             TextSpan(
                //               text: AppStrings.onTimeText,
                //               style: AppTextStyle.textLightStyle(
                //                   color: AppColors.infoIconColor, fontSize: 12),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 8, 3),
                      child: Text(
                        "₹ " + consultationPrice,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.amountColor, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // Center(
                    //   child: Image.asset(
                    //     'assets/images/Practo-logo.png',
                    //     height: 40,
                    //     width: 60,
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  height: 1,
                  width: width,
                  color: const Color.fromARGB(255, 238, 238, 238),
                ),
                GestureDetector(
                  onTap: () {
                    datePicker();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                        width: width * 0.6,
                        height: 36,
                        decoration: BoxDecoration(
                            color: AppColors.tileColors,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.tileColors)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                _selectedDate!,
                                style: AppTextStyle.textSemiBoldStyle(
                                    color: AppColors.white, fontSize: 14),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: futureDiscoveryResponse,
                  builder: (context, loadingData) {
                    switch (loadingData.connectionState) {
                      case ConnectionState.waiting:
                        return CommonLoadingIndicator();

                      case ConnectionState.active:
                        return Text(AppStrings().loadingData);

                      case ConnectionState.done:
                        return loadingData.data != null
                            ? buildTimeSlots(loadingData.data)
                            : Container(
                                padding: EdgeInsets.fromLTRB(25, 0, 8, 10),
                                child: Text(
                                  AppStrings().timeSlotError,
                                  style: AppTextStyle.textLightStyle(
                                      color: AppColors.infoIconColor,
                                      fontSize: 12),
                                ),
                              );
                      default:
                        return loadingData.data != null
                            ? buildTimeSlots(loadingData.data)
                            : Container(
                                padding: EdgeInsets.fromLTRB(25, 0, 8, 10),
                                child: Text(
                                  AppStrings().timeSlotError,
                                  style: AppTextStyle.textLightStyle(
                                      color: AppColors.infoIconColor,
                                      fontSize: 12),
                                ),
                              );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeSlots(Object? data) {
    _discoveryResponse = data as DiscoveryResponseModel;

    setTimeSlots();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timeSlotList.length > 0
            ? Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 8, 10),
                child: Text(
                  AppStrings().chooseTimeSlot,
                  style: AppTextStyle.textLightStyle(
                      color: AppColors.infoIconColor, fontSize: 12),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 8, 10),
                child: Text(
                  AppStrings().noTimeSlot,
                  style: AppTextStyle.textLightStyle(
                      color: AppColors.infoIconColor, fontSize: 12),
                ),
              ),
        GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4.4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 8,
            ),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 100),
            itemCount: _timeSlotList.length,
            itemBuilder: (BuildContext context, int index) {
              TimeSlotModel timeSlotModel = _timeSlotList[index];
              String startTime = DateFormat("hh:mm a").format(
                  DateTime.parse(timeSlotModel.start!.time!.timestamp!));

              String endTime = DateFormat("hh:mm a")
                  .format(DateTime.parse(timeSlotModel.end!.time!.timestamp!));
              return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlotIndex = index;
                      _selectedTimeSlot = _timeSlotList[index];
                    });
                  },
                  //   child: Container(
                  //     padding: EdgeInsets.all(10),
                  //     decoration: BoxDecoration(
                  //         color: _selectedTimeSlotIndex == index
                  //             ? AppColors.tileColors
                  //             : AppColors.white,
                  //         borderRadius: BorderRadius.circular(5),
                  //         boxShadow: AppShadows.shadow2,
                  //         border: Border.all(color: AppColors.tileColors)),
                  //     child: Center(
                  //       child: Text(
                  //         startTime + " - " + endTime,
                  //         style: _selectedTimeSlotIndex == index
                  //             ? AppTextStyle.textSemiBoldStyle(
                  //                 color: AppColors.white, fontSize: 14)
                  //             : AppTextStyle.textMediumStyle(
                  //                 color: AppColors.darkGrey323232, fontSize: 14),
                  //         maxLines: 2,
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  // );
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      decoration: BoxDecoration(
                          color: _selectedTimeSlotIndex == index
                              ? AppColors.tileColors
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: AppShadows.shadow2,
                          border: Border.all(color: AppColors.tileColors)),
                      child: Center(
                        child: Text(
                          startTime + " - " + endTime,
                          style: _selectedTimeSlotIndex == index
                              ? AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.white, fontSize: 14)
                              : AppTextStyle.textMediumStyle(
                                  color: AppColors.darkGrey323232,
                                  fontSize: 14),
                        ),
                      ),
                    ),
                  ));
            }),
      ],
    );
  }

  String getForm(DateTime startDate) {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String getUntil(DateTime endDate) {
    return DateFormat('dd MMM yyyy').format(endDate);
  }

  datePicker() {
    CalendarDateRangePicker(
      context: context,
      isDateRange: false,
      minDateTime: DateTime.now(),
      onDateSubmit: (startDate, endDate) {
        final DateFormat formatter = DateFormat('dd MMM yyyy');
        if (startDate == null) {
          startDate = DateTime.now();
        }
        log("DATE PICKER");
        setState(() {
          _selectedDate = DateFormat('MMMM d').format(startDate!);
          _slotsStartTime = DateFormat("y-MM-ddTHH:mm:ss").format(startDate);
          // _slotsEndTime = DateFormat("y-MM-ddThh:mm:ss").format(endDate!);
          _selectedDate = getForm(startDate);
        });
        // connectToStompServer();
        onRefresh();
      },
    ).sfDatePicker();
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
}

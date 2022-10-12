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
import 'package:uhi_flutter_app/view/discovery/discovery.dart';
import 'package:uhi_flutter_app/view/group-consultation/src/multiple_doctor_appointment_details_page.dart';
import 'package:uhi_flutter_app/widgets/src/calendar_date_range_picker.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uuid/uuid.dart';

import '../../../observer/home_page_obsevable.dart';

class MultipleDoctorCommonSlotsPage extends StatefulWidget {
  String doctor1AbhaId;
  String doctor1Name;
  String doctor1ProviderUri;
  Fulfillment doctor1DiscoveryFulfillments;

  String doctor2AbhaId;
  String doctor2Name;
  String doctor2ProviderUri;
  Fulfillment doctor2DiscoveryFulfillments;

  String consultationType;
  bool isRescheduling;
  String uniqueId;

  MultipleDoctorCommonSlotsPage({
    Key? key,
    required this.doctor1AbhaId,
    required this.doctor1Name,
    required this.doctor1ProviderUri,
    required this.doctor1DiscoveryFulfillments,
    required this.doctor2AbhaId,
    required this.doctor2Name,
    required this.doctor2ProviderUri,
    required this.doctor2DiscoveryFulfillments,
    required this.consultationType,
    required this.isRescheduling,
    required this.uniqueId,
  }) : super(key: key);

  @override
  State<MultipleDoctorCommonSlotsPage> createState() =>
      _DiscoveryResultsPageState();
}

class _DiscoveryResultsPageState extends State<MultipleDoctorCommonSlotsPage> {
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
  List<TimeSlotModel> _timeSlotListDocOne =
      List<TimeSlotModel>.empty(growable: true);
  List<TimeSlotModel> _timeSlotListDocTwo =
      List<TimeSlotModel>.empty(growable: true);
  List<TimeSlotModel> _timeSlotListCommon =
      List<TimeSlotModel>.empty(growable: true);
  BookingOnInitResponseModel? bookingOnInitResponseModel;
  int messageQueueNum = 0;
  String? _slotsStartTime =
      DateFormat("y-MM-ddTHH:mm:ss").format(DateTime.now());

  String? abhaAddress;
  String? _orderId;

  DiscoveryResponseModel? _discoveryResponseDocOne;
  DiscoveryResponseModel? _discoveryResponseDocTwo;
  Future<List<DiscoveryResponseModel?>>? futureDiscoveryResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();

  String? _consultationType;

  Timer? _timer;

  bool _isRescheduling = false;

  TimeSlotModel? _selectedTimeSlotDocOne;
  TimeSlotModel? _selectedTimeSlotDocTwo;
  List<GroupConsultTimeSlot> _groupConsultTimeSlotList =
      List<GroupConsultTimeSlot>.empty(growable: true);
  String minSlot = "";
  DateTime minTimeForSlot1 = DateTime.now();
  DateTime maxTimeForSlot1 = DateTime.now();
  DateTime minTimeForSlot2 = DateTime.now();
  DateTime maxTimeForSlot2 = DateTime.now();
  int minSlotIndex = 0;

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
    _uniqueId = widget.uniqueId != "" ? widget.uniqueId : const Uuid().v1();

    if (mounted) {
      futureDiscoveryResponse = getResponseOfMultipleDoctors();
    }
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  Future<List<DiscoveryResponseModel?>> getResponseOfMultipleDoctors() async {
    List<DiscoveryResponseModel?> listOfDicoveryResponseForMultipleDocs =
        List.empty(growable: true);
    DiscoveryResponseModel? firstDiscoveryResponse;
    DiscoveryResponseModel? secondDiscoveryResponse;

    firstDiscoveryResponse = await getFirstDoctorDiscoveryResponse();
    await Future.delayed(Duration(seconds: 1));
    secondDiscoveryResponse = await getSecondDoctorDiscoveryResponse();

    listOfDicoveryResponseForMultipleDocs.add(firstDiscoveryResponse);
    listOfDicoveryResponseForMultipleDocs.add(secondDiscoveryResponse);

    return listOfDicoveryResponseForMultipleDocs;
  }

  Future<DiscoveryResponseModel?> getFirstDoctorDiscoveryResponse() async {
    DiscoveryResponseModel? discoveryResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postSearch2APIForDocOne);
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

  Future<DiscoveryResponseModel?> getSecondDoctorDiscoveryResponse() async {
    DiscoveryResponseModel? discoveryResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postSearch2APIForDocTwo);
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
    futureDiscoveryResponse = getResponseOfMultipleDoctors();
  }

  ///SEARCH 2 API
  postSearch2APIForDocOne() async {
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
    contextModel.providerUrl = widget.doctor1ProviderUri;

    DoctorNameRequestModel professionalNameRequestModel =
        DoctorNameRequestModel();

    professionalNameRequestModel.context = contextModel;
    DoctorNameMessage message = DoctorNameMessage();
    DoctorNameIntent intent = DoctorNameIntent();
    DoctorNameFulfillment fulfillment = DoctorNameFulfillment();
    DoctorNameAgent agent = DoctorNameAgent();
    agent.cred = widget.doctor1AbhaId;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    Tags tags = Tags();

    start.time = startTime;
    end.time = endTime;
    startTime.timestamp = _slotsStartTime;
    // var tmpDate = DateFormat("y-MM-dd")
    //     .format(DateTime.parse(_slotsStartTime!).add(Duration(days: 1)));
    endTime.timestamp = DateFormat("y-MM-ddT23:59:59")
        .format(DateTime.parse(_slotsStartTime!))
        .toString();

    tags.abdmGovInGroupConsultation = "true";
    tags.abdmGovInPrimaryDoctor = widget.doctor1AbhaId;
    tags.abdmGovInSecondaryDoctor = widget.doctor2AbhaId;

    fulfillment.startTime = start;
    fulfillment.endTime = end;
    fulfillment.type = _consultationType;
    agent.tags = tags;
    fulfillment.agent = agent;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("==> ${jsonEncode(professionalNameRequestModel)}");

    await _postProfessionalDetailsController.postProfessionalDetails(
        professionalDetails: professionalNameRequestModel);
  }

  ///SEARCH 2 API
  postSearch2APIForDocTwo() async {
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
    contextModel.providerUrl = widget.doctor2ProviderUri;

    DoctorNameRequestModel professionalNameRequestModel =
        DoctorNameRequestModel();

    professionalNameRequestModel.context = contextModel;
    DoctorNameMessage message = DoctorNameMessage();
    DoctorNameIntent intent = DoctorNameIntent();
    DoctorNameFulfillment fulfillment = DoctorNameFulfillment();
    DoctorNameAgent agent = DoctorNameAgent();
    agent.cred = widget.doctor2AbhaId;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    Tags tags = Tags();

    start.time = startTime;
    end.time = endTime;
    startTime.timestamp = _slotsStartTime;
    // var tmpDate = DateFormat("y-MM-dd")
    //     .format(DateTime.parse(_slotsStartTime!).add(Duration(days: 1)));
    endTime.timestamp = DateFormat("y-MM-ddT23:59:59")
        .format(DateTime.parse(_slotsStartTime!))
        .toString();

    tags.abdmGovInGroupConsultation = "true";
    tags.abdmGovInPrimaryDoctor = widget.doctor1AbhaId;
    tags.abdmGovInSecondaryDoctor = widget.doctor2AbhaId;

    fulfillment.startTime = start;
    fulfillment.endTime = end;
    fulfillment.type = _consultationType;
    agent.tags = tags;
    fulfillment.agent = agent;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("==> ${jsonEncode(professionalNameRequestModel)}");

    await _postProfessionalDetailsController.postProfessionalDetails(
        professionalDetails: professionalNameRequestModel);
  }

  setTimeSlots() {
    _timeSlotListDocOne.clear();
    _timeSlotListDocTwo.clear();
    _timeSlotListCommon.clear();
    _groupConsultTimeSlotList.clear();

    _discoveryResponseDocOne?.message?.catalog?.fulfillments
        ?.forEach((element) {
      TimeSlotModel timeSlotModel = TimeSlotModel();
      TimeSlotStart timeSlotStart = TimeSlotStart();
      TimeSlotStart timeSlotEnd = TimeSlotStart();
      TimeSlotTags timeSlotTags = TimeSlotTags();
      TimeSlotStartTime timeSlotStartTime = TimeSlotStartTime();
      TimeSlotStartTime timeSlotEndTime = TimeSlotStartTime();

      if (Jiffy(DateTime.parse(element.start!.time!.timestamp!))
          .isSameOrAfter(DateTime.now())) {
        timeSlotStartTime.timestamp = element.start?.time?.timestamp;
        timeSlotStart.time = timeSlotStartTime;

        timeSlotEndTime.timestamp = element.end?.time?.timestamp;
        timeSlotEnd.time = timeSlotEndTime;

        timeSlotTags.abdmGovInSlot = element.initTimeSlotTags?.slotId;
        timeSlotModel.start = timeSlotStart;
        timeSlotModel.end = timeSlotEnd;
        timeSlotModel.tags = timeSlotTags;
        _timeSlotListDocOne.add(timeSlotModel);
      }
    });

    _discoveryResponseDocTwo?.message?.catalog?.fulfillments
        ?.forEach((element) {
      TimeSlotModel timeSlotModel = TimeSlotModel();
      TimeSlotStart timeSlotStart = TimeSlotStart();
      TimeSlotStart timeSlotEnd = TimeSlotStart();
      TimeSlotTags timeSlotTags = TimeSlotTags();
      TimeSlotStartTime timeSlotStartTime = TimeSlotStartTime();
      TimeSlotStartTime timeSlotEndTime = TimeSlotStartTime();

      if (Jiffy(DateTime.parse(element.start!.time!.timestamp!))
          .isSameOrAfter(DateTime.now())) {
        timeSlotStartTime.timestamp = element.start?.time?.timestamp;
        timeSlotStart.time = timeSlotStartTime;

        timeSlotEndTime.timestamp = element.end?.time?.timestamp;
        timeSlotEnd.time = timeSlotEndTime;

        timeSlotTags.abdmGovInSlot = element.initTimeSlotTags?.slotId;
        timeSlotModel.start = timeSlotStart;
        timeSlotModel.end = timeSlotEnd;
        timeSlotModel.tags = timeSlotTags;
        _timeSlotListDocTwo.add(timeSlotModel);
      }
    });

    _timeSlotListCommon
        .addAll(getCommonSlots(_timeSlotListDocOne, _timeSlotListDocTwo));
  }

  List<TimeSlotModel> getCommonSlots(
      List<TimeSlotModel> slots1, List<TimeSlotModel> slots2) {
    DateTime minStartTime = DateTime.now().toLocal();
    List<TimeSlotModel> matchingSlots =
        List<TimeSlotModel>.empty(growable: true);

    // String minSlot = "";

    if (slots1.isNotEmpty && slots2.isNotEmpty) {
      minTimeForSlot1 = DateTime.parse(slots1[0].start!.time!.timestamp!);
      maxTimeForSlot1 =
          DateTime.parse(slots1[(slots1.length - 1)].end!.time!.timestamp!);
      minTimeForSlot2 = DateTime.parse(slots2[0].start!.time!.timestamp!);
      maxTimeForSlot2 =
          DateTime.parse(slots2[(slots2.length - 1)].end!.time!.timestamp!);
      checkMinSlot(slots1, slots2);

      slots1.forEach((s1) {
        DateTime s1Start = DateTime.parse(s1.start!.time!.timestamp!).toLocal();
        DateTime s1End = DateTime.parse(s1.end!.time!.timestamp!).toLocal();

        if (s1Start.isBefore(minStartTime) && s1Start != minStartTime) {
          return;
        }

        slots2.forEach((s2) {
          DateTime s2Start =
              DateTime.parse(s2.start!.time!.timestamp!).toLocal();
          DateTime s2End = DateTime.parse(s2.end!.time!.timestamp!).toLocal();

          if (s2Start.isBefore(minStartTime) && s2Start != minStartTime) {
            return;
          }

          /// Logic by Ganesh
          /// Below if indicates that s1 time range is greater than s2 time range and s2 time ranges in s1 time range
          if ((s1Start.isBefore(s2Start) || s1Start == s2Start) &&
              (s1End.isAfter(s2End) || s1End == s2End)) {
            debugPrint(
                'Common slots are $s1Start - $s1End and $s2Start - $s2End');
            matchingSlots.add(s2);
            _groupConsultTimeSlotList.add(
                GroupConsultTimeSlot(docOneTimeSlot: s1, docTwoTimeSlot: s2));
          } else if ((s2Start.isBefore(s1Start) || s2Start == s1Start) &&
              (s2End.isAfter(s1End) || s2End == s1End)) {
            debugPrint(
                'Common slots are $s1Start - $s1End and $s2Start - $s2End');
            matchingSlots.add(s1);
            _groupConsultTimeSlotList.add(
                GroupConsultTimeSlot(docOneTimeSlot: s1, docTwoTimeSlot: s2));
          } else {}

          // if (between(s1Start, s2Start, s2End) ||
          //     between(s2Start, s1Start, s1End)) {
          //   if (minSlot == "s1") {
          //     matchingSlots.add(s1);
          //     _groupConsultTimeSlotList.add(
          //         GroupConsultTimeSlot(docOneTimeSlot: s1, docTwoTimeSlot: s2));
          //   } else if (minSlot == "s2") {
          //     matchingSlots.add(s2);
          //     _groupConsultTimeSlotList.add(
          //         GroupConsultTimeSlot(docOneTimeSlot: s1, docTwoTimeSlot: s2));
          //   }
          // }
        });
      });

      matchingSlots = matchingSlots.toSet().toList();
      _groupConsultTimeSlotList = _groupConsultTimeSlotList.toSet().toList();
    }
    return matchingSlots;
  }

  bool between(DateTime t, DateTime t1, DateTime t2) {
    return (t.isBefore(t2) || t == t2) && (t.isAfter(t1) || t == t1);
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

  checkMinSlot(List<TimeSlotModel> slots1, List<TimeSlotModel> slots2) {
    if (slots1.isNotEmpty &&
        slots2.isNotEmpty &&
        slots1.length >= minSlotIndex &&
        slots2.length >= minSlotIndex) {
      if (slots1.length == minSlotIndex) {
        minSlot = "s1";
        minSlotIndex = 0;

        return;
      } else if (slots2.length == minSlotIndex) {
        minSlot = "s2";
        minSlotIndex = 0;

        return;
      }

      DateTime s1StartZeroElement =
          DateTime.parse(slots1[minSlotIndex].start!.time!.timestamp!)
              .toLocal();
      DateTime s1EndZeroElement =
          DateTime.parse(slots1[minSlotIndex].end!.time!.timestamp!).toLocal();
      DateTime s2StartZeroElement =
          DateTime.parse(slots2[minSlotIndex].start!.time!.timestamp!)
              .toLocal();
      DateTime s2EndZeroElement =
          DateTime.parse(slots2[minSlotIndex].end!.time!.timestamp!).toLocal();

      if (maxTimeForSlot1.isBefore(minTimeForSlot2) ||
          maxTimeForSlot1.isAtSameMomentAs(minTimeForSlot2)) {
        minSlot = "";
        minSlotIndex = 0;

        return;
      } else if (maxTimeForSlot2.isBefore(minTimeForSlot1) ||
          maxTimeForSlot2.isAtSameMomentAs(minTimeForSlot1)) {
        minSlot = "";
        minSlotIndex = 0;

        return;
      }

      if (minBetween(s1StartZeroElement, s1EndZeroElement, s2StartZeroElement,
              s2EndZeroElement) ==
          "s1") {
        minSlot = "s1";
        minSlotIndex = 0;

        return;
      } else if (minBetween(s1StartZeroElement, s1EndZeroElement,
              s2StartZeroElement, s2EndZeroElement) ==
          "s2") {
        minSlot = "s2";
        minSlotIndex = 0;

        return;
      } else {
        minSlotIndex++;
        checkMinSlot(slots1, slots2);
      }
    }
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
            log("DOC ONE => ${jsonEncode(_selectedTimeSlotDocOne)}");
            log("DOC TWO => ${jsonEncode(_selectedTimeSlotDocTwo)}");

            if (_selectedTimeSlot == "" || _selectedTimeSlot == null) {
              DialogHelper.showErrorDialog(
                  title: AppStrings().errorString,
                  description: AppStrings().selectTimeSlot);
            } else {
              _groupConsultTimeSlotList.forEach((element) {
                if (_selectedTimeSlot?.tags?.abdmGovInSlot ==
                    element.docOneTimeSlot.tags?.abdmGovInSlot) {
                  _selectedTimeSlotDocOne = element.docOneTimeSlot;
                  _selectedTimeSlotDocTwo = element.docTwoTimeSlot;
                } else if (_selectedTimeSlot?.tags?.abdmGovInSlot ==
                    element.docTwoTimeSlot.tags?.abdmGovInSlot) {
                  _selectedTimeSlotDocOne = element.docOneTimeSlot;
                  _selectedTimeSlotDocTwo = element.docTwoTimeSlot;
                }
              });

              if (widget.isRescheduling) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings:
                          RouteSettings(name: "/AppointmentDetailsDetailPage"),
                      builder: (context) =>
                          MultipleDoctorAppointmentDetailsPage(
                            docOneDiscoveryFulfillments:
                                widget.doctor1DiscoveryFulfillments,
                            doctor1AbhaId: widget.doctor1AbhaId,
                            docOneProviderUri: widget.doctor1ProviderUri,
                            docOneTimeSlot: _selectedTimeSlotDocOne!,
                            docTwoDiscoveryFulfillments:
                                widget.doctor2DiscoveryFulfillments,
                            doctor2AbhaId: widget.doctor2AbhaId,
                            docTwoProviderUri: widget.doctor2ProviderUri,
                            docTwoTimeSlot: _selectedTimeSlotDocTwo!,
                            consultationType: _consultationType,
                            uniqueId: _uniqueId,
                            appointmentStartTime:
                                _selectedTimeSlot?.start?.time?.timestamp ?? "",
                            appointmentEndTime:
                                _selectedTimeSlot?.end?.time?.timestamp ?? "",
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
                      builder: (context) =>
                          MultipleDoctorAppointmentDetailsPage(
                            docOneDiscoveryFulfillments:
                                widget.doctor1DiscoveryFulfillments,
                            doctor1AbhaId: widget.doctor1AbhaId,
                            docOneProviderUri: widget.doctor1ProviderUri,
                            docOneTimeSlot: _selectedTimeSlotDocOne!,
                            docTwoDiscoveryFulfillments:
                                widget.doctor2DiscoveryFulfillments,
                            doctor2AbhaId: widget.doctor2AbhaId,
                            docTwoProviderUri: widget.doctor2ProviderUri,
                            docTwoTimeSlot: _selectedTimeSlotDocTwo!,
                            consultationType: _consultationType,
                            uniqueId: _uniqueId,
                            appointmentStartTime:
                                _selectedTimeSlot?.start?.time?.timestamp ?? "",
                            appointmentEndTime:
                                _selectedTimeSlot?.end?.time?.timestamp ?? "",
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
                "BOOK SLOT",
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
                buildDoctorTile(widget.doctor1DiscoveryFulfillments),
                buildDoctorTile(widget.doctor2DiscoveryFulfillments),
                // Container(
                //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                //   height: 1,
                //   width: width,
                //   color: const Color.fromARGB(255, 238, 238, 238),
                // ),
                Spacing(
                  isWidth: false,
                  size: 15,
                ),
                Container(
                  width: width,
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 5,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                  ),
                  child: Text(
                    "Common slots for doctors",
                    style: AppTextStyle.textSemiBoldStyle(
                        color: AppColors.doctorNameColor, fontSize: 18),
                  ),
                ),
                Spacing(
                  isWidth: false,
                  size: 15,
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
                        margin: const EdgeInsets.fromLTRB(16, 0, 8, 10),
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
                                padding: EdgeInsets.fromLTRB(16, 0, 8, 10),
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
                                padding: EdgeInsets.fromLTRB(16, 0, 8, 10),
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

  buildDoctorTile(Fulfillment fulfillment) {
    String consultationPrice =
        (fulfillment.agent!.tags!.firstConsultation ?? "00") + " /-";

    return Column(
      children: [
        DoctorDetailsView(
          doctorName: fulfillment.agent?.name,
          doctorAbhaId: fulfillment.agent?.id,
          tags: fulfillment.agent?.tags,
          gender: fulfillment.agent?.gender,
          profileImage: fulfillment.agent?.image,
        ),
        const SizedBox(
          height: 5,
        ),
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
          ],
        ),
      ],
    );
  }

  Widget buildTimeSlots(Object? data) {
    data = data as List<DiscoveryResponseModel?>;
    _discoveryResponseDocOne = data[0];
    _discoveryResponseDocTwo = data[1];

    setTimeSlots();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timeSlotListCommon.length > 0
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
                child: Text(
                  AppStrings().chooseTimeSlot,
                  style: AppTextStyle.textLightStyle(
                      color: AppColors.infoIconColor, fontSize: 12),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
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
            itemCount: _timeSlotListCommon.length,
            itemBuilder: (BuildContext context, int index) {
              TimeSlotModel timeSlotModel = _timeSlotListCommon[index];
              String startTime = DateFormat("hh:mm a").format(
                  DateTime.parse(timeSlotModel.start!.time!.timestamp!)
                      .toLocal());

              String endTime = DateFormat("hh:mm a").format(
                  DateTime.parse(timeSlotModel.end!.time!.timestamp!)
                      .toLocal());
              return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlotIndex = index;
                      _selectedTimeSlot = _timeSlotListCommon[index];
                      log("${jsonEncode(_selectedTimeSlot)}");
                      _selectedTimeSlotDocOne =
                          _groupConsultTimeSlotList[index].docOneTimeSlot;
                      log("${jsonEncode(_selectedTimeSlotDocOne)}");

                      _selectedTimeSlotDocTwo =
                          _groupConsultTimeSlotList[index].docTwoTimeSlot;
                      log("${jsonEncode(_selectedTimeSlotDocTwo)}");
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
          minSlotIndex = 0;
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

class GroupConsultTimeSlot {
  TimeSlotModel docOneTimeSlot;
  TimeSlotModel docTwoTimeSlot;

  GroupConsultTimeSlot(
      {required this.docOneTimeSlot, required this.docTwoTimeSlot});
}

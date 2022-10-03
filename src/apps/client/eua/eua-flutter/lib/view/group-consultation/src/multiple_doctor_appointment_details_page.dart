import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/booking/post_booking_details_controller.dart';
import 'package:uhi_flutter_app/controller/discovery/src/post_init_booking_details_controller.dart';
import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/common/src/time_slot_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/services/src/stomp_socket_connection.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uhi_flutter_app/view/group-consultation/src/multiple_doctor_payment_page.dart';
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uuid/uuid.dart';

class MultipleDoctorAppointmentDetailsPage extends StatefulWidget {
  Fulfillment docOneDiscoveryFulfillments;
  String doctor1AbhaId;
  DiscoveryItems? docOneDiscoveryItems;
  TimeSlotModel docOneTimeSlot;
  String docOneProviderUri;

  Fulfillment docTwoDiscoveryFulfillments;
  String doctor2AbhaId;
  DiscoveryItems? docTwoDiscoveryItems;
  TimeSlotModel docTwoTimeSlot;
  String docTwoProviderUri;

  String? consultationType;
  String uniqueId;
  String appointmentStartTime;
  String appointmentEndTime;

  MultipleDoctorAppointmentDetailsPage({
    Key? key,
    required this.doctor1AbhaId,
    required this.docOneDiscoveryFulfillments,
    this.docOneDiscoveryItems,
    required this.docOneProviderUri,
    required this.docOneTimeSlot,
    required this.docTwoDiscoveryFulfillments,
    required this.doctor2AbhaId,
    this.docTwoDiscoveryItems,
    required this.docTwoTimeSlot,
    required this.docTwoProviderUri,
    this.consultationType,
    required this.uniqueId,
    required this.appointmentStartTime,
    required this.appointmentEndTime,
  }) : super(key: key);

  @override
  State<MultipleDoctorAppointmentDetailsPage> createState() =>
      _MultipleDoctorAppointmentDetailsPageState();
}

class _MultipleDoctorAppointmentDetailsPageState
    extends State<MultipleDoctorAppointmentDetailsPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final _postBookingDetailsController = Get.put(PostBookingDetailsController());
  final _postInitBookingDetailsController =
      Get.put(PostInitBookingDetailsController());

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  String? _selectedDate;
  int? _selectedTimeSlotIndex;
  BookingOnInitResponseModel? _bookingOnInitResponseModel;
  String? _teleconsultationFees = "0/-";
  String? _totalFees = "0/-";
  String? _appointmentDateAndTime;
  String? _appointmentStartDateAndTime;
  String? _appointmentEndDateAndTime;
  String _uniqueId = "";
  int messageQueueNum = 0;
  StompClient? stompClient;
  String? abhaAddress;
  bool _loading = false;

  String? _orderId;
  BookingOnInitResponseModel? _initResponse;
  TimeSlotModel? _timeSlotDocOne;
  TimeSlotModel? _timeSlotDocTwo;

  Fulfillment? _docOneDiscoveryFulfillments;
  Fulfillment? _docTwoDiscoveryFulfillments;

  BookingOnInitResponseModel? _docOneInitResponse;
  BookingOnInitResponseModel? _docTwoInitResponse;

  Future<List<BookingOnInitResponseModel?>>? futureInitResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();

  String? _consultationType;
  Timer? _timer;

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
    // _bookingOnInitResponseModel = widget.bookingOnInitResponseModel;
    _timeSlotDocOne = widget.docOneTimeSlot;
    _timeSlotDocTwo = widget.docTwoTimeSlot;
    _docOneDiscoveryFulfillments = widget.docOneDiscoveryFulfillments;
    _docTwoDiscoveryFulfillments = widget.docTwoDiscoveryFulfillments;
    _consultationType = widget.consultationType;
    _uniqueId = widget.uniqueId != "" ? widget.uniqueId : const Uuid().v1();
    _appointmentStartDateAndTime = widget.appointmentStartTime;
    _appointmentEndDateAndTime = widget.appointmentEndTime;

    if (mounted) {
      futureInitResponse = getResponseOfMultipleDoctors();
    }
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    _timer?.cancel();

    super.dispose();
  }

  Future<List<BookingOnInitResponseModel?>>
      getResponseOfMultipleDoctors() async {
    List<BookingOnInitResponseModel?> listOfInitResponseForMultipleDocs =
        List.empty(growable: true);
    BookingOnInitResponseModel? firstInitResponse;
    BookingOnInitResponseModel? secondInitResponse;

    firstInitResponse = await getFirstDoctorInitResponse();
    await Future.delayed(Duration(seconds: 1));
    secondInitResponse = await getSecondDoctorInitResponse();

    listOfInitResponseForMultipleDocs.add(firstInitResponse);
    listOfInitResponseForMultipleDocs.add(secondInitResponse);

    return listOfInitResponseForMultipleDocs;
  }

  Future<BookingOnInitResponseModel?> getFirstDoctorInitResponse() async {
    BookingOnInitResponseModel? bookingOnInitResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postInitAPIForDocOne);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        bookingOnInitResponseModel = BookingOnInitResponseModel.fromJson(
            json.decode(response.response!));
        _timer?.cancel();

        log("${json.encode(bookingOnInitResponseModel)}", name: "RESPONSE");
      }
    };

    // stompSocketConnection.disconnect();

    // await Future.delayed(Duration(milliseconds: 3000));

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return bookingOnInitResponseModel;
  }

  Future<BookingOnInitResponseModel?> getSecondDoctorInitResponse() async {
    BookingOnInitResponseModel? bookingOnInitResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postInitAPIForDocTwo);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        bookingOnInitResponseModel = BookingOnInitResponseModel.fromJson(
            json.decode(response.response!));
        _timer?.cancel();

        log("${json.encode(bookingOnInitResponseModel)}", name: "RESPONSE");
      }
    };

    // stompSocketConnection.disconnect();

    // await Future.delayed(Duration(milliseconds: 3000));

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return bookingOnInitResponseModel;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureInitResponse = getResponseOfMultipleDoctors();
  }

  ///INIT API FOR DOC ONE
  postInitAPIForDocOne() async {
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
    _orderId = const Uuid().v1();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesHelper.bookingOrderIdOne, _orderId!);

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "init";
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
    contextModel.providerUrl = widget.docOneProviderUri;

    BookingInitRequestModel bookingInitRequestModel = BookingInitRequestModel();
    bookingInitRequestModel.context = contextModel;
    Message? message = Message();
    Order? order = Order();
    DiscoveryItems discoveryItems = DiscoveryItems();
    DiscoveryDescriptor? descriptor = DiscoveryDescriptor();
    DiscoveryPrice? price = DiscoveryPrice();

    Fulfillment? fulfillment = Fulfillment();
    DiscoveryAgent agent = DiscoveryAgent();
    agent.id = widget.docOneDiscoveryFulfillments.agent?.id;
    agent.name = widget.docOneDiscoveryFulfillments.agent?.name;
    agent.gender = widget.docOneDiscoveryFulfillments.agent?.gender;
    // agent.tags = widget.docOneDiscoveryFulfillments.agent?.tags;
    Tags tags = Tags();
    tags.abdmGovInGroupConsultation = "true";
    tags.abdmGovInPrimaryDoctor = widget.doctor1AbhaId;
    tags.abdmGovInSecondaryDoctor = widget.doctor2AbhaId;
    agent.tags = tags;
    fulfillment.agent = agent;
    fulfillment.id = widget.docOneDiscoveryFulfillments.id;
    fulfillment.type = _consultationType;

    price.currency = "INR";
    price.value =
        widget.docOneDiscoveryFulfillments.agent?.tags?.firstConsultation;

    discoveryItems.price = price;
    discoveryItems.descriptor = descriptor;
    descriptor.name = "Consultation";
    discoveryItems.id = "1";
    discoveryItems.fulfillmentId = _timeSlotDocOne?.tags?.abdmGovInSlot;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    InitTimeSlotTags initTimeSlotTags = InitTimeSlotTags();

    startTime.timestamp = _timeSlotDocOne?.start?.time?.timestamp;
    endTime.timestamp = _timeSlotDocOne?.end?.time?.timestamp;
    initTimeSlotTags.abdmGovInSlotId = _timeSlotDocOne?.tags?.abdmGovInSlot;
    start.time = startTime;
    end.time = endTime;
    fulfillment.start = start;
    fulfillment.end = end;
    fulfillment.initTimeSlotTags = initTimeSlotTags;
    fulfillment.id = _timeSlotDocOne?.tags?.abdmGovInSlot;

    order.id = _orderId;
    order.item = widget.docOneDiscoveryItems;
    order.fulfillment = fulfillment;
    order.item = discoveryItems;

    Billing billing = Billing();
    Customer customer = Customer();
    Address address = Address();

    customer.id = "";
    // customer.cred = "vi.s@sbx";
    customer.cred = abhaAddress;

    billing.name = getUserDetailsResponseModel.fullName;
    billing.email = getUserDetailsResponseModel.email;
    billing.phone = getUserDetailsResponseModel.mobile;
    address.door = "";
    address.name = getUserDetailsResponseModel.address;
    address.locality = "";
    address.city = getUserDetailsResponseModel.districtName;
    address.state = getUserDetailsResponseModel.stateName;
    address.country = getUserDetailsResponseModel.countryName;
    address.areaCode = getUserDetailsResponseModel.pincode;

    billing.address = address;
    order.billing = billing;
    order.customer = customer;
    message.order = order;
    bookingInitRequestModel.message = message;

    log("==> Init request ${jsonEncode(bookingInitRequestModel)}");

    await _postInitBookingDetailsController.postInitBookingDetails(
        bookingInitRequestModel: bookingInitRequestModel);
  }

  ///INIT API FOR DOC TWO
  postInitAPIForDocTwo() async {
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
    _orderId = const Uuid().v1();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesHelper.bookingOrderIdTwo, _orderId!);

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "init";
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
    contextModel.providerUrl = widget.docTwoProviderUri;

    BookingInitRequestModel bookingInitRequestModel = BookingInitRequestModel();
    bookingInitRequestModel.context = contextModel;
    Message? message = Message();
    Order? order = Order();
    DiscoveryItems discoveryItems = DiscoveryItems();
    DiscoveryDescriptor? descriptor = DiscoveryDescriptor();
    DiscoveryPrice? price = DiscoveryPrice();

    Fulfillment? fulfillment = Fulfillment();
    DiscoveryAgent agent = DiscoveryAgent();
    agent.id = widget.docTwoDiscoveryFulfillments.agent?.id;
    agent.name = widget.docTwoDiscoveryFulfillments.agent?.name;
    agent.gender = widget.docTwoDiscoveryFulfillments.agent?.gender;
    // agent.tags = widget.docTwoDiscoveryFulfillments.agent?.tags;
    Tags tags = Tags();
    tags.abdmGovInGroupConsultation = "true";
    tags.abdmGovInPrimaryDoctor = widget.doctor1AbhaId;
    tags.abdmGovInSecondaryDoctor = widget.doctor2AbhaId;
    agent.tags = tags;
    fulfillment.agent = agent;
    fulfillment.id = widget.docTwoDiscoveryFulfillments.id;
    fulfillment.type = _consultationType;

    price.currency = "INR";
    price.value =
        widget.docTwoDiscoveryFulfillments.agent?.tags?.firstConsultation;

    discoveryItems.price = price;
    discoveryItems.descriptor = descriptor;
    descriptor.name = "Consultation";
    discoveryItems.id = "1";
    discoveryItems.fulfillmentId = _timeSlotDocTwo?.tags?.abdmGovInSlot;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    InitTimeSlotTags initTimeSlotTags = InitTimeSlotTags();

    startTime.timestamp = _timeSlotDocTwo?.start?.time?.timestamp;
    endTime.timestamp = _timeSlotDocTwo?.end?.time?.timestamp;
    initTimeSlotTags.abdmGovInSlotId = _timeSlotDocTwo?.tags?.abdmGovInSlot;
    start.time = startTime;
    end.time = endTime;
    fulfillment.start = start;
    fulfillment.end = end;
    fulfillment.initTimeSlotTags = initTimeSlotTags;
    fulfillment.id = _timeSlotDocTwo?.tags?.abdmGovInSlot;

    order.id = _orderId;
    order.item = widget.docTwoDiscoveryItems;
    order.fulfillment = fulfillment;
    order.item = discoveryItems;

    Billing billing = Billing();
    Customer customer = Customer();
    Address address = Address();

    customer.id = "";
    // customer.cred = "vi.s@sbx";
    customer.cred = abhaAddress;

    billing.name = getUserDetailsResponseModel.fullName;
    billing.email = getUserDetailsResponseModel.email;
    billing.phone = getUserDetailsResponseModel.mobile;
    address.door = "";
    address.name = getUserDetailsResponseModel.address;
    address.locality = "";
    address.city = getUserDetailsResponseModel.districtName;
    address.state = getUserDetailsResponseModel.stateName;
    address.country = getUserDetailsResponseModel.countryName;
    address.areaCode = getUserDetailsResponseModel.pincode;

    billing.address = address;
    order.billing = billing;
    order.customer = customer;
    message.order = order;
    bookingInitRequestModel.message = message;

    log("==> Init request ${jsonEncode(bookingInitRequestModel)}");

    await _postInitBookingDetailsController.postInitBookingDetails(
        bookingInitRequestModel: bookingInitRequestModel);
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
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            onPressed: () {
              // Get.back();
              Navigator.pop(context, true);
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
            "You are Booking appointments with",
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
        ),
        body: FutureBuilder(
          future: futureInitResponse,
          builder: (context, loadingData) {
            switch (loadingData.connectionState) {
              case ConnectionState.waiting:
                return CommonLoadingIndicator();

              case ConnectionState.active:
                return Text(AppStrings().loadingData);

              case ConnectionState.done:
                return loadingData.data != null
                    ? buildWidgets(loadingData.data)
                    : RefreshIndicator(
                        onRefresh: onRefresh,
                        child: Stack(
                          children: [
                            ListView(),
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  AppStrings().serverBusyErrorMsg,
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              default:
                return loadingData.data != null
                    ? buildWidgets(loadingData.data)
                    : RefreshIndicator(
                        onRefresh: onRefresh,
                        child: Stack(
                          children: [
                            ListView(),
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  AppStrings().serverBusyErrorMsg,
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
            }
          },
        ),
        bottomSheet: GestureDetector(
          onTap: () async {
            Get.to(() => MultipleDoctorPaymentPage(
                  teleconsultationFees: _teleconsultationFees,
                  docOneFulfillment: _docOneDiscoveryFulfillments!,
                  docTwoFulfillment: _docTwoDiscoveryFulfillments!,
                  docOneInitResponse: _docOneInitResponse!,
                  docTwoInitResponse: _docTwoInitResponse!,
                  consultationType: _consultationType!,
                  doctorImage: _docOneDiscoveryFulfillments?.agent?.image,
                  uniqueId: _uniqueId,
                  appointmentStartDateAndTime:
                      _appointmentStartDateAndTime ?? "",
                  appointmentEndDateAndTime: _appointmentEndDateAndTime ?? "",
                ));
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
                AppStrings().payNow,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildWidgets(Object? data) {
    if (data != null) {
      data = data as List;
      _docOneInitResponse = data[0];
      _docTwoInitResponse = data[1];
    }

    String docOneName;
    String docOneSpeciality;
    String docOneImage;
    String docOneGender;
    String docOneFees;

    String docTwoName;
    String docTwoSpeciality;
    String docTwoImage;
    String docTwoGender;
    String docTwoFees;

    String appointmentFees;

    docOneName =
        (_docOneDiscoveryFulfillments?.agent?.name?.split("-")[1].trim()) ?? "";
    docOneSpeciality =
        _docOneDiscoveryFulfillments?.agent?.tags?.specialtyTag ?? "";
    docOneGender = _docOneDiscoveryFulfillments?.agent?.gender ?? "";
    docOneImage = _docOneDiscoveryFulfillments?.agent?.image ?? "";
    docOneFees =
        _docOneDiscoveryFulfillments?.agent?.tags?.firstConsultation ?? "";

    docTwoName =
        (_docTwoDiscoveryFulfillments?.agent?.name?.split("-")[1].trim()) ?? "";
    docTwoSpeciality =
        _docTwoDiscoveryFulfillments?.agent?.tags?.specialtyTag ?? "";
    docTwoGender = _docTwoDiscoveryFulfillments?.agent?.gender ?? "";
    docTwoImage = _docTwoDiscoveryFulfillments?.agent?.image ?? "";
    docTwoFees =
        _docTwoDiscoveryFulfillments?.agent?.tags?.firstConsultation ?? "";

    log("${_docOneDiscoveryFulfillments?.start?.time?.timestamp}");

    // _appointmentDateAndTime = DateFormat("EE, MMMM dd y, hh:mm a").format(
    //     DateTime.parse(_timeSlotDocOne?.start?.time?.timestamp ??
    //         DateTime.now().toString()));
    _appointmentDateAndTime = DateFormat("EE, MMMM dd y, hh:mm a").format(
        DateTime.parse(
            _appointmentStartDateAndTime ?? DateTime.now().toString()));
    appointmentFees =
        _docOneDiscoveryFulfillments?.agent?.tags?.firstConsultation ?? "";

    double tmpFirstDocFees = double.parse(
        _docOneDiscoveryFulfillments?.agent?.tags?.firstConsultation ?? "0");
    double tmpSecondDocFees = double.parse(
        _docTwoDiscoveryFulfillments?.agent?.tags?.firstConsultation ?? "0");
    _teleconsultationFees = (tmpFirstDocFees + tmpSecondDocFees).toString();

    return SingleChildScrollView(
        child: Scrollbar(
      thickness: 10, //width of scrollbar
      radius: Radius.circular(20), //corner radius of scrollbar
      scrollbarOrientation: ScrollbarOrientation.right,
      child: Container(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doctorDetailWidget(
                docOneGender, docOneImage, "$docOneName", "$docOneSpeciality"),
            Spacing(isWidth: false),
            doctorDetailWidget(
                docTwoGender, docTwoImage, "$docTwoName", "$docTwoSpeciality"),
            Spacing(isWidth: false),
            Container(
              height: 4.0,
              color: AppColors.innerBoxColor,
            ),
            Spacing(isWidth: false, size: 20),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "Online Consultation",
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.appointmentConfirmDoctorActionsTextColor,
                    fontSize: 15),
              ),
            ),
            Spacing(isWidth: false),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "$_appointmentDateAndTime",
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 18),
              ),
            ),
            Spacing(isWidth: false, size: 20),
            Container(
              height: 4.0,
              color: AppColors.innerBoxColor,
            ),
            // Spacing(isWidth: false),
            // Padding(
            //   padding: EdgeInsets.only(left: 16.0, right: 16.0),
            //   child: Text(
            //     "Message of the doctor",
            //     style: AppTextStyle.textBoldStyle(
            //         color: AppColors.appointmentStatusColor, fontSize: 15),
            //   ),
            // ),
            // Spacing(isWidth: false),
            // Padding(
            //   padding: EdgeInsets.only(left: 16.0, right: 16.0),
            //   child: Text(
            //     "Write your symptoms or anything you want the doctor to know",
            //     style: AppTextStyle.textBoldStyle(
            //         color: AppColors.appointmentConfirmDoctorActionsTextColor,
            //         fontSize: 15),
            //   ),
            // ),
            // Spacing(isWidth: false),
            // Container(
            //   height: 4.0,
            //   color: AppColors.innerBoxColor,
            // ),
            Spacing(isWidth: false, size: 20),
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                "Bill Details",
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 18),
              ),
            ),
            Spacing(size: 20, isWidth: false),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: splitBillWidget("Consultation Fee (Primary Doctor)"),
                  ),
                  Spacing(),
                  splitBillWidget("Rs. $docOneFees"),
                ],
              ),
            ),
            Spacing(isWidth: false),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:
                        splitBillWidget("Consultation Fee (Secondary Doctor)"),
                  ),
                  Spacing(),
                  splitBillWidget("Rs. $docTwoFees"),
                ],
              ),
            ),
            Spacing(isWidth: false),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: splitBillWidget("Booking Fee"),
                  ),
                  Spacing(),
                  splitBillWidget("Rs. 0"),
                ],
              ),
            ),
            Spacing(size: 20, isWidth: false),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: finalBillWidget("Total Payable"),
                  ),
                  Spacing(),
                  finalBillWidget("Rs. $_teleconsultationFees"),
                ],
              ),
            ),
            Spacing(isWidth: false, size: 20),
            Container(
              height: 4.0,
              color: AppColors.innerBoxColor,
            ),
            Spacing(isWidth: false),
            // Container(
            //   alignment: Alignment.bottomRight,
            //   child: InkWell(
            //     onTap: () {
            //       // TODO DISABLE
            //       // Get.to(() => ConfirmGroupTeleconsultationPage(
            //       //       consultationType: DataStrings.groupConsultation,
            //       //     ));

            //       // TODO ENABLE
            //       // findDoctor();
            //     },
            //     child: Container(
            //       width: 150.0,
            //       height: height * 0.06,
            //       margin: EdgeInsets.only(bottom: 20, right: 10),
            //       // padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            //       decoration: BoxDecoration(
            //         color: AppColors
            //             .appointmentConfirmDoctorActionsEnabledTextColor,
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //       child: Center(
            //         child: Text(
            //           "Pay and Confirm",
            //           style: AppTextStyle.textSemiBoldStyle(
            //               color: AppColors.white, fontSize: 15),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ));
  }

  Widget doctorDetailWidget(
      String gender, String image, String docName, String docSpeciality) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: image.isEmpty
                ? AssetImage(gender == "M"
                    ? 'assets/images/male_doctor_avatar.png'
                    : 'assets/images/female_doctor_avatar.jpeg')
                : Image.memory(Base64Decoder().convert(image)).image,
          ),
          Spacing(size: 15, isWidth: true),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacing(isWidth: false),
                Text(
                  docName,
                  style: AppTextStyle.textSemiBoldStyle(
                      color: AppColors.testColor, fontSize: 20),
                ),
                Text(
                  docSpeciality,
                  style: AppTextStyle.textSemiBoldStyle(
                      color: AppColors.appointmentConfirmDoctorActionsTextColor,
                      fontSize: 15),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget splitBillWidget(String billTypeDetail) {
    return Text(
      billTypeDetail,
      style: AppTextStyle.textBoldStyle(
          color: AppColors.appointmentConfirmDoctorActionsTextColor,
          fontSize: 15),
    );
  }

  Widget finalBillWidget(String finalBillDetail) {
    return Text(
      finalBillDetail,
      style:
          AppTextStyle.textBoldStyle(color: AppColors.testColor, fontSize: 18),
    );
  }
}

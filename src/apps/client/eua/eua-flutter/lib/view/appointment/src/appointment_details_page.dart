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
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/src/data_strings.dart';

class AppointmentDetailsPage extends StatefulWidget {
  // BookingOnInitResponseModel? bookingOnInitResponseModel;
  Fulfillment discoveryFulfillments;
  DiscoveryItems? discoveryItems;
  DiscoveryProviders? discoveryProviders;
  TimeSlotModel timeSlot;
  String? consultationType;
  String? uniqueId;

  String doctorProviderUri;

  AppointmentDetailsPage({
    Key? key,
    // this.bookingOnInitResponseModel,
    required this.discoveryFulfillments,
    this.discoveryItems,
    this.discoveryProviders,
    required this.doctorProviderUri,
    required this.timeSlot,
    this.consultationType,
    this.uniqueId,
  }) : super(key: key);

  @override
  State<AppointmentDetailsPage> createState() => _DiscoveryResultsPageState();
}

class _DiscoveryResultsPageState extends State<AppointmentDetailsPage> {
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
  String? _uniqueId = "";
  int messageQueueNum = 0;
  StompClient? stompClient;
  String? abhaAddress;
  bool _loading = false;

  String? _orderId;
  BookingOnInitResponseModel? _initResponse;
  TimeSlotModel? _timeSlot;
  Future<BookingOnInitResponseModel?>? futureInitResponse;
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
    _timeSlot = widget.timeSlot;
    _consultationType = widget.consultationType;
    _uniqueId = widget.uniqueId ?? const Uuid().v1();

    if (mounted) {
      futureInitResponse = getInitResponse();
    }
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    _timer?.cancel();

    super.dispose();
  }

  Future<BookingOnInitResponseModel?> getInitResponse() async {
    BookingOnInitResponseModel? bookingOnInitResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    // _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(uniqueId: _uniqueId!, api: postInitAPI);
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
    futureInitResponse = getInitResponse();
  }

  ///INIT API
  postInitAPI() async {
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
    contextModel.providerUrl = widget.doctorProviderUri;

    BookingInitRequestModel bookingInitRequestModel = BookingInitRequestModel();
    bookingInitRequestModel.context = contextModel;
    Message? message = Message();
    Order? order = Order();
    DiscoveryItems discoveryItems = DiscoveryItems();
    DiscoveryDescriptor? descriptor = DiscoveryDescriptor();
    DiscoveryPrice? price = DiscoveryPrice();

    Fulfillment? fulfillment = Fulfillment();
    DiscoveryAgent agent = DiscoveryAgent();
    Tags tags = Tags();
    agent.id = widget.discoveryFulfillments.agent?.id;
    agent.name = widget.discoveryFulfillments.agent?.name;
    agent.gender = widget.discoveryFulfillments.agent?.gender;
    // agent.tags = widget.discoveryFulfillments.agent?.tags;

    tags.education = widget.discoveryFulfillments.agent?.tags?.education;
    tags.experience = widget.discoveryFulfillments.agent?.tags?.experience;
    tags.firstConsultation =
        widget.discoveryFulfillments.agent?.tags?.firstConsultation;
    tags.followUp = widget.discoveryFulfillments.agent?.tags?.followUp;
    tags.hprId = widget.discoveryFulfillments.agent?.tags?.hprId;
    tags.languageSpokenTag =
        widget.discoveryFulfillments.agent?.tags?.languageSpokenTag;
    tags.medicinesTag = widget.discoveryFulfillments.agent?.tags?.medicinesTag;
    tags.slotId = widget.discoveryFulfillments.agent?.tags?.slotId;
    tags.specialtyTag = widget.discoveryFulfillments.agent?.tags?.specialtyTag;
    tags.upiId = widget.discoveryFulfillments.agent?.tags?.upiId;
    tags.patientGender = getUserDetailsResponseModel.gender;
    tags.abdmGovInGroupConsultation = "false";
    tags.abdmGovInConsumerUrl = RequestUrls.bookingService;

    agent.tags = tags;

    fulfillment.agent = agent;
    fulfillment.id = _timeSlot?.tags?.abdmGovInSlot;
    fulfillment.type = _consultationType;

    price.currency = "INR";
    price.value = widget.discoveryFulfillments.agent?.tags?.firstConsultation;

    discoveryItems.price = price;
    discoveryItems.descriptor = descriptor;
    descriptor.name = "Consultation";
    discoveryItems.id = "0";
    discoveryItems.fulfillmentId = _timeSlot?.tags?.abdmGovInSlot;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    InitTimeSlotTags initTimeSlotTags = InitTimeSlotTags();

    startTime.timestamp = _timeSlot?.start?.time?.timestamp;
    endTime.timestamp = _timeSlot?.end?.time?.timestamp;
    initTimeSlotTags.abdmGovInSlotId = _timeSlot?.tags?.abdmGovInSlot;
    start.time = startTime;
    end.time = endTime;
    fulfillment.start = start;
    fulfillment.end = end;
    fulfillment.initTimeSlotTags = initTimeSlotTags;

    order.id = _orderId;
    order.item = widget.discoveryItems;
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

    log(" ${jsonEncode(bookingInitRequestModel)}", name: "INIT REQUEST MODEL");

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
            AppStrings().appointmentDetails,
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
      ),
    );
  }

  buildWidgets(Object? data) {
    _initResponse = data as BookingOnInitResponseModel;

    _appointmentDateAndTime = DateFormat("EE, MMMM dd y, hh:mm a").format(
        DateTime.parse(_initResponse!
            .message!.order!.fulfillment!.start!.time!.timestamp!));
    // log("$_appointmentDateAndTime", name: "DATE AND TIME");

    _teleconsultationFees = _initResponse
        ?.message?.order?.fulfillment?.agent?.tags?.firstConsultation;
    _teleconsultationFees = "₹ $_teleconsultationFees/-";
    _totalFees = _teleconsultationFees;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  DoctorDetailsView(
                    doctorName:
                        _initResponse?.message?.order?.fulfillment?.agent?.name,
                    doctorAbhaId:
                        _initResponse?.message?.order?.fulfillment?.agent?.id,
                    tags:
                        _initResponse!.message!.order!.fulfillment!.agent!.tags,
                    gender: _initResponse!
                        .message!.order!.fulfillment!.agent!.gender,
                    profileImage: _initResponse!
                        .message!.order!.fulfillment!.agent!.image,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 80.0, bottom: 10),
                      //   child: Image.asset(
                      //     'assets/images/Practo-logo.png',
                      //     height: 18,
                      //     width: 65,
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
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      _consultationType == DataStrings.teleconsultation
                          ? AppStrings().selectedTimeForConsultation
                          : AppStrings().selectedTimeForPhysicalConsultation,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // "Monday April 17th 5pm",
                          _appointmentDateAndTime!,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                        // Text(
                        //   "Token No: 11",
                        //   style: AppTextStyle.textBoldStyle(
                        //       color: AppColors.testColor, fontSize: 15),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      AppStrings().billingDetails,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _consultationType == DataStrings.teleconsultation
                              ? AppStrings().teleconsultationFees
                              : AppStrings().physicalConsultationFees,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.infoIconColor, fontSize: 14),
                        ),
                        Text(
                          // "₹ 900/-",
                          _teleconsultationFees!,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.infoIconColor, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings().bookingFees,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.infoIconColor, fontSize: 14),
                        ),
                        Text(
                          "₹ 0/-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.infoIconColor, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings().totalPayables,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.amountColor, fontSize: 14),
                        ),
                        Text(
                          // "₹ 900/-",
                          _teleconsultationFees!,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.amountColor, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      AppStrings().cancelAppointmentTerms,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // showProgressDialog();
                // connectToStompServer();
                Get.to(() => PaymentPage(
                      teleconsultationFees: _teleconsultationFees,
                      doctorsUPIaddress:
                          _initResponse?.message?.order?.fulfillment?.agent?.id,
                      bookingOnInitResponseModel: _initResponse,
                      consultationType: _consultationType!,
                      doctorImage: widget.discoveryFulfillments.agent?.image,
                      uniqueId: _uniqueId,
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
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

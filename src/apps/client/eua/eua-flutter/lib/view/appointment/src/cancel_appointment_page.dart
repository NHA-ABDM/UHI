import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../../common/common.dart';
import '../../../constants/constants.dart';
import '../../../constants/src/data_strings.dart';
import '../../../controller/controller.dart';
import '../../../model/model.dart';
import '../../../services/services.dart';
import '../../view.dart';

class CancelAppointment extends StatefulWidget {
  Fulfillment? discoveryFulfillments;
  UpcomingAppointmentResponseModal? upcomingAppointmentResponseModal;
  bool? isRescheduleAppointment;

  CancelAppointment(
      {Key? key,
      this.discoveryFulfillments,
      required this.upcomingAppointmentResponseModal,
      required this.isRescheduleAppointment})
      : super(key: key);

  @override
  State<CancelAppointment> createState() => _CancelAppointmentState();
}

class _CancelAppointmentState extends State<CancelAppointment> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final _postCancelAppointmentController = PostCancelAppointmentController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  String? _selectedDate;
  int? _selectedTimeSlotIndex;
  bool isBtnLoading = false;
  bool isBtnPressed = false;

  ///SOCKET
  StompSocketConnection stompSocketConnection = StompSocketConnection();
  Timer? _timer;

  ///DATA VARIABLES
  String _uniqueId = "";
  bool _isRescheduleAppointment = false;
  UpcomingAppointmentResponseModal? _upcomingAppointmentResponse;
  BookingConfirmResponseModel? _bookingConfirmResponse;

  @override
  void initState() {
    super.initState();
    _isRescheduleAppointment = widget.isRescheduleAppointment ?? false;
    _upcomingAppointmentResponse =
        widget.upcomingAppointmentResponseModal ?? null;
    _bookingConfirmResponse = BookingConfirmResponseModel.fromJson(
        jsonDecode(_upcomingAppointmentResponse!.message!));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    stompSocketConnection.disconnect();
    super.dispose();
  }

  _cancelAppointment() async {
    CancelAppointmentRequestModel? cancelAppointmentRequestModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postCancelAppointmentAPI);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
        // DialogHelper.showInfoDialog(
        //     description:
        //         "Your appointment is cancelled successfully.\nBut we are unable to update your request right now.\nPlease check back again sometime.");

        stompSocketConnection.disconnect();
      } else {
        cancelAppointmentRequestModel = CancelAppointmentRequestModel.fromJson(
            json.decode(response.response!));
        // _timer?.cancel();
        log("${json.decode(response.response!)}");
        if (cancelAppointmentRequestModel != null &&
            cancelAppointmentRequestModel != "") {
          if (cancelAppointmentRequestModel?.message?.order?.state ==
              "CANCELLED") {
            setState(() {
              isBtnLoading = false;
              isBtnPressed = false;
            });
            _timer?.cancel();
            stompSocketConnection.disconnect();

            if (_isRescheduleAppointment) {
              Get.to(() => DoctorsDetailPage(
                    doctorAbhaId: _upcomingAppointmentResponse
                            ?.healthcareProfessionalId ??
                        "",
                    doctorName: _upcomingAppointmentResponse
                            ?.healthcareProfessionalName ??
                        "",
                    doctorProviderUri:
                        _bookingConfirmResponse?.context?.providerUrl ?? "",
                    discoveryFulfillments:
                        _bookingConfirmResponse!.message!.order!.fulfillment!,
                    consultationType:
                        _upcomingAppointmentResponse?.serviceFulfillmentType ==
                                DataStrings.teleconsultation
                            ? DataStrings.teleconsultation
                            : DataStrings.physicalConsultation,
                    isRescheduling: true,
                    bookingConfirmResponseModel: _bookingConfirmResponse,
                    uniqueId: Uuid().v1(),
                  ));
            } else {
              Get.back(result: true);
            }
          } else {
            setState(() {
              isBtnLoading = false;
              isBtnPressed = false;
            });
            _timer?.cancel();

            stompSocketConnection.disconnect();

            DialogHelper.showErrorDialog(
                description:
                    "Unable to process your request.\nPlease again in sometime.");
          }
        } else {
          setState(() {
            isBtnLoading = false;
            isBtnPressed = false;
          });
          _timer?.cancel();

          stompSocketConnection.disconnect();

          DialogHelper.showErrorDialog(
              description:
                  "Unable to process your request.\nPlease again in sometime.");
        }
      }
    };

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    setState(() {
      isBtnLoading = false;
      isBtnPressed = false;
    });

    stompSocketConnection.disconnect();
  }

  ///CANCEL APPOINTMENT API
  postCancelAppointmentAPI() async {
    _postCancelAppointmentController.refresh();

    CancelAppointmentRequestModel cancelAppointmentRequestModel =
        CancelAppointmentRequestModel();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "cancel";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.providerUrl = _bookingConfirmResponse?.context?.providerUrl;
    contextModel.timestamp = DateTime.now().toLocal().toUtc().toIso8601String();
    contextModel.transactionId = _uniqueId;

    CancelAppointmentRequestMessage cancelAppointmentRequestMessage =
        CancelAppointmentRequestMessage();
    CancelAppointmentRequestOrder cancelAppointmentRequestOrder =
        CancelAppointmentRequestOrder();
    CancelAppointmentRequestFulfillment cancelAppointmentRequestFulfillment =
        CancelAppointmentRequestFulfillment();
    CancelAppointmentRequestTags cancelAppointmentRequestTags =
        CancelAppointmentRequestTags();

    cancelAppointmentRequestTags.abdmGovInCancelledby = "patient";
    cancelAppointmentRequestFulfillment.tags = cancelAppointmentRequestTags;

    cancelAppointmentRequestOrder.id = _upcomingAppointmentResponse?.orderId;
    cancelAppointmentRequestOrder.state = "CANCELLED";
    cancelAppointmentRequestOrder.fulfillment =
        cancelAppointmentRequestFulfillment;

    cancelAppointmentRequestMessage.order = cancelAppointmentRequestOrder;

    cancelAppointmentRequestModel.context = contextModel;
    cancelAppointmentRequestModel.message = cancelAppointmentRequestMessage;

    log("${jsonEncode(cancelAppointmentRequestModel)}");

    await _postCancelAppointmentController.postAppointmentDetails(
        appointmentDetails: cancelAppointmentRequestModel);
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
          _isRescheduleAppointment
              ? AppStrings().rescheduleAppointment
              : AppStrings().cancelAppointment,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    String? amount =
        widget.discoveryFulfillments!.agent!.tags!.firstConsultation ?? "";
    String appointmentStartDate = "";
    String appointmentStartTime = "";
    var tmpStartDate;
    tmpStartDate = widget.discoveryFulfillments!.start!.time!.timestamp;
    appointmentStartDate =
        DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));
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
                    doctorAbhaId: widget.discoveryFulfillments!.agent!.id!,
                    doctorName: widget.discoveryFulfillments!.agent!.name!,
                    tags: widget.discoveryFulfillments!.agent!.tags!,
                    gender: widget.discoveryFulfillments!.agent!.gender!,
                    profileImage: widget.discoveryFulfillments!.agent?.image,
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
                      _upcomingAppointmentResponse?.serviceFulfillmentType ==
                              DataStrings.teleconsultation
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
                          //"Monday April 17th 5pm",
                          appointmentStartDate + " at " + appointmentStartTime,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                        Text(
                          "Paid ₹ $amount/-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.amountColor, fontSize: 14),
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
              onTap: isBtnPressed
                  ? () {}
                  : () {
                      setState(() {
                        isBtnPressed = true;
                      });
                      NewConfirmationDialog(
                          context: context,
                          title: _isRescheduleAppointment
                              ? AppStrings().rescheduleAppointment
                              : AppStrings().cancelAppointment,
                          description: _isRescheduleAppointment
                              ? AppStrings().rescheduleAppointmentConfirmation
                              : AppStrings().cancelAppointmentConfirmation,
                          submitButtonText: "",
                          onCancelTap: () {
                            setState(() {
                              isBtnPressed = false;
                            });
                            Get.back();
                          },
                          onSubmitTap: () async {
                            setState(() {
                              isBtnLoading = true;
                            });
                            Get.back();
                            await _cancelAppointment();
                          }).showAlertDialog();
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
                  child: isBtnLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(color: AppColors.white))
                      : Text(
                          _isRescheduleAppointment
                              ? AppStrings().rescheduleAppointmentCaps
                              : AppStrings().cancelAppointmentCaps,
                          style: AppTextStyle.textSemiBoldStyle(
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

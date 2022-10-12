import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/src/appointment_status.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/request_urls.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/appointments_controller.dart';
import '../../../model/request/src/cancel_appointment_request.dart';
import '../../../model/response/src/acknowledgement_response_model.dart';
import '../../../model/response/src/cancel_appointment_response.dart';
import '../../../model/response/src/provider_appointments_response.dart';
import '../../../model/src/chat_message_dhp_model.dart';
import '../../../model/src/context_model.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/alert_dialog_with_single_action.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';

class CancelAppointmentPage extends StatefulWidget {
  const CancelAppointmentPage({Key? key}) : super(key: key);

/*  const CancelAppointmentPage({Key? key, required this.providerAppointment}) : super(key: key);
  final ProviderAppointments providerAppointment;*/

  @override
  State<CancelAppointmentPage> createState() => _CancelAppointmentPageState();
}

class _CancelAppointmentPageState extends State<CancelAppointmentPage> {

  /// Arguments
  dynamic providerAppointment;
  late final bool isOpenMrsAppointment;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final TextEditingController _reasonTextController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    /// Get arguments
    providerAppointment = Get.arguments['providerAppointment'];
    isOpenMrsAppointment = Get.arguments['isOpenMrsAppointment'];
    super.initState();
  }

  @override
  void dispose() {
    _reasonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            AppStrings().labelCancellation,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
            onPressed: () {
              Get.back(result: false);
            },
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(AppStrings().labelCancellingAppointment, style: AppTextStyle.textSemiBoldStyle(fontSize: 18, color: AppColors.titleTextColor),),
                    VerticalSpacing(size: 20,),
                    Text(AppStrings().labelAppointmentDetails, style: AppTextStyle.textSemiBoldStyle(fontSize: 18, color: AppColors.titleTextColor),),
                    VerticalSpacing(size: 16,),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(top: 2, left: 4, right: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isOpenMrsAppointment
                                          ? providerAppointment.patient!.person!.display!
                                          : providerAppointment.patientName!,
                                      style: AppTextStyle.textSemiBoldStyle(
                                          color: AppColors.testColor, fontSize: 16),
                                    ),
                                    Spacing(),
                                    Text(
                                      isOpenMrsAppointment
                                          ? Utility.getAppointmentDisplayDate(
                                          date: DateTime.parse(providerAppointment
                                              .timeSlot!.startDate!))
                                          : Utility.getAppointmentDisplayDate(
                                          date: DateTime.parse(providerAppointment
                                              .serviceFulfillmentStartTime!)),
                                      style: AppTextStyle
                                          .textNormalStyle(
                                          color: AppColors.testColor, fontSize: 16),
                                    ),
                                  ],
                                ),
                                VerticalSpacing(size: 6,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isOpenMrsAppointment
                                          ? providerAppointment.reason ?? ''
                                          : providerAppointment.healthcareServiceName ?? '',
                                      style: AppTextStyle.textNormalStyle(
                                          color: AppColors.testColor, fontSize: 12),
                                    ),
                                    Spacing(),
                                    Text(
                                      isOpenMrsAppointment
                                          ? Utility.getAppointmentDisplayTimeRange(
                                          startDateTime: DateTime.parse(
                                              providerAppointment
                                                  .timeSlot!.startDate!
                                                  .split('.')
                                                  .first),
                                          endDateTime: DateTime.parse(
                                              providerAppointment.timeSlot!.endDate!
                                                  .split('.')
                                                  .first))
                                          : Utility.getAppointmentDisplayTimeRange(
                                          startDateTime: DateTime.parse(
                                              providerAppointment
                                                  .serviceFulfillmentStartTime!),
                                          endDateTime: DateTime.parse(
                                              providerAppointment
                                                  .serviceFulfillmentEndTime!)),
                                      style: AppTextStyle
                                          .textNormalStyle(
                                          color: AppColors.testColor, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalSpacing(size: 16,),

                    TextFormField(
                      controller: _reasonTextController,
                      cursorColor: AppColors.titleTextColor,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.titleTextColor),
                      decoration: InputDecoration(
                          labelText: AppStrings().labelSendMessage,
                          labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.feesLabelTextColor),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.titleTextColor))
                      ),
                      keyboardType: TextInputType.text,
                      autovalidateMode: _autoValidateMode,
                      validator: (String? text){
                        if(text != null && text.trim().isNotEmpty){
                          return null;
                        } else {
                          return AppStrings().errorProvideCancelReason;
                        }
                      },
                    ),
                    VerticalSpacing(size: 8,),
                  ],
                ),
              ),
            ),
          ),
          SquareRoundedButtonWithIcon(text: AppStrings().btnSubmit, assetImage: AssetImages.arrowLongRight, onPressed: () async{
            if(_formKey.currentState!.validate()) {

              setState(() {
                _isLoading = true;
              });

              String cancelReason = _reasonTextController.text.trim();
              AppointmentsController appointmentsController = AppointmentsController();

              /// Get cancel request body
              CancelAppointmentRequestModel requestBody = await getCancelAppointmentRequestBody();

              /// This is for cancel appointment from both EUA and HSPA backend and from open mrs also
              AcknowledgementMessage? acknowledgementMessage = await appointmentsController.cancelProviderAppointmentWrapper(
                  appointmentUUID: isOpenMrsAppointment ? providerAppointment.uuid! : providerAppointment.appointmentId!,
                  cancelAppointmentRequestModel: requestBody);

              /// This is for cancel appointment from open mrs only
              //CancelAppointmentResponse? cancelAppointmentResponse = await appointmentsController.cancelProviderAppointment(appointmentUUID: isOpenMrsAppointment ? providerAppointment.uuid! : providerAppointment.appointmentId!,, status: AppointmentStatus.cancelled, cancelReason: cancelReason);

              /*if(cancelAppointmentResponse != null) {
                bool? status = await appointmentsController.purgeCanceledAppointmentSlot(appointmentUUID: isOpenMrsAppointment ? providerAppointment.uuid! : providerAppointment.appointmentId!);
              }*/

              setState(() {
                _isLoading = false;
              });
              if(acknowledgementMessage != null && acknowledgementMessage.ack?.status != null && acknowledgementMessage.ack?.status == 'ACK') {
                AlertDialogWithSingleAction(context: context,
                  title: AppStrings().labelCancelAlertTitle,
                  showIcon: true,
                  onCloseTap: () {
                    Navigator.of(context).pop();
                    Get.back(result: true);
                  },).showAlertDialog();
              }
            } else {
              setState(() {
                _autoValidateMode = AutovalidateMode.always;
              });
            }
          }),
        ],
      ),
    );
  }

  Future<CancelAppointmentRequestModel> getCancelAppointmentRequestBody() async{
    String _uniqueId = const Uuid().v1();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "cancel";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    //contextModel.consumerUri = RequestUrls.cancelConsumerUriSandbox;
    //contextModel.providerUrl = _providerUri;
    contextModel.timestamp = DateTime.now().toLocal().toUtc().toIso8601String();
    contextModel.transactionId = _uniqueId;
    // contextModel.transactionId = isOpenMrsAppointment ? _uniqueId : providerAppointment.transId;


    CancelAppointmentRequestTags tags = CancelAppointmentRequestTags();
    tags.tagMap = <String, dynamic>{};
    tags.tagMap!.addAll({
      '@abdm/gov.in/cancelledby' : 'doctor',
      '@abdm/gov.in/cancelReason' : _reasonTextController.text.trim(),
      '@abdm/gov.in/groupConsultation' : isOpenMrsAppointment ? false : providerAppointment.groupConsultStatus
    });

    CancelAppointmentRequestFulfillment cancelAppointmentRequestFulfillment = CancelAppointmentRequestFulfillment();
    cancelAppointmentRequestFulfillment.tags = tags;

    CancelAppointmentRequestOrder cancelAppointmentRequestOrder = CancelAppointmentRequestOrder();
    cancelAppointmentRequestOrder.id = isOpenMrsAppointment ? providerAppointment.uuid! : providerAppointment.appointmentId!;
    cancelAppointmentRequestOrder.state = AppointmentStatus.cancelled;
    cancelAppointmentRequestOrder.fulfillment = cancelAppointmentRequestFulfillment;

    CancelAppointmentRequestMessage cancelAppointmentRequestMessage = CancelAppointmentRequestMessage();
    cancelAppointmentRequestMessage.order = cancelAppointmentRequestOrder;

    CancelAppointmentRequestModel cancelAppointmentRequestModel = CancelAppointmentRequestModel();
    cancelAppointmentRequestModel.context = contextModel;
    cancelAppointmentRequestModel.message =cancelAppointmentRequestMessage;

    return cancelAppointmentRequestModel;
  }
}

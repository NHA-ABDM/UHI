import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/utils/src/validator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/provider_attributes.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/doctor_setup_controller.dart';
import '../../../model/response/src/add_appointment_time_slot_response.dart';
import '../../../model/response/src/add_provider_attribute_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/underlined_text_form_field.dart';
import '../../../widgets/src/vertical_spacing.dart';
import '../../dashboard/src/dashboard_page.dart';

enum Payment {afterConsultation, beforeConsultation, withInWeek}

class AddUpiPage extends StatefulWidget {
  const AddUpiPage({Key? key, required this.consultType}) : super(key: key);
  final String consultType;

  @override
  State<AddUpiPage> createState() => _AddUpiPageState();
}

class _AddUpiPageState extends State<AddUpiPage> {
  TextEditingController upiIdController = TextEditingController();
  Payment paymentGroupValue = Payment.afterConsultation;
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    upiIdController.dispose();
    super.dispose();
  }

  @override
  initState () {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            widget.consultType,
            style:
            AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: AppColors.progressBarBackColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.amountColor,
                      ),
                      value: 0.85,  ///Setting this now as we have discarded signature steps here  //0.70,
                      minHeight: 8,
                    ),
                    VerticalSpacing(
                      size: 20,
                    ),
                    Text(
                      AppStrings().labelProvideUpiId,
                      style: AppTextStyle.textSemiBoldStyle(
                          fontSize: 18, color: AppColors.titleTextColor),
                    ),
                    VerticalSpacing(),
                    UnderlinedTextFormField(
                      controller: upiIdController,
                      labelText: AppStrings().labelUpiId,
                      keyboardType: TextInputType.emailAddress,
                      autoValidateMode: _autoValidateMode,
                      textInputAction: TextInputAction.done,
                      validate: (String? value) {
                        return Validator.validateUpiId(value);
                      },
                    ),
                    VerticalSpacing(size: 20,),
                    RadioListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      value: Payment.afterConsultation,
                      groupValue: paymentGroupValue,
                      title: Text(
                        AppStrings().labelPaymentAfterConsultation,
                        style: AppTextStyle.textLightStyle(
                            fontSize: 14, color: AppColors.feesLabelTextColor),
                      ),
                      onChanged: (Payment? value) {
                        setState(
                          () {
                            if (value != null) {
                              paymentGroupValue = value;
                            }
                          },
                        );
                      },
                    ),
                    VerticalSpacing(),
                    RadioListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      value: Payment.beforeConsultation,
                      groupValue: paymentGroupValue,
                      title: Text(
                        AppStrings().labelPaymentBeforeConsultation,
                        style: AppTextStyle.textLightStyle(
                            fontSize: 14, color: AppColors.feesLabelTextColor),
                      ),
                      onChanged: (Payment? value) {
                        setState(
                          () {
                            if (value != null) {
                              paymentGroupValue = value;
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacing(isWidth: false, size: 16,),
              SquareRoundedButtonWithIcon(
                  text: AppStrings().btnCancel,
                  assetImage: null,
                  icon: Icons.clear,
                  textColor: AppColors.tileColors,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.tileColors,
                  onPressed: (){
                    setState(() {
                    });
                  }),
              VerticalSpacing(),
              SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: (){
                /*Get.to(() => const TakeUploadPhotoPage(
                  consultType: AppStrings(.labelTeleconsultation,),
                );*/
                handleApi();
              }),
            ],
          ),        ],
      ),
    );
  }

  void handleApi() {
    if(_formKey.currentState!.validate()) {
      DoctorSetupValues doctorSetupValues = DoctorSetupValues();
      doctorSetupValues.upiId = upiIdController.text.trim();
      String receivePayment = 'After consultation';
      if(paymentGroupValue == Payment.beforeConsultation) {
        receivePayment = 'Before consultation';
      }
      doctorSetupValues.receivePayment = receivePayment;

      /*Get.to(() => const TakeUploadPhotoPage(
        consultType: AppStrings(.labelTeleconsultation,),
        transition: Utility.pageTransition,
      );*/
      setProviderSettings();
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  Future<void> setProviderSettings() async{
      setState(() {
        isLoading = true;
      });
      DoctorSetUpController doctorSetUpController = DoctorSetUpController();
      DoctorSetupValues doctorSetupValues = DoctorSetupValues();
      List<Map<String, dynamic>> attributes = <Map<String, dynamic>>[];
      attributes.addAll([
        /*{"attributeType": ProviderAttributesLocal.firstConsultation, "value": doctorSetupValues.firstConsultation},
        {"attributeType": ProviderAttributesLocal.followUp, "value": doctorSetupValues.followUp},
        {"attributeType": ProviderAttributesLocal.labReportConsultation, "value": doctorSetupValues.labReportConsultation},*/
        {"attributeType": ProviderAttributesLocal.upiId, "value": doctorSetupValues.upiId},
        {"attributeType": ProviderAttributesLocal.receivePayment, "value": doctorSetupValues.receivePayment},
        {"attributeType": ProviderAttributesLocal.isTeleconsultation, "value": doctorSetupValues.isTeleconsultation},
        {"attributeType": ProviderAttributesLocal.isPhysicalConsultation, "value": doctorSetupValues.isPhysicalConsultation},
      ]);

      if(doctorSetupValues.isTeleconsultation !=  null && doctorSetupValues.isTeleconsultation!) {
        attributes.addAll([
          {"attributeType": ProviderAttributesLocal.firstConsultation, "value": doctorSetupValues.firstConsultation},
          {"attributeType": ProviderAttributesLocal.followUp, "value": doctorSetupValues.followUp},
          {"attributeType": ProviderAttributesLocal.labReportConsultation, "value": doctorSetupValues.labReportConsultation},
        ]);
      }

      if(doctorSetupValues.isPhysicalConsultation !=  null && doctorSetupValues.isPhysicalConsultation!) {
        attributes.addAll([
          {"attributeType": ProviderAttributesLocal.psFirstConsultation, "value": doctorSetupValues.psFirstConsultation ?? '0.0'},
          {"attributeType": ProviderAttributesLocal.psFollowUp, "value": doctorSetupValues.psFollowUp ?? '0.0'},
          {"attributeType": ProviderAttributesLocal.psLabReportConsultation, "value": doctorSetupValues.psLabReportConsultation ?? '0.0'},
        ]);
      }

      DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
      if (doctorProfile != null) {
        String providerUuid = doctorProfile.uuid!;

        for (Map<String, dynamic> map in attributes) {
          AddProviderAttributeResponse? attributeResponse = await doctorSetUpController.addAttributeToProvider(
              providerUUID: providerUuid,
              value: map['value'],
              attributeTypeUUID: map['attributeType']);

          if (attributeResponse != null) {
            debugPrint('Attribute type is ${attributeResponse.value}');
            switch (map['attributeType']) {
              case ProviderAttributesLocal.firstConsultation:
                doctorProfile.firstConsultation = map['value'];
                break;
              case ProviderAttributesLocal.followUp:
                doctorProfile.followUp = map['value'];
                break;
              case ProviderAttributesLocal.labReportConsultation:
                doctorProfile.labReportConsultation = map['value'];
                break;
              case ProviderAttributesLocal.psFirstConsultation:
                doctorProfile.psFirstConsultation = map['value'];
                break;
              case ProviderAttributesLocal.psFollowUp:
                doctorProfile.psFollowUp = map['value'];
                break;
              case ProviderAttributesLocal.psLabReportConsultation:
                doctorProfile.psLabReportConsultation = map['value'];
                break;
              case ProviderAttributesLocal.upiId:
                doctorProfile.upiId = map['value'];
                break;
              case ProviderAttributesLocal.receivePayment:
                doctorProfile.receivePayment = map['value'];
                break;
              case ProviderAttributesLocal.isTeleconsultation:
                doctorProfile.isTeleconsultation = map['value'].toString().toLowerCase() == 'true';
                break;
              case ProviderAttributesLocal.isPhysicalConsultation:
                doctorProfile.isPhysicalConsultation = map['value'];
                break;
            }
          }
        }

        /// Create Provider Appointment slots API
        debugPrint('date time slot value length is ${doctorSetupValues.dateTimeSlot}');
        if(doctorSetupValues.dateTimeSlot.isNotEmpty){
          for(DateTime dateTime in doctorSetupValues.dateTimeSlot){
            String startDate = Utility.getAPIRequestDateFormatString(dateTime);
            String endDate = Utility.getAPIRequestDateFormatString(dateTime.add(Duration(minutes: doctorSetupValues.fixedDurationSlot!)));
            AddAppointmentTimeSlotResponse? addAppointmentSlotResponse = await doctorSetUpController.addProviderAppointmentTimeSlots(startDate: startDate, endDate: endDate, providerUUID: providerUuid, types: doctorSetupValues.serviceTypes);
            debugPrint('addAppointmentSlotResponse is ${addAppointmentSlotResponse?.uuid}');
          }
        }

        await doctorProfile.saveDoctorProfile();
        setState(() {
          isLoading = false;
        });
        Get.offAll(() => const DashboardPage(),
          transition: Utility.pageTransition,);
      } else {
        DialogHelper.showErrorDialog(title: AppStrings().alert, description: AppStrings().errorProviderUUIDNotFound);
      }
  }
}

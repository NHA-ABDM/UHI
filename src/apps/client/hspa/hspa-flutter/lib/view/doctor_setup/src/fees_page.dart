import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/utils/src/validator.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'add_upi_page.dart';

class FeesPage extends StatefulWidget {
  const FeesPage({Key? key}) : super(key: key);

  /*const FeesPage({Key? key, required this.consultType}) : super(key: key);
  final String consultType;*/

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {

  /// Arguments
  late final String consultType;

  TextEditingController firstConsultController = TextEditingController();
  TextEditingController followUpController = TextEditingController();
  TextEditingController labReportConsultController = TextEditingController();
  TextEditingController psFirstConsultController = TextEditingController();
  TextEditingController psFollowUpController = TextEditingController();
  TextEditingController psLabReportConsultController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    /// Get Arguments
    consultType = Get.arguments['consultType'];
    super.initState();
  }

  @override
  void dispose() {
    firstConsultController.dispose();
    followUpController.dispose();
    labReportConsultController.dispose();
    psFirstConsultController.dispose();
    psFollowUpController.dispose();
    psLabReportConsultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          consultType,
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
                      value: 0.55,
                      minHeight: 8,
                    ),
                    VerticalSpacing(
                      size: 20,
                    ),
                    Text(
                      AppStrings().labelMentionFees,
                      style: AppTextStyle.textSemiBoldStyle(
                          fontSize: 18, color: AppColors.titleTextColor),
                    ),
                    if(consultType == AppStrings().labelTeleconsultation || consultType == AppStrings().labelBoth)
                      getTeleconsultationInputFields(),
                    if(consultType == AppStrings().labelPhysicalConsultation || consultType == AppStrings().labelBoth)
                    getPhysicalTeleconsultationInputFields(),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacing(isWidth: false, size: 16,),
              SquareRoundedButtonWithIcon(
                  text: AppStrings().btnReset,
                  assetImage: AssetImages.reset,
                  textColor: AppColors.tileColors,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.tileColors,
                  onPressed: (){
                  setState(() {
                    firstConsultController.text = '';
                    followUpController.text = '';
                    labReportConsultController.text = '';
                    psFirstConsultController.text = '';
                    psFollowUpController.text = '';
                    psLabReportConsultController.text = '';
                  });
              }),
              VerticalSpacing(),
              SquareRoundedButtonWithIcon(text: AppStrings().btnNext, assetImage: AssetImages.arrowLongRight, onPressed: (){
                validateAndGoNext();
              }),
            ],
          ),        ],
      ),
    );
  }

  getInputTextWidget({
    required TextEditingController controller,
    Color textColor = AppColors.titleTextColor,
    Color hintTextColor = AppColors.feesLabelTextColor,
    required String labelText,
    TextInputAction textInputAction = TextInputAction.next,
    TextInputType keyboardType = TextInputType.number
  }){
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.titleTextColor,
      textInputAction: textInputAction,
      autovalidateMode: _autoValidateMode,
      style: AppTextStyle.textNormalStyle(fontSize: 16, color: textColor),
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: hintTextColor),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.titleTextColor))
      ),
      keyboardType: keyboardType,
      inputFormatters: <TextInputFormatter>[
        //FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
      ],
      validator: (String? value) {
        return Validator.validateFees(value);
      },
    );
  }

  void validateAndGoNext() {
    if(_formKey.currentState!.validate()) {
      DoctorSetupValues doctorSetupValues = DoctorSetupValues();
      if(consultType == AppStrings().labelTeleconsultation || consultType == AppStrings().labelBoth) {
        doctorSetupValues.firstConsultation = firstConsultController.text.trim();
        doctorSetupValues.followUp = followUpController.text.trim();
        doctorSetupValues.labReportConsultation = labReportConsultController.text.trim();
      }
      if(consultType == AppStrings().labelPhysicalConsultation || consultType == AppStrings().labelBoth) {
        doctorSetupValues.psFirstConsultation = psFirstConsultController.text.trim();
        doctorSetupValues.psFollowUp = psFollowUpController.text.trim();
        doctorSetupValues.psLabReportConsultation = psLabReportConsultController.text.trim();
      }
      /*Get.to(() => AddUpiPage(consultType: consultType,),
        transition: Utility.pageTransition,);*/
      Get.toNamed(AppRoutes.addUpiPage, arguments: {'consultType': consultType});
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  getTeleconsultationInputFields() {
    return Padding(
      padding: consultType == AppStrings().labelBoth ?
      const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(consultType == AppStrings().labelBoth)
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                AppStrings().labelTeleconsultation,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 16, color: AppColors.titleTextColor),
              ),
            ),
          VerticalSpacing(),
          getInputTextWidget(
            controller: firstConsultController,
            labelText: AppStrings().labelFirstConsultation,
          ),
          VerticalSpacing(),
          getInputTextWidget(controller: followUpController, labelText: AppStrings().labelFollowUp),
          VerticalSpacing(),
          getInputTextWidget(
              controller: labReportConsultController,
              labelText: AppStrings().labelLabReportConsultation,
              textInputAction: consultType == AppStrings().labelBoth ? TextInputAction.next : TextInputAction.done),

        ],
      ),
    );
  }


  getPhysicalTeleconsultationInputFields() {
    return Padding(
      padding: consultType == AppStrings().labelBoth ?
      const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(consultType == AppStrings().labelBoth)
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                AppStrings().labelPhysicalConsultation,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 16, color: AppColors.titleTextColor),
              ),
            ),
          VerticalSpacing(),
          getInputTextWidget(
            controller: psFirstConsultController,
            labelText: AppStrings().labelFirstConsultation,
          ),
          VerticalSpacing(),
          getInputTextWidget(controller: psFollowUpController, labelText: AppStrings().labelFollowUp),
          VerticalSpacing(),
          getInputTextWidget(controller: psLabReportConsultController, labelText: AppStrings().labelLabReportConsultation, textInputAction: TextInputAction.done),

        ],
      ),
    );
  }
}

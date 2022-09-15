import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/utils/src/utility.dart';
import 'package:hspa_app/widgets/src/square_rounded_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/get_pages.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/doctor_setup_controller.dart';
import '../../../model/response/src/add_appointment_time_slot_response.dart';
import '../../../model/response/src/add_provider_attribute_response.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../dashboard/src/dashboard_page.dart';

class TakeUploadPhotoPage extends StatefulWidget {
  const TakeUploadPhotoPage({Key? key}) : super(key: key);

  /*const TakeUploadPhotoPage({Key? key, required this.consultType})
      : super(key: key);
  final String consultType;*/

  @override
  State<TakeUploadPhotoPage> createState() => _TakeUploadPhotoPageState();
}

class _TakeUploadPhotoPageState extends State<TakeUploadPhotoPage> {

  /// Arguments
  late final String consultType;

  late DoctorSetUpController _doctorSetUpController;
  late double progressValue;
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    /// Get Arguments
    consultType = Get.arguments['consultType'];

    progressValue = 0.85;
    _doctorSetUpController = DoctorSetUpController();
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
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    backgroundColor: AppColors.progressBarBackColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.amountColor,
                    ),
                    value: progressValue,
                    minHeight: 8,
                  ),
                  VerticalSpacing(
                    size: 20,
                  ),
                  Text(
                    AppStrings().labelAddPhoto,
                    style: AppTextStyle.textSemiBoldStyle(
                        fontSize: 18, color: AppColors.titleTextColor),
                  ),
                  VerticalSpacing(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DottedBorder(
                            color: AppColors.tileColors,
                            strokeWidth: 1,
                            dashPattern: const [8, 8],
                            child: Container(
                              height: MediaQuery.of(context).size.width / 1.4,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: pickedFile == null ? takePhotoWidget() : previewPhotoWidget(),
                            ),
                          ),
                          VerticalSpacing(),
                          Text(
                            AppStrings().labelSignatureUsage,
                            style: AppTextStyle.textLightStyle(
                                fontSize: 14,
                                color: AppColors.feesLabelTextColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  VerticalSpacing(),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Spacing(
                isWidth: false,
                size: 16,
              ),
              SquareRoundedButtonWithIcon(
                text: pickedFile == null
                    ? AppStrings().btnContinue
                    : AppStrings().btnSubmit,
                assetImage: AssetImages.arrowLongRight,
                onPressed: () async{
                  //Get.offAll(() => const DashboardPage());
                  await handleApi();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  takePhotoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              AssetImages.camera,
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
            ),
          ),
        ),
        SquareRoundedButton(
            text: AppStrings().btnTakePhoto,
            borderColor: AppColors.tileColors,
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.white,
            textColor: AppColors.tileColors,
            textStyle: AppTextStyle.textBoldStyle(
                fontSize: 14, color: AppColors.tileColors),
            onPressed: () {
              openSortBottomSheetDialog();
            })
      ],
    );
  }

  previewPhotoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Center(
            child: Image.file(File(pickedFile!.path)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(pickedFile!.name, style: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.tileColors),maxLines: 2,)),
            Spacing(),
            TextButton(
              onPressed: () {
                setState(() {
                  pickedFile = null;
                  progressValue = 0.85;
                });
              },
              child: Text(AppStrings().btnDelete,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 16,
                    color: AppColors.tileColors,
                    decoration: TextDecoration.underline
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }

  void openSortBottomSheetDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _onImageButtonPressed(source: ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.amountColor,
                          child: Icon(Icons.camera, color: AppColors.white,),
                        ),
                        VerticalSpacing(),
                        Text(AppStrings().camera, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.titleTextColor),)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _onImageButtonPressed(source: ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.amountColor,
                          child: Icon(Icons.folder, color: AppColors.white,),
                        ),
                        VerticalSpacing(),
                        Text(AppStrings().gallery, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.titleTextColor),)
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> _onImageButtonPressed({required ImageSource source}) async {
    try {
      pickedFile = await _picker.pickImage(
        source: source,
      );
      if(pickedFile != null){
        setState(() {
          progressValue = 1;
          debugPrint('Picked image path is ${pickedFile!.path}');
        });
      }

    } catch (e) {
      debugPrint('Pick image error is ${e.toString()}');
      setState(() {
        //_pickImageError = e;
      });
    }
  }

  Future<void> handleApi() async{
    if(pickedFile == null) {
      Get.snackbar(AppStrings().alert, AppStrings().errorSelectImage);
    } else {
      setState(() {
        isLoading = true;
      });
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
          AddProviderAttributeResponse? attributeResponse = await _doctorSetUpController.addAttributeToProvider(
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
            AddAppointmentTimeSlotResponse? addAppointmentSlotResponse = await _doctorSetUpController.addProviderAppointmentTimeSlots(startDate: startDate, endDate: endDate, providerUUID: providerUuid, types: doctorSetupValues.serviceTypes);
            debugPrint('addAppointmentSlotResponse is ${addAppointmentSlotResponse?.uuid}');
          }
        }

        await doctorProfile.saveDoctorProfile();
        setState(() {
          isLoading = false;
        });
        /*Get.offAll(() => const DashboardPage(),
          transition: Utility.pageTransition,);*/
        Get.offAllNamed(AppRoutes.dashboardPage);
      } else {
        DialogHelper.showErrorDialog(title: AppStrings().alert, description: AppStrings().errorProviderUUIDNotFound);
      }
    }
  }
}

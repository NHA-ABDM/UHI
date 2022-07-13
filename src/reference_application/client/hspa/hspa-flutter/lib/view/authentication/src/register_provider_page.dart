import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/register_provider_controller.dart';
import '../../../model/response/src/register_provider_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../utils/src/validator.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import '../../dashboard/src/dashboard_page.dart';
import '../../profile/src/doctor_profile_page.dart';

enum Gender {male, female}

class RegisterProviderPage extends StatefulWidget {
  const RegisterProviderPage({Key? key}) : super(key: key);

  @override
  State<RegisterProviderPage> createState() => _RegisterProviderPageState();
}

class _RegisterProviderPageState extends State<RegisterProviderPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController hprAddressController = TextEditingController();
  TextEditingController hprIdController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController languagesController = TextEditingController();
  TextEditingController specialityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  Gender? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    hprAddressController.dispose();
    hprIdController.dispose();
    educationController.dispose();
    experienceController.dispose();
    languagesController.dispose();
    specialityController.dispose();
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
            AppStrings().titleRegisterProvider,
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
                    getInputTextWidget(
                      controller: firstNameController,
                      keyboardType: TextInputType.name,
                      labelText: AppStrings().labelName, validate: (String? value) {
                        if(value!.trim().isEmpty) {
                          return AppStrings().errorEnterName;
                        }
                        return null;
                    },),
                    /*VerticalSpacing(),
                    getInputTextWidget(controller: lastNameController, labelText: AppStrings(.labelLastName, validate: (String? value) {
                      if(value!.trim().isEmpty) {
                        return AppStrings(.errorEnterLastName;
                      }
                      return null;
                    },),*/
                    VerticalSpacing(),
                    getInputTextWidget(controller: hprAddressController, labelText: AppStrings().labelHPRAddress, keyboardType: TextInputType.emailAddress, validate: (String? value) {
                      return Validator.validateHprAddress(value);
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: hprIdController, labelText: AppStrings().labelHPRId, keyboardType: TextInputType.text, maxLength: 14, validate: (String? value) {
                      return Validator.validateHprId(value);
                    },),

                    VerticalSpacing(size: 16,),
                    Text(AppStrings().labelSelectGender, style: AppTextStyle.textMediumStyle(fontSize: 14, color: AppColors.black),),
                    VerticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: Text(
                              AppStrings().labelMale,
                              style: AppTextStyle.textNormalStyle(
                                  fontSize: 14, color: AppColors.black),
                            ),
                            value: Gender.male,
                            groupValue: _selectedGender,
                            onChanged: (Gender? value) {
                              setState(() {
                                _selectedGender = Gender.male;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: Text(
                              AppStrings().labelFemale,
                              style: AppTextStyle.textNormalStyle(
                                  fontSize: 14, color: AppColors.black),
                            ),
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: (Gender? value) {
                              setState(() {
                                _selectedGender = Gender.female;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    getInputTextWidget(controller: ageController, labelText: AppStrings().labelAge, keyboardType: TextInputType.number, validate: (String? value) {
                      return Validator.validateAge(value);
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: educationController, labelText: AppStrings().labelEducationWithHint, validate: (String? value) {
                      if(value!.trim().isEmpty) {
                        return AppStrings().errorEnterEducation;
                      }
                      return null;
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: experienceController, labelText: AppStrings().labelExperience, keyboardType: TextInputType.number, validate: (String? value) {
                      return Validator.validateExperience(value);
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: specialityController, labelText: AppStrings().labelSpeciality, validate: (String? value) {
                      if(value!.trim().isEmpty) {
                        return AppStrings().errorEnterSpeciality;
                      }
                      return null;
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: languagesController, labelText: AppStrings().labelLanguagesWithHint, textInputAction: TextInputAction.done, validate: (String? value) {
                      if(value!.trim().isEmpty) {
                        return AppStrings().errorEnterLanguagesKnown;
                      }
                      return null;
                    },),

                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacing(isWidth: false, size: 16,),
              VerticalSpacing(),
              SquareRoundedButtonWithIcon(text: AppStrings().btnRegister, assetImage: AssetImages.arrowLongRight, onPressed: (){

                if(_formKey.currentState!.validate()){
                  if(_selectedGender == null) {
                    Get.snackbar(AppStrings().alert, AppStrings().errorSelectGender);
                  } else {
                    handleRegisterProviderAPI();
                  }
                } else {
                  setState(() {
                    _autoValidateMode = AutovalidateMode.always;
                  });
                }
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
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validate,
    int? maxLength,
  }){
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.titleTextColor,
      textInputAction: textInputAction,
      autovalidateMode: _autoValidateMode,
      maxLength: maxLength,
      style: AppTextStyle.textNormalStyle(fontSize: 16, color: textColor),
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: hintTextColor),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.titleTextColor)),
        counterText: ''
      ),
      keyboardType: keyboardType,
      validator: validate,
    );
  }

  void handleRegisterProviderAPI() async{
    try {
      setState(() {
        _isLoading = true;
      });

      RegisterProviderController registerProviderController = RegisterProviderController();
      RegisterProviderResponse? registerProviderResponse =
      await registerProviderController.registerProvider(requestBody: getAddProviderRequestBody());
      setState(() {
        _isLoading = false;
      });

      if(registerProviderResponse != null && registerProviderResponse.uuid != null) {
        DoctorProfile? profile = await DoctorProfile.getSavedProfile();
        if (profile != null && profile.firstConsultation == null) {
          Get.to(() => const DoctorProfilePage(),
            transition: Utility.pageTransition,);
        } else {
          Get.offAll(() => const DashboardPage(),
            transition: Utility.pageTransition,);
        }
      }

    } catch (e) {
      debugPrint('Register provider exception is ${e.toString()}');
    }
  }

  Map<String, dynamic> getAddProviderRequestBody() {
    String gender = 'M';
    if(_selectedGender == Gender.female) {
      gender = 'F';
    }

    List<Map<String, dynamic>> names = <Map<String, dynamic>>[];
    names.add({
      "givenName" : firstNameController.text.trim(),
      // "familyName" : lastNameController.text.trim(),
      "familyName" : '',
    });

    List<Map<String, dynamic>> attributes = <Map<String, dynamic>>[];
    attributes.addAll([
      {
        "attributeType": ProviderAttributesLocal.educationAttribute,
        "value": educationController.text.trim(),
      },
      {
        "attributeType": ProviderAttributesLocal.experienceAttribute,
        "value": experienceController.text.trim(),
      },
      {
        "attributeType": ProviderAttributesLocal.hprAddressAttribute,
        "value": hprAddressController.text.trim(),
      },
      {
        "attributeType": ProviderAttributesLocal.hprIdAttribute,
        "value": hprIdController.text.trim(),
      },
      {
        "attributeType": ProviderAttributesLocal.languagesAttribute,
        "value": languagesController.text.trim(),
      },
      {
        "attributeType": ProviderAttributesLocal.specialityAttribute,
        "value": specialityController.text.trim(),
      },
    ]);

    Map<String, dynamic> personMap = {
      "gender" : gender,
      "age" : ageController.text.trim(),
      "names" : names.toList(),
    };

    Map<String, dynamic> providerMap = {
      // "name" : firstNameController.text.trim() + ' ' + lastNameController.text.trim(),
      "name" : firstNameController.text.trim(),
      "person" : personMap,
      "identifier" : hprAddressController.text.trim(),
      "attributes" : attributes.toList(),
      "retired" : false,
    };

    return providerMap;
  }
}

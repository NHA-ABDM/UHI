import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/language_constant.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/get_pages.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/register_provider_controller.dart';
import '../../../model/response/src/hpr_id_profile_response.dart';
import '../../../model/response/src/register_provider_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/validator.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';

enum Gender {male, female}

class CompleteProviderProfilePage extends StatefulWidget {
  const CompleteProviderProfilePage({Key? key}) : super(key: key);

  /*const CompleteProviderProfilePage({Key? key, required this.hprIdProfileResponse}) : super(key: key);
  final HPRIDProfileResponse hprIdProfileResponse;*/

  @override
  State<CompleteProviderProfilePage> createState() => _CompleteProviderProfilePageState();
}

class _CompleteProviderProfilePageState extends State<CompleteProviderProfilePage> {

  /// Arguments
  late final HPRIDProfileResponse hprIdProfileResponse;

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
  bool _enableSelectGender = false;

  List<Object?> selectedLanguages = <Object?>[];
  List<Object?> selectedSpecialities = <Object?>[];
  List<Object?> selectedEducations = <Object?>[];
  final FocusNode _languagesFocusNode = FocusNode();
  final FocusNode _specialityFocusNode = FocusNode();
  final FocusNode _educationFocusNode = FocusNode();

  @override
  void initState() {
    /// Get Arguments
    hprIdProfileResponse = Get.arguments['hprIdProfileResponse'];
    setUpExistingProviderData();
    super.initState();
  }

  setUpExistingProviderData(){

    int yearOfBirth = int.parse(hprIdProfileResponse.yearOfBirth!);
    int monthOfBirth = int.parse(hprIdProfileResponse.monthOfBirth ?? '12');
    int dayOfBirth = int.parse(hprIdProfileResponse.dayOfBirth ?? '31');

    DateTime birthDate = DateTime(yearOfBirth, monthOfBirth, dayOfBirth);

    DateTime today =  DateTime.now();
    int age = today.year - birthDate.year;
    int m = today.month - birthDate.month;
    if (m < 0 || (m == 0 && today.isBefore(birthDate)))
    {
      age--;
    }

    firstNameController.text = hprIdProfileResponse.name!;
    ageController.text = age.toString();
    hprAddressController.text = hprIdProfileResponse.hprId!;
    hprIdController.text = hprIdProfileResponse.hprIdNumber!;

    /// Set Gender value
    if(hprIdProfileResponse.gender != null) {
      _selectedGender =
      hprIdProfileResponse.gender!.toUpperCase() == 'M' ? Gender.male : Gender.female;
    } else {
      _selectedGender = null;
      _enableSelectGender = true;
    }
  }

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
    _languagesFocusNode.dispose();
    _specialityFocusNode.dispose();
    _educationFocusNode.dispose();
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
            AppStrings().titleCompleteProfile,
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
                    Text(AppStrings().labelLoginForFirstTime, textAlign: TextAlign.start,style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.black)),
                    VerticalSpacing(size: 20,),
                    getInputTextWidget(
                      controller: firstNameController,
                      keyboardType: TextInputType.name,
                      labelText: AppStrings().labelName, validate: (String? value) {
                      if(value!.isEmpty) {
                        return AppStrings().errorEnterName;
                      } else if(value.startsWith(' ')) {
                        return AppStrings().errorNameShouldStartWithCharactersOnly;
                      } else if(value.trim().contains('  ')) {
                        return AppStrings().errorShouldContainSingleSpaceBetweenName;
                      } else if(!Validator.nameRegex.hasMatch(value)) {
                        return AppStrings().errorEnterValidName;
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
                      //return Validator.validateHprId(value);
                      return null;
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
                                  fontSize: 14, color: _enableSelectGender ? AppColors.black : AppColors.feesLabelTextColor),
                            ),
                            value: Gender.male,
                            groupValue: _selectedGender,
                            onChanged: _enableSelectGender ? (Gender? value) {
                              setState(() {
                                _selectedGender = Gender.male;
                              });
                            } : null,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: Text(
                              AppStrings().labelFemale,
                              style: AppTextStyle.textNormalStyle(
                                  fontSize: 14, color: _enableSelectGender ? AppColors.black : AppColors.feesLabelTextColor),
                            ),
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: _enableSelectGender ?(Gender? value) {
                              setState(() {
                                _selectedGender = Gender.female;
                              });
                            } : null,
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
                    getInputTextWidget(controller: educationController, labelText: AppStrings().labelEducationWithHint, enable: true,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(' , ,', replacementString: ' ,'),
                        FilteringTextInputFormatter.deny(',,', replacementString: ','),
                        FilteringTextInputFormatter.deny('  ', replacementString: ' ')
                      ],
                      readOnly: true,
                      focusNode: _educationFocusNode,
                      onTap: () {
                        _showMultiSelectWidget(context,
                            title: AppStrings().labelSelectQualification,
                            searchHint: AppStrings().labelSearchQualification,
                            itemList: AppStrings.educations,
                            controller: educationController,
                            selectedItems: selectedEducations,
                          onConfirm: (List<dynamic> values) {
                            setState(() {
                              String items = '';
                              values.map((e) => items += '$e, ').toList();
                              if(items.length > 2) {
                                items = items.substring(0, items.length - 2);
                              }
                              educationController.text = items.trim();
                              selectedEducations = values;
                            });
                          }
                        );
                        _educationFocusNode.unfocus();
                      },
                      hintTextColor: AppColors.titleTextColor,
                      validate: (String? value) {
                        if(value!.isEmpty) {
                          return AppStrings().errorEnterEducation;
                        } /*else if(value.startsWith(' ') || value.startsWith(',')) {
                          return AppStrings().errorShouldStartWithCharactersOnly(type: AppStrings().labelEducation);
                        } else if(!Validator.stringWithCommaRegex.hasMatch(value)) {
                          return AppStrings().errorEnterValidEducation;
                        } else if(value.trim().endsWith(' ,') || value.trim().endsWith(',')) {
                          return AppStrings().errorRemoveCommaAtLast;
                        }*/
                        return null;
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: experienceController, labelText: AppStrings().labelExperience, enable: true, keyboardType: TextInputType.number, validate: (String? value) {
                      String? validatedString = Validator.validateExperience(value);
                      if(validatedString == null && ageController.text.trim().isNotEmpty){
                        double? age = double.tryParse(ageController.text.trim());
                        if(age != null) {
                          if(age < double.parse(experienceController.text.trim())) {
                            return AppStrings().errorInvalidExperience;
                          }
                        }
                      }
                      return validatedString;
                    },),
                    VerticalSpacing(),
                    getInputTextWidget(controller: specialityController, labelText: AppStrings().labelSpeciality, enable: true,
                      readOnly: true,
                      focusNode: _specialityFocusNode,
                      onTap: () {
                        _showMultiSelectWidget(context,
                            title: AppStrings().labelSelectSpeciality,
                            searchHint: AppStrings().labelSearchSpeciality,
                            itemList: AppStrings.specialities,
                            controller: specialityController,
                            selectedItems: selectedSpecialities,
                            onConfirm: (List<dynamic> values) {
                              setState(() {
                                String items = '';
                                values.map((e) => items += '$e, ').toList();
                                if(items.length > 2) {
                                  items = items.substring(0, items.length - 2);
                                }
                                specialityController.text = items.trim();
                                selectedSpecialities = values;
                              });
                            }
                        );
                        _specialityFocusNode.unfocus();
                      },
                      hintTextColor: AppColors.titleTextColor,
                      validate: (String? value) {
                      if(value!.isEmpty) {
                        return AppStrings().errorEnterSpeciality;
                      } /*else if(value.startsWith(' ')) {
                        return AppStrings().errorShouldStartWithCharactersOnly(type: AppStrings().labelSpeciality);
                      } else if(!Validator.nameRegex.hasMatch(value)) {
                        return AppStrings().errorEnterValidSpeciality;
                      }*/
                      return null;
                    },),
                    VerticalSpacing(),
                    /*getInputTextWidget(controller: languagesController, labelText: AppStrings().labelLanguagesWithHint, enable: true, textInputAction: TextInputAction.done,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(' , ,', replacementString: ' ,'),
                        FilteringTextInputFormatter.deny(',,', replacementString: ','),
                        FilteringTextInputFormatter.deny('  ', replacementString: ' ')
                      ],
                      validate: (String? value) {
                        if(value!.isEmpty) {
                          return AppStrings().errorEnterLanguagesKnown;
                        } else if(value.startsWith(' ') || value.startsWith(',')) {
                          return AppStrings().errorShouldStartWithCharactersOnly(type: AppStrings().labelLanguages);
                        } else if(!Validator.stringWithCommaRegex.hasMatch(value)) {
                          return AppStrings().errorEnterValidLanguages;
                        } else if(value.trim().endsWith(' ,') || value.trim().endsWith(',')) {
                          return AppStrings().errorRemoveCommaAtLast;
                        }
                        return null;
                    },),*/
                    getInputTextWidget(controller: languagesController, labelText: AppStrings().labelLanguagesWithHint, enable: true, textInputAction: TextInputAction.done,
                      focusNode: _languagesFocusNode,
                      readOnly: true,
                      onTap: () {
                        _showMultiSelectWidget(context,
                            title: AppStrings().labelSelectLanguage,
                            itemList: LanguageConstant.indianLanguages,
                          controller: languagesController,
                          selectedItems: selectedLanguages,
                          searchHint: AppStrings().labelSearchLanguage,
                            onConfirm: (List<dynamic> values) {
                              setState(() {
                                String items = '';
                                values.map((e) => items += '$e, ').toList();
                                if(items.length > 2) {
                                  items = items.substring(0, items.length - 2);
                                }
                                languagesController.text = items.trim();
                                selectedLanguages = values;
                              });
                            }
                        );
                        _languagesFocusNode.unfocus();
                      },
                      hintTextColor: AppColors.titleTextColor,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(' , ,', replacementString: ' ,'),
                        FilteringTextInputFormatter.deny(',,', replacementString: ','),
                        FilteringTextInputFormatter.deny('  ', replacementString: ' ')
                      ],
                      validate: (String? value) {
                        if(value!.isEmpty) {
                          return AppStrings().errorEnterLanguagesKnown;
                        } /*else if(value.startsWith(' ') || value.startsWith(',')) {
                          return AppStrings().errorShouldStartWithCharactersOnly(type: AppStrings().labelLanguages);
                        } else if(!Validator.stringWithCommaRegex.hasMatch(value)) {
                          return AppStrings().errorEnterValidLanguages;
                        } else if(value.trim().endsWith(' ,') || value.trim().endsWith(',')) {
                          return AppStrings().errorRemoveCommaAtLast;
                        }*/
                        return null;
                      },),

                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              const Spacing(isWidth: false, size: 16,),
              VerticalSpacing(),
              SquareRoundedButtonWithIcon(text: AppStrings().btnSaveProfile, assetImage: AssetImages.arrowLongRight, onPressed: (){

                if(_formKey.currentState!.validate()){
                  debugPrint('Age ${int.parse(ageController.text.trim())} and Experience is ${int.parse(experienceController.text.trim())}');
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
    bool enable = false,
  List<TextInputFormatter>? inputFormatters,
    Function()? onTap,
    bool readOnly = false,
    FocusNode? focusNode
  }){
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      cursorColor: AppColors.titleTextColor,
      textInputAction: textInputAction,
      autovalidateMode: _autoValidateMode,
      minLines: 1,
      maxLines: 5,
      maxLength: maxLength,
      style: AppTextStyle.textNormalStyle(fontSize: 14, color: enable ? textColor : hintTextColor),
      enabled: enable,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
          labelText: labelText,
          enabled: enable,
          labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: hintTextColor),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.titleTextColor)),
          counterText: ''
      ),
      keyboardType: keyboardType,
      validator: validate,
      inputFormatters: inputFormatters,
    );
  }

  void handleRegisterProviderAPI() async{
    debugPrint('In CompleteProviderProfilePage handleRegisterProviderAPI');
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
          /*Get.to(() => const DoctorProfilePage(),
            transition: Utility.pageTransition,);*/
          Get.toNamed(AppRoutes.doctorProfilePage);
        } else {
          /*Get.offAll(() => const DashboardPage(),
            transition: Utility.pageTransition,);*/
          Get.offAllNamed(AppRoutes.dashboardPage);
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
        "attributeType": ProviderAttributesLocal.profilePhotoAttribute,
        "value": hprIdProfileResponse.profilePhoto,
      },
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

  void _showMultiSelectWidget(
      BuildContext context,
      {String title = 'Select',
        String searchHint = 'Search',
        required List<dynamic> itemList,
        required List<Object?> selectedItems,
        required TextEditingController controller,
        required Function(List<dynamic>)? onConfirm,
        double childSize = 0.8
      }) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      isDismissible: false,
      builder: (ctx) {
        return  MultiSelectBottomSheet(
          searchable: true,
          title: Text(title, style: AppTextStyle.textMediumStyle(fontSize: 18, color: AppColors.tileColors),),
          cancelText: Text(AppStrings().btnCancel, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.tileColors),),
          confirmText: Text(AppStrings().btnOk, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.tileColors),),
          searchIcon: const Icon(Icons.search, color: AppColors.tileColors,),
          checkColor: AppColors.white,
          selectedColor: AppColors.tileColors,
          searchHint: searchHint,
          items: itemList
              .map((e) => MultiSelectItem(e, e))
              .toList(),
          initialValue: selectedItems,
          onConfirm: onConfirm,
          /*(values) {
            debugPrint('Selected list ${values.toString()}');
            setState(() {
              String items = '';
              values.map((e) => items += '$e, ').toList();
              if(items.length > 2) {
                items = items.substring(0, items.length - 2);
              }
              controller.text = items.trim();
              selectedItems = values;
            });
          },*/
          maxChildSize: childSize,
          initialChildSize: childSize,
        );
      },
    );
  }

  /// Shows Alert Dialog to show list of languages
  void _selectLanguages(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          searchable: true,
          title: Text(
            AppStrings().labelSelectLanguage,
            style: AppTextStyle.textMediumStyle(
                fontSize: 18, color: AppColors.tileColors),
          ),
          cancelText: Text(
            AppStrings().btnCancel,
            style: AppTextStyle.textMediumStyle(
                fontSize: 16, color: AppColors.tileColors),
          ),
          confirmText: Text(
            AppStrings().btnOk,
            style: AppTextStyle.textMediumStyle(
                fontSize: 16, color: AppColors.tileColors),
          ),
          searchIcon: const Icon(
            Icons.search,
            color: AppColors.tileColors,
          ),
          searchHint: AppStrings().labelSelectLanguage,
          items: LanguageConstant.indianLanguages
              .map((e) => MultiSelectItem(e, e))
              .toList(),
          listType: MultiSelectListType.LIST,
          onConfirm: (values) {
            debugPrint('Selected languages are ${values.toString()}');
            setState(() {
              String languages = '';
              values.map((e) => languages += '$e, ').toList();
              if (languages.length > 2) {
                languages = languages.substring(0, languages.length - 2);
              }
              debugPrint(' languages are $languages');
              languagesController.text = languages.trim();
              selectedLanguages = values;
            });
          }, initialValue: selectedLanguages,
        );
      },
    );
  }
}

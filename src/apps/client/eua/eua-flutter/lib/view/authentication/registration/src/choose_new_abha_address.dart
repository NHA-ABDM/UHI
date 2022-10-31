import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/login/src/access_token_controller.dart';
import 'package:uhi_flutter_app/controller/registration/src/choose_new_abha_address_controller.dart';
import 'package:uhi_flutter_app/model/common/src/session_id_model.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/theme/src/app_text_style.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_success_page.dart';

import '../../../../common/common.dart';

class ChooseNewAbhaAddress extends StatefulWidget {
  String sessionId;
  bool? isFromMobile;

  ChooseNewAbhaAddress({Key? key, required this.sessionId, this.isFromMobile})
      : super(key: key);

  @override
  State<ChooseNewAbhaAddress> createState() => _ChooseNewAbhaAddressState();
}

class _ChooseNewAbhaAddressState extends State<ChooseNewAbhaAddress> {
  var width;
  var height;
  var isPortrait;
  bool _passwordVisible = false;
  final _userAbhaAddressTextController = TextEditingController();
  final _userPasswordTextController = TextEditingController();
  final _userConfirmPasswordTextController = TextEditingController();
  final _chooseNewABHAAddressForm = GlobalKey<FormState>();
  var passwordEmpty;
  final accessTokenController = Get.put(AccessTokenController());
  late SessionIdModel sessionIdModel;
  bool isAlreadyExistingPhrAddress = false;

  final chooseNewAbhaAddressController = AbhaAddressSuggestionsController();
  List<String>? _suggestedPhrAddress;

  bool isLoading = false;
  bool isPageLoading = false;
  final _formKey = GlobalKey<FormState>();
  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");

  bool validatePassword(String pass) {
    String _password = pass.trim();
    if (_password.length >= 8 && pass_valid.hasMatch(_password)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // callAccessTokenApi();
    callSuggestApi();
    _passwordVisible = false;
  }

  showProgressIndicator() {
    setState(() {
      isLoading = true;
    });
  }

  hideProgressIndicator() {
    setState(() {
      isLoading = false;
    });
  }

  callAccessTokenApi() async {
    accessTokenController.refresh();
    await accessTokenController.postAccessTokenAPI();
  }

  callSuggestApi() async {
    setState(() {
      isPageLoading = true;
    });
    sessionIdModel = SessionIdModel(sessionId: widget.sessionId);
    await chooseNewAbhaAddressController.postSuggestApi(
        suggestionRequest: sessionIdModel);
    log("${jsonEncode(chooseNewAbhaAddressController.abhaAddressSuggestionsResponse)}");
    populateSuggestedPhrAddressListFromApi();
  }

  void populateSuggestedPhrAddressListFromApi() {
    var suggestedPhrAddressList = chooseNewAbhaAddressController
        .abhaAddressSuggestionsResponse!.suggestedPhrAddress;
    if (suggestedPhrAddressList != null) {
      _suggestedPhrAddress = suggestedPhrAddressList;
    }
    setState(() {
      isPageLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        title: Text(
          widget.isFromMobile!
              ? AppStrings().registrationWithMobileNumber
              : AppStrings().registrationWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isPageLoading
          ? Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: AppColors.primaryLightBlue007BFF,
                ),
              ),
            )
          : buildWidgets(),
    );
  }

  buildWidgets() {
    return Form(
      key: _chooseNewABHAAddressForm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings().createNewABHAAddress,
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 16),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 68,
              width: width * 0.89,
              child: TextField(
                onChanged: (str) {
                  if (str.length >= 4 && str.length <= 32) {
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        checkIfPhrAddressAlreadyExists();
                      });
                    });
                  }
                  // checkIfPhrAddressAlreadyExists();
                },
                controller: _userAbhaAddressTextController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  suffixText: AppStrings().abdmAt,
                  labelText: AppStrings().abhaAddress,
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(), gapPadding: 0),
                ),
              ),
            ),
            Text(
              AppStrings().suggestions,
              style: AppTextStyle.textSemiBoldStyle(
                color: AppColors.mobileNumberTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(child: suggestedPhrAddressList),
            SizedBox(
              height: 25,
            ),
            Text(
              AppStrings().createYourPassword,
              style: AppTextStyle.textBoldStyle(
                color: AppColors.mobileNumberTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(
              height: 88,
              width: width * 0.89,
              child: TextFormField(
                controller: _userPasswordTextController,
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                // validator: (value) {
                //   String passwordValidationMessage = passwordValidation();
                //   if (passwordValidationMessage == 'true') {
                //     return null;
                //   } else {
                //     return passwordValidationMessage;
                //   }
                //   ;
                // },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter password";
                  } else {
                    bool result = validatePassword(value);
                    if (result) {
                      return null;
                    } else {
                      return "Password must contain Capital, small letter,Number &\nSpecial character and at least 8 or more character";
                    }
                  }
                },
                decoration: InputDecoration(
                  errorText: passwordEmpty,
                  labelText: AppStrings().createPassword,
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    gapPadding: 0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 68,
              width: width * 0.89,
              child: TextFormField(
                controller: _userConfirmPasswordTextController,
                textAlignVertical: TextAlignVertical.center,
                obscureText: !_passwordVisible,
                validator: (value) {
                  String passwordValidationMessage = passwordValidation();
                  if (passwordValidationMessage == 'true') {
                    return null;
                  } else {
                    return passwordValidationMessage;
                  }
                  ;
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  labelText: AppStrings().confirmPassword,
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    gapPadding: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              AppStrings().btnContinue,
              style: AppTextStyle.textMediumStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
            submitButton(),
          ],
        ),
      ),
    );
  }

  void checkIfPhrAddressAlreadyExists() async {
    await chooseNewAbhaAddressController.getIfAlreadyExistsPhrAddress(
        _userAbhaAddressTextController.text + AppStrings().abdmAt);

    if (chooseNewAbhaAddressController.alreadyExistingPhrResponse != null) {
      if (chooseNewAbhaAddressController.alreadyExistingPhrResponse?.status !=
          null) {
        if (chooseNewAbhaAddressController
            .alreadyExistingPhrResponse!.status!) {
          isAlreadyExistingPhrAddress = true;
        } else {
          isAlreadyExistingPhrAddress = false;
        }
      }
    }
  }

  Wrap get suggestedPhrAddressList {
    // return GridView.builder(
    //   shrinkWrap: true,
    //   itemCount: _suggestedPhrAddress?.length,
    //   itemBuilder: (context, index) {
    //     return phrSuggetion(_suggestedPhrAddress?[index] ?? "");
    //   },
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: (MediaQuery.of(context).size.width ~/ 250).toInt(),
    //     crossAxisSpacing: 5,
    //     childAspectRatio: 3 / 1,
    //   ),
    // );
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          _suggestedPhrAddress?.map((e) => phrSuggestion(e)).toList() ?? [],
    );
  }

  Widget phrSuggestion(String suggestion) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _userAbhaAddressTextController.text = suggestion;
        });
      },
      child: Text(
        suggestion,
        style: AppTextStyle.textBoldStyle(
          color: AppColors.primaryLightBlue007BFF,
          fontSize: 16,
        ),
      ),
    );
  }

  GestureDetector submitButton() {
    return GestureDetector(
      onTap: isLoading
          ? () {}
          : () async {
              if (_chooseNewABHAAddressForm.currentState!.validate()) {
                var userAbhaAddress = _userAbhaAddressTextController.text;
                if (userAbhaAddress.isNotEmpty) {
                  showProgressIndicator();
                  chooseNewAbhaAddressController.refresh();

                  Future.delayed(Duration(milliseconds: 100));

                  userAbhaAddress += AppStrings().abdmAt;
                  CreatePhrAddressRequestModel phrRequest =
                      makeCreatePhrAddressRequestReady();
                  await createPhrAddressRequestApiCall(phrRequest);

                  log("${jsonEncode(chooseNewAbhaAddressController.createPhrAddressResponseModel)}");

                  if (chooseNewAbhaAddressController
                              .createPhrAddressResponse?.phrAddress !=
                          null &&
                      chooseNewAbhaAddressController
                              .createPhrAddressResponse?.phrAddress !=
                          "") {
                    hideProgressIndicator();
                    Get.to(
                      () => RegistrationSuccessPage(
                        phrAddress: chooseNewAbhaAddressController
                            .createPhrAddressResponse!,
                      ),
                    );
                  } else if (chooseNewAbhaAddressController.errorString != "") {
                    hideProgressIndicator();
                  } else {
                    hideProgressIndicator();

                    DialogHelper.showErrorDialog(
                        title: AppStrings().errorString,
                        description: AppStrings().somethingWentWrongErrorMsg);
                  }
                }
              }
            },
      child: Container(
        height: 40,
        width: width * 0.89,
        decoration: const BoxDecoration(
          color: AppColors.tileColors,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                )
              : Text(
                  AppStrings().submit.toUpperCase(),
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.white, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Future<void> createPhrAddressRequestApiCall(
      CreatePhrAddressRequestModel phrRequest) async {
    await chooseNewAbhaAddressController.postCreatePhrAddressApi(
      createPhrAddressRequestModel: phrRequest,
    );
  }

  CreatePhrAddressRequestModel makeCreatePhrAddressRequestReady() {
    CreatePhrAddressRequestModel phrRequest = CreatePhrAddressRequestModel();

    if (isAlreadyExistingPhrAddress) {
      phrRequest.alreadyExistedPHR = true;
    } else {
      phrRequest.alreadyExistedPHR = false;
    }
    phrRequest.password = _userPasswordTextController.text;
    phrRequest.phrAddress =
        _userAbhaAddressTextController.text + AppStrings().abdmAt;
    phrRequest.sessionId = sessionIdModel.sessionId;

    return phrRequest;
  }

  String passwordValidation() {
    bool _passwordAndConfirmPAsswordIsNotEmpty =
        _userConfirmPasswordTextController.text.isNotEmpty ||
            _userPasswordTextController.text.isNotEmpty;
    bool _passwordAndConfirmPasswordMaching =
        _userConfirmPasswordTextController.text ==
            _userPasswordTextController.text;
    bool _passwordLengthGreaterThanEquals6 =
        _userPasswordTextController.text.length >= 6;

    return getPasswordValidationErrorMessage(
      _passwordAndConfirmPAsswordIsNotEmpty,
      _passwordLengthGreaterThanEquals6,
      _passwordAndConfirmPasswordMaching,
    );
  }

  String getPasswordValidationErrorMessage(
      bool _passwordAndConfirmPAsswordIsNotEmpty,
      bool _passwordLengthGreaterThanEquals6,
      bool _passwordAndConfirmPasswordMaching) {
    if (_passwordAndConfirmPAsswordIsNotEmpty &&
        _passwordLengthGreaterThanEquals6 &&
        _passwordAndConfirmPasswordMaching) {
      return "true";
    } else if (!_passwordAndConfirmPAsswordIsNotEmpty) {
      return AppStrings().enterPassword;
    } else if (!_passwordAndConfirmPasswordMaching) {
      return AppStrings().passwordNotMatching;
    } else if (!_passwordLengthGreaterThanEquals6) {
      return AppStrings().passwordGreaterThan6;
    } else {
      return "unknown";
    }
  }
}

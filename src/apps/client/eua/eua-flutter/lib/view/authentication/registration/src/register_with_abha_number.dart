import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/abha_auth_methods_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../model/common/common.dart';
import '../../login/src/web_view_registration.dart';

class RegisterWithAbhaNumberPage extends StatefulWidget {
  const RegisterWithAbhaNumberPage({Key? key}) : super(key: key);

  @override
  State<RegisterWithAbhaNumberPage> createState() =>
      _RegisterWithAbhaNumberPageState();
}

class _RegisterWithAbhaNumberPageState
    extends State<RegisterWithAbhaNumberPage> {
  ///CONTROLLERS
  AbhaNumberController _abhaNumberController = AbhaNumberController();

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool? _isChecked = false;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final _abhaNumberTextController = TextEditingController();
  final _passwordTextField = TextEditingController();
  String _selectedOption = 'ABHA Number';
  final Uri _url = Uri.parse('https://healthidsbx.abdm.gov.in/register');
  bool _isValidate = false;
  final _abhaFormKey = GlobalKey<FormState>();
  bool isLoading = false;

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
  }

  ///ABHA AUTH MODE API
  postAbhaAuthModeAPI() async {
    showProgressIndicator();
    _abhaNumberController.refresh();

    if (_abhaNumberTextController.text.isEmpty) {
      DialogHelper.showErrorDialog(description: AppStrings().enterABHANumber);
      hideProgressIndicator();

      return;
    }

    AbhaIdAuthModel abhaIdAuthModel = AbhaIdAuthModel();
    abhaIdAuthModel.healthIdNumber = _abhaNumberTextController.text;

    log("${jsonEncode(abhaIdAuthModel)}", name: "ABHA AUTH MODE MODEL");

    await _abhaNumberController.postAbhaNumberDetails(
        abhaNumberDetails: abhaIdAuthModel);

    if (_abhaNumberController.abhaNumberAckDetails != null &&
        _abhaNumberController.abhaNumberAckDetails != "") {
      hideProgressIndicator();
      if (_abhaNumberController.abhaNumberAckDetails["healthIdNumber"] !=
              null &&
          _abhaNumberController.abhaNumberAckDetails["healthIdNumber"] != "") {
        Get.to(() => AbhaAuthMethodsPage(
              healthIdNumber:
                  _abhaNumberController.abhaNumberAckDetails["healthIdNumber"],
            ));
      } else {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else if (_abhaNumberController.errorString != '') {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();
      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }
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

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: AppColors.white,
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
          AppStrings().registrationWithABHANUmber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterABHANumber,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                height: 50,
                color: Colors.white,
                width: width * 0.88,
                child: Form(
                  autovalidateMode: _isValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  key: _abhaFormKey,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 0),
                      child: PinCodeTextField(
                        controller: _abhaNumberTextController,
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        appContext: context,
                        length: 14,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          if (v!.length < 14) {
                            return AppStrings().invalidABHANumber;
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 30,
                            fieldWidth: 20,
                            selectedFillColor: Colors.grey,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedColor: Colors.white,
                            inactiveColor: Colors.grey,
                            borderWidth: 1),
                        cursorColor: Colors.black,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        onCompleted: (v) {},
                        onChanged: (value) {
                          setState(() {
                            // currentText = value;
                          });
                        },
                      )),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => WebViewRegistration(isForgotAbhaNumber: true));
                },
                child: Text(
                  AppStrings().forgotABHANumber,
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.paymentButtonBackgroundColor,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppStrings().dontHaveABHANumber,
                style: AppTextStyle.textNormalStyle(
                    color: AppColors.doctorExperienceColor, fontSize: 10),
              ),
              const SizedBox(
                width: 4,
              ),
              GestureDetector(
                onTap: () {
                  // _launchUrl();
                  Get.to(() => WebViewRegistration());
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    AppStrings().createNew,
                    style: AppTextStyle.textMediumStyle(
                        color: AppColors.paymentButtonBackgroundColor,
                        fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: isLoading
                  ? () {}
                  : () {
                      if (_abhaFormKey.currentState!.validate()) {
                        setState(() {
                          _isValidate = true;
                        });
                        postAbhaAuthModeAPI();
                      }
                    },
              child: Container(
                height: 50,
                width: width * 0.89,
                decoration: const BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
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
                          AppStrings().btnContinue,
                          style: AppTextStyle.textMediumStyle(
                              color: AppColors.white, fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/model/common/src/validate_otp_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/authentication.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/choose_new_abha_address.dart';

import '../../../../common/common.dart';
import '../../../../model/common/common.dart';

class RegistrationOTPVerificationPage extends StatefulWidget {
  String? mobileNumber;
  String? emailId;
  bool? isFromMobile;
  String sessionId;
  bool? isFromHealthId;
  RegistrationOTPVerificationPage(
      {this.mobileNumber,
      this.emailId,
      required this.isFromMobile,
      required this.sessionId,
      this.isFromHealthId});

  @override
  State<RegistrationOTPVerificationPage> createState() =>
      _RegistrationOTPVerificationPageState();
}

class _RegistrationOTPVerificationPageState
    extends State<RegistrationOTPVerificationPage> {
  ///CONTROLLERS
  // final loginVerifyController = Get.put(LoginVerifyController());
  ValidateOtpController _validateOtpController = ValidateOtpController();
  AbhaNumberController _abhaNumberController = AbhaNumberController();
  TextEditingController _otpTextController = TextEditingController();
  GenerateOtpController _generateOtpController = GenerateOtpController();

  ///SIZE
  var width;
  var height;
  var isPortrait;
  String? mobileNumber;
  String? otpValue;
  List<String>? mappedPhrAddress = [];
  Duration myDuration = Duration(minutes: 10);
  Timer? countdownTimer;
  int timerSeconds = 600;

  ///DATA VARIABLES
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  dispose() {
    countdownTimer?.cancel();
    _otpTextController.dispose();
    super.dispose();
  }

  void startTimer() {
    timerSeconds = 600;
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(minutes: 10));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      timerSeconds = myDuration.inSeconds - reduceSecondsBy;
      if (timerSeconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: timerSeconds);
      }
    });
  }

  ///ENCRYPT OTP
  Future<Encrypted> encryptOtp() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encrypter = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encrypter.encrypt(_otpTextController.text);
    return encrypted;
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  ///VALIDATE OTP API
  postValidateOtpAPI() async {
    showProgressIndicator();
    _validateOtpController.refresh();
    _abhaNumberController.refresh();

    if (_otpTextController.text.isEmpty || _otpTextController.text.length < 6) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(description: AppStrings().invalidOTP);
      return;
    }

    ValidateOtpModel validateOtpModel = ValidateOtpModel();
    validateOtpModel.sessionId = widget.sessionId;
    try {
      Encrypted encrypted = await encryptOtp();
      validateOtpModel.value = encrypted.base64;
    } catch (error) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }

    log("${jsonEncode(validateOtpModel)}", name: "VALIDATE OTP MODEL");

    if (widget.isFromHealthId == true) {
      await _abhaNumberController.postAbhaValidateDetails(
          abhaValidateDetails: validateOtpModel);

      if (_abhaNumberController.abhaValidateAckDetails != null &&
          _abhaNumberController.abhaValidateAckDetails != "") {
        hideProgressIndicator();
        String sessionId =
            _abhaNumberController.abhaValidateAckDetails["sessionId"];

        log("$sessionId");

        if (sessionId.isNotEmpty) {
          setState(() {
            _otpTextController.text = "";
          });
          Get.to(() => ChooseNewAbhaAddress(
                sessionId: sessionId,
              ));
        }
      } else if (_abhaNumberController.errorString != "") {
        hideProgressIndicator();
      } else {
        hideProgressIndicator();
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else {
      await _validateOtpController.postValidateOtpDetails(
          validateOtpDetails: validateOtpModel);

      if (_validateOtpController.validateOtpAckDetails != null &&
          _validateOtpController.validateOtpAckDetails != "") {
        hideProgressIndicator();
        String sessionId =
            _validateOtpController.validateOtpAckDetails["sessionId"];

        log("$sessionId");

        if (sessionId.isNotEmpty) {
          countdownTimer?.cancel();
          _otpTextController.clear();
          Get.to(() => UserDetailsFormPage(
                sessionId: sessionId,
                mobileNumber: widget.mobileNumber,
                emailId: widget.emailId,
                isFromMobile: widget.isFromMobile,
              ));
        }
      } else if (_validateOtpController.errorString != "") {
        hideProgressIndicator();
      } else {
        hideProgressIndicator();

        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
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

  // navigateToLinkAccountPage() {
  //   SharedPreferencesHelper.setTransactionId(
  //       loginVerifyController.loginVerifyResponseModel?.transactionId!);
  //   Get.to(ABHAAddressSelectionPage(mappedPhrAddress: mappedPhrAddress!));
  // }

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
          widget.isFromHealthId == true
              ? AppStrings().registrationWithABHANUmber
              : widget.isFromMobile == true
                  ? AppStrings().registrationWithMobileNumber
                  : AppStrings().registrationWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().sentOTPOn +
                " " +
                (widget.isFromMobile == true
                    ? widget.mobileNumber!
                    : widget.emailId!),
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 12),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                height: 50,
                color: Colors.white,
                width: width * 0.88,
                child: Form(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 0),
                      child: PinCodeTextField(
                        controller: _otpTextController,
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        appContext: context,
                        length: 6,
                        validator: (v) {
                          if (v!.length < 6) {
                            return AppStrings().invalidOTP;
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 30,
                            fieldWidth: 40,
                            selectedFillColor: Colors.grey,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedColor: Colors.white,
                            inactiveColor: Colors.grey,
                            borderWidth: 1),
                        cursorColor: Colors.black,
                        enableActiveFill: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        keyboardType: TextInputType.number,
                        // onCompleted: (v) {
                        //   debugPrint("Completed:$v");
                        //   otpValue = v;
                        // },
                        onChanged: (value) {},
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (timerSeconds < 0) {
                    resetTimer();
                    if (widget.isFromMobile!) {
                      postGenerateMobileOtpAPI();
                    } else {
                      postGenerateEmailOtpAPI();
                    }
                  }
                },
                child: Text(
                  AppStrings().resendOTP,
                  style: AppTextStyle.textNormalStyle(
                      color: timerSeconds < 0 ? Colors.blue : Colors.grey,
                      fontSize: 14),
                ),
              ),
              Text(
                AppStrings().expiresIn + ' $minutes Mins $seconds Secs',
                style: AppTextStyle.textNormalStyle(
                    color: AppColors.amountColor, fontSize: 14),
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
                      // showProgressDialog();
                      // callApi();
                      // Get.to(()=>const RegistrationWithAllDetails());
                      // Get.to(() => UserDetailsFormPage());
                      if (_otpTextController.text.isNotEmpty) {
                        postValidateOtpAPI();
                      } else {
                        DialogHelper.showErrorDialog(
                            title: AppStrings().errorString,
                            description: AppStrings().emptyOTP);
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

  Future<encrypt.Encrypted> encryptMobileNumber() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encryptedString = encrypt.Encrypter(encrypt.RSA(
      publicKey: publicKey,
    ));
    if (widget.isFromMobile!) {
      final encrypted = encryptedString.encrypt(widget.mobileNumber!);
      return encrypted;
    } else {
      final encrypted = encryptedString.encrypt(widget.emailId!);
      return encrypted;
    }
  }

  postGenerateEmailOtpAPI() async {
    showProgressIndicator();
    GenerateOtpModel generateOtpModel = GenerateOtpModel();
    generateOtpModel.authMode = "MOBILE_OTP";
    try {
      encrypt.Encrypted encrypted = await encryptMobileNumber();
      generateOtpModel.value = encrypted.base64;
    } catch (error) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
      return;
    }

    log("${jsonEncode(generateOtpModel)}", name: "GENERATE OTP MODEL");

    await _generateOtpController.postGenerateOtpDetails(
        generateOtpDetails: generateOtpModel);

    if (_generateOtpController.generateOtpAckDetails != null &&
        _generateOtpController.generateOtpAckDetails != "") {
      hideProgressIndicator();

      String? sessionId =
          _generateOtpController.generateOtpAckDetails["sessionId"];
      log("$sessionId");

      if (sessionId != null && sessionId.isNotEmpty) {
        startTimer();
      } else {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else if (_generateOtpController.errorString != '') {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }
  }

  postGenerateMobileOtpAPI() async {
    showProgressIndicator();
    _generateOtpController.refresh();
    GenerateOtpModel generateOtpModel = GenerateOtpModel();
    generateOtpModel.authMode = "MOBILE_OTP";
    try {
      encrypt.Encrypted encrypted = await encryptMobileNumber();
      generateOtpModel.value = encrypted.base64;
    } catch (error) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
      return;
    }

    log("${jsonEncode(generateOtpModel)}", name: "GENERATE OTP MODEL");

    await _generateOtpController.postGenerateOtpDetails(
        generateOtpDetails: generateOtpModel);

    if (_generateOtpController.generateOtpAckDetails != null &&
        _generateOtpController.generateOtpAckDetails != "") {
      hideProgressIndicator();

      String? sessionId =
          _generateOtpController.generateOtpAckDetails["sessionId"];
      log("$sessionId");

      if (sessionId != null && sessionId.isNotEmpty) {
        startTimer();
      } else {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else if (_generateOtpController.errorString != '') {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }
  }
}

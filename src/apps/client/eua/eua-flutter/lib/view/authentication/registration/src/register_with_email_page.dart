import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_otp_verification.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/view/view.dart';

import '../../../../common/common.dart';
import '../../../../controller/login/login.dart';
import '../../../../model/common/common.dart';
import '../../../../widgets/widgets.dart';

class RegisterWithEmailPage extends StatefulWidget {
  const RegisterWithEmailPage({Key? key}) : super(key: key);

  @override
  State<RegisterWithEmailPage> createState() => _RegisterWithEmailPageState();
}

class _RegisterWithEmailPageState extends State<RegisterWithEmailPage> {
  ///CONTROLLERS
  GenerateOtpController _generateOtpController = GenerateOtpController();

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool? _isChecked = false;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final emailTextFieldController = TextEditingController();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  ///DATA VARIABLES
  bool isLoading = false;
  bool _isValidate = false;

  ///ENCRYPT MOBILE NUMBER
  Future<encrypt.Encrypted> encryptMobileNumber() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encryptedString = encrypt.Encrypter(encrypt.RSA(
      publicKey: publicKey,
    ));
    final encrypted = encryptedString.encrypt(emailTextFieldController.text);
    return encrypted;
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  ///GENERATE OTP API
  postGenerateOtpAPI() async {
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
        Get.to(() => RegistrationOTPVerificationPage(
              emailId: emailTextFieldController.text,
              sessionId: sessionId,
              isFromMobile: false,
            ));
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
          AppStrings().registrationWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  navigateToOtpVerificationPage() {
    Get.to(RegistrationOTPVerificationPage(
      emailId: emailTextFieldController.text,
      sessionId: "",
      isFromMobile: false,
    ));
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   AppStrings().enterEmail,
          //   style: AppTextStyle.textMediumStyle(
          //       color: AppColors.mobileNumberTextColor, fontSize: 14),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // Container(
          //   height: 50,
          //   width: width * 0.9,
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: AppColors.doctorExperienceColor,
          //     ),
          //   ),
          //   child: TextFormField(
          //     key: _emailFieldKey,
          //     autovalidateMode: _isValidate
          //         ? AutovalidateMode.always
          //         : AutovalidateMode.disabled,
          //     controller: emailTextFieldController,
          //     decoration: InputDecoration(
          //       contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          //       border: InputBorder.none,
          //       hintText: AppStrings().hintEmail,
          //       hintStyle: AppTextStyle.textLightStyle(
          //           color: AppColors.testColor, fontSize: 14),
          //     ),
          //     validator: (input) => (input ?? "").isValidEmail()
          //         ? null
          //         : "Please enter valid email",
          //   ),
          // ),
          textFieldWithOutsideLabel(
            key: _emailFieldKey,
            label: AppStrings().enterEmail,
            controller: emailTextFieldController,
            validator: emailTextFieldController.text.isNotEmpty
                ? (input) => (input ?? "").isValidEmail()
                    ? null
                    : AppStrings().invalidEmailError
                : null,
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: isLoading
                  ? () {}
                  : () {
                      if (emailTextFieldController.text.isNotEmpty) {
                        if (_emailFieldKey.currentState!.validate()) {
                          setState(() {
                            _isValidate = true;
                          });
                          postGenerateOtpAPI();
                        }
                      } else {
                        DialogHelper.showErrorDialog(
                            description: AppStrings().enterEmailIdMsg);
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

  textFieldWithOutsideLabel({
    Key? key,
    required String label,
    bool? isRequired,
    required TextEditingController controller,
    String? inputType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyle.textBoldStyle(
                color: AppColors.black,
                fontSize: 14,
              ),
            ),
            // isRequired != null && isRequired
            //     ? Text(
            //         "*",
            //         style: AppTextStyle.textBoldStyle(
            //           color: AppColors.amountColor,
            //           fontSize: 14,
            //         ),
            //       )
            //     : Text(
            //         " (optional)",
            //         style: AppTextStyle.textBoldStyle(
            //           color: AppColors.black,
            //           fontSize: 14,
            //         ),
            //       ),
          ],
        ),
        Spacing(size: 5, isWidth: false),
        TextFormField(
          key: key,
          controller: controller,
          maxLength: maxLength != null ? maxLength : null,
          inputFormatters: inputType != null && inputType.isNotEmpty
              ? [
                  inputType == "text"
                      ? FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                      : inputType == "number"
                          ? FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                          : FilteringTextInputFormatter.allow(
                              RegExp("[0-9a-zA-Z]")),
                ]
              : [],
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

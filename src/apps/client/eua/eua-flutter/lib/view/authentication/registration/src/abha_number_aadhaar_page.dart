import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/controller/registration/registration.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/utils/src/custom_input_formatters.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt_io.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/abha_number_user_details_page.dart';

import '../../../../constants/constants.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/src/shared_preferences.dart';
import '../../../../widgets/widgets.dart';
import '../../../view.dart';

class AbhaNumberAadhaarPage extends StatefulWidget {
  @override
  State<AbhaNumberAadhaarPage> createState() => _AbhaNumberAadhaarPageState();
}

class _AbhaNumberAadhaarPageState extends State<AbhaNumberAadhaarPage> {
  ///CONTROLLERS
  TextEditingController _aadhaarTextController = TextEditingController();
  AadharRegistrationController _aadharRegistrationController =
      AadharRegistrationController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///DATA VARIABLES
  bool isLoading = false;
  bool _isValidate = false;
  GlobalKey<FormFieldState> _aadhaarFieldKey = GlobalKey<FormFieldState>();
  String? _accessToken;

  @override
  void initState() {
    super.initState();

    getSharedPrefs();
  }

  getSharedPrefs() async {
    _accessToken = await SharedPreferencesHelper.getRegAccessToken();
  }

  ///ENCRYPT AADHAAR NUMBER
  Future<encrypt.Encrypted> encryptAadhaarNumber() async {
    var pubKey =
        await rootBundle.load("assets/keys/publicKeyForRegistration.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/publicKeyForRegistration.pem');
    final publicKey = await parseKeyFromFile<RSAPublicKey>(
        File('$dir/publicKeyForRegistration.pem').path);
    final encryptedString = encrypt.Encrypter(encrypt.RSA(
      publicKey: publicKey,
    ));
    final encrypted = encryptedString
        .encrypt(_aadhaarTextController.text.replaceAll(" ", ""));
    return encrypted;
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  ///GENERATE AADHAAR OTP API
  postGenerateAadhaarOtpAPI() async {
    showProgressIndicator();
    _aadharRegistrationController.refresh();

    if (_aadhaarTextController.text.isEmpty) {
      DialogHelper.showErrorDialog(description: "Please enter aadhaar number.");
      return;
    }

    AadhaarGenerateOtpModel aadhaarGenerateOtpModel = AadhaarGenerateOtpModel();
    try {
      encrypt.Encrypted encrypted = await encryptAadhaarNumber();
      aadhaarGenerateOtpModel.aadhaar = encrypted.base64;
    } catch (error) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
      return;
    }

    aadhaarGenerateOtpModel.consent = true;

    log("${jsonEncode(aadhaarGenerateOtpModel)}");

    await _aadharRegistrationController.postGenerateAadhaarOtpDetails(
        aadhaarDetails: aadhaarGenerateOtpModel, authToken: _accessToken ?? "");

    if (_aadharRegistrationController.aadhaarOtpDetails != null &&
        _aadharRegistrationController.aadhaarOtpDetails != "") {
      hideProgressIndicator();
      if (_aadharRegistrationController.aadhaarOtpDetails["txnId"] != null &&
          _aadharRegistrationController.aadhaarOtpDetails["txnId"] != "") {
        String sessionId =
            _aadharRegistrationController.aadhaarOtpDetails["txnId"];
        Get.to(() => RegistrationOTPVerificationPage(
              mobileNumber: "",
              sessionId: sessionId,
              isFromMobile: true,
            ));
      } else {
        DialogHelper.showErrorDialog(
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else if (_aadharRegistrationController.errorString != "") {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
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
          // AppStrings().registrationWithEmail,
          "Register with Aadhar Number",
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: Container(
        width: width,
        height: height,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            textFieldWithOutsideLabel(
              key: _aadhaarFieldKey,
              controller: _aadhaarTextController,
              label: "Enter your aadhaar number",
              inputType: "number",
              maxLength: 14,
              validator: _aadhaarTextController.text.isNotEmpty
                  ? (input) => (input ?? "").isValidAadhaarNumber()
                      ? null
                      : "Please enter valid aadhaar number"
                  : null,
            ),
            Spacing(size: 30, isWidth: false),
            Center(
              child: GestureDetector(
                onTap: isLoading
                    ? () {}
                    : () {
                        if (_aadhaarFieldKey.currentState!.validate()) {
                          setState(() {
                            _isValidate = true;
                          });
                          postGenerateAadhaarOtpAPI();
                        }
                        // Get.to(() => AbhaNumberUserDetailsPage());
                      },
                child: Container(
                  padding: EdgeInsets.all(15),
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
          autovalidateMode:
              _isValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          maxLength: maxLength != null ? maxLength : null,
          inputFormatters: inputType != null && inputType.isNotEmpty
              ? [
                  inputType == "text"
                      ? FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                      : inputType == "number"
                          ? FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                          : FilteringTextInputFormatter.allow(
                              RegExp("[0-9a-zA-Z]")),
                  CustomInputFormatters(),
                ]
              : [],
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            counterText: "",
          ),
        ),
      ],
    );
  }
}

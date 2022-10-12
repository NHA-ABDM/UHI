import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/model/common/common.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/register_with_details.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_otp_verification.dart';

import '../../../../common/common.dart';

class RegisterWithMobile extends StatefulWidget {
  const RegisterWithMobile({Key? key}) : super(key: key);

  @override
  State<RegisterWithMobile> createState() => _RegisterWithMobileState();
}

class _RegisterWithMobileState extends State<RegisterWithMobile> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final mobileNumberTextEditingController = TextEditingController();
  GenerateOtpController _generateOtpController = GenerateOtpController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///DATA VARIABLES
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  bool isLoading = false;

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
    final encrypted =
        encryptedString.encrypt(mobileNumberTextEditingController.text);
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
        Get.to(() => RegistrationOTPVerificationPage(
              mobileNumber: mobileNumberTextEditingController.text,
              sessionId: sessionId,
              isFromMobile: true,
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
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().registrationWithMobileNumber,
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
      child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterMobileNumber,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 68,
            width: width * 0.89,
            child: IntlPhoneField(
              controller: mobileNumberTextEditingController,
              textAlignVertical: TextAlignVertical.center,
              flagsButtonMargin: EdgeInsets.only(left: 8),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(top: 5),
                border:
                    OutlineInputBorder(borderSide: BorderSide(), gapPadding: 0),
                counterText: "",
              ),
              dropdownIconPosition: IconPosition.trailing,
              initialCountryCode: 'IN',
              countries: ['IN'],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]"))
              ],
              onChanged: (phone) {},
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: isLoading
                  ? () {}
                  : () {
                      //Get.to(const RegistrationWithAllDetails());
                      // navigateToOtpVerificationPage();
                      if (mobileNumberTextEditingController.text.length > 0) {
                        if (mobileNumberTextEditingController.text.length ==
                            10) {
                          postGenerateOtpAPI();
                        } else {
                          DialogHelper.showErrorDialog(
                              title: AppStrings().errorString,
                              description:
                                  AppStrings().invalidMobileNumberError);
                        }
                      } else {
                        DialogHelper.showErrorDialog(
                            title: AppStrings().errorString,
                            description: AppStrings().emptyMobileNumberError);
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
}

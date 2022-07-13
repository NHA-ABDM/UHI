import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/login_verify_controller.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/authentication.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/register_with_details.dart';

class RegistrationOTPVerificationPage extends StatefulWidget {
  String? mobileNumber;
  String? emailId;
  bool? isFromMobile;
  RegistrationOTPVerificationPage(
      {this.mobileNumber, this.emailId, @required this.isFromMobile});

  @override
  State<RegistrationOTPVerificationPage> createState() =>
      _RegistrationOTPVerificationPageState();
}

class _RegistrationOTPVerificationPageState
    extends State<RegistrationOTPVerificationPage> {
  ///CONTROLLERS
  final loginVerifyController = Get.put(LoginVerifyController());

  ///SIZE
  var width;
  var height;
  var isPortrait;
  String? mobileNumber;
  String? otpValue;
  List<String>? mappedPhrAddress = [];

  ///DATA VARIABLES
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  void showProgressDialog() {
    setState(() {
      _loading = true;
    });
  }

  void hideProgressDialog() {
    setState(() {
      _loading = false;
    });
  }

  @override
  dispose() {
    loginVerifyController.dispose();
    super.dispose();
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<Encrypted> encryptMobileNumber() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encrypter = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encrypter.encrypt(otpValue!);
    return encrypted;
  }

  callApi() async {
    loginVerifyController.refresh();
    String? transactionId = await SharedPreferencesHelper.getTransactionId();
    LoginVerifyRequestModel loginVerifyRequestModel = LoginVerifyRequestModel();
    Encrypted encrypted = await encryptMobileNumber();
    loginVerifyRequestModel.authCode = encrypted.base64;
    loginVerifyRequestModel.requesterId = "phr_001";
    loginVerifyRequestModel.transactionId = transactionId;

    await loginVerifyController.postVerify(
        loginDetails: loginVerifyRequestModel);
    hideProgressDialog();
    mappedPhrAddress =
        loginVerifyController.loginVerifyResponseModel?.mappedPhrAddress!;
    loginVerifyController.loginVerifyResponseModel != null
        ? navigateToLinkAccountPage()
        : null;
  }

  navigateToLinkAccountPage() {
    SharedPreferencesHelper.setTransactionId(
        loginVerifyController.loginVerifyResponseModel?.transactionId!);
    Get.to(ABHAAddressSelectionPage(mappedPhrAddress: mappedPhrAddress!));
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
          widget.isFromMobile == true
              ? AppStrings().loginWithMobileNumber
              : AppStrings().loginWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: ModalProgressHUD(
        child: buildWidgets(),
        inAsyncCall: _loading,
        dismissible: false,
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: AppColors.DARK_PURPLE,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
        ),
      ),
    );
  }

  buildWidgets() {
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
                        keyboardType: TextInputType.number,
                        onCompleted: (v) {
                          debugPrint("Completed:$v");
                          otpValue = v;
                        },
                        onChanged: (value) {},
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     GestureDetector(
          //       onTap: () {},
          //       child: Text(
          //         AppStrings().resendOTP,
          //         style: AppTextStyle.resendOTPText,
          //       ),
          //     ),
          //     Text(
          //       AppStrings().expiresIn + '44 sec',
          //       style: AppTextStyle.textNormalStyle(
          //           color: AppColors.amountColor, fontSize: 14),
          //     ),
          //   ],
          // ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                // showProgressDialog();
                // callApi();
                Get.to(const RegistrationWithAllDetails());
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
                  child: Text(
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

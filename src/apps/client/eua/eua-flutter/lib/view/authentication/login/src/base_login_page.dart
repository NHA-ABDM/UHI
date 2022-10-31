import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/controller/login/src/access_token_controller.dart';
import 'package:uhi_flutter_app/controller/registration/registration.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/authentication.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/prominent_disclosure.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/web_view_registration.dart';
import 'package:uhi_flutter_app/view/discovery/discovery.dart';
import 'package:uhi_flutter_app/view/group-consultation/src/book_group_teleconsultation_page.dart';

import '../../../../constants/constants.dart';

import '../../../view.dart';

import '../../../../model/response/src/access_token_response_model.dart';
import '../../../../utils/utils.dart';

class BaseLoginPage extends StatefulWidget {
  const BaseLoginPage();

  @override
  State<BaseLoginPage> createState() => _BaseLoginPageState();
}

class _BaseLoginPageState extends State<BaseLoginPage> {
  ///CONTROLLERS
  final mobileNumberTextEditingController = TextEditingController();
  final loginInitController = Get.put(LoginInitController());
  //final AccessTokenController commonController = Get.find();
  final accessTokenController = Get.put(AccessTokenController());
  AadharRegistrationController _aadharRegistrationController =
      AadharRegistrationController();

  ///DATA VARIABLES
  Future<AccessTokenResponseModel?>? futureOfAccessTokenResponse;
  AccessTokenResponseModel? _accessTokenResponse;

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  String? encryptedMobileNumber;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      futureOfAccessTokenResponse = getAccessTokenResponse();
    }
  }

  Future<AccessTokenResponseModel?>? getAccessTokenResponse() async {
    AccessTokenResponseModel? accessTokenResponseModel =
        AccessTokenResponseModel();

    await _aadharRegistrationController.postSessionToken();

    if (_aadharRegistrationController.sessionTokenDetails != null &&
        _aadharRegistrationController.sessionTokenDetails != "") {
      if (_aadharRegistrationController.sessionTokenDetails?.accessToken !=
              null &&
          _aadharRegistrationController.sessionTokenDetails?.accessToken !=
              "") {
        await callAccessTokenApi();

        // await _aadharRegistrationController.getAuthCert();

        SharedPreferencesHelper.setRegAccessToken(
            "${_aadharRegistrationController.sessionTokenDetails?.accessToken}");

        SharedPreferencesHelper.setRegRefreshToken(
            "${_aadharRegistrationController.sessionTokenDetails?.refreshToken}");

        accessTokenResponseModel =
            _aadharRegistrationController.sessionTokenDetails!;
      } else {
        DialogHelper.showErrorDialog(
            description: AppStrings().somethingWentWrongErrorMsg);
        return null;
      }
    } else if (_aadharRegistrationController.errorString != "") {
      return null;
    } else {
      DialogHelper.showErrorDialog(
          description: AppStrings().somethingWentWrongErrorMsg);
      return null;
    }

    return accessTokenResponseModel;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureOfAccessTokenResponse = getAccessTokenResponse();
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
    final encryptedString = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted =
        encryptedString.encrypt(mobileNumberTextEditingController.text);
    return encrypted;
  }

  callAccessTokenApi() async {
    accessTokenController.refresh();
    await accessTokenController.postAccessTokenAPI();
  }

  ///APIs
  callApi() async {
    loginInitController.refresh();
    LoginInitRequestModel initRequestModel = LoginInitRequestModel();
    initRequestModel.authMode = "MOBILE_OTP";
    initRequestModel.purpose = "CM_ACCESS";
    LoginInitRequester initRequester = LoginInitRequester();
    initRequester.id = "phr_001";
    initRequester.type = "PHR";
    initRequestModel.requester = initRequester;
    try {
      Encrypted encrypted = await encryptMobileNumber();
      initRequestModel.value = encrypted.base64;
    } catch (error) {
      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
      hideProgressDialog();
    }
    await loginInitController.postInitAuth(loginDetails: initRequestModel);
    hideProgressDialog();
    loginInitController.loginInitResponseModel != null
        ? navigateToOtpVerificationPage(
            loginInitController.loginInitResponseModel!.transactionId)
        : null;
  }

  navigateToOtpVerificationPage(String? transactionId) {
    Get.to(OTPVerificationPage(
      mobileNumber: mobileNumberTextEditingController.text,
      isFromMobile: true,
      transactionId: transactionId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().btnLogin,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: FutureBuilder(
        future: futureOfAccessTokenResponse,
        builder: (context, loadingData) {
          switch (loadingData.connectionState) {
            case ConnectionState.waiting:
              return CommonLoadingIndicator();

            case ConnectionState.active:
              return Text(AppStrings().loadingData);

            case ConnectionState.done:
              return loadingData.data != null ? buildWidgets() : buildWidgets();
            default:
              return loadingData.data != null ? buildWidgets() : buildWidgets();
          }
        },
      ),
      // body: ModalProgressHUD(
      //   child: buildWidgets(),
      //   inAsyncCall: _loading,
      //   dismissible: false,
      //   progressIndicator: const CircularProgressIndicator(
      //     backgroundColor: AppColors.DARK_PURPLE,
      //     valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
      //   ),
      // ),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: ListView(
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
              keyboardType: TextInputType.number,
              invalidNumberMessage: AppStrings().invalidMobileNumberError,
              controller: mobileNumberTextEditingController,
              textAlignVertical: TextAlignVertical.center,
              flagsButtonMargin: EdgeInsets.only(left: 8),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(top: 5),
                border:
                    OutlineInputBorder(borderSide: BorderSide(), gapPadding: 0),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]"))
              ],
              dropdownIconPosition: IconPosition.trailing,
              initialCountryCode: 'IN',
              countries: ['IN'],
              onChanged: (phone) {},
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              if (mobileNumberTextEditingController.text.length > 0) {
                if (mobileNumberTextEditingController.text.length == 10) {
                  showProgressDialog();
                  callApi();
                } else {
                  DialogHelper.showErrorDialog(
                      title: AppStrings().errorString,
                      description: AppStrings().invalidMobileNumberError);
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
                child: Text(
                  AppStrings().btnLogin,
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              AppStrings().orText,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // GestureDetector(
          //   onTap: () {
          //     Get.to(const LoginWithAbhaAddressPage());
          //   },
          //   child: Container(
          //     height: 50,
          //     width: width * 0.89,
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: AppColors.tileColors,
          //       ),
          //       borderRadius: const BorderRadius.all(
          //         Radius.circular(10),
          //       ),
          //     ),
          //     child: Center(
          //       child: Text(
          //         AppStrings().loginWithABHAAddress,
          //         style: AppTextStyle.textMediumStyle(
          //             color: AppColors.tileColors, fontSize: 16),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          GestureDetector(
            onTap: () {
              Get.to(LoginWithEmailPage());
            },
            child: Container(
              height: 50,
              width: width * 0.89,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.tileColors,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings().loginWithEmail,
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.tileColors, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 50,
              width: width * 0.89,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.tileColors,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  "Login With Abha Address",
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.tileColors, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // GestureDetector(
          //   onTap: () {
          //     Get.to(const LoginWithAbhaNumberPage());
          //   },
          //   child: Container(
          //     height: 50,
          //     width: width * 0.89,
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: AppColors.tileColors,
          //       ),
          //       borderRadius: const BorderRadius.all(
          //         Radius.circular(10),
          //       ),
          //     ),
          //     child: Center(
          //       child: Text(
          //         AppStrings().loginWithABHANumber,
          //         style: AppTextStyle.textMediumStyle(
          //             color: AppColors.tileColors, fontSize: 16),
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 40,
          ),
          // Center(
          //   child: SizedBox(
          //     height: 125,
          //     width: 155,
          //     child: Center(
          //       child: Image.asset(
          //         'assets/images/face_id_icon.png',
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          GestureDetector(
            onTap: () {
              //Get.to(() => WebViewRegistration());
              //Get.to(ProminentDisclosures());
              Get.to(RegistrationPage());
              //Get.to(UserDetailsFormPage(sessionId: ""));
            },
            child: Center(
              child: Text(
                AppStrings().doNotHaveAccountRegister,
                textAlign: TextAlign.center,
                style: AppTextStyle.textMediumStyle(
                    color: AppColors.tileColors, fontSize: 16),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 40,
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     await context.setLocale(context.supportedLocales[1]);
          //     Get.updateLocale(context.supportedLocales[1]);
          //   },
          //   child: Center(
          //     child: Text(
          //       "Hindi",
          //       textAlign: TextAlign.center,
          //       style: AppTextStyle.textMediumStyle(
          //           color: AppColors.tileColors, fontSize: 16),
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 40,
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     await context.setLocale(context.supportedLocales[0]);
          //     Get.updateLocale(context.supportedLocales[0]);
          //   },
          //   child: Center(
          //     child: Text(
          //       'English',
          //       textAlign: TextAlign.center,
          //       style: AppTextStyle.textMediumStyle(
          //           color: AppColors.tileColors, fontSize: 16),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

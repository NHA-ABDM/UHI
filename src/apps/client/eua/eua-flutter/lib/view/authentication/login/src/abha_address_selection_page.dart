import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uhi_flutter_app/controller/login/src/login_confirm_controller.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/view.dart';

import '../../../../controller/login/src/post_fcm_token_controller.dart';
import '../../../../model/common/src/fcm_token_model.dart';

class ABHAAddressSelectionPage extends StatefulWidget {
  List<String> mappedPhrAddress;
  String? fcmToken;
  String? transactionId;

  ABHAAddressSelectionPage(
      {Key? key,
      required this.mappedPhrAddress,
      this.fcmToken,
      this.transactionId})
      : super(key: key);

  @override
  State<ABHAAddressSelectionPage> createState() =>
      _ABHAAddressSelectionPageState();
}

class _ABHAAddressSelectionPageState extends State<ABHAAddressSelectionPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final loginConfirmController = Get.put(LoginConfirmController());
  final postFcmTokenController = Get.put(PostFCMTokenController());

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;

  String _selectedOption = '';

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

  ///APIs
  callApi(String selectedAbhaAddress) async {
    loginConfirmController.refresh();
    LoginConfirmRequestModel confirmRequestModel = LoginConfirmRequestModel();
    confirmRequestModel.patientId = selectedAbhaAddress;
    confirmRequestModel.requesterId = "phr_001";
    confirmRequestModel.transactionId = widget.transactionId;

    await loginConfirmController.postConfirm(loginDetails: confirmRequestModel);
    hideProgressDialog();
    loginConfirmController.loginConfirmResponseModel != null
        ? navigateToHomePage(selectedAbhaAddress)
        : null;
  }

  navigateToHomePage(String selectedAbhaAddress) {
    postFcmToken(selectedAbhaAddress);
    SharedPreferencesHelper.setAutoLoginFlag(true);
    Get.offAll(HomePage());
  }

  ///SAVE FCM TOKEN API
  postFcmToken(String? selectedAbhaAddress) async {
    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = selectedAbhaAddress;
    fcmTokenModel.token = widget.fcmToken;
    fcmTokenModel.deviceId = await _getId();
    fcmTokenModel.type = Platform.operatingSystem;

    log("${json.encode(fcmTokenModel)}", name: "FCM TOKEN MODEL");

    await postFcmTokenController.postFCMTokenDetails(
        fcmTokenDetails: fcmTokenModel);

    if (postFcmTokenController.fcmTokenAckDetails["status"] == 200) {
      SharedPreferencesHelper.setFCMToken(widget.fcmToken);
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
    return null;
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
          "Login",
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Select the ABHA address through which you\nwish to login",
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: width,
            height: height * 0.75,
            color: AppColors.backgroundWhiteColorFBFCFF,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 20,
                );
              },
              itemCount: widget.mappedPhrAddress.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 55,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.doctorExperienceColor,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: ListTileTheme(
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Container(
                              height: 55,
                              child: Center(
                                child: RadioListTile<String>(
                                  value: widget.mappedPhrAddress[index],
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      showProgressDialog();
                                      _selectedOption = value!;
                                      callApi(widget.mappedPhrAddress[index]);
                                    });
                                  },
                                  title: Transform.translate(
                                    offset: const Offset(-20, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child:
                                          Text(widget.mappedPhrAddress[index]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // const SizedBox(
          //   height: 30,
          // ),
          // GestureDetector(
          //   onTap: () {
          //     Get.to(const HomePage());
          //   },
          //   child: Container(
          //     height: 50,
          //     width: width * 0.89,
          //     decoration: const BoxDecoration(
          //       color: AppColors.tileColors,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(10),
          //       ),
          //     ),
          //     child: Center(
          //       child: Text(
          //         "Login",
          //         style: AppTextStyle.textMediumStyle(
          //             color: AppColors.white, fontSize: 16),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/home_screen_controller.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/theme/src/app_text_style.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/base_login_page.dart';

import '../../../controller/login/src/logout_controller.dart';
import '../../../model/model.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _loading = false;
  var width;
  var height;
  var isPortrait;
  bool imageNull = false;
  late var decodedBytes;
  String? userName;
  String? imageB64;
  final homeScreenController = Get.put(HomeScreenController());
  final postLogoutController = Get.put(LogoutController());

  String? mobileNumber;
  String? emailID;
  String? gender;
  String? dateOfBirth;
  late File imgFile;
  String? userData;
  String? ABHANumer;
  String? abhaAddress;
  //final imgPicker = ImagePicker();

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
  void initState() {
    super.initState();
    showProgressDialog();
    callUserDataAPI();
  }

  callUserDataAPI() async {
    await SharedPreferencesHelper.getUserData().then((value) => setState(() {
          setState(() {
            userData = value;
          });
        }));
    if (userData == null) {
      showProgressDialog();
      await getUserProfileData();
    } else {
      hideProgressDialog();
      GetUserDetailsResponse? getUserDetailsResponseModel =
          GetUserDetailsResponse.fromJson(jsonDecode(userData!));

      log("getUserDetailsResponseModel:${json.encode(getUserDetailsResponseModel)}");

      abhaAddress = getUserDetailsResponseModel.id!;
      SharedPreferencesHelper.setABhaAddress(abhaAddress!);
      userData = jsonEncode(getUserDetailsResponseModel);

      String firstName = getUserDetailsResponseModel.name!.first!;
      String lastName = getUserDetailsResponseModel.name!.last!;
      userName = firstName + " " + lastName;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(AppStrings().chatUserName, userName!);

      String profilePhoto = getUserDetailsResponseModel.profilePhoto ?? "";
      mobileNumber = getUserDetailsResponseModel.mobile!;
      emailID = getUserDetailsResponseModel.email!;
      gender = getUserDetailsResponseModel.gender;

      int day;
      int month;
      int year;
      day = getUserDetailsResponseModel.dateOfBirth!.date!;
      month = getUserDetailsResponseModel.dateOfBirth!.month!;
      year = getUserDetailsResponseModel.dateOfBirth!.year!;

      dateOfBirth = "$day/" + "$month/" + "$year";

      if (gender == "F") {
        gender = "Female";
      } else {
        gender = "Male";
      }
      if (profilePhoto.isNotEmpty) {
        decodedBytes = base64Decode(profilePhoto);
        imageNull = true;
      } else {
        imageNull = false;
      }

      ABHANumer = getUserDetailsResponseModel.healthId;

      if (profilePhoto.isNotEmpty && profilePhoto.length > 50) {
        decodedBytes = base64Decode(profilePhoto);
        imageNull = true;
      } else {
        imageNull = false;
      }
    }
  }

  getUserProfileData() async {
    homeScreenController.refresh();
    await homeScreenController.getUserDetailsAPI();
    hideProgressDialog();
    if (homeScreenController.getUserDetailsResponseModel != null) {
      String firstName =
          homeScreenController.getUserDetailsResponseModel!.name!.first!;
      String lastName =
          homeScreenController.getUserDetailsResponseModel!.name!.last!;
      userName = firstName + " " + lastName;

      String profilePhoto =
          homeScreenController.getUserDetailsResponseModel?.profilePhoto ?? "";
      mobileNumber = homeScreenController.getUserDetailsResponseModel!.mobile!;
      emailID = homeScreenController.getUserDetailsResponseModel!.email!;
      gender = homeScreenController.getUserDetailsResponseModel!.gender;

      int day;
      int month;
      int year;
      day =
          homeScreenController.getUserDetailsResponseModel!.dateOfBirth!.date!;
      month =
          homeScreenController.getUserDetailsResponseModel!.dateOfBirth!.month!;
      year =
          homeScreenController.getUserDetailsResponseModel!.dateOfBirth!.year!;

      dateOfBirth = "$day/" + "$month/" + "$year";

      if (gender == "F") {
        gender = "Female";
      } else {
        gender = "Male";
      }
      if (profilePhoto.isNotEmpty) {
        decodedBytes = base64Decode(profilePhoto);
        imageNull = true;
      } else {
        imageNull = false;
      }
    }
    if (homeScreenController.errorString.isNotEmpty) {
      log("${homeScreenController.errorString}", name: "ERROR");
      if (homeScreenController.errorString == "Token verification failed") {
        DialogHelper.showErrorDialog(
          title: AppStrings().infoString,
          description: AppStrings().sessionExpireError,
          onTap: logout,
        );
      }
    }
  }

  ///LOGOUT USER API
  logout() async {
    showProgressDialog();
    Get.back();

    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = abhaAddress;
    fcmTokenModel.deviceId = await _getId();

    log("${json.encode(fcmTokenModel)}", name: "LOGOUT MODEL");

    await postLogoutController.postLogoutDetails(logoutDetails: fcmTokenModel);

    if (postLogoutController.logoutResponse["status"] == 200) {
      hideProgressDialog();
      SharedPreferencesHelper.setAutoLoginFlag(false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      Get.offAll(() => BaseLoginPage());
    } else {
      hideProgressDialog();
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

  // logout() {
  //   Get.back();
  //   SharedPreferencesHelper.setAutoLoginFlag(false);
  //   Get.offAll(() => BaseLoginPage());
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      dismissible: false,
      progressIndicator: const CircularProgressIndicator(
        backgroundColor: AppColors.DARK_PURPLE,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
      ),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              AppStrings().userProfile,
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.black, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: _buildWidgets()),
    );
  }

  Future<void> showOptionsDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Options"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        openCamera();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        openGallery();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void openCamera() async {
    // var imgCamera =
    //     await imgPicker.getImage(source: ImageSource.camera, imageQuality: 50);
    // if (imgCamera != null) {
    //   imgFile = File(imgCamera.path);
    //   List<int> imageBytes = imgFile.readAsBytesSync();
    //   imageB64 = base64Encode(imageBytes);
    //   decodedBytes = base64Decode(imageB64!);
    //   imageNull = true;
    // }
    // setState(() {});
    Navigator.of(context).pop();
  }

  void openGallery() async {
    // var imgGallery =
    //     await imgPicker.getImage(source: ImageSource.gallery, imageQuality: 50);
    // if (imgGallery != null) {
    //   imgFile = File(imgGallery.path);

    //   List<int> imageBytes = imgFile.readAsBytesSync();
    //   imageB64 = base64Encode(imageBytes);
    //   decodedBytes = base64Decode(imageB64!);
    //   imageNull = true;
    // }
    // setState(() {});
    Navigator.of(context).pop();
  }

  _buildWidgets() {
    return Container(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName != null ? userName! : "",
                  style: AppTextStyle.textBoldStyle(
                      color: AppColors.appointmentConfirmTextColor,
                      fontSize: 18),
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: imageNull == false
                          ? AssetImage('assets/images/account.png')
                          : Image.memory(decodedBytes).image,
                    ),
                    // Positioned(
                    //   top: 5,
                    //   right: -10,
                    //   child: CircleAvatar(
                    //     backgroundColor: AppColors.dividerColor,
                    //     radius: 16,
                    //     child: IconButton(
                    //       iconSize: 18,
                    //       icon: Icon(Icons.edit),
                    //       color: AppColors
                    //           .appointmentConfirmDoctorActionsEnabledTextColor,
                    //       onPressed: () {
                    //         showOptionsDialog(context);
                    //       },
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: SizedBox(
              height: 1,
              width: MediaQuery.of(context).size.width,
              child: Container(color: AppColors.DARK_PURPLE.withOpacity(0.05)),
            ),
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().mobileNumber,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        mobileNumber != null ? mobileNumber! : "",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().emailId,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        emailID != null ? emailID! : "",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().genderHint,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        gender != null ? gender! : "",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().dateOfBirth,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        dateOfBirth != null ? dateOfBirth! : "",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().bloodGroup,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        "-",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().height,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        "-",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings().weight,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.doctorNameColor, fontSize: 16),
                          ),
                          // Icon(
                          //   Icons.edit,
                          //   color: AppColors.darkGrey323232,
                          //   size: 24,
                          // ),
                        ],
                      ),
                      Text(
                        "-",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.doctorNameColor, fontSize: 16),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

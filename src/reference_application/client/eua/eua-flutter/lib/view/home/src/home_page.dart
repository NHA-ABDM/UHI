import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/home_screen_controller.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/theme/src/app_text_style.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/home/src/change_language_page.dart';
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../controller/login/src/post_fcm_token_controller.dart';
import '../../../model/common/src/fcm_token_model.dart';
import '../../discovery/src/book_a_teleconsultation_page.dart';

class HomePage extends StatefulWidget {
  String? fcmToken;
  HomePage({Key? key, this.fcmToken}) : super(key: key);

  @override
  State<HomePage> createState() => _DiscoverServicesPageState();
}

class _DiscoverServicesPageState extends State<HomePage> {
  ///CONTROLLERS
  final postFcmTokenController = Get.put(PostFCMTokenController());

  var height;
  var isPortrait;
  final homeScreenController = Get.put(HomeScreenController());
  bool _loading = false;
  String? abhaAddress;
  List<UpcomingAppointmentResponseModal?> upcomingAppointmentList = [];
  List<UpcomingAppointmentResponseModal?> historyAppointmentList = [];
  bool imageNull = false;
  late var decodedBytes;
  String? userName;
  String? imageB64;
  String? ABHANumer;
  String? profilePhoto;
  String? userData;
  BookingConfirmResponseModel bookOnConfirmHistoryResponseModel =
      BookingConfirmResponseModel();

  BookingConfirmResponseModel bookOnConfirmUpcomingResponseModel =
      BookingConfirmResponseModel();

  GetUserDetailsResponse? getUserDetailsResponseModel;

  ///SIZE
  var width;

  // void showProgressDialog() {
  //   setState(() {
  //     _loading = true;
  //   });
  // }

  // void hideProgressDialog() {
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   showProgressDialog();
  //   getUserProfileData();
  // }

  // getUserProfileData() async {
  //   homeScreenController.refresh();
  //   await homeScreenController.getUserDetailsAPI();
  //   hideProgressDialog();
  //   if (homeScreenController.getUserDetailsResponseModel != null) {
  //     abhaAddress = homeScreenController.getUserDetailsResponseModel!.id!;
  //     SharedPreferencesHelper.setABhaAddress(abhaAddress!);
  //     String userData =
  //         jsonEncode(homeScreenController.getUserDetailsResponseModel);

  //     String firstName =
  //         homeScreenController.getUserDetailsResponseModel!.name!.first!;
  //     String lastName =
  //         homeScreenController.getUserDetailsResponseModel!.name!.last!;
  //     userName = firstName + " " + lastName;
  //     final prefs = await SharedPreferences.getInstance();
  //     prefs.setString(AppStrings().chatUserName, userName!);

  //     String profilePhoto =
  //         homeScreenController.getUserDetailsResponseModel?.profilePhoto ?? "";

  //     ABHANumer = homeScreenController.getUserDetailsResponseModel!.healthId;

  //     if (profilePhoto.isNotEmpty) {
  //       decodedBytes = base64Decode(profilePhoto);
  //       imageNull = true;
  //     } else {
  //       imageNull = false;
  //     }

  //     SharedPreferencesHelper.setUserData(userData);
  //     showProgressDialog();
  //     getUpcomingAppointments();
  //   }

  //   if (homeScreenController.errorString.isNotEmpty) {
  //     log("${homeScreenController.errorString}", name: "ERROR");
  //     if (homeScreenController.errorString == "Token verification failed") {
  //       DialogHelper.showInfoDialog(
  //         title: AppStrings().infoString,
  //         description: AppStrings().sessionExpireError,
  //         onTap: logout,
  //       );
  //     }
  //   }
  // }

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
    getSharedPrefData();
    showProgressDialog();
    // callUserDataAPI();
    //callFCMToken();
  }

  getSharedPrefData() {
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            abhaAddress = value;
            callUserDataAPI();
          });
        }));
  }

  callUserDataAPI() async {
    if (abhaAddress != null) {
      homeScreenController.refresh();
      await homeScreenController.getUserDataFromEUA(abhaAddress!);
      getUserDetailsResponseModel =
          homeScreenController.getUserDetailsResponseModel;
      abhaAddress = homeScreenController.getUserDetailsResponseModel!.id!;
      userData = jsonEncode(homeScreenController.getUserDetailsResponseModel);
    }
    if (userData == null) {
      showProgressDialog();
      await getUserProfileData();
    } else {
      GetUserDetailsResponse? getUserDetailsResponseModel =
          GetUserDetailsResponse.fromJson(jsonDecode(userData!));

      abhaAddress = getUserDetailsResponseModel.id!;
      SharedPreferencesHelper.setABhaAddress(abhaAddress!);
      userData = jsonEncode(getUserDetailsResponseModel);

      String firstName = getUserDetailsResponseModel.name!.first!;
      String lastName = getUserDetailsResponseModel.name!.last!;
      userName = firstName + " " + lastName;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(AppStrings().chatUserName, userName!);

      String profilePhoto = getUserDetailsResponseModel.profilePhoto ?? "";

      ABHANumer = getUserDetailsResponseModel.healthId;

      if (profilePhoto.isNotEmpty && profilePhoto.length > 50) {
        decodedBytes = base64Decode(profilePhoto);
        imageNull = true;
      } else {
        imageNull = false;
      }
    }

    showProgressDialog();
    getUpcomingAppointments();
  }

  callFCMToken() async {
    await SharedPreferencesHelper.getFCMToken().then((value) => setState(() {
          if (value == null || value.isEmpty) {
            postFcmToken();
          }
        }));
  }

  ///SAVE FCM TOKEN API
  postFcmToken() async {
    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = abhaAddress;
    fcmTokenModel.token = widget.fcmToken;
    fcmTokenModel.deviceId = await _getId();
    fcmTokenModel.type = Platform.operatingSystem;

    log("${json.encode(fcmTokenModel)}", name: "FCM TOKEN MODEL");

    await postFcmTokenController.postFCMTokenDetails(
        fcmTokenDetails: fcmTokenModel);

    if (postFcmTokenController.fcmTokenAckDetails["status"] == 200) {
      SharedPreferencesHelper.setFCMToken(widget.fcmToken);
      log("=========FCM TOKEN SAVED=========");
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

  getUserProfileData() async {
    homeScreenController.refresh();
    await homeScreenController.getUserDetailsAPI();
    hideProgressDialog();
    if (homeScreenController.getUserDetailsResponseModel != null) {
      getUserDetailsResponseModel =
          homeScreenController.getUserDetailsResponseModel;
      abhaAddress = homeScreenController.getUserDetailsResponseModel!.id!;
      SharedPreferencesHelper.setABhaAddress(abhaAddress!);
      userData = jsonEncode(homeScreenController.getUserDetailsResponseModel);

      String firstName =
          homeScreenController.getUserDetailsResponseModel!.name!.first!;
      String lastName =
          homeScreenController.getUserDetailsResponseModel!.name!.last!;
      userName = firstName + " " + lastName;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(AppStrings().chatUserName, userName!);

      String profilePhoto =
          homeScreenController.getUserDetailsResponseModel?.profilePhoto ?? "";

      ABHANumer = homeScreenController.getUserDetailsResponseModel!.healthId;

      if (profilePhoto.isNotEmpty && profilePhoto.length > 50) {
        decodedBytes = base64Decode(profilePhoto);
        imageNull = true;
      } else {
        imageNull = false;
      }

      SharedPreferencesHelper.setUserData(userData!);
      await saveUserDataToEUA(getUserDetailsResponseModel);
    }

    if (homeScreenController.errorString.isNotEmpty) {
      log("${homeScreenController.errorString}", name: "ERROR");
      if (homeScreenController.errorString == "Token verification failed") {
        DialogHelper.showInfoDialog(
          title: AppStrings().infoString,
          description: AppStrings().sessionExpireError,
          onTap: logout,
        );
      }
    }
  }

  saveUserDataToEUA(GetUserDetailsResponse? getUserDetailsResponseModel) async {
    await homeScreenController.saveUserDataToEUA(getUserDetailsResponseModel!);
  }

  getUpcomingAppointments() async {
    await homeScreenController.getUpcomingAppointment(abhaAddress!);
    if (homeScreenController.upcomingAppointmentResponseModal.isNotEmpty) {
      for (int i = 0;
          i < homeScreenController.upcomingAppointmentResponseModal.length;
          i++) {
        if (homeScreenController.upcomingAppointmentResponseModal[i]!
            .serviceFulfillmentStartTime!.isNotEmpty) {
          String startDate = homeScreenController
              .upcomingAppointmentResponseModal[i]!
              .serviceFulfillmentStartTime!;
          var now = new DateTime.now();
          var formatter = new DateFormat('y-MM-ddTHH:mm');
          String formattedDate = formatter.format(now);
          DateTime currentDate =
              DateFormat("y-MM-ddTHH:mm").parse(formattedDate);
          DateTime tempStartDate = DateFormat("y-MM-ddTHH:mm").parse(startDate);
          int duration = currentDate.difference(tempStartDate).inMinutes;
          if (duration < 0) {
            if (homeScreenController
                    .upcomingAppointmentResponseModal[i]!.isServiceFulfilled ==
                "CONFIRMED") {
              upcomingAppointmentList.add(
                  homeScreenController.upcomingAppointmentResponseModal[i]!);
            }
          } else {
            if (homeScreenController
                    .upcomingAppointmentResponseModal[i]!.isServiceFulfilled ==
                "CONFIRMED") {
              historyAppointmentList.add(
                  homeScreenController.upcomingAppointmentResponseModal[i]!);
            }
          }
        }
      }
      if (historyAppointmentList.length > 0) {
        String? orderDetailHistoryMessage = historyAppointmentList[0]!.message;
        bookOnConfirmHistoryResponseModel =
            BookingConfirmResponseModel.fromJson(
                jsonDecode(orderDetailHistoryMessage!));
      }

      if (upcomingAppointmentList.length > 0) {
        String? orderDetailUpComingMessage =
            upcomingAppointmentList[0]!.message;

        bookOnConfirmUpcomingResponseModel =
            BookingConfirmResponseModel.fromJson(
                jsonDecode(orderDetailUpComingMessage!));
      }
    }
    hideProgressDialog();
  }

  logout() async {
    Get.back();
    SharedPreferencesHelper.setAutoLoginFlag(false);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Get.offAll(() => BaseLoginPage());
  }

  Widget sideMenuDrawer() {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: imageNull == false
                          ? AssetImage('assets/images/account.png')
                          : Image.memory(decodedBytes).image,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      userName != null ? userName! : "",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.appointmentConfirmTextColor,
                          fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings().abhaNumber,
                          style: AppTextStyle.textNormalStyle(
                              color: AppColors.appointmentConfirmTextColor,
                              fontSize: 12),
                        ),
                        Text(
                          ABHANumer != null ? ABHANumer! : "-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.mobileNumberTextColor,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings().abhaAddress,
                          style: AppTextStyle.textNormalStyle(
                              color: AppColors.appointmentConfirmTextColor,
                              fontSize: 12),
                        ),
                        Text(
                          abhaAddress != null ? abhaAddress! : "-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.tileColors, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(UserProfilePage());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.amountColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        height: 42,
                        width: 120,
                        child: Center(
                          child: Text(
                            AppStrings().editProfile,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        DialogHelper.showInfoDialog(
                            title: AppStrings().infoString,
                            description: AppStrings().comingSoon);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.tileColors,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        height: 42,
                        width: 120,
                        child: Center(
                          child: Text(
                            AppStrings().switchAccount,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.tileColors, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SizedBox(
              height: height * 0.7,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      AppStrings().upcomingAppointment,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(const UpcomingAppointmentPage());
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().appointmentsHistory,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(const AppointmentHistoryPage());
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().labTest,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().ambulance,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().bloodBank,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().language,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(ChangeLanguagePage());
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().setting,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(SettingsPage());
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().helpCenter,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 0),
                    child: SizedBox(
                      height: 1,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          color: AppColors.DARK_PURPLE.withOpacity(0.05)),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().terms,
                      style: AppTextStyle.textMediumStyle(
                          color: AppColors.tileColors, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppStrings().policy,
                      style: AppTextStyle.textMediumStyle(
                          color: AppColors.tileColors, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      DialogHelper.showInfoDialog(
                          title: AppStrings().infoString,
                          description: AppStrings().comingSoon);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
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
        drawer: sideMenuDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          // actions: [
          //   GestureDetector(
          //     onTap: () {
          //       NewConfirmationDialog(
          //           context: context,
          //           title: AppStrings().logoutTitle,
          //           description: AppStrings().logoutDescription,
          //           submitButtonText: "",
          //           onCancelTap: () {
          //             Navigator.pop(context);
          //           },
          //           onSubmitTap: () {
          //             logout();
          //           }).showAlertDialog();
          //     },
          //     child: const Padding(
          //       padding: EdgeInsets.only(right: 8.0),
          //       child: Icon(
          //         Icons.logout_outlined,
          //         size: 25,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ],
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    AppStrings().abdmText,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.black, fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 40,
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Heading
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                  child: Text(
                    AppStrings().whatLookingText,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.appointmentConfirmTextColor,
                        fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: dashboardGridItems(
                              assetImage: 'assets/images/teleconsutation.png',
                              actionText: AppStrings().teleconsultation,
                              onTap: () {
                                Get.to(() => BookATeleconsultationPage(
                                      consultationType:
                                          DataStrings.teleconsultation,
                                    ));
                              },
                            ),
                          ),
                          Expanded(
                            child: dashboardGridItems(
                              assetImage: 'assets/images/doctor.png',
                              actionText: AppStrings().physicalConsultation,
                              onTap: () {
                                Get.to(() => BookATeleconsultationPage(
                                      consultationType:
                                          DataStrings.physicalConsultation,
                                    ));
                              },
                            ),
                          ),
                          Expanded(
                            child: dashboardGridItems(
                              assetImage: 'assets/images/ambulance.png',
                              actionText: AppStrings().ambulance,
                              onTap: () {
                                DialogHelper.showInfoDialog(
                                  title: AppStrings().infoString,
                                  description: AppStrings().comingSoon,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: dashboardGridItems(
                              assetImage: 'assets/images/testing_lab.png',
                              actionText: AppStrings().labTest,
                              onTap: () {
                                DialogHelper.showInfoDialog(
                                  title: AppStrings().infoString,
                                  description: AppStrings().comingSoon,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: dashboardGridItems(
                              assetImage: 'assets/images/blood_bank.png',
                              actionText: AppStrings().bloodBank,
                              onTap: () {
                                DialogHelper.showInfoDialog(
                                  title: AppStrings().infoString,
                                  description: AppStrings().comingSoon,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                //Upcoming Appointments
                upcomingAppointmentsView(),
                //Appointment History
                appointmentHistoryView()
              ],
            ),
          ),
        ),
      ),
    );
  }

  dashboardGridItems(
      {required String assetImage,
      required String actionText,
      required Function() onTap}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.pressed)
              ? AppColors.testColor.withAlpha(50)
              : null;
        }),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                assetImage,
                height: 40,
                width: 28,
              ),
              SizedBox(height: 8),
              Divider(
                color: AppColors.testColor.withAlpha(50),
              ),
              SizedBox(
                height: 34,
                child: Center(
                  child: Text(
                    actionText,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.testColor, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appointmentHistoryView() {
    String appointmentStartDate = "";
    String appointmentEndDate = "";
    String appointmentStartTime = "";
    String appointmentEndTime = "";
    String doctorName = "";
    String hprId = "";
    String gender = "";
    int duration = 0;
    var tmpStartDate;
    var tmpEndDate;
    if (historyAppointmentList.isNotEmpty) {
      tmpStartDate = historyAppointmentList[0]!.serviceFulfillmentStartTime!;
      appointmentStartDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
      appointmentStartTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));

      tmpEndDate = historyAppointmentList[0]!.serviceFulfillmentEndTime!;
      appointmentEndDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpEndDate));
      appointmentEndTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpEndDate));

      var StringArray =
          historyAppointmentList[0]!.healthcareProfessionalName!.split("-");
      doctorName = StringArray[1].replaceFirst(" ", "");
      hprId = StringArray[0];

      DateTime tempStartDate = DateFormat("HH:mm").parse(appointmentStartTime);
      DateTime tempEndDate = new DateFormat("HH:mm").parse(appointmentEndTime);
      duration = tempEndDate.difference(tempStartDate).inMinutes;
      gender = historyAppointmentList[0]!.healthcareProfessionalGender!;
    }
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings().appointmentsHistory,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.appointmentConfirmTextColor, fontSize: 18),
              ),
              historyAppointmentList.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Get.to(const AppointmentHistoryPage());
                      },
                      child: Text(
                        AppStrings().viewAll,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.tileColors, fontSize: 15),
                      ),
                    )
                  : Container(),
            ],
          ),
          Spacing(size: 20, isWidth: false),
          historyAppointmentList.isNotEmpty
              ? Container(
                  width: width * 0.9,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 10,
                        color: Color(0x1B1C204D),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width * 0.2,
                              height: width * 0.2,
                              margin: EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: Image.network(gender == "M"
                                            ? AppStrings().maleDoctorImage
                                            : AppStrings().femaleDoctorImage)
                                        .image),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 10, top: 10, right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        //height: 50,
                                        width: width * 0.5,
                                        child: Text(
                                          doctorName,
                                          style: AppTextStyle.textBoldStyle(
                                              color: AppColors.testColor,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Spacing(),
                                      // Text(
                                      //   "Cardiologist",
                                      //   style: AppTextStyle
                                      //       .textNormalStyle(
                                      //           color:
                                      //               AppColors.testColor,
                                      //           fontSize: 15),
                                      // ),
                                    ],
                                  ),
                                  Text(
                                    hprId,
                                    style: AppTextStyle.textBoldStyle(
                                        color: AppColors.doctorNameColor,
                                        fontSize: 12),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    //"Tomorrow at 8:42 AM",
                                    appointmentStartDate +
                                        " at " +
                                        appointmentStartTime,
                                    style: AppTextStyle.textBoldStyle(
                                        color: AppColors.testColor,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "$duration minutes",
                                    style: AppTextStyle.textLightStyle(
                                        color: AppColors.testColor,
                                        fontSize: 13),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    historyAppointmentList[0]!
                                                .serviceFulfillmentType ==
                                            DataStrings.teleconsultation
                                        ? DataStrings.teleconsultation
                                        : AppStrings()
                                            .physicalConsultationString,
                                    style: AppTextStyle.textBoldStyle(
                                        color: AppColors.testColor,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.appointmentStatusColor,
                              ),
                              height: 20,
                              width: 20,
                            ),
                            Container(
                              color: AppColors.appointmentStatusColor,
                              height: 2,
                              width: 90,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.appointmentStatusColor,
                              ),
                              height: 20,
                              width: 20,
                            ),
                            Container(
                              color: AppColors.appointmentStatusColor,
                              height: 2,
                              width: 90,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.appointmentStatusColor,
                              ),
                              height: 20,
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  //"19 April 22\n  8:00pm",
                                  appointmentStartDate +
                                      "\n  " +
                                      appointmentStartTime,
                                  style: AppTextStyle.textBoldStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                                Text(
                                  AppStrings().appointmentBooked,
                                  style: AppTextStyle.textLightStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  appointmentStartDate +
                                      "\n " +
                                      appointmentStartTime,
                                  style: AppTextStyle.textBoldStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                                Text(
                                  AppStrings()
                                      .appointmentInProgressOnHomeScreen,
                                  style: AppTextStyle.textLightStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  appointmentEndDate +
                                      "\n " +
                                      appointmentEndTime,
                                  style: AppTextStyle.textBoldStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                                Text(
                                  AppStrings()
                                      .appointmentInCompletedOnHomeScreen,
                                  style: AppTextStyle.textLightStyle(
                                      color: AppColors.doctorExperienceColor,
                                      fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Spacing(isWidth: false),
                      Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          width: 1,
                          color: Color(0xFFF0F3F4),
                          // color: Colors.green,
                        ))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: showDoctorActionView(
                                  assetImage: 'assets/images/Show.png',
                                  color: AppColors.infoIconColor,
                                  actionText: AppStrings().viewDetails,
                                  onTap: () {
                                    Get.to(ConsultationCompletedPage(
                                      startDateTime: historyAppointmentList[0]!
                                          .serviceFulfillmentStartTime!,
                                      endDateTime: historyAppointmentList[0]!
                                          .serviceFulfillmentEndTime!,
                                      doctorName: historyAppointmentList[0]!
                                          .healthcareProfessionalName!,
                                      gender: gender,
                                      bookingConfirmResponseModel:
                                          bookOnConfirmHistoryResponseModel,
                                    ));
                                  }),
                            ),
                            Container(
                              color: Color(0xFFF0F3F4),
                              height: 60,
                              width: 1,
                            ),
                            Expanded(
                              child: showDoctorActionView(
                                  assetImage: 'assets/images/Tick-Square.png',
                                  color: AppColors.infoIconColor,
                                  actionText: AppStrings().bookAgain,
                                  onTap: () async {
                                    Get.to(BookAppointmentAgain(
                                      discoveryFulfillments:
                                          bookOnConfirmHistoryResponseModel
                                              .message!.order!.fulfillment,
                                      consultationType:
                                          historyAppointmentList[0]!
                                                      .serviceFulfillmentType ==
                                                  DataStrings.teleconsultation
                                              ? DataStrings.teleconsultation
                                              : AppStrings()
                                                  .physicalConsultationString,
                                      providerUri:
                                          bookOnConfirmHistoryResponseModel
                                              .context!.providerUrl!,
                                    ));
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    AppStrings().noHistoryFound,
                    style: AppTextStyle.textBoldStyle(
                        color:
                            AppColors.appointmentConfirmDoctorActionsTextColor,
                        fontSize: 14),
                  ),
                ),
        ],
      ),
    );
  }

  showDoctorActionView(
      {required String assetImage,
      required Color color,
      required String actionText,
      required Function() onTap}) {
    return SizedBox(
      height: 60,
      child: InkWell(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.pressed)
              ? color.withAlpha(50)
              : null;
        }),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetImage,
              height: 16,
              width: 16,
            ),
            Spacing(size: 5),
            Text(
              actionText,
              style: AppTextStyle.textNormalStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget upcomingAppointmentsView() {
    String appointmentStartDate = "";
    String appointmentEndDate = "";
    String appointmentStartTime = "";
    String appointmentEndTime = "";
    String doctorName = "";
    String hprId = "";
    int duration = 0;
    var tmpStartDate;
    var tmpEndDate;
    String gender = "";
    //String? doctorProfileImage = "";
    if (upcomingAppointmentList.isNotEmpty) {
      tmpStartDate = upcomingAppointmentList[0]!.serviceFulfillmentStartTime!;
      appointmentStartDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
      appointmentStartTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));

      tmpEndDate = upcomingAppointmentList[0]!.serviceFulfillmentEndTime!;
      appointmentEndDate =
          DateFormat("dd MMM y").format(DateTime.parse(tmpEndDate));
      appointmentEndTime =
          DateFormat("hh:mm a").format(DateTime.parse(tmpEndDate));

      var StringArray =
          upcomingAppointmentList[0]!.healthcareProfessionalName!.split("-");
      doctorName = StringArray[1].replaceFirst(" ", "");
      hprId = StringArray[0];

      DateTime tempStartDate = DateFormat("HH:mm").parse(appointmentStartTime);
      DateTime tempEndDate = new DateFormat("HH:mm").parse(appointmentEndTime);
      duration = tempEndDate.difference(tempStartDate).inMinutes;
      gender = upcomingAppointmentList[0]!.healthcareProfessionalGender!;
    }

    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings().upcomingAppointments,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.appointmentConfirmTextColor, fontSize: 18),
              ),
              upcomingAppointmentList.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Get.to(const UpcomingAppointmentPage());
                      },
                      child: Text(
                        AppStrings().viewAll,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.tileColors, fontSize: 15),
                      ),
                    )
                  : Container(),
            ],
          ),
          Spacing(size: 20, isWidth: false),
          upcomingAppointmentList.isNotEmpty
              ? Container(
                  width: width * 0.9,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 10,
                        color: Color(0x1B1C204D),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(AppointmentStatusConfirmPage(
                            bookingConfirmResponseModel:
                                bookOnConfirmUpcomingResponseModel,
                            startDateTime: upcomingAppointmentList[0]!
                                .serviceFulfillmentStartTime!,
                            endDateTime: upcomingAppointmentList[0]!
                                .serviceFulfillmentEndTime!,
                            doctorName: upcomingAppointmentList[0]!
                                .healthcareProfessionalName!,
                            consultationType: upcomingAppointmentList[0]!
                                        .serviceFulfillmentType ==
                                    DataStrings.teleconsultation
                                ? DataStrings.teleconsultation
                                : DataStrings.physicalConsultation,
                            gender: gender,
                            navigateToHomeAndRefresh: false,
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.2,
                                height: width * 0.2,
                                margin: EdgeInsets.only(top: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: Image.network(gender == "M"
                                              ? AppStrings().maleDoctorImage
                                              : AppStrings().femaleDoctorImage)
                                          .image),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 10, top: 10, right: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          //height: 50,
                                          width: width * 0.5,
                                          child: Text(
                                            doctorName,
                                            style: AppTextStyle.textBoldStyle(
                                                color: AppColors.testColor,
                                                fontSize: 15),
                                          ),
                                        ),
                                        Spacing(),
                                        // Text(
                                        //   "Cardiologist",
                                        //   style: AppTextStyle
                                        //       .textNormalStyle(
                                        //           color:
                                        //               AppColors.testColor,
                                        //           fontSize: 15),
                                        // ),
                                      ],
                                    ),
                                    Text(
                                      hprId,
                                      style: AppTextStyle.textBoldStyle(
                                          color: AppColors.doctorNameColor,
                                          fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      //"Tomorrow at 8:42 AM",
                                      appointmentStartDate +
                                          " at " +
                                          appointmentStartTime,
                                      style: AppTextStyle.textBoldStyle(
                                          color: AppColors.testColor,
                                          fontSize: 15),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "$duration minutes",
                                      style: AppTextStyle.textLightStyle(
                                          color: AppColors.testColor,
                                          fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      upcomingAppointmentList[0]!
                                                  .serviceFulfillmentType ==
                                              DataStrings.teleconsultation
                                          ? DataStrings.teleconsultation
                                          : AppStrings()
                                              .physicalConsultationString,
                                      style: AppTextStyle.textBoldStyle(
                                          color: AppColors.testColor,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacing(isWidth: false),
                      Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          width: 1,
                          color: Color(0xFFF0F3F4),
                          // color: Colors.green,
                        ))),
                      ),
                      //Spacing(isWidth: false),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20, right: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //           Get.to(CancelAppointment(
                      //               discoveryFulfillments:
                      //                   bookOnConfirmUpcomingResponseModel
                      //                       .message!.order!.fulfillment));
                      //         },
                      //         child: Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Image.asset(
                      //               'assets/images/cross.png',
                      //               height: 16,
                      //               width: 16,
                      //             ),
                      //             Spacing(size: 5),
                      //             Text(
                      //               AppStrings().cancel,
                      //               style: AppTextStyle.textLightStyle(
                      //                   color: AppColors.tileColors,
                      //                   fontSize: 12),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       //Spacing(isWidth: true),
                      //       Container(
                      //         color: Color(0xFFF0F3F4),
                      //         height: 60,
                      //         width: 1,
                      //       ),
                      //       //Spacing(isWidth: true),
                      //       GestureDetector(
                      //         onTap: () async {
                      //           //rescheduleAppointment();
                      //         },
                      //         child: Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Image.asset(
                      //               'assets/images/Calendar.png',
                      //               height: 16,
                      //               width: 16,
                      //             ),
                      //             Spacing(size: 5),
                      //             Text(
                      //               AppStrings().reschedule,
                      //               style: AppTextStyle.textLightStyle(
                      //                   color: AppColors.tileColors,
                      //                   fontSize: 12),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Container(
                      //         color: Color(0xFFF0F3F4),
                      //         height: 60,
                      //         width: 1,
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           //Get.to(ChatPage());
                      //           Get.to(() => ChatPage(
                      //                 doctorHprId: upcomingAppointmentList[0]
                      //                     ?.healthcareProfessionalId,
                      //                 patientAbhaId:
                      //                     upcomingAppointmentList[0]?.abhaId,
                      //                 doctorName: doctorName,
                      //                 doctorGender: gender,
                      //                 providerUri: upcomingAppointmentList[0]
                      //                     ?.healthcareProviderUrl,
                      //               ));
                      //         },
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(left: 8),
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Image.asset(
                      //                 'assets/images/Chat.png',
                      //                 height: 16,
                      //                 width: 16,
                      //               ),
                      //               Spacing(size: 5),
                      //               Text(
                      //                 AppStrings().startChat,
                      //                 style: AppTextStyle.textLightStyle(
                      //                     color: AppColors.tileColors,
                      //                     fontSize: 12),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: showDoctorActionView(
                                  assetImage: 'assets/images/cross.png',
                                  color: AppColors.infoIconColor,
                                  actionText: AppStrings().cancel,
                                  onTap: () {
                                    Get.to(CancelAppointment(
                                        discoveryFulfillments:
                                            bookOnConfirmUpcomingResponseModel
                                                .message!.order!.fulfillment));
                                  }),
                            ),
                            Container(
                              color: Color(0xFFF0F3F4),
                              height: 60,
                              width: 1,
                            ),
                            Expanded(
                              child: showDoctorActionView(
                                  assetImage: 'assets/images/Calendar.png',
                                  color: AppColors.infoIconColor,
                                  actionText: AppStrings().reschedule,
                                  onTap: () async {
                                    //rescheduleAppointment();
                                  }),
                            ),
                            Container(
                              color: Color(0xFFF0F3F4),
                              height: 60,
                              width: 1,
                            ),
                            Expanded(
                              child: showDoctorActionView(
                                  assetImage: 'assets/images/Chat.png',
                                  color: AppColors.infoIconColor,
                                  actionText: AppStrings().startChat,
                                  onTap: () async {
                                    Get.to(() => ChatPage(
                                          doctorHprId:
                                              upcomingAppointmentList[0]
                                                  ?.healthcareProfessionalId,
                                          patientAbhaId:
                                              upcomingAppointmentList[0]
                                                  ?.abhaId,
                                          doctorName: doctorName,
                                          doctorGender: gender,
                                          providerUri:
                                              upcomingAppointmentList[0]
                                                  ?.healthcareProviderUrl,
                                        ));
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    AppStrings().noUpcomingAppointmentsFound,
                    style: AppTextStyle.textBoldStyle(
                        color:
                            AppColors.appointmentConfirmDoctorActionsTextColor,
                        fontSize: 14),
                  ),
                ),
        ],
      ),
    );
  }

  rescheduleAppointment() {
    Get.to(() => DoctorsDetailPage(
          doctorAbhaId: bookOnConfirmUpcomingResponseModel
              .message!.order!.fulfillment!.agent!.id!,
          doctorName: bookOnConfirmUpcomingResponseModel
              .message!.order!.fulfillment!.agent!.name!,
          doctorProviderUri:
              bookOnConfirmUpcomingResponseModel.context!.providerUrl!,
          discoveryFulfillments:
              bookOnConfirmUpcomingResponseModel.message!.order!.fulfillment!,
          consultationType:
              upcomingAppointmentList[0]!.serviceFulfillmentType ==
                      DataStrings.teleconsultation
                  ? DataStrings.teleconsultation
                  : DataStrings.physicalConsultation,
          isRescheduling: true,
          bookingConfirmResponseModel: bookOnConfirmUpcomingResponseModel,
        ));
  }
}

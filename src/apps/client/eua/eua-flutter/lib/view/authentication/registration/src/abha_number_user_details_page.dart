import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/model/request/src/registration_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/district_list_response_model%20copy.dart';
import 'package:uhi_flutter_app/model/response/src/state_list_response_model.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../constants/constants.dart';
import '../../../../controller/login/src/register_with_all_info_controller.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/src/calendar_date_range_picker.dart';
import '../registration.dart';

class AbhaNumberUserDetailsPage extends StatefulWidget {
  AbhaNumberUserDetailsPage();

  @override
  State<AbhaNumberUserDetailsPage> createState() =>
      _AbhaNumberUserDetailsPageState();
}

class _AbhaNumberUserDetailsPageState extends State<AbhaNumberUserDetailsPage> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  TextEditingController _firstNameTextController = TextEditingController();
  TextEditingController _middleNameTextController = TextEditingController();
  TextEditingController _lastNameTextController = TextEditingController();
  TextEditingController _dateOfBirthTextController = TextEditingController();
  TextEditingController _emailIdTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  TextEditingController _pinCodeTextController = TextEditingController();
  TextEditingController _mobileNumberTextController = TextEditingController();
  RegistrationController _registrationController = RegistrationController();
  RegisterWithAllInfoController _infoController =
      RegisterWithAllInfoController();

  ///DATA VARIABLES
  List<String> _genderList = ["Male", "Female", "Other"];
  String _genderDropdownValue = "Male";
  List<String> _stateList = [];
  String _stateDropdownValue = "";
  List<String> _districtList = [];
  String _districtDropdownValue = "";
  bool _agreementCheckboxValue = false;
  bool _isValidate = false;
  Future<List<StateListResponseModel?>?>? futureStateList;
  List<StateListResponseModel?> _stateAndCodeList = List.empty(growable: true);
  List<DistrictListResponseModel?> _districtAndCodeList =
      List.empty(growable: true);
  bool isLoading = false;
  bool isBtnLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime _dateOfBirth = DateTime.now();

  bool imageNull = false;
  var _imageBytes;
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    // if (mounted) {
    //   futureStateList = getStateList();
    // }
  }

  ///GET STATES AND DISTRICTS
  Future<List<StateListResponseModel?>?>? getStateList() async {
    _infoController.refresh();
    List<StateListResponseModel?>? stateListResponseModel;

    await _infoController.getStateList();

    if (_infoController.stateListResponseModel.isNotEmpty) {
      stateListResponseModel = _infoController.stateListResponseModel;
    }

    return stateListResponseModel;
  }

  getDistrictList(String? stateCode) async {
    showProgressIndicator();
    _infoController.refresh();

    log("STATE CODE $stateCode");

    await _infoController.getDistrictList(stateCode);

    if (_infoController.districtListResponseModel.isNotEmpty) {
      hideProgressIndicator();
      _districtAndCodeList.addAll(_infoController.districtListResponseModel);
      _districtAndCodeList = _districtAndCodeList.toSet().toList();
      _districtList =
          _districtAndCodeList.map((e) => e?.name ?? "").toSet().toList();
    } else {
      hideProgressIndicator();
    }
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureStateList = getStateList();
  }

  showProgressIndicator() {
    setState(() {
      isLoading = true;
    });
  }

  hideProgressIndicator() {
    setState(() {
      isLoading = false;
      isBtnLoading = false;
    });
  }

  String? getStateCode({required String stateName}) {
    String? stateCode;

    _stateAndCodeList.forEach((element) {
      if (element?.stateName == stateName) {
        stateCode = element?.stateCode;
      }
    });

    return stateCode;
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        title: Text(
          "Registration",
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: buildWidgets(),
      // body: FutureBuilder(
      //   future: futureStateList,
      //   builder: (context, loadingData) {
      //     switch (loadingData.connectionState) {
      //       case ConnectionState.waiting:
      //         return CommonLoadingIndicator();

      //       case ConnectionState.active:
      //         return Text(AppStrings().loadingData);

      //       case ConnectionState.done:
      //         return loadingData.data != null
      //             ? buildWidgets(loadingData.data)
      //             : RefreshIndicator(
      //                 onRefresh: onRefresh,
      //                 child: Stack(
      //                   children: [
      //                     ListView(),
      //                     Container(
      //                       padding: EdgeInsets.all(15),
      //                       child: Center(
      //                         child: Text(
      //                           AppStrings().serverBusyErrorMsg,
      //                           style: TextStyle(
      //                               fontFamily: "Poppins",
      //                               fontStyle: FontStyle.normal,
      //                               fontWeight: FontWeight.w500,
      //                               fontSize: 16.0),
      //                           textAlign: TextAlign.center,
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               );
      //       default:
      //         return loadingData.data != null
      //             ? buildWidgets(loadingData.data)
      //             : RefreshIndicator(
      //                 onRefresh: onRefresh,
      //                 child: Stack(
      //                   children: [
      //                     ListView(),
      //                     Container(
      //                       padding: EdgeInsets.all(15),
      //                       child: Center(
      //                         child: Text(
      //                           AppStrings().serverBusyErrorMsg,
      //                           style: TextStyle(
      //                               fontFamily: "Poppins",
      //                               fontStyle: FontStyle.normal,
      //                               fontWeight: FontWeight.w500,
      //                               fontSize: 16.0),
      //                           textAlign: TextAlign.center,
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               );
      //     }
      //   },
      // ),
    );
  }

  buildWidgets() {
    if (_profilePhoto != null && _profilePhoto != "") {
      _imageBytes = base64Decode(_profilePhoto ?? "");
      imageNull = true;
    } else {
      imageNull = false;
    }

    return Container(
      width: width,
      height: height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacing(isWidth: false, size: 20),
            Column(
              children: [
                Row(
                  children: [
                    Spacing(size: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: imageNull == false
                          ? AssetImage('assets/images/account.png')
                          : Image.memory(_imageBytes).image,
                    ),
                    Spacing(size: 20),
                    Column(
                      children: [
                        displayText(label: "Name", text: "Vishal U Swami"),
                        Spacing(isWidth: false, size: 20),
                        displayText(
                            label: "Date Of Birth", text: "25 June 1997"),
                      ],
                    ),
                  ],
                ),
                Spacing(isWidth: false, size: 20),
                buildUserDetails(),
              ],
            ),
            Spacing(isWidth: false, size: 20),
            continueBtn(),
            Spacing(isWidth: false, size: 20),
          ],
        ),
      ),
    );
  }

  buildUserDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              displayText(label: "Gender", text: "Male"),
              Spacing(size: 20),
              displayText(label: "Mobile Number", text: "7721043046"),
            ],
          ),
          Spacing(isWidth: false, size: 20),
          Row(
            children: [
              displayText(label: "Email", text: "vswami241@gmail.com"),
              Spacing(size: 20),
              displayText(label: "Address", text: "Someshwar Nagar, Parli V."),
            ],
          ),
          Spacing(isWidth: false, size: 20),
          Row(
            children: [
              displayText(label: "District", text: "Beed"),
              Spacing(size: 20),
              displayText(label: "State", text: "Maharashtra"),
            ],
          ),
          Spacing(isWidth: false, size: 20),
        ],
      ),
    );
  }

  displayText({required String label, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.textLightStyle(
            color: AppColors.black,
            fontSize: 14,
          ),
        ),
        Container(
          constraints: BoxConstraints(minWidth: width * 0.4),
          child: Wrap(
            children: [
              Text(
                text,
                style: AppTextStyle.textBoldStyle(
                  color: AppColors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  continueBtn() {
    return InkWell(
      onTap: isBtnLoading ? () {} : () {},
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.tileColors,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isBtnLoading
              ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                )
              : Text(
                  "CONTINUE",
                  style: AppTextStyle.textBoldStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}

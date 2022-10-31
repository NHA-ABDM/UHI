import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/controller/login/login.dart';
import 'package:uhi_flutter_app/model/request/src/registration_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/district_list_response_model%20copy.dart';
import 'package:uhi_flutter_app/model/response/src/state_list_response_model.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../../constants/constants.dart';
import '../../../../controller/login/src/register_with_all_info_controller.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/src/calendar_date_range_picker.dart';
import '../registration.dart';

class UserDetailsFormPage extends StatefulWidget {
  String sessionId;
  String? mobileNumber;
  String? emailId;
  bool? isFromMobile;

  UserDetailsFormPage(
      {required this.sessionId,
      this.mobileNumber,
      this.emailId,
      this.isFromMobile});

  @override
  State<UserDetailsFormPage> createState() => _UserDetailsFormPageState();
}

class _UserDetailsFormPageState extends State<UserDetailsFormPage> {
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
  List<String> _genderList = [
    "Please select gender",
    "Male",
    "Female",
    "Other"
  ];
  String _genderDropdownValue = "Please select gender";
  List<String> _stateList = [];
  String? _stateDropdownValue;
  List<String> _districtList = [];
  String? _districtDropdownValue;
  bool _agreementCheckboxValue = false;
  bool _isValidate = false;
  Future<List<StateListResponseModel?>?>? futureStateList;
  List<StateListResponseModel?> _stateAndCodeList = [];
  List<DistrictListResponseModel?> _districtAndCodeList = [];
  bool isLoading = false;
  bool isBtnLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime _dateOfBirth = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      futureStateList = getStateList();
    }
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
    _districtList.clear();
    _districtAndCodeList.clear();
    _districtDropdownValue = null;
    _infoController.refresh();
    showProgressIndicator();
    log("STATE CODE $stateCode");

    await _infoController.getDistrictList(stateCode);

    if (_infoController.districtListResponseModel.isNotEmpty) {
      hideProgressIndicator();
      _districtList.add("Please select district");
      _districtAndCodeList.addAll(_infoController.districtListResponseModel);
      _districtAndCodeList = _districtAndCodeList.toSet().toList();
      _districtList =
          _districtAndCodeList.map((e) => e?.name ?? "").toSet().toList();
      _districtList.add("Please select district");
      _districtDropdownValue = "Please select district";
    } else {
      hideProgressIndicator();
    }
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureStateList = getStateList();
  }

  ///REGISTER API
  postRegistrationDetails() async {
    if (_firstNameTextController.text.isEmpty ||
        _dateOfBirthTextController.text.isEmpty ||
        _dateOfBirthTextController.text == "Please select birth date" ||
        _genderDropdownValue.isEmpty ||
        _genderDropdownValue == "Please select gender" ||
        _addressTextController.text.isEmpty ||
        _stateDropdownValue!.isEmpty ||
        _districtDropdownValue!.isEmpty ||
        _districtDropdownValue! == "Please select district" ||
        _pinCodeTextController.text.isEmpty) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          description: "Please fill all the required fields.");
      return;
    } else if (!_agreementCheckboxValue) {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          description: "Please accept the User Information Agreement.");
      return;
    }

    _registrationController.refresh();

    StateListResponseModel? state = StateListResponseModel();
    DistrictListResponseModel? district = DistrictListResponseModel();

    _stateAndCodeList.forEach((element) {
      if (element?.stateName == _stateDropdownValue) {
        state = element;
      }
    });

    _districtAndCodeList.forEach((element) {
      if (element?.name == _districtDropdownValue) {
        district = element;
      }
    });

    RegistrationRequestModel registrationRequest = RegistrationRequestModel();
    RegistrationDateOfBirth dateOfBirth = RegistrationDateOfBirth();
    RegistrationName name = RegistrationName();

    registrationRequest.address = _addressTextController.text;
    registrationRequest.countryCode = "+91";
    dateOfBirth.date = _dateOfBirth.day;
    dateOfBirth.month = _dateOfBirth.month;
    dateOfBirth.year = _dateOfBirth.year;
    registrationRequest.dateOfBirth = dateOfBirth;
    registrationRequest.districtCode = district?.code;
    registrationRequest.gender = _genderDropdownValue[0];
    name.first = _firstNameTextController.text;
    name.middle = _middleNameTextController.text;
    name.last = _lastNameTextController.text;
    registrationRequest.name = name;
    registrationRequest.pinCode = _pinCodeTextController.text;
    registrationRequest.sessionId = widget.sessionId;
    registrationRequest.stateCode = state?.stateCode;

    if (widget.isFromMobile != null && widget.isFromMobile!) {
      Encrypted encrypted = await encryptDate(widget.mobileNumber!);
      registrationRequest.mobile = encrypted.base64;
    } else {
      Encrypted encrypted = await encryptDate(widget.emailId!);
      registrationRequest.email = encrypted.base64;
    }

    if (_emailIdTextController.text.isNotEmpty) {
      try {
        Encrypted encrypted = await encryptDate(_emailIdTextController.text);
        registrationRequest.email = encrypted.base64;
      } catch (error) {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
        return;
      }
    }

    if (_mobileNumberTextController.text.isNotEmpty) {
      try {
        Encrypted encrypted =
            await encryptDate(_mobileNumberTextController.text);
        registrationRequest.mobile = encrypted.base64;
      } catch (error) {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
        return;
      }
    }

    log("${jsonEncode(registrationRequest)}", name: "REGISTRATION MODEL");

    await _registrationController.postRegistrationDetails(
        registrationDetails: registrationRequest);

    if (_registrationController.registrationDetails != null &&
        _registrationController.registrationDetails != "") {
      hideProgressIndicator();

      String sessionId =
          _registrationController.registrationDetails["sessionId"];
      if (sessionId.isNotEmpty) {
        Get.to(() => ChooseNewAbhaAddress(
              sessionId: sessionId,
              isFromMobile: widget.isFromMobile,
            ));
      }
    } else if (_registrationController.errorString != "") {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();

      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }
  }

  ///ENCRYPT MOBILE NUMBER
  Future<Encrypted> encryptDate(String inputData) async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encryptedString = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encryptedString.encrypt(inputData);
    return encrypted;
  }

  // Future<Encrypted> encryptEmailId() async {
  //   var pubKey = await rootBundle.load("assets/keys/public.pem");
  //   String dir = (await getApplicationDocumentsDirectory()).path;

  //   writeToFile(pubKey, '$dir/public.pem');
  //   final publicKey =
  //       await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
  //   final encryptedString = Encrypter(RSA(
  //     publicKey: publicKey,
  //   ));
  //   final encrypted = encryptedString.encrypt(_emailIdTextController.text);
  //   return encrypted;
  // }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
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
        title: Text(
          "Registration",
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: futureStateList,
        builder: (context, loadingData) {
          switch (loadingData.connectionState) {
            case ConnectionState.waiting:
              return CommonLoadingIndicator();

            case ConnectionState.active:
              return Text(AppStrings().loadingData);

            case ConnectionState.done:
              return loadingData.data != null
                  ? buildWidgets(loadingData.data)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: Stack(
                        children: [
                          ListView(),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                AppStrings().serverBusyErrorMsg,
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            default:
              return loadingData.data != null
                  ? buildWidgets(loadingData.data)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: Stack(
                        children: [
                          ListView(),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                AppStrings().serverBusyErrorMsg,
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
          }
        },
      ),
    );
  }

  buildWidgets(Object? data) {
    List<StateListResponseModel>? dataList =
        data as List<StateListResponseModel>;

    if (dataList.isNotEmpty) {
      if (_stateAndCodeList.isEmpty) {
        _stateAndCodeList.addAll(dataList);
        _stateAndCodeList = _stateAndCodeList.toSet().toList();
        _stateList =
            _stateAndCodeList.map((e) => e?.stateName ?? "").toSet().toList();
      }
    }

    return Container(
      width: width,
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                autovalidateMode: _isValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    textFieldWithOutsideLabel(
                      label: "First Name",
                      isRequired: true,
                      inputType: "text",
                      controller: _firstNameTextController,
                    ),
                    Spacing(size: 10, isWidth: false),
                    Row(
                      children: [
                        Expanded(
                          child: textFieldWithOutsideLabel(
                            label: "Middle Name",
                            inputType: "text",
                            controller: _middleNameTextController,
                          ),
                        ),
                        Spacing(size: 10),
                        Expanded(
                          child: textFieldWithOutsideLabel(
                            label: "Last Name",
                            inputType: "text",
                            controller: _lastNameTextController,
                          ),
                        ),
                      ],
                    ),
                    Spacing(size: 10, isWidth: false),
                    datePickerField(
                      label: "Date of Birth",
                      isRequired: true,
                      controller: _dateOfBirthTextController,
                    ),
                    Spacing(size: 10, isWidth: false),
                    dropdownField(
                      label: "Gender",
                      isRequired: true,
                      dropdownValue: _genderDropdownValue,
                      dropdownList: _genderList,
                    ),
                    Spacing(size: 10, isWidth: false),
                    widget.isFromMobile != null && widget.isFromMobile == false
                        ? Container()
                        : textFieldWithOutsideLabel(
                            label: "Email ID",
                            isRequired: false,
                            controller: _emailIdTextController,
                            validator: _emailIdTextController.text.isNotEmpty
                                ? (input) => (input ?? "").isValidEmail()
                                    ? null
                                    : "Please enter valid email"
                                : null,
                          ),
                    Spacing(size: 10, isWidth: false),
                    widget.isFromMobile != null && widget.isFromMobile == true
                        ? Container()
                        : textFieldWithOutsideLabel(
                            label: "Mobile Number",
                            isRequired: true,
                            inputType: "number",
                            maxLength: 10,
                            controller: _mobileNumberTextController,
                            validator: _mobileNumberTextController
                                    .text.isNotEmpty
                                ? (input) => (input ?? "").isValidMobileNumber()
                                    ? null
                                    : "Please enter valid mobile number"
                                : null,
                          ),
                    Spacing(size: 10, isWidth: false),
                    textFieldWithOutsideLabel(
                      label: "Address",
                      isRequired: true,
                      controller: _addressTextController,
                    ),
                    Spacing(size: 10, isWidth: false),
                    dropdownField(
                      label: "Select Your State",
                      isRequired: true,
                      dropdownValue: _stateDropdownValue,
                      dropdownList: _stateList,
                    ),
                    Spacing(size: 10, isWidth: false),
                    dropdownField(
                      label: "Select Your District",
                      hintText: isLoading
                          ? "Loading districts..."
                          : "Please select state first",
                      isRequired: true,
                      dropdownValue: _districtDropdownValue,
                      loadingIndicator: true,
                      dropdownList: _districtList,
                    ),
                    Spacing(size: 10, isWidth: false),
                    textFieldWithOutsideLabel(
                        label: "Pin Code",
                        isRequired: true,
                        inputType: "number",
                        maxLength: 6,
                        controller: _pinCodeTextController,
                        validator: _pinCodeTextController.text.isNotEmpty
                            ? (input) => (input ?? "").isValidPincode()
                                ? null
                                : "Please enter valid pincode"
                            : null),
                    Spacing(size: 10, isWidth: false),
                    userInfoAgreement(),
                    Spacing(size: 20, isWidth: false),
                    continueBtn(),
                    Spacing(size: 20, isWidth: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  textFieldWithOutsideLabel({
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
            isRequired != null && isRequired
                ? Text(
                    "*",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.amountColor,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    " (optional)",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
          ],
        ),
        Spacing(size: 5, isWidth: false),
        TextFormField(
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
            prefixText: label == "Mobile Number" ? "+91" : "",
            counterText: "",
          ),
        ),
      ],
    );
  }

  datePickerField(
      {required String label,
      bool? isRequired,
      required TextEditingController controller}) {
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
            isRequired != null && isRequired
                ? Text(
                    "*",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.amountColor,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    " (optional)",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
          ],
        ),
        Spacing(size: 5, isWidth: false),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: controller.text.isNotEmpty
                ? "${controller.text}"
                : "Please select birth date",
            border: OutlineInputBorder(),
          ),
          onTap: () {
            CalendarDateRangePicker(
              context: context,
              isDateRange: false,
              maxDateTime: DateTime.now().subtract(Duration(days: 1)),
              onDateSubmit: (startDate, endDate) {
                if (startDate == null) {
                  startDate = DateTime.now();
                }
                if (endDate == null) {
                  endDate = startDate;
                }
                setState(() {
                  _dateOfBirthTextController.text = DateFormat("dd MMMM yyyy")
                      .format(startDate ?? DateTime.now());
                  _dateOfBirth = startDate ?? DateTime.now();
                });
              },
            ).sfDatePicker();
          },
        ),
      ],
    );
  }

  dropdownField({
    required String label,
    String? hintText,
    bool? isRequired,
    required String? dropdownValue,
    required List<String> dropdownList,
    bool? loadingIndicator,
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
            isRequired != null && isRequired
                ? Text(
                    "*",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.amountColor,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    " (optional)",
                    style: AppTextStyle.textBoldStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
          ],
        ),
        Spacing(size: 5, isWidth: false),
        DropdownButtonFormField<String?>(
          // value: dropdownValue,
          isExpanded: true,
          icon: loadingIndicator != null && loadingIndicator && isLoading
              ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(color: AppColors.black))
              : Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.testColor,
                  size: 24,
                ),
          style: AppTextStyle.textLightStyle(
              color: AppColors.testColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText != null && hintText.isNotEmpty ? hintText : "",
            border: OutlineInputBorder(),
          ),
          items: dropdownList.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
          onChanged: (String? newValue) {
            if (label == "Gender") {
              setState(() {
                _genderDropdownValue = newValue!;
              });
            } else if (label.toLowerCase().contains("state")) {
              if (_stateDropdownValue != newValue) {
                setState(() {
                  _districtDropdownValue = null;
                });
                getDistrictList(getStateCode(stateName: newValue ?? ""));
              }
              setState(() {
                _stateDropdownValue = newValue!;
              });
            } else if (label.toLowerCase().contains("district")) {
              setState(() {
                _districtDropdownValue = newValue!;
              });
            } else {
              setState(() {
                dropdownValue = newValue!;
              });
            }
          },
          value: dropdownValue,
        )
      ],
    );
  }

  userInfoAgreement() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.agreementTextBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreementCheckboxValue,
            onChanged: (value) {
              setState(() {
                _agreementCheckboxValue = value!;
              });
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "I agree to voluntary share my identity information with NHA to create my ABHA address.",
                    style: AppTextStyle.textNormalStyle(
                      color: AppColors.darkGrey363636,
                      fontSize: 18,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showDialog(
                          "User Agreement", AppStrings().userAgreementText);
                    },
                    child: Text(
                      "User Information Agreement",
                      style: AppTextStyle.textNormalStyle(
                        color: AppColors.primaryLightBlue007BFF,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String body) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            title,
            style: const TextStyle(
                color: Colors.blue,
                fontStyle: FontStyle.normal,
                fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child: new Text(
              body,
              style: const TextStyle(
                  color: AppColors.DARK_PURPLE,
                  fontStyle: FontStyle.normal,
                  fontSize: 16.0),
            ),
          ),
          actions: <Widget>[
            new TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(AppColors.DARK_PURPLE)),
              child: new Text(
                "Ok",
                style: TextStyle(
                    color: AppColors.white,
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  continueBtn() {
    return InkWell(
      onTap: isBtnLoading
          ? () {}
          : () {
              setState(() {
                isBtnLoading = true;
              });
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isValidate = true;
                });
                postRegistrationDetails();
              } else {
                hideProgressIndicator();
              }
            },
      // onTap: () {
      //   postRegistrationDetails();
      // },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.primaryLightBlue007BFF,
          borderRadius: BorderRadius.circular(5),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/register_with_all_info_controller.dart';
import 'package:uhi_flutter_app/model/response/src/district_list_response_model%20copy.dart';
import 'package:uhi_flutter_app/model/response/src/state_list_response_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/new_dialog_screen.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/create_new_abha_address.dart';
import 'package:uhi_flutter_app/widgets/src/calendar_date_range_picker.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class RegistrationWithAllDetails extends StatefulWidget {
  const RegistrationWithAllDetails({Key? key}) : super(key: key);

  @override
  State<RegistrationWithAllDetails> createState() =>
      _RegistrationWithAllDetailsPageState();
}

enum searchOption { doctorsName, hpID }

class _RegistrationWithAllDetailsPageState
    extends State<RegistrationWithAllDetails> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  final _firstNameTextEditingController = TextEditingController();
  final _middleNameTextEditingController = TextEditingController();
  final _lastNameTextEditingController = TextEditingController();
  final _AddressTextEditingController = TextEditingController();
  final _pinCodeTextEditingController = TextEditingController();

  final registerWithAllInfoController =
      Get.put(RegisterWithAllInfoController());

  ///DATA VARIABLES

  String _genderDropdownValue = "";
  final List<String> _listOfGenderDropdownValue = ["Male", "Female", "Other"];

  StateListResponseModel _stateDropdownValue = StateListResponseModel();
  List<StateListResponseModel?> _listStateDropdownValue = [];

  DistrictListResponseModel _cityDropdownValue = DistrictListResponseModel();
  List<DistrictListResponseModel?> _listOfCityDropdownValue = [];

  String? _selectedDate = "Select Date";
  bool _loading = false;
  bool? checkedValue = false;

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
    callStateListApi();
  }

  callStateListApi() async {
    registerWithAllInfoController.refresh();
    await registerWithAllInfoController.getStateList();
    hideProgressDialog();
    registerWithAllInfoController.stateListResponseModel.isNotEmpty
        ? setStateDropDownData()
        : null;
  }

  callCityListAPI(String stateId) async {
    registerWithAllInfoController.refresh();
    await registerWithAllInfoController.getDistrictList(stateId);
    hideProgressDialog();
    registerWithAllInfoController.districtListResponseModel.isNotEmpty
        ? setCityDropDownData()
        : null;
  }

  setStateDropDownData() {
    _listStateDropdownValue
        .addAll(registerWithAllInfoController.stateListResponseModel);
  }

  setCityDropDownData() {
    _cityDropdownValue =
        registerWithAllInfoController.districtListResponseModel[0]!;
    _listOfCityDropdownValue
        .addAll(registerWithAllInfoController.districtListResponseModel);
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
          AppStrings().registrationWithMobileNumber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        dismissible: false,
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: AppColors.DARK_PURPLE,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
        ),
        child: Container(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _firstNameTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().firstNameHint,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      TextFormField(
                        controller: _middleNameTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().middleNameHint,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      TextFormField(
                        controller: _lastNameTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().lastNameHint,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      Column(
                        children: <Widget>[
                          Material(
                            child: InkWell(
                              onTap: () => datePicker(),
                              child: Container(
                                child: ClipRRect(
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, bottom: 10),
                                          child: Text(_selectedDate!,
                                              textAlign: TextAlign.start,
                                              style:
                                                  AppTextStyle.textLightStyle(
                                                      color:
                                                          AppColors.testColor,
                                                      fontSize: 14)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3),
                                          child: Icon(
                                            Icons.calendar_today,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SizedBox(
                              height: 1,
                              child: Container(
                                color: AppColors.DARK_PURPLE.withOpacity(0.45),
                              ),
                            ),
                          )
                        ],
                      ),
                      Spacing(size: 20, isWidth: false),
                      DropdownButtonFormField<String>(
                        icon: const Icon(
                          Icons.expand_more_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                        style: AppTextStyle.textLightStyle(
                            color: AppColors.testColor, fontSize: 14),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _genderDropdownValue = newValue!;
                          });
                        },
                        hint: Text(
                          AppStrings().genderHint,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                        ),
                        items: _listOfGenderDropdownValue
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      Spacing(size: 20, isWidth: false),
                      TextFormField(
                        controller: _AddressTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().addressHint,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child:
                                DropdownButtonFormField<StateListResponseModel>(
                              icon: const Icon(
                                Icons.expand_more_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.testColor, fontSize: 14),
                              isExpanded: true,
                              onChanged: (StateListResponseModel? newValue) {
                                setState(() {
                                  _stateDropdownValue = newValue!;
                                  callCityListAPI(
                                      _stateDropdownValue.stateCode!);
                                });
                              },
                              hint: Text(
                                AppStrings().stateHint,
                                style: AppTextStyle.textLightStyle(
                                    color: AppColors.testColor, fontSize: 14),
                              ),
                              items: _listStateDropdownValue.map<
                                      DropdownMenuItem<StateListResponseModel>>(
                                  (StateListResponseModel? value) {
                                return DropdownMenuItem<StateListResponseModel>(
                                  value: value,
                                  child: Text(value!.stateName!),
                                );
                              }).toList(),
                            ),
                          ),
                          Spacing(size: 10),
                          Expanded(
                            child: DropdownButtonFormField<
                                DistrictListResponseModel>(
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.testColor, fontSize: 14),
                              isExpanded: true,
                              onChanged: (DistrictListResponseModel? newValue) {
                                setState(() {
                                  _cityDropdownValue = newValue!;
                                });
                              },
                              hint: Text(
                                AppStrings().cityHint,
                                style: AppTextStyle.textLightStyle(
                                    color: AppColors.testColor, fontSize: 14),
                              ),
                              items: _listOfCityDropdownValue.map<
                                      DropdownMenuItem<
                                          DistrictListResponseModel>>(
                                  (DistrictListResponseModel? value) {
                                return DropdownMenuItem<
                                    DistrictListResponseModel>(
                                  value: value,
                                  child: Text(value!.name!),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Spacing(size: 20, isWidth: false),
                      TextFormField(
                        controller: _pinCodeTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().pincode,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                              value: checkedValue,
                              activeColor: AppColors.DARK_PURPLE,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  checkedValue = newValue;
                                });
                              }),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width * 0.75,
                                child: Text(
                                  AppStrings().agreementText,
                                  style: AppTextStyle.textSemiBoldStyle(
                                      color: AppColors.testColor, fontSize: 14),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  NewMessageDialog(
                                          context: context,
                                          title: AppStrings()
                                              .userInformationAgreement,
                                          description:
                                              AppStrings().userAgreementDetails)
                                      .showAlertDialog();
                                },
                                child: Text(
                                  AppStrings().userInformationAgreement,
                                  style: AppTextStyle.textBoldStyle(
                                      color: AppColors.tileColors,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Spacing(size: 20, isWidth: false),
                InkWell(
                  onTap: () {
                    Get.to(const CreateNewAbhaAddress());
                  },
                  child: Container(
                    width: width * 0.92,
                    height: height * 0.06,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8705A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings().submit,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  datePicker() {
    CalendarDateRangePicker(
      context: context,
      isDateRange: false,
      startDate: DateTime(1900),
      endDate: DateTime.now(),
      maxDateTime: DateTime.now(),
      onDateSubmit: (startDate, endDate) {
        final DateFormat formatter = DateFormat('dd MMM yyyy');
        setState(() {
          _selectedDate = DateFormat('dd MMM yyyy').format(startDate!);
          debugPrint("=====>$_selectedDate");
        });
      },
    ).sfDatePicker();
  }
}

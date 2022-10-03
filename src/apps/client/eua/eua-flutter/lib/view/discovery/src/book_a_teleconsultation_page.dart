import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/widgets/src/calendar_date_range_picker.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

import '../../../constants/src/data_strings.dart';

class BookATeleconsultationPage extends StatefulWidget {
  String consultationType;

  BookATeleconsultationPage({Key? key, required this.consultationType})
      : super(key: key);

  @override
  State<BookATeleconsultationPage> createState() =>
      _BookATeleconsultationPageState();
}

enum searchOption { doctorsName, hpID }

class _BookATeleconsultationPageState extends State<BookATeleconsultationPage> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  final _doctorNameOrIdTextEditingController = TextEditingController();
  final _hospitalOrClinicTextEditingController = TextEditingController();
  final _cityTextEditingController = TextEditingController();
  final _postDiscoveryDetailsController =
      Get.put(PostDiscoveryDetailsController());

  final _getDiscoveryDetailsController =
      Get.put(GetDiscoveryDetailsController());
  DoctorNameRequestModel professionalNameRequestModel =
      DoctorNameRequestModel();

  DiscoveryResponseModel discoveryResponseModel = DiscoveryResponseModel();

  ///DATA VARIABLES
  String _specialtiesDropdownValue = "";
  final List<String> _listOfSpecialtiesDropdownValue = [
    "Physician",
    "Orthopedist",
    "Psychiatrist",
  ];

  String _followUpDropdownValue = "";
  final List<String> _listOfFollowUpDropdownValue = [
    "First Time",
    "Following Up",
  ];

  String _systemOfMedDropdownValue = "";
  final List<String> _listOfSystemOfMedDropdownValue = [
    "Internal",
    "External",
  ];

  String _languageDropdownValue = "";
  final List<String> _listOfLanguageDropdownValue = [
    "English",
    "Hindi",
    "Assamese",
    "Bengali",
    "Gujarati",
    "Kannada",
    "Kashmiri",
    "Konkani",
    "Malayalam",
    "Manipuri",
    "Marathi",
    "Nepali",
    "Oriya",
    "Punjabi",
    "Sanskrit",
    "Sindhi",
    "Tamil",
    "Telugu",
    "Urdu",
    "Urdu",
    "Santhali",
    "Maithili",
    "Dogri",
  ];

  List<Object?> selectedLanguage = [];

  String? _cityDropdownValue;
  final List<String> _listOfCityDropdownValue = [
    "Pune",
    "Mumbai",
    "Delhi",
    "Kolkata",
    "Bangalore"
  ];

  bool isToday = true;
  bool isThisWeek = false;
  bool isThisMonth = false;
  String? city = "";
  String location = 'Null, Press Button';
  String address = 'search';
  String _uniqueId = "";
  searchOption selectedValue = searchOption.doctorsName;
  bool _loading = false;
  String? _selectedDate;
  StompClient? stompClient;
  int messageQueueNum = 0;

  String? _selectedStartTime =
      DateFormat("y-MM-ddTHH:mm:ss").format(DateTime.now());

  String? _selectedEndTime =
      DateFormat("y-MM-ddT23:59:59").format(DateTime.now());

  String? _consultationType;

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
    //readJson();
    final DateFormat formatter = DateFormat("dd MMM yyyy");
    _selectedDate = formatter.format(DateTime.now());
    SharedPreferencesHelper.getCity().then((value) => setState(() {
          setState(() {
            city = value;
            getLocation();
          });
        }));

    _consultationType = widget.consultationType;
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/specialties.json');
    final data = await json.decode(response);
    setState(() {
      for (int i = 0; i < data["items"].length; i++) {
        _listOfSpecialtiesDropdownValue.add(data["items"][i].toString());
      }
    });
  }

  getLocation() async {
    if (city != null && city!.isNotEmpty) {
      if (!_listOfCityDropdownValue.contains(city)) {
        _listOfCityDropdownValue.add(city!);
        _cityDropdownValue = city!;
      }
      setState(() {});
    } else {
      // DialogHelper.showErrorDialog(
      //     title: AppStrings().locationString,
      //     description: AppStrings().locationErrorMsgString);
    }
  }

  generateRadioButton({
    required searchOption value,
    required String label,
  }) {
    return RadioListTile<searchOption>(
      groupValue: selectedValue,
      value: value,
      onChanged: (searchOption? value) {
        setState(() {
          selectedValue = value!;
          if (selectedValue.name != "doctorsName") {
            selectedLanguage.clear();
          }
          _doctorNameOrIdTextEditingController.clear();
        });
      },
      title: Transform.translate(
        offset: Offset(-20, 0),
        child: Text(
          label,
          style: AppTextStyle.textMediumStyle(
              fontSize: 14, color: AppColors.doctorNameColor),
        ),
      ),
    );
  }

  findDoctor() {
    Get.to(() => DiscoveryResultsPage(
          searchType: selectedValue.name,
          doctorName: _doctorNameOrIdTextEditingController.text,
          doctorHprId: _doctorNameOrIdTextEditingController.text,
          languages: selectedLanguage,
          systemOfMed: _systemOfMedDropdownValue,
          speciality: _specialtiesDropdownValue,
          hospitalOrClinic: _hospitalOrClinicTextEditingController.text,
          startTime: _selectedStartTime,
          endTime: _selectedEndTime,
          consultationType: _consultationType,
        ));
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
          _consultationType == DataStrings.teleconsultation
              ? AppStrings().bookATeleconsultation
              : AppStrings().bookAPhysicalConsultation,
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
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacing(size: 30, isWidth: false),
                Center(
                  child: Container(
                    width: width * 0.92,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 15,
                          color: Color(0x1B1C204D),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _consultationType == DataStrings.teleconsultation
                              ? AppStrings().howDoTeleconsultationWork
                              : AppStrings().howDoPhysicalConsultationWork,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 12),
                        ),
                        Spacing(size: 16, isWidth: false),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                AppStrings().searchDoctor,
                                style: AppTextStyle.textMediumStyle(
                                    color: AppColors.testColor, fontSize: 12),
                              ),
                              Spacing(size: 10),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Color(0xFF324755),
                              ),
                              Spacing(size: 10),
                              Text(
                                AppStrings().completePayment,
                                style: AppTextStyle.textMediumStyle(
                                    color: AppColors.testColor, fontSize: 12),
                              ),
                              Spacing(size: 10),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Color(0xFF324755),
                              ),
                              Spacing(size: 10),
                              Text(
                                _consultationType ==
                                        DataStrings.teleconsultation
                                    ? AppStrings().startConsultation
                                    : AppStrings().bookAnAppointment,
                                style: AppTextStyle.textMediumStyle(
                                    color: AppColors.testColor, fontSize: 12),
                              ),
                              Spacing(size: 10),
                              _consultationType ==
                                      DataStrings.physicalConsultation
                                  ? Spacing(size: 2)
                                  : Container(),
                              _consultationType ==
                                      DataStrings.physicalConsultation
                                  ? const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: Color(0xFF324755),
                                    )
                                  : Container(),
                              Spacing(size: 10),
                              _consultationType ==
                                      DataStrings.physicalConsultation
                                  ? Spacing(size: 2)
                                  : Container(),
                              _consultationType ==
                                      DataStrings.physicalConsultation
                                  ? Text(
                                      AppStrings().visitFacility,
                                      style: AppTextStyle.textMediumStyle(
                                          color: AppColors.testColor,
                                          fontSize: 12),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacing(size: 30, isWidth: false),
                SizedBox(
                  width: width * 0.92,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings().findDoctor,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                      Spacing(size: 10, isWidth: false),
                      SizedBox(
                        height: 50,
                        //width: width,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 60,
                              width: width * 0.5,
                              child: generateRadioButton(
                                value: searchOption.doctorsName,
                                label: AppStrings().searchByDoctorsName,
                              ),
                            ),
                            SizedBox(
                              height: 60,
                              width: width * 0.4,
                              child: generateRadioButton(
                                value: searchOption.hpID,
                                label: AppStrings().searchByHPID,
                              ),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _doctorNameOrIdTextEditingController,
                        decoration: InputDecoration(
                          hintText: selectedValue.name == "doctorsName"
                              ? AppStrings().doctorNameHint
                              : AppStrings().HPIDHint,
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
                            child: DropdownButtonFormField<String>(
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: selectedValue.name == "doctorsName"
                                    ? Colors.black
                                    : const Color(0xFFC4C4C4),
                                size: 24,
                              ),
                              //disabledHint: const Text("Disabled"),
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.testColor, fontSize: 14),
                              isExpanded: true,
                              onChanged: selectedValue.name == "doctorsName"
                                  ? (String? newValue) {
                                      setState(() {
                                        _specialtiesDropdownValue = newValue!;
                                      });
                                    }
                                  : null,
                              hint: Text(
                                AppStrings().specialtyHint,
                                style: AppTextStyle.textLightStyle(
                                    color: selectedValue.name == "doctorsName"
                                        ? AppColors.testColor
                                        : const Color(0xFFC4C4C4),
                                    fontSize: 14),
                              ),
                              items: _listOfSpecialtiesDropdownValue
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      //Spacing(size: 20, isWidth: false),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Expanded(
                      //       child: DropdownButtonFormField<String>(
                      //         disabledHint: const Text("Disabled"),
                      //         // value: _systemOfMedDropdownValue,
                      //         icon: Icon(
                      //           Icons.expand_more_rounded,
                      //           color: selectedValue.name == "doctorsName"
                      //               ? Colors.black
                      //               : Color(0xFFC4C4C4),
                      //           size: 24,
                      //         ),
                      //         style: AppTextStyle.textLightStyle(
                      //             color: AppColors.testColor, fontSize: 14),
                      //         isExpanded: true,
                      //         onChanged: selectedValue.name == "doctorsName"
                      //             ? (String? newValue) {
                      //                 setState(() {
                      //                   _systemOfMedDropdownValue = newValue!;
                      //                 });
                      //               }
                      //             : null,
                      //         hint: Text(
                      //           AppStrings().systemOfMedicineHint,
                      //           style: AppTextStyle.textLightStyle(
                      //               color: AppColors.testColor, fontSize: 14),
                      //         ),
                      //         items: _listOfSystemOfMedDropdownValue
                      //             .map<DropdownMenuItem<String>>(
                      //                 (String value) {
                      //           return DropdownMenuItem<String>(
                      //             value: value,
                      //             child: Text(value),
                      //           );
                      //         }).toList(),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Spacing(size: 20, isWidth: false),
                      selectedValue.name != "doctorsName"
                          ? DropdownButtonFormField<String>(
                              // disabledHint: const Text("Disabled"),
                              // value: _cityDropdownValue,
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: selectedValue.name == "doctorsName"
                                    ? Colors.black
                                    : Color(0xFFC4C4C4),
                                size: 24,
                              ),
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.testColor, fontSize: 14),
                              isExpanded: true,
                              onChanged: selectedValue.name == "doctorsName"
                                  ? (String? newValue) {
                                      setState(() {
                                        _cityDropdownValue = newValue!;
                                      });
                                    }
                                  : null,
                              hint: Text(
                                AppStrings().language,
                                style: AppTextStyle.textLightStyle(
                                    color: selectedValue.name == "doctorsName"
                                        ? AppColors.testColor
                                        : const Color(0xFFC4C4C4),
                                    fontSize: 14),
                              ),
                              items: _listOfCityDropdownValue
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          : MultiSelectDialogField(
                              searchable: true,
                              buttonText: Text(
                                selectedValue.name == "doctorsName"
                                    ? AppStrings().language
                                    : 'Disabled',
                                style: AppTextStyle.textLightStyle(
                                    color: AppColors.testColor, fontSize: 14),
                              ),
                              buttonIcon: Icon(
                                Icons.expand_more_rounded,
                                color: selectedValue.name == "doctorsName"
                                    ? Colors.black
                                    : Color(0xFFC4C4C4),
                                size: 24,
                              ),
                              items: _listOfLanguageDropdownValue
                                  .map((e) => MultiSelectItem(e, e))
                                  .toList(),
                              listType: MultiSelectListType.LIST,
                              onConfirm: (values) {
                                setState(() {
                                  selectedLanguage = values;
                                });
                              },
                            ),
                      Spacing(
                          size: selectedLanguage.isEmpty ? 20 : 0,
                          isWidth: false),
                      DropdownButtonFormField<String>(
                        value: _cityDropdownValue,
                        icon: Icon(
                          Icons.expand_more_rounded,
                          color: selectedValue.name == "doctorsName"
                              ? Colors.black
                              : const Color(0xFFC4C4C4),
                          size: 24,
                        ),
                        //disabledHint: const Text("Disabled"),
                        style: AppTextStyle.textLightStyle(
                            color: AppColors.testColor, fontSize: 14),
                        isExpanded: true,
                        onChanged: selectedValue.name == "doctorsName"
                            ? (String? newValue) {
                                setState(() {
                                  _specialtiesDropdownValue = newValue!;
                                });
                              }
                            : null,
                        hint: Text(
                          AppStrings().cityHint,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                        ),
                        items: _listOfCityDropdownValue
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      // TextFormField(
                      //   readOnly:
                      //       selectedValue.name == "doctorsName" ? false : true,
                      //   controller: _cityTextEditingController,
                      //   decoration: InputDecoration(
                      //     hintText: selectedValue.name == "doctorsName"
                      //         ? AppStrings().cityHint
                      //         : "Disabled",
                      //     hintStyle: AppTextStyle.textLightStyle(
                      //         color: AppColors.testColor, fontSize: 14),
                      //     border: const UnderlineInputBorder(),
                      //   ),
                      // ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     // Expanded(
                      //     //   child: DropdownButtonFormField<String>(
                      //     //     disabledHint: const Text("Disabled"),
                      //     //     // value: _cityDropdownValue,
                      //     //     icon: Icon(
                      //     //       Icons.expand_more_rounded,
                      //     //       color: selectedValue.name == "doctorsName"
                      //     //           ? Colors.black
                      //     //           : Color(0xFFC4C4C4),
                      //     //       size: 24,
                      //     //     ),
                      //     //     style: AppTextStyle.textLightStyle(
                      //     //         color: AppColors.testColor, fontSize: 14),
                      //     //     isExpanded: true,
                      //     //     onChanged: selectedValue.name == "doctorsName"
                      //     //         ? (String? newValue) {
                      //     //             setState(() {
                      //     //               _cityDropdownValue = newValue!;
                      //     //             });
                      //     //           }
                      //     //         : null,
                      //     //     hint: Text(
                      //     //       AppStrings().cityHint,
                      //     //       style: AppTextStyle.textLightStyle(
                      //     //           color: AppColors.testColor, fontSize: 14),
                      //     //     ),
                      //     //     items: _listOfCityDropdownValue
                      //     //         .map<DropdownMenuItem<String>>((String value) {
                      //     //       return DropdownMenuItem<String>(
                      //     //         value: value,
                      //     //         child: Text(value),
                      //     //       );
                      //     //     }).toList(),
                      //     //   ),
                      //     // ),
                      //     Expanded(
                      //       child: TextFormField(
                      //         readOnly: selectedValue.name == "doctorsName"
                      //             ? false
                      //             : true,
                      //         controller: _cityTextEditingController,
                      //         decoration: InputDecoration(
                      //           hintText: selectedValue.name == "doctorsName"
                      //               ? AppStrings().cityHint
                      //               : "Disabled",
                      //           hintStyle: AppTextStyle.textLightStyle(
                      //               color: AppColors.testColor, fontSize: 14),
                      //           border: const UnderlineInputBorder(),
                      //         ),
                      //       ),
                      //     ),
                      //     Spacing(size: 10),
                      //     // Expanded(
                      //     //   child: TextFormField(
                      //     //     readOnly: selectedValue.name == "doctorsName"
                      //     //         ? false
                      //     //         : true,
                      //     //     controller:
                      //     //         _hospitalOrClinicTextEditingController,
                      //     //     decoration: InputDecoration(
                      //     //       hintText: selectedValue.name == "doctorsName"
                      //     //           ? AppStrings().hospitalClinic
                      //     //           : "Disabled",
                      //     //       hintStyle: AppTextStyle.textLightStyle(
                      //     //           color: AppColors.testColor, fontSize: 14),
                      //     //       border: const UnderlineInputBorder(),
                      //     //     ),
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                      Spacing(size: 30, isWidth: false),
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
                    ],
                  ),
                ),
                Spacing(size: 20, isWidth: false),
                InkWell(
                  onTap: () {
                    //Get.to(() => DiscoveryResultsPage());

                    // callApis();
                    findDoctor();
                  },
                  child: Container(
                    width: width * 0.92,
                    height: height * 0.06,
                    // padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8705A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings().btnFindDoctor,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                Spacing(size: 30, isWidth: false),
                InkWell(
                  onTap: () {
                    Get.to(() => AppointmentHistoryPage());
                  },
                  child: Container(
                    width: width * 0.76,
                    height: height * 0.06,
                    // padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 1,
                          color: Color(0xFF264488),
                        )),
                    child: Center(
                      child: Text(
                        AppStrings().btnViewAppointmentHistory,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.tileColors, fontSize: 14),
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

  String getForm(DateTime startDate) {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String getUntil(DateTime endDate) {
    return DateFormat('dd MMM yyyy').format(endDate);
  }

  datePicker() {
    CalendarDateRangePicker(
      context: context,
      isDateRange: true,
      minDateTime: DateTime.now(),
      onDateSubmit: (startDate, endDate) {
        final DateFormat formatter = DateFormat('dd MMM yyyy');
        if (startDate == null) {
          startDate = DateTime.now();
        }
        if (endDate == null) {
          endDate = startDate;
        }
        setState(() {
          _selectedDate = DateFormat('MMMM d').format(startDate!);
          _selectedStartTime = DateFormat("y-MM-ddTHH:mm:ss").format(startDate);
          _selectedEndTime = DateFormat("y-MM-ddT23:59:59").format(endDate!);
          _selectedDate = getForm(startDate) + " - " + getUntil(endDate);
        });
      },
    ).sfDatePicker();
  }
}

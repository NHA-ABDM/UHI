import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/common/src/dialog_helper.dart';
import '../../discovery/discovery.dart';

class BookGroupTeleconsultationPage extends StatefulWidget {
  final String consultationType;

  BookGroupTeleconsultationPage({Key? key, required this.consultationType})
      : super(key: key);

  @override
  State<BookGroupTeleconsultationPage> createState() =>
      _BookGroupTeleconsultationPageState();
}

// enum searchOption { doctorsName, hpID }
enum DropDownType { speciality, city, language }
enum AvailabilityType { today, thisWeek, thisMonth }

class _BookGroupTeleconsultationPageState
    extends State<BookGroupTeleconsultationPage> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  final _doctorNameOrIdTextEditingController = TextEditingController();
  final _doctorNameTwoOrIdTextEditingController = TextEditingController();
  AvailabilityType availabilityType = AvailabilityType.today;
  DoctorNameRequestModel professionalNameRequestModel =
      DoctorNameRequestModel();
  DiscoveryResponseModel discoveryResponseModel = DiscoveryResponseModel();
  bool _firstDocTextFieldValidate = false;
  bool _secondDocTextFieldValidate = false;

  ///DATA VARIABLES
  String? _specialtiesDropdownValue;
  String? _specialtiesTwoDropdownValue;
  final List<String> _listOfSpecialtiesDropdownValue = [
    "Physician",
    "Orthopedist",
    "Psychiatrist",
  ];

  String? _cityDropdownValue;
  String? _cityTwoDropdownValue;
  final List<String> _listOfCityDropdownValue = [
    "Pune",
    "Mumbai",
    "Delhi",
    "Kolkata",
    "Bangalore"
  ];

  List<String> _languageDropdownValueList = [];
  List<String> _languageTwoDropdownValueList = [];
  String? _languageDropdownValue;
  String? _languageTwoDropdownValue;
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

  String? _selectedEndTime = DateFormat("y-MM-ddT23:59:59")
      .format(DateTime.now().add(Duration(hours: 12)));

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
    final DateFormat formatter = DateFormat("dd MMM yyyy");
    _selectedDate = formatter.format(DateTime.now());

    _consultationType = widget.consultationType;

    _doctorNameOrIdTextEditingController.addListener(() {
      setState(() {
        _firstDocTextFieldValidate = false;
      });
    });
    _doctorNameTwoOrIdTextEditingController.addListener(() {
      setState(() {
        _secondDocTextFieldValidate = false;
      });
    });
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

  void findDoctor() {
    String docFirstName = _doctorNameOrIdTextEditingController.text;
    String docSecondName = _doctorNameTwoOrIdTextEditingController.text;
    if (validate(docFirstName, docSecondName)) {
      Get.to(() => MultipleDoctorResultsPage(
            doctor1Name: docFirstName,
            doctor2Name: docSecondName,
            doctor1Speciality: _specialtiesDropdownValue,
            doctor2Speciality: _specialtiesTwoDropdownValue,
            doctor1City: _cityDropdownValue,
            doctor2City: _cityTwoDropdownValue,
            doctor1Language: _languageDropdownValueList,
            doctor2Language: _languageTwoDropdownValueList,
            startTime: _selectedStartTime,
            endTime: _selectedEndTime,
            consultationType:
                _consultationType ?? DataStrings.groupConsultation,
          ));
    }
  }

  bool validate(String docFirstName, String docSecondName) {
    if (docFirstName.isEmpty && docSecondName.isEmpty) {
      setState(() {
        _firstDocTextFieldValidate = true;
        _secondDocTextFieldValidate = true;
      });
      return false;
    } else if (docFirstName.isEmpty) {
      setState(() {
        _firstDocTextFieldValidate = true;
      });
      return false;
    } else if (docSecondName.isEmpty) {
      setState(() {
        _secondDocTextFieldValidate = true;
      });
      return false;
    } else if (docFirstName == docSecondName &&
        _specialtiesDropdownValue == null &&
        _specialtiesTwoDropdownValue == null &&
        _cityDropdownValue == null &&
        _cityTwoDropdownValue == null &&
        _languageDropdownValue == null &&
        _languageTwoDropdownValue == null) {
      DialogHelper.showErrorDialog(description: 'Doctors name can not be same');
      return false;
    } else if (docFirstName == docSecondName &&
        _specialtiesDropdownValue == _specialtiesTwoDropdownValue &&
        _cityDropdownValue == _cityTwoDropdownValue) {
      DialogHelper.showErrorDialog(
          description: 'Doctors name and details can not be same');
      return false;
    }
    return true;
  }

  String getDropDownHint(Enum dDType) {
    return dDType == DropDownType.speciality
        ? AppStrings().specialtyHint
        : dDType == DropDownType.city
            ? AppStrings().cityHint
            : dDType == DropDownType.language
                ? AppStrings().language
                : "";
  }

  List<String> _getDropDownShowValueHandler(Enum dDType) {
    if (dDType == DropDownType.speciality) {
      return _listOfSpecialtiesDropdownValue;
    } else if (dDType == DropDownType.city) {
      return _listOfCityDropdownValue;
    } else {
      return _listOfLanguageDropdownValue;
    }
  }

  void _getDropDownOnChangeHandler(
      bool isFirstDoctor, Enum dDType, String? newValue) {
    debugPrint(isFirstDoctor.toString());
    debugPrint(dDType.toString());
    debugPrint(newValue);

    newValue ??= "";
    if (isFirstDoctor) {
      if (dDType == DropDownType.speciality) {
        _specialtiesDropdownValue = newValue;
      } else if (dDType == DropDownType.city) {
        _cityDropdownValue = newValue;
      } else {
        _languageDropdownValue = newValue;
        _languageDropdownValueList.clear();
        _languageDropdownValueList.add(_languageDropdownValue ?? "");
      }
    } else {
      if (dDType == DropDownType.speciality) {
        _specialtiesTwoDropdownValue = newValue;
      } else if (dDType == DropDownType.city) {
        _cityTwoDropdownValue = newValue;
      } else {
        _languageTwoDropdownValue = newValue;
        _languageTwoDropdownValueList.clear();
        _languageTwoDropdownValueList.add(_languageTwoDropdownValue ?? "");
      }
    }
  }

  String? _getUpdatedValueOfDropDown(bool isFirstDoctor, Enum dDType) {
    return dDType == DropDownType.speciality
        ? isFirstDoctor
            ? _specialtiesDropdownValue
            : _specialtiesTwoDropdownValue
        : dDType == DropDownType.city
            ? isFirstDoctor
                ? _cityDropdownValue
                : _cityTwoDropdownValue
            : dDType == DropDownType.language
                ? isFirstDoctor
                    ? _languageDropdownValue
                    : _languageTwoDropdownValue
                : "";
  }

  void _availabilityTypeHandler() {
    if (availabilityType == AvailabilityType.today) {
      _selectedStartTime = DateTime.now().toLocal().toUtc().toString();
      _selectedEndTime =
          DateTime.now().add(Duration(hours: 12)).toLocal().toUtc().toString();
    } else if (availabilityType == AvailabilityType.thisWeek) {
      _selectedStartTime = DateTime.now().toLocal().toUtc().toString();
      _selectedEndTime =
          DateTime.now().add(Duration(days: 7)).toLocal().toUtc().toString();
    } else if (availabilityType == AvailabilityType.thisMonth) {
      _selectedStartTime = DateTime.now().toLocal().toUtc().toString();
      _selectedEndTime =
          DateTime.now().add(Duration(days: 30)).toLocal().toUtc().toString();
    }
    setState(() {});
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
          "Book a Group Consultation",
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: SingleChildScrollView(
                      child: Scrollbar(
                thickness: 10, //width of scrollbar
                radius: Radius.circular(20), //corner radius of scrollbar
                scrollbarOrientation: ScrollbarOrientation.right,
                child: Container(
                  width: width,
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleTextWidget("Search for Doctor 1"),
                        Spacing(isWidth: false),
                        doctorNameTextWidget(
                          "Doctor name/HPID",
                        ),
                        Spacing(isWidth: false),
                        searchDoctorTextFieldWidget(
                            _doctorNameOrIdTextEditingController,
                            _firstDocTextFieldValidate),
                        Spacing(size: 20, isWidth: false),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              dropDownWidget(
                                  "Speciality", true, DropDownType.speciality),
                              Spacing(size: 5, isWidth: true),
                              dropDownWidget("City", true, DropDownType.city),
                              Spacing(size: 5, isWidth: true),
                              dropDownWidget(
                                  "Language", true, DropDownType.language),
                            ]),
                        Spacing(size: 30, isWidth: false),
                        titleTextWidget("Search for Doctor 2"),
                        Spacing(isWidth: false),
                        doctorNameTextWidget(
                          "Doctor name/HPID",
                        ),
                        Spacing(isWidth: false),
                        searchDoctorTextFieldWidget(
                            _doctorNameTwoOrIdTextEditingController,
                            _secondDocTextFieldValidate),
                        Spacing(size: 20, isWidth: false),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              dropDownWidget(
                                  "Speciality", false, DropDownType.speciality),
                              Spacing(size: 5, isWidth: true),
                              dropDownWidget("City", false, DropDownType.city),
                              Spacing(size: 5, isWidth: true),
                              dropDownWidget(
                                  "Language", false, DropDownType.language),
                            ]),
                        Spacing(size: 30, isWidth: false),
                        titleTextWidget("Availability"),
                        Spacing(isWidth: false),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  availabilityType = AvailabilityType.today;
                                  _availabilityTypeHandler();
                                },
                                child: availabilityCheckerWidget(
                                    "Today", AvailabilityType.today),
                              ),
                              Spacing(size: 5, isWidth: true),
                              InkWell(
                                onTap: () {
                                  availabilityType = AvailabilityType.thisWeek;
                                  _availabilityTypeHandler();
                                },
                                child: availabilityCheckerWidget(
                                    "This Week", AvailabilityType.thisWeek),
                              ),
                              Spacing(size: 5, isWidth: true),
                              InkWell(
                                onTap: () {
                                  availabilityType = AvailabilityType.thisMonth;
                                  _availabilityTypeHandler();
                                },
                                child: availabilityCheckerWidget(
                                    "This Month", AvailabilityType.thisMonth),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ))),
              Spacing(isWidth: false),
              InkWell(
                onTap: () {
                  //Get.to(() => DiscoveryResultsPage());

                  // callApis();
                  findDoctor();
                },
                child: Container(
                  width: width * 0.92,
                  height: height * 0.06,
                  margin: EdgeInsets.only(bottom: 20),
                  // padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8705A),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "Find Doctors",
                      style: AppTextStyle.textSemiBoldStyle(
                          color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget titleTextWidget(String title) {
    return Text(
      title,
      style: AppTextStyle.textSemiBoldStyle(
          color: AppColors.testColor, fontSize: 15),
    );
  }

  Widget doctorNameTextWidget(String title) {
    return Text(
      title,
      style: AppTextStyle.textNormalStyle(
          color: AppColors.testColor, fontSize: 13),
    );
  }

  Widget searchDoctorTextFieldWidget(
      TextEditingController controller, bool isError) {
    return SizedBox(
        height: isError ? 60.0 : 40.0,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.paymentButtonBackgroundColor, width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.appointmentConfirmDoctorActionsTextColor,
                  width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            errorText: isError ? 'Enter Doctor Name' : null,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide:
                    BorderSide(width: 1, color: AppColors.darkThemeWhiteColor)),
          ),
        ));
  }

  Widget dropDownWidget(String title, bool isFirstDoctor, Enum dDType) {
    return Flexible(
        child: Column(
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.testColor, fontSize: 12),
        ),
        Spacing(size: 5, isWidth: false),
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: AppColors.appointmentConfirmDoctorActionsTextColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 50.0,
            child: Center(
              child: DropdownButton<String>(
                icon: Icon(
                  Icons.expand_more_rounded,
                  size: 24,
                ),
                style: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
                // isExpanded: true,
                underline: Container(),
                hint: Text(
                  getDropDownHint(dDType),
                  style: AppTextStyle.textLightStyle(fontSize: 14),
                ),
                items: _getDropDownShowValueHandler(dDType).map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                value: _getUpdatedValueOfDropDown(isFirstDoctor, dDType),
                onChanged: (value) {
                  _getDropDownOnChangeHandler(isFirstDoctor, dDType, value);
                  setState(() {});
                },
              ),
            ))
      ],
    ));
  }

  Widget availabilityCheckerWidget(String title, AvailabilityType avType) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: availabilityType == avType
              ? AppColors.appointmentConfirmDoctorActionsTextColor
              : availabilityType == avType
                  ? AppColors.appointmentConfirmDoctorActionsTextColor
                  : availabilityType == avType
                      ? AppColors.appointmentConfirmDoctorActionsTextColor
                      : AppColors.white,
          border: Border.all(
            color: AppColors.appointmentConfirmDoctorActionsTextColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: 100.0,
        height: 40.0,
        child: Center(
            child: Text(
          title,
          style: AppTextStyle.textNormalStyle(
              color: AppColors.testColor, fontSize: 12),
        )));
  }
}

import 'package:intl/intl.dart';
import '../../../constants/src/data_strings.dart';
import '../../view.dart';

class ConfirmGroupTeleconsultationPage extends StatefulWidget {
  final String consultationType;

  ConfirmGroupTeleconsultationPage({Key? key, required this.consultationType})
      : super(key: key);

  @override
  State<ConfirmGroupTeleconsultationPage> createState() =>
      _ConfirmGroupTeleconsultationPageState();
}

class _ConfirmGroupTeleconsultationPageState
    extends State<ConfirmGroupTeleconsultationPage> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  final _postDiscoveryDetailsController =
      Get.put(PostDiscoveryDetailsController());
  final _getDiscoveryDetailsController =
      Get.put(GetDiscoveryDetailsController());
  DoctorNameRequestModel professionalNameRequestModel =
      DoctorNameRequestModel();
  DiscoveryResponseModel discoveryResponseModel = DiscoveryResponseModel();

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
    //readJson();
    final DateFormat formatter = DateFormat("dd MMM yyyy");
    _selectedDate = formatter.format(DateTime.now());
    // SharedPreferencesHelper.getCity().then((value) => setState(() {
    //       setState(() {
    //         city = value;
    //         getLocation();
    //       });
    //     }));

    _consultationType = widget.consultationType;
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
          "You are Booking appointments with",
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
          child: SingleChildScrollView(
              child: Scrollbar(
            thickness: 10, //width of scrollbar
            radius: Radius.circular(20), //corner radius of scrollbar
            scrollbarOrientation: ScrollbarOrientation.right,
            child: Container(
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  doctorDetailWidget("", "Name", "Speciality"),
                  Spacing(isWidth: false),
                  doctorDetailWidget("", "Name", "Speciality"),
                  Spacing(isWidth: false),
                  Container(
                    height: 4.0,
                    color: AppColors.innerBoxColor,
                  ),
                  Spacing(isWidth: false),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      "Online Consultation",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors
                              .appointmentConfirmDoctorActionsTextColor,
                          fontSize: 15),
                    ),
                  ),
                  Spacing(isWidth: false),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      "Tue, 11 apr 5 pm",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.testColor, fontSize: 18),
                    ),
                  ),
                  Spacing(isWidth: false),
                  Container(
                    height: 4.0,
                    color: AppColors.innerBoxColor,
                  ),
                  Spacing(isWidth: false),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      "Message of the doctor",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.appointmentStatusColor,
                          fontSize: 15),
                    ),
                  ),
                  Spacing(isWidth: false),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      "Write your symptoms or anything you want the doctor to know",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors
                              .appointmentConfirmDoctorActionsTextColor,
                          fontSize: 15),
                    ),
                  ),
                  Spacing(isWidth: false),
                  Container(
                    height: 4.0,
                    color: AppColors.innerBoxColor,
                  ),
                  Spacing(isWidth: false),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      "Bill detail",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.testColor, fontSize: 18),
                    ),
                  ),
                  Spacing(size: 15, isWidth: false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      splitBillWidget("Consultation Fee"),
                      splitBillWidget("Rs.1200"),
                    ],
                  ),
                  Spacing(isWidth: false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      splitBillWidget("booking Fee"),
                      splitBillWidget("Rs. 0"),
                    ],
                  ),
                  Spacing(size: 15, isWidth: false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      finalBillWidget("Total Payable"),
                      finalBillWidget("Rs.1200"),
                    ],
                  ),
                  Spacing(isWidth: false),
                  Container(
                    height: 4.0,
                    color: AppColors.innerBoxColor,
                  ),
                  Spacing(isWidth: false),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        // TODO DISABLE
                        Get.to(() => ConfirmGroupTeleconsultationPage(
                              consultationType: DataStrings.groupConsultation,
                            ));

                        // TODO ENABLE
                        // findDoctor();
                      },
                      child: Container(
                        width: 150.0,
                        height: height * 0.06,
                        margin: EdgeInsets.only(bottom: 20, right: 10),
                        // padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          color: AppColors
                              .appointmentConfirmDoctorActionsEnabledTextColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "Pay and Confirm",
                            style: AppTextStyle.textSemiBoldStyle(
                                color: AppColors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))),
    );
  }

  Widget doctorDetailWidget(
      String image, String docName, String docSpeciality) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image.isEmpty
              ? Image.asset('assets/images/account.png', width: 80.0)
              : Image.memory(
                  const Base64Decoder().convert(image),
                  width: 80.0,
                ),
          Spacing(size: 15, isWidth: true),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacing(isWidth: false),
              Text(
                docName,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.testColor, fontSize: 20),
              ),
              Text(
                docSpeciality,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.appointmentConfirmDoctorActionsTextColor,
                    fontSize: 15),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget splitBillWidget(String billTypeDetail) {
    return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Text(
          billTypeDetail,
          style: AppTextStyle.textBoldStyle(
              color: AppColors.appointmentConfirmDoctorActionsTextColor,
              fontSize: 15),
        ));
  }

  Widget finalBillWidget(String finalBillDetail) {
    return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Text(
          finalBillDetail,
          style: AppTextStyle.textBoldStyle(
              color: AppColors.testColor, fontSize: 18),
        ));
  }
}

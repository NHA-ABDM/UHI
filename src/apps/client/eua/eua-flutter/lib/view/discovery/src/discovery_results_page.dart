import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/view/view.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/services/src/stomp_socket_connection.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/loading_indicator.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uuid/uuid.dart';

class DiscoveryResultsPage extends StatefulWidget {
  DiscoveryResponseModel? discoveryDetails;
  List? languages;
  String? systemOfMed;
  String? speciality;
  String? doctorName;
  String? doctorHprId;
  String? hospitalOrClinic;
  String? searchType;
  String? startTime;
  String? endTime;
  String? consultationType;

  DiscoveryResultsPage({
    Key? key,
    @required this.discoveryDetails,
    this.languages,
    this.systemOfMed,
    this.speciality,
    this.doctorName,
    this.doctorHprId,
    this.hospitalOrClinic,
    this.searchType,
    this.startTime,
    this.endTime,
    this.consultationType,
  }) : super(key: key);

  @override
  State<DiscoveryResultsPage> createState() => _DiscoveryResultsPageState();
}

enum SortBy { yearsOfExperience, noOfTeleconsultations, price }

class _DiscoveryResultsPageState extends State<DiscoveryResultsPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final _postDiscoveryDetailsController =
      Get.put(PostDiscoveryDetailsController());

  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///SEARCH PARAMS
  List? _languages;
  String? _systemOfMed;
  String? _speciality;
  String? _doctorName;
  String? _doctorHprId;
  String? _hospitalOrClinic;
  String? _searchType;
  String? _startTime;
  String? _endTime;
  String _uniqueId = "";
  String? _consultationType;

  DiscoveryResponseModel? _discoveryResponse;
  Future<DiscoveryResponseModel?>? futureDiscoveryResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  bool showSortOptions = false;
  SortBy? selectedSortValue;
  bool _loading = false;
  List<Fulfillment>? fulfillments = [];
  List<DiscoveryItems>? discoveryItems = [];
  DiscoveryMessage? message;

  Timer? _timer;

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
    // if (widget.discoveryDetails != null) {
    //   fulfillments = widget.discoveryDetails!.message!.catalog!.fulfillments;

    //   message = widget.discoveryDetails!.message!;
    // }
    _languages = widget.languages ?? [];
    _systemOfMed = widget.systemOfMed ?? "";
    _speciality = widget.speciality ?? "";
    _doctorName = widget.doctorName ?? "";
    _doctorHprId = widget.doctorHprId ?? "";
    _hospitalOrClinic = widget.hospitalOrClinic ?? "";
    _searchType = widget.searchType ?? "";
    _startTime = widget.startTime ?? "";
    _endTime = widget.endTime ?? "";
    _consultationType = widget.consultationType;

    if (mounted) {
      futureDiscoveryResponse = getDiscoveryResponse();
    }
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  Future<DiscoveryResponseModel?> getDiscoveryResponse() async {
    DiscoveryResponseModel? discoveryResponseModel;
    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(uniqueId: _uniqueId, api: postSearchAPI);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        discoveryResponseModel =
            DiscoveryResponseModel.fromJson(json.decode(response.response!));
        _timer?.cancel();
        log("${json.encode(discoveryResponseModel)}", name: "RESPONSE");
      }
    };

    // stompSocketConnection.disconnect();

    // await Future.delayed(Duration(milliseconds: duration));

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return discoveryResponseModel;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureDiscoveryResponse = getDiscoveryResponse();
  }

  ///SEARCH API
  postSearchAPI() async {
    String? deviceId = await _getId();
    // _uniqueId = const Uuid().v1();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "search";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.timestamp = DateTime.now().toLocal().toUtc().toIso8601String();
    contextModel.transactionId = _uniqueId;

    DoctorNameRequestModel professionalNameRequestModel =
        DoctorNameRequestModel();

    professionalNameRequestModel.context = contextModel;
    DoctorNameMessage message = DoctorNameMessage();
    DoctorNameIntent intent = DoctorNameIntent();
    DoctorNameFulfillment fulfillment = DoctorNameFulfillment();

    DoctorNameAgent? agent = showAgentParameter() ? DoctorNameAgent() : null;
    //DoctorNameAgent? agent = DoctorNameAgent();
    Tags? tags =
        (_languages!.isNotEmpty) || (_systemOfMed != "") || (_speciality != "")
            ? Tags()
            : null;
    DiscoveryProviders? provider =
        _hospitalOrClinic!.isNotEmpty ? DiscoveryProviders() : null;
    DiscoveryDescriptor descriptor = DiscoveryDescriptor();
    intent.provider = provider;
    provider?.descriptor = descriptor;

    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();

    start.time = startTime;
    end.time = endTime;
    startTime.timestamp = _startTime;
    endTime.timestamp = _endTime;

    fulfillment.startTime = start;
    fulfillment.endTime = end;

    if (_searchType == "doctorsName") {
      if (_doctorName!.isNotEmpty) {
        agent?.name = _doctorName;
      }
      if (_languages!.isNotEmpty) {
        tags?.languageSpokenTag = _languages?.join(",");
      }
      if (_systemOfMed != "") {
        tags?.medicinesTag = _systemOfMed;
      }
      if (_speciality != "") {
        tags?.specialtyTag = _speciality;
      }

      if (_hospitalOrClinic!.isNotEmpty) {
        descriptor.name = _hospitalOrClinic;
      }
    } else {
      agent?.id = _doctorHprId;
    }

    fulfillment.type = _consultationType;
    fulfillment.agent = agent;
    agent?.tags = tags;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("${jsonEncode(professionalNameRequestModel)}", name: "SEARCH 1 MODEL");

    await _postDiscoveryDetailsController.postDiscoveryDetails(
        discoveryDetails: professionalNameRequestModel);
  }

  bool showAgentParameter() {
    if ((_doctorName != "" || _doctorHprId != "") ||
        _languages!.isNotEmpty ||
        _systemOfMed != "" ||
        _speciality != "") {
      return true;
    } else {
      return false;
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

  ///DATA VARIABLES
  @override
  Widget build(BuildContext context) {
    // debugPrint(
    //     "discoveryResult:${widget.discoveryDetails!.message!.catalog!.fulfillments?.length}");

    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
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
        titleSpacing: 0,
        title: Text(
          AppStrings().searchResult,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: FutureBuilder(
        future: futureDiscoveryResponse,
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
      // body: buildWidgets(),
      bottomSheet: Container(
        //height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.shadow1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            showSortOptions
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      generateRadioButton(
                        value: SortBy.yearsOfExperience,
                        label: AppStrings().experienceFilter,
                        onTap: (SortBy? value) {
                          fulfillments?.sort(
                              (a, b) => a.agent!.tags!.experience!.compareTo(
                                    b.agent!.tags!.experience!,
                                  ));
                          setState(() {
                            selectedSortValue = value;
                          });
                        },
                      ),
                      // generateRadioButton(
                      //   value: SortBy.noOfTeleconsultations,
                      //   label: AppStrings().consultationFilter,
                      //   onTap: () {
                      //     fulfillments?.sort(
                      //         (a, b) => a.tags!.firstConsultation!.compareTo(
                      //               b.tags!.firstConsultation!,
                      //             ));
                      //   },
                      // ),
                      generateRadioButton(
                        value: SortBy.price,
                        label: AppStrings().priceFilter,
                        onTap: (SortBy? value) {
                          fulfillments?.sort((a, b) =>
                              a.agent!.tags!.firstConsultation!.compareTo(
                                b.agent!.tags!.firstConsultation!,
                              ));
                          setState(() {
                            selectedSortValue = value;
                          });
                        },
                      ),
                    ],
                  )
                : Container(),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(0),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mode_edit_outline_outlined,
                            color: AppColors.doctorNameColor,
                            size: 25,
                          ),
                          Text(AppStrings().editSmall,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.doctorNameColor)),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                Container(
                  color: Colors.grey[350],
                  height: 60,
                  width: 1,
                ),
                Expanded(
                  child: InkWell(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(0))),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_alt,
                            color: AppColors.doctorNameColor,
                            size: 25,
                          ),
                          Text(AppStrings().sortBy,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.doctorNameColor)),
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showSortOptions = !showSortOptions;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildWidgets(Object? data) {
    _discoveryResponse = data as DiscoveryResponseModel;
    fulfillments = _discoveryResponse?.message?.catalog?.fulfillments;
    message = _discoveryResponse?.message;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        // padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
        child: Column(
          children: [
            buildDoctorsList(),
          ],
        ),
      ),
    );
  }

  buildDoctorsList() {
    return fulfillments!.isNotEmpty
        ? Expanded(
            child: ListView.separated(
              itemCount: fulfillments!.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return buildNewDoctorTile(index);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 20,
                );
              },
              padding: EdgeInsets.fromLTRB(15, 15, 15, 80),
            ),
          )
        : Expanded(
            child: Container(
              child: Center(
                child: Text(
                  AppStrings().noDoctorAvailable,
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
  }

  buildNewDoctorTile(int index) {
    // String? priceValue;
    // List<DiscoveryItems> item = [];
    Fulfillment discoveryFulfillments = fulfillments![index];
    // if (discoveryItems![index].price!.value != null) {
    //   if (discoveryFulfillments.id == discoveryItems![index].fulfillmentId) {
    //     item.add(discoveryItems![index]);
    //   }
    // }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.shadow3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DoctorDetailsView(
            doctorName: discoveryFulfillments.agent?.name,
            doctorAbhaId: discoveryFulfillments.agent?.id,
            tags: discoveryFulfillments.agent!.tags,
            gender: discoveryFulfillments.agent?.gender,
            profileImage: discoveryFulfillments.agent?.image,
          ),
          const SizedBox(
            height: 5,
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       RichText(
          //         text: TextSpan(
          //           text: AppStrings.teleconsultVaue,
          //           style: AppTextStyle.textSemiBoldStyle(
          //               color: AppColors.black, fontSize: 14),
          //           children: [
          //             TextSpan(
          //               text: AppStrings.teleconsultText,
          //               style: AppTextStyle.textLightStyle(
          //                   color: AppColors.infoIconColor, fontSize: 12),
          //             ),
          //           ],
          //         ),
          //       ),
          //       RichText(
          //         text: TextSpan(
          //           text: AppStrings.onTimePercentage,
          //           style: AppTextStyle.textSemiBoldStyle(
          //               color: AppColors.black, fontSize: 14),
          //           children: [
          //             TextSpan(
          //               text: AppStrings.onTimeText,
          //               style: AppTextStyle.textLightStyle(
          //                   color: AppColors.infoIconColor, fontSize: 12),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            height: 1,
            width: width,
            color: const Color.fromARGB(255, 238, 238, 238),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            width: width,
            height: 31,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                // if (item[index].price!.value != null) {
                //   priceValue = item[index].price?.value;
                // }
                return GestureDetector(
                  onTap: () {
                    Get.to(() => DoctorsDetailPage(
                          // discoveryFulfillments: discoveryFulfillments,
                          //discoveryItems: item[index],
                          // discoveryProviders: widget.discoveryDetails!.message!
                          //     .catalog!.providers![0],
                          doctorAbhaId: discoveryFulfillments.agent!.id!,
                          doctorName: discoveryFulfillments.agent!.name!,
                          doctorProviderUri:
                              _discoveryResponse?.context?.providerUrl ?? "",
                          discoveryFulfillments: discoveryFulfillments,
                          consultationType: _consultationType!,
                          isRescheduling: false,
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.tileColors)),
                    height: 31,
                    width: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 2),
                          child: Text(
                            "₹ " +
                                discoveryFulfillments
                                    .agent!.tags!.firstConsultation!,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.amountColor, fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 2),
                          child: Text(
                            "HSPA",
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.amountColor, fontSize: 14),
                          ),
                        ),
                        // Image.asset(
                        //   'assets/images/esanjivani-logo.png',
                        //   height: 30,
                        //   width: 70,
                        // ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 20,
                );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          //   child: Row(
          //     // alignment: WrapAlignment.spaceBetween,
          //     // direction: Axis.horizontal,
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Get.to(() => const DoctorsDetailPage());
          //         },
          //         child: Container(
          //           decoration: BoxDecoration(
          //               color: AppColors.white,
          //               borderRadius: BorderRadius.circular(20),
          //               border: Border.all(color: AppColors.tileColors)),
          //           height: 31,
          //           width: 130,
          //           child: Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 2),
          //                 child: Text(
          //                   "Rs900",
          //                   style: AppTextStyle.textBoldStyle(
          //                       color: AppColors.amountColor, fontSize: 14),
          //                 ),
          //               ),
          //               Image.asset(
          //                 'assets/images/esanjivani-logo.png',
          //                 height: 30,
          //                 width: 70,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 10,
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           Get.to(() => const DoctorsDetailPage());
          //         },
          //         child: Container(
          //           decoration: BoxDecoration(
          //               color: AppColors.white,
          //               borderRadius: BorderRadius.circular(20),
          //               border: Border.all(color: AppColors.tileColors)),
          //           height: 31,
          //           width: 130,
          //           child: Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
          //                 child: Text(
          //                   "Rs500",
          //                   style: AppTextStyle.textBoldStyle(
          //                       color: AppColors.amountColor, fontSize: 14),
          //                 ),
          //               ),
          //               Image.asset(
          //                 'assets/images/Practo-logo.png',
          //                 height: 30,
          //                 width: 50,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  generateRadioButton({
    required SortBy value,
    required String label,
    required Function(SortBy? value) onTap,
  }) {
    return RadioListTile<SortBy>(
      groupValue: selectedSortValue,
      value: value,
      onChanged: onTap,
      title: Text(
        label,
        style: AppTextStyle.textMediumStyle(
            fontSize: 14, color: AppColors.doctorNameColor),
      ),
    );
  }
}

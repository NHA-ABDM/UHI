import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/constants.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/controller.dart';
import '../../../model/model.dart';
import '../../../model/request/src/booking_init_request_model.dart';
import '../../../services/services.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../view.dart';

class MultipleDoctorResultsPage extends StatefulWidget {
  String? doctor1Name;
  String? doctor2Name;
  String? doctor1Speciality;
  String? doctor2Speciality;
  String? doctor1City;
  String? doctor2City;
  List? doctor1Language;
  List? doctor2Language;
  String? startTime;
  String? endTime;
  String consultationType;

  MultipleDoctorResultsPage({
    this.doctor1Name,
    this.doctor2Name,
    required this.consultationType,
    this.doctor1Speciality,
    this.doctor2Speciality,
    this.doctor1City,
    this.doctor2City,
    this.doctor1Language,
    this.doctor2Language,
    this.startTime,
    this.endTime,
  });

  @override
  State<MultipleDoctorResultsPage> createState() =>
      _MultipleDoctorResultsPageState();
}

class _MultipleDoctorResultsPageState extends State<MultipleDoctorResultsPage> {
  ///CONTROLLERS
  PostDiscoveryDetailsController _postDiscoveryDetailsController =
      PostDiscoveryDetailsController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///DATA VARIABLES
  String? _doctor1Name;
  String? _doctor2Name;
  int? _selectedDoctorIndex;
  bool isFirstDoctor = true;
  bool isLoading = false;

  ///SEARCH PARAMS
  String? _specialityDoc1;
  String? _specialityDoc2;
  String? _cityDoc1;
  String? _cityDoc2;
  List? _doctorLanguage1;
  List? _doctorLanguage2;
  String? _startTime;
  String? _endTime;
  String _uniqueId = "";
  String? _consultationType;
  DiscoveryResponseModel? _discoveryResponse;
  List<DiscoveryResponseModel?> _listOfDiscoveryResponse =
      List.empty(growable: true);
  Future<List<List<DiscoveryResponseModel?>>>? futureDiscoveryResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();
  List<Fulfillment>? _fulfillments = [];
  List<DiscoveryItems>? discoveryItems = [];
  DiscoveryMessage? message;
  Fulfillment? _fulfillmentObjDoc1;
  Fulfillment? _fulfillmentObjDoc2;

  String? _providerUriDoc1;
  String? _providerUriDoc2;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _doctor1Name = widget.doctor1Name ?? "";
    _doctor2Name = widget.doctor2Name ?? "";
    _specialityDoc1 = widget.doctor1Speciality ?? "";
    _specialityDoc2 = widget.doctor2Speciality ?? "";
    _cityDoc1 = widget.doctor1City ?? "";
    _cityDoc2 = widget.doctor2City ?? "";
    _doctorLanguage1 = widget.doctor1Language ?? [];
    _doctorLanguage2 = widget.doctor2Language ?? [];
    _startTime = widget.startTime ?? "";
    _endTime = widget.endTime ?? "";
    _consultationType = widget.consultationType;

    if (mounted) {
      futureDiscoveryResponse = getResponseOfMultipleDoctors();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  showProgressIndicator() {
    setState(() {
      isLoading = true;
    });
  }

  hideProgressIndicator() {
    setState(() {
      isLoading = false;
    });
  }

  Future<List<List<DiscoveryResponseModel?>>>
      getResponseOfMultipleDoctors() async {
    _fulfillments?.clear();
    _listOfDiscoveryResponse.clear();

    List<List<DiscoveryResponseModel?>> listOfDicoveryResponseForMultipleDocs =
        List.empty(growable: true);
    List<DiscoveryResponseModel?> listOfFirstDiscoveryResponse;
    List<DiscoveryResponseModel?> listOfSecondDiscoveryResponse;

    listOfFirstDiscoveryResponse = await getFirstDoctorDiscoveryResponse();
    Future.delayed(Duration(seconds: 1));
    listOfSecondDiscoveryResponse = await getSecondDoctorDiscoveryResponse();

    listOfDicoveryResponseForMultipleDocs.add(listOfFirstDiscoveryResponse);
    listOfDicoveryResponseForMultipleDocs.add(listOfSecondDiscoveryResponse);

    return listOfDicoveryResponseForMultipleDocs;
  }

  Future<List<DiscoveryResponseModel?>>
      getFirstDoctorDiscoveryResponse() async {
    _fulfillments?.clear();
    _listOfDiscoveryResponse.clear();

    DiscoveryResponseModel? discoveryResponseModel;
    List<DiscoveryResponseModel?> listOfDiscoveryResponse =
        List.empty(growable: true);

    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postSearchAPIForDocOne);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        discoveryResponseModel =
            DiscoveryResponseModel.fromJson(json.decode(response.response!));
        // _timer?.cancel();
        if (discoveryResponseModel != null ||
            discoveryResponseModel?.message != null) {
          listOfDiscoveryResponse.add(discoveryResponseModel);
          listOfDiscoveryResponse = listOfDiscoveryResponse.toSet().toList();
        }
        log("${json.encode(listOfDiscoveryResponse)}", name: "RESPONSE");
        discoveryResponseModel = null;
      }
    };

    if (discoveryResponseModel == null ||
        discoveryResponseModel?.message == null) {
      await Timer.periodic(Duration(seconds: 1), (timer) async {
        if (timer.tick == 3) {
          _timer?.cancel();
        }
      });
    }

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return listOfDiscoveryResponse;
  }

  Future<List<DiscoveryResponseModel?>>
      getSecondDoctorDiscoveryResponse() async {
    _fulfillments?.clear();
    _listOfDiscoveryResponse.clear();

    DiscoveryResponseModel? discoveryResponseModel;
    List<DiscoveryResponseModel?> listOfDiscoveryResponse =
        List.empty(growable: true);

    _timer =
        await Timer.periodic(Duration(milliseconds: 100), (timer) async {});

    _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(
        uniqueId: _uniqueId, api: postSearchAPIForDocTwo);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        _timer?.cancel();
      } else {
        discoveryResponseModel =
            DiscoveryResponseModel.fromJson(json.decode(response.response!));
        // _timer?.cancel();
        if (discoveryResponseModel != null ||
            discoveryResponseModel?.message != null) {
          listOfDiscoveryResponse.add(discoveryResponseModel);
          listOfDiscoveryResponse = listOfDiscoveryResponse.toSet().toList();
        }
        log("${json.encode(listOfDiscoveryResponse)}", name: "RESPONSE");
        discoveryResponseModel = null;
      }
    };

    if (discoveryResponseModel == null ||
        discoveryResponseModel?.message == null) {
      await Timer.periodic(Duration(seconds: 1), (timer) async {
        if (timer.tick == 3) {
          _timer?.cancel();
        }
      });
    }

    while (_timer!.isActive) {
      // log("${_timer?.tick}");
      await Future.delayed(Duration(milliseconds: 100));
    }

    stompSocketConnection.disconnect();

    return listOfDiscoveryResponse;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureDiscoveryResponse = getResponseOfMultipleDoctors();
  }

  ///SEARCH API
  postSearchAPIForDocOne() async {
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
    Tags? tags = (_doctorLanguage1!.isNotEmpty) ? Tags() : null;
    // DiscoveryProviders? provider = _hospitalName1!.isNotEmpty ? DiscoveryProviders() : null;
    // DiscoveryDescriptor descriptor = DiscoveryDescriptor();
    // intent.provider = provider;
    // provider?.descriptor = descriptor;

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

    if (_doctor1Name!.isNotEmpty) {
      agent?.name = _doctor1Name;
    }
    if (_specialityDoc1 != "") {
      tags?.specialtyTag = _specialityDoc1;
    }
    // if (_hospitalDoc1!.isNotEmpty) {
    //   descriptor.name = _hospitalDoc1;
    // }
    if (_doctorLanguage1!.isNotEmpty) {
      tags?.languageSpokenTag = _doctorLanguage1?.join(",");
    }
    tags?.abdmGovInGroupConsultation = "";
    tags?.abdmGovInPrimaryDoctor = "";
    tags?.abdmGovInSecondaryDoctor = "";
    agent?.tags = tags;
    fulfillment.type = _consultationType;
    fulfillment.agent = agent;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("${jsonEncode(professionalNameRequestModel)}",
        name: "SEARCH 1 FOR DOC 1 MODEL");

    await _postDiscoveryDetailsController.postDiscoveryDetails(
        discoveryDetails: professionalNameRequestModel);
  }

  ///SEARCH API
  postSearchAPIForDocTwo() async {
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
    Tags? tags = (_doctorLanguage2!.isNotEmpty) ? Tags() : null;
    // DiscoveryProviders? provider = _hospitalName2!.isNotEmpty ? DiscoveryProviders() : null;
    // DiscoveryDescriptor descriptor = DiscoveryDescriptor();
    // intent.provider = provider;
    // provider?.descriptor = descriptor;

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

    if (_doctor2Name!.isNotEmpty) {
      agent?.name = _doctor2Name;
    }
    if (_specialityDoc2 != "") {
      tags?.specialtyTag = _specialityDoc2;
    }
    // if (_hospitalDoc2!.isNotEmpty) {
    //   descriptor.name = _hospitalDoc2;
    // }
    if (_doctorLanguage2!.isNotEmpty) {
      tags?.languageSpokenTag = _doctorLanguage2?.join(",");
    }

    tags?.abdmGovInGroupConsultation = "";
    tags?.abdmGovInPrimaryDoctor = "";
    tags?.abdmGovInSecondaryDoctor = "";

    fulfillment.type = _consultationType;
    fulfillment.agent = agent;
    agent?.tags = tags;
    intent.fulfillment = fulfillment;
    message.intent = intent;
    professionalNameRequestModel.message = message;

    log("${jsonEncode(professionalNameRequestModel)}",
        name: "SEARCH 1 DOC 2 MODEL");

    await _postDiscoveryDetailsController.postDiscoveryDetails(
        discoveryDetails: professionalNameRequestModel);
  }

  bool showAgentParameter() {
    if ((_doctor1Name != "" || _specialityDoc1 != "") ||
        (_doctor2Name != "" || _specialityDoc2 != "")) {
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

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () async {
            if (isFirstDoctor) {
              Get.back();
            } else {
              showProgressIndicator();
              await Future.delayed(Duration(seconds: 1));
              _fulfillments?.clear();
              _listOfDiscoveryResponse.clear();
              setState(() {
                isFirstDoctor = true;
              });
              hideProgressIndicator();
            }
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
    );
  }

  buildWidgets(Object? data) {
    if (_listOfDiscoveryResponse.isEmpty) {
      data = data as List;
      // _discoveryResponse = data as DiscoveryResponseModel;
      // fulfillments = _discoveryResponse?.message?.catalog?.fulfillments;
      if (data.isNotEmpty) {
        if (isFirstDoctor) {
          List tmpList = data[0];
          if (tmpList.isNotEmpty) {
            tmpList.forEach((element) {
              element = element as DiscoveryResponseModel;
              if (element.message != null) {
                _listOfDiscoveryResponse.add(element);
              }
            });
          }
        } else {
          List tmpList = data[1];
          if (tmpList.isNotEmpty) {
            tmpList.forEach((element) {
              element = element as DiscoveryResponseModel;
              if (element.message != null) {
                _listOfDiscoveryResponse.add(element);
              }
            });
          }
        }
      }

      // data.forEach((element) {
      //   if (isFirstDoctor) {
      //     if (element != null && element != []) {
      //       element.forEach((response) {
      //         if (response?.message != null) {
      //           _listOfDiscoveryResponse.add(response);
      //         }
      //       });
      //     }
      //   } else {
      //     if (data[1].isNotEmpty) {
      //       data[1].forEach((element) {
      //         if (element?.message != null) {
      //           _listOfDiscoveryResponse.add(element);
      //         }
      //       });
      //     }
      //   }
      // });

      _listOfDiscoveryResponse = _listOfDiscoveryResponse.toSet().toList();

      _listOfDiscoveryResponse.forEach((element) {
        if (element?.message?.catalog?.fulfillments != null) {
          _fulfillments?.addAll(
              element?.message?.catalog?.fulfillments as Iterable<Fulfillment>);
        }
      });

      _fulfillments = _fulfillments?.toSet().toList();

      // message = _discoveryResponse?.message;
    }

    return _fulfillments != null && _fulfillments!.isNotEmpty
        ? isLoading
            ? CommonLoadingIndicator()
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: buildDoctorsList(),
              )
        : RefreshIndicator(
            onRefresh: onRefresh,
            child: Stack(
              children: [
                ListView(),
                Container(
                  padding: EdgeInsets.all(15),
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
              ],
            ),
          );
  }

  buildDoctorsList() {
    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacing(
            isWidth: false,
            size: 15,
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Text(
              "Search results for ${((isFirstDoctor ? _doctor1Name : _doctor2Name) ?? "doctor 1")}",
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.black, fontSize: 15),
            ),
          ),
          Spacing(
            isWidth: false,
            size: 15,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _fulfillments?.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return buildDoctorTile(index: index);
              },
            ),
          ),
          InkWell(
            onTap: () async {
              if (_selectedDoctorIndex == null || _selectedDoctorIndex == "") {
                DialogHelper.showErrorDialog(
                    description: "Please select a doctor to continue.");
              } else if (isFirstDoctor) {
                showProgressIndicator();
                await Future.delayed(Duration(seconds: 1));
                _fulfillments?.clear();
                _listOfDiscoveryResponse.clear();
                setState(() {
                  isFirstDoctor = false;
                  _selectedDoctorIndex = null;
                });
                hideProgressIndicator();
              } else if (_fulfillmentObjDoc1?.agent?.id ==
                  _fulfillmentObjDoc2?.agent?.id) {
                DialogHelper.showErrorDialog(
                    description:
                        "Both doctors are same please select the different doctor");
              } else {
                log("${jsonEncode(_fulfillmentObjDoc1)}",
                    name: "DOCTOR 1 INFO");
                log("${jsonEncode(_fulfillmentObjDoc2)}",
                    name: "DOCTOR 2 INFO");
                Get.to(() => MultipleDoctorCommonSlotsPage(
                      doctor1AbhaId: _fulfillmentObjDoc1?.agent?.id ?? "",
                      doctor1Name: _fulfillmentObjDoc1?.agent?.name ?? "",
                      doctor1ProviderUri: _providerUriDoc1 ?? "",
                      doctor1DiscoveryFulfillments: _fulfillmentObjDoc1!,
                      doctor2AbhaId: _fulfillmentObjDoc2?.agent?.id ?? "",
                      doctor2Name: _fulfillmentObjDoc2?.agent?.name ?? "",
                      doctor2ProviderUri: _providerUriDoc2 ?? "",
                      doctor2DiscoveryFulfillments: _fulfillmentObjDoc2!,
                      consultationType: _consultationType!,
                      isRescheduling: false,
                      uniqueId: _uniqueId,
                    ));
              }
            },
            child: Container(
              width: width,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: isFirstDoctor
                    ? AppColors.amountColor
                    : AppColors.tileColors,
              ),
              child: Text(
                isFirstDoctor
                    ? "Proceed to select ${_doctor1Name!.contains("dr") ? "" : "Dr."} ${(_doctor2Name ?? "doctor 2")}"
                        .toUpperCase()
                    : "Confirm",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildDoctorTile({required int index}) {
    String? providerUri;
    bool imageNull = false;
    var decodedBytes;
    String profileImage;
    String gender;
    String speciality;
    String name;
    String? hospitalName;
    String consultationFees;

    Fulfillment discoveryFulfillments = _fulfillments![index];
    _listOfDiscoveryResponse.forEach(
      (discoveryResponse) {
        discoveryResponse?.message?.catalog?.fulfillments
            ?.forEach((fullfillment) {
          if (fullfillment.agent?.id == _fulfillments?[index].agent?.id) {
            providerUri = discoveryResponse.context?.providerUrl;
            hospitalName =
                discoveryResponse.message?.catalog?.descriptor?.name ?? "";
          }
        });
      },
    );
    profileImage = discoveryFulfillments.agent?.image ?? "";
    gender = discoveryFulfillments.agent?.gender ?? "";
    speciality = discoveryFulfillments.agent?.tags?.specialtyTag ?? "";
    name = discoveryFulfillments.agent?.name ?? "";
    name = name.split("-")[1].trim();
    hospitalName = hospitalName ?? "";
    consultationFees =
        discoveryFulfillments.agent?.tags?.firstConsultation ?? "";

    if (profileImage != "") {
      decodedBytes = base64Decode(profileImage);
      imageNull = true;
    } else {
      imageNull = false;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: index != ((_fulfillments?.length ?? 0) - 1)
            ? Border(
                bottom: BorderSide(
                width: 1,
                color: AppColors.grey787878,
              ))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: imageNull == false
                    ? AssetImage(gender == "M"
                        ? 'assets/images/male_doctor_avatar.png'
                        : 'assets/images/female_doctor_avatar.jpeg')
                    : Image.memory(decodedBytes).image,
              ),
              Spacing(size: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing(isWidth: false, size: 10),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.doctorNameColor, fontSize: 18),
                    ),
                    Spacing(isWidth: false, size: 5),
                    Text(
                      speciality,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.grey787878, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, right: 5),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 25,
                  color: AppColors.grey787878,
                ),
              ),
            ],
          ),
          Spacing(isWidth: false, size: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "$hospitalName",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.black, fontSize: 14),
                          // children: <TextSpan>[
                          //   TextSpan(
                          //     text: "Vasant Kunj",
                          //     style: AppTextStyle.textMediumStyle(
                          //         color: AppColors.grey8B8B8B, fontSize: 14),
                          //   ),
                          // ],
                        ),
                      ),
                      Spacing(size: 10),
                      RichText(
                        text: TextSpan(
                          text: "Rs $consultationFees ",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Consultation Fees",
                              style: AppTextStyle.textMediumStyle(
                                  color: AppColors.grey8B8B8B, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacing(size: 10),
              InkWell(
                onTap: () {
                  if (_selectedDoctorIndex == index) {
                    if (isFirstDoctor) {
                      _fulfillmentObjDoc1 = null;
                      _providerUriDoc1 = null;
                    } else {
                      _fulfillmentObjDoc2 = null;
                      _providerUriDoc2 = null;
                    }
                    setState(() {
                      _selectedDoctorIndex = null;
                    });
                  } else {
                    if (isFirstDoctor) {
                      _fulfillmentObjDoc1 = discoveryFulfillments;
                      _providerUriDoc2 = providerUri;
                    } else {
                      _fulfillmentObjDoc2 = discoveryFulfillments;
                      _providerUriDoc1 = providerUri;
                    }
                    setState(() {
                      _selectedDoctorIndex = index;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                  decoration: BoxDecoration(
                    color: _selectedDoctorIndex == index
                        ? AppColors.selectGreenColor
                        : AppColors.tileColors,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDoctorIndex == index ? "Selected" : "Select",
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          Spacing(isWidth: false, size: 10),
        ],
      ),
    );
  }
}

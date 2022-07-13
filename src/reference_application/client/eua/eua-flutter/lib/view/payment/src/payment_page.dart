import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/common/src/snackbar_message.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/booking/post_booking_details_controller.dart';
import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_on_confirm_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/model/response/src/response_model.dart';
import 'package:uhi_flutter_app/services/src/stomp_socket_connection.dart';
import 'package:uhi_flutter_app/utils/src/loading_indicator.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/appointment/src/appointment_status_confirm_page.dart';
import 'package:uuid/uuid.dart';

import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import 'package:upi_pay/upi_pay.dart';

class PaymentPage extends StatefulWidget {
  String? teleconsultationFees;
  String? doctorsUPIaddress;
  BookingOnInitResponseModel? bookingOnInitResponseModel;
  String consultationType;

  // BookingConfirmResponseModel? bookingConfirmResponseModel;
  PaymentPage({
    Key? key,
    this.teleconsultationFees,
    this.doctorsUPIaddress,
    this.bookingOnInitResponseModel,
    required this.consultationType,
    // this.bookingConfirmResponseModel,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<ApplicationMeta>? _apps;
  String? _upiAddrError;
  // ApplicationMeta? applicationMeta;
  String _uniqueId = "";
  int messageQueueNum = 0;
  StompClient? stompClient;
  String? abhaAddress;
  BookingOnInitResponseModel? _bookingOnInitResponseModel;
  final _postBookingDetailsController = Get.put(PostBookingDetailsController());

  BookingConfirmResponseModel? _confirmResponse;
  StompSocketConnection stompSocketConnection = StompSocketConnection();
  bool isLoadingIndicator = false;
  bool isBtnPressed = false;

  String? _consultationType;

  @override
  void initState() {
    super.initState();
    _bookingOnInitResponseModel = widget.bookingOnInitResponseModel;
    SharedPreferencesHelper.getABhaAddress().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference abhaAddress : $value");
            abhaAddress = value;
          });
        }));
    Future.delayed(Duration(milliseconds: 0), () async {
      _apps = await UpiPay.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all);
      setState(() {});
    });

    _consultationType = widget.consultationType;
  }

  @override
  void dispose() {
    stompSocketConnection.disconnect();
    super.dispose();
  }

  getConfirmResponse() async {
    BookingConfirmResponseModel? bookingConfirmResponseModel;
    _uniqueId = const Uuid().v1();

    stompSocketConnection.connect(uniqueId: _uniqueId, api: postConfirmAPI);
    stompSocketConnection.onResponse = (response) {
      if (response == null) {
        if (isBtnPressed) {
          DialogHelper.showErrorDialog(
              title: AppStrings().errorString,
              description: AppStrings().somethingWentWrongErrorMsg);
          setState(() {
            isLoadingIndicator = false;
            isBtnPressed = false;
          });
          stompSocketConnection.disconnect();
        }
      } else {
        bookingConfirmResponseModel = BookingConfirmResponseModel.fromJson(
            json.decode(response.response!));
        debugPrint("${json.encode(bookingConfirmResponseModel)}");
        if (bookingConfirmResponseModel != null) {
          _confirmResponse = bookingConfirmResponseModel;
          developer.log("${_confirmResponse?.message?.order?.state}");
          if (_confirmResponse?.message?.order?.state == "FAILED") {
            DialogHelper.showErrorDialog(
                title: AppStrings().failureString,
                description: AppStrings().bookingFailedMsg);
            setState(() {
              _confirmResponse == null;
              isLoadingIndicator = false;
              isBtnPressed = false;
            });
            stompSocketConnection.disconnect();
          } else if (_confirmResponse?.message?.order?.state == "CONFIRMED") {
            Get.to(() => AppointmentStatusConfirmPage(
                  bookingConfirmResponseModel: _confirmResponse,
                  consultationType: _consultationType,
                  navigateToHomeAndRefresh: true,
                ));
            setState(() {
              isLoadingIndicator = false;
              isBtnPressed = false;
            });
            stompSocketConnection.disconnect();
          }
        } else if (isBtnPressed) {
          DialogHelper.showErrorDialog(
              title: AppStrings().errorString,
              description: AppStrings().somethingWentWrongErrorMsg);
          setState(() {
            isLoadingIndicator = false;
            isBtnPressed = false;
          });
          stompSocketConnection.disconnect();
        }
      }
    };

    stompSocketConnection.disconnect();

    // await Future.delayed(Duration(milliseconds: 2000));
  }

  postConfirmAPI() async {
    String? userData;

    await SharedPreferencesHelper.getUserData().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference userData : $value");
            userData = value;
          });
        }));

    GetUserDetailsResponse? getUserDetailsResponseModel =
        GetUserDetailsResponse.fromJson(jsonDecode(userData!));

    final prefs = await SharedPreferences.getInstance();
    String? orderId = await prefs.getString(AppStrings().bookingOrderId);

    developer.log("$orderId", name: "ORDER ID");

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "confirm";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.timestamp = DateTime.now()
        .add(Duration(days: 4))
        .toLocal()
        .toUtc()
        .toIso8601String();
    contextModel.transactionId = _uniqueId;
    contextModel.providerUrl =
        _bookingOnInitResponseModel?.context?.providerUrl;

    BookOnConfirmResponseModel bookOnConfirmResponseModel =
        BookOnConfirmResponseModel();
    BookOnConfirmResponseMessage message = BookOnConfirmResponseMessage();
    BookingConfirmResponseOrder bookingConfirmResponseOrder =
        BookingConfirmResponseOrder();

    DiscoveryItems item = DiscoveryItems();
    DiscoveryDescriptor discoveryDescriptor = DiscoveryDescriptor();
    DiscoveryPrice priceFee = DiscoveryPrice();
    DiscoveryPrice priceCGST = DiscoveryPrice();
    DiscoveryPrice priceSGST = DiscoveryPrice();
    DiscoveryPrice priceReg = DiscoveryPrice();
    DiscoveryPrice price = DiscoveryPrice();

    Fulfillment fulfillment = Fulfillment();
    Billing? billing = Billing();
    Quote? quote = Quote();
    Payment? payment = Payment();
    Start start = Start();
    Start end = Start();
    Time startTime = Time();
    Time endTime = Time();
    Customer customer = Customer();
    Address address = Address();
    Breakup breakupPrice = Breakup();
    Breakup breakupSGST = Breakup();
    Breakup breakupCGST = Breakup();
    Breakup breakupReg = Breakup();
    Params params = Params();

    item.id = _bookingOnInitResponseModel?.message?.order?.item?.id;
    discoveryDescriptor.name = "Consultation";
    item.descriptor = discoveryDescriptor;
    item.fulfillmentId = _bookingOnInitResponseModel
        ?.message?.order?.fulfillment?.initTimeSlotTags?.abdmGovInSlotId;
    priceFee.currency =
        _bookingOnInitResponseModel?.message?.order?.item?.price?.currency;
    priceFee.value =
        _bookingOnInitResponseModel?.message?.order?.item?.price?.value;
    item.price = priceFee;

    startTime.timestamp = _bookingOnInitResponseModel
        ?.message?.order?.fulfillment?.start?.time?.timestamp;
    endTime.timestamp = _bookingOnInitResponseModel
        ?.message?.order?.fulfillment?.end?.time?.timestamp;
    start.time = startTime;
    end.time = endTime;

    fulfillment.start = start;
    fulfillment.end = end;
    fulfillment.agent =
        _bookingOnInitResponseModel?.message?.order?.fulfillment?.agent;
    fulfillment.type =
        _bookingOnInitResponseModel?.message?.order?.fulfillment?.type;
    fulfillment.id =
        _bookingOnInitResponseModel?.message?.order?.fulfillment?.id;
    fulfillment.initTimeSlotTags = _bookingOnInitResponseModel
        ?.message?.order?.fulfillment?.initTimeSlotTags;

    customer.id = "";
    // customer.cred = "vi.s@sbx";
    customer.cred = abhaAddress;

    billing.name = getUserDetailsResponseModel.fullName;
    billing.email = getUserDetailsResponseModel.email;
    billing.phone = getUserDetailsResponseModel.mobile;
    address.door = "21A";
    address.name = "ABC Apartments";
    address.locality = "Dwarka";
    address.city = "New Delhi";
    address.state = "New Delhi";
    address.country = "India";
    address.areaCode = "110011";
    billing.address = address;

    breakupPrice.title = "Consultation";
    breakupPrice.price = priceFee;

    breakupCGST.title = "CGST @ 5%";
    priceCGST.currency = "INR";
    priceCGST.value = "50";
    breakupCGST.price = priceCGST;

    breakupSGST.title = "SGST @ 5%";
    priceSGST.currency = "INR";
    priceSGST.value = "50";
    breakupSGST.price = priceSGST;

    breakupReg.title = "Registration";
    priceReg.currency = "INR";
    priceReg.value = "400";
    breakupReg.price = priceReg;

    price.currency =
        _bookingOnInitResponseModel?.message?.order?.item?.price?.currency;
    price.value =
        _bookingOnInitResponseModel?.message?.order?.item?.price?.value;

    quote.price = price;
    quote.breakup = [breakupPrice, breakupCGST, breakupSGST, breakupReg];

    params.amount = "1500";
    params.mode = "UPI";
    params.vpa = "sana.bhatt@upi";
    params.transactionId = "abc128-riocn83920";
    payment.uri =
        "https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi";
    payment.tlMethod = "http/get";
    payment.status = "PAID";
    payment.type = "ON-ORDER";
    payment.params = params;

    bookingConfirmResponseOrder.id = orderId;
    bookingConfirmResponseOrder.fulfillment = fulfillment;
    bookingConfirmResponseOrder.item = item;
    bookingConfirmResponseOrder.customer = customer;
    bookingConfirmResponseOrder.billing = billing;
    bookingConfirmResponseOrder.payment = payment;
    bookingConfirmResponseOrder.quote = quote;

    message.order = bookingConfirmResponseOrder;

    bookOnConfirmResponseModel.context = contextModel;
    bookOnConfirmResponseModel.message = message;

    developer.log("==> ${jsonEncode(bookOnConfirmResponseModel)}");

    await _postBookingDetailsController.postConfirmBookingDetails(
        bookOnConfirmResponseModel: bookOnConfirmResponseModel);
  }

  @override
  Widget build(BuildContext context) {
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
          AppStrings().payment,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 24),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        generateHeadingCard(),
                        Spacing(isWidth: false, size: 16),
                        generateUserDetailsCard(),
                        Spacing(isWidth: false, size: 8),
                        Row(
                          children: [
                            Text(
                              AppStrings().paymentUPI,
                              style: AppTextStyle.textSemiBoldStyle(
                                  color: AppColors.black, fontSize: 14),
                            ),
                            Expanded(child: Container()),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.paymentButtonBackgroundColor,
                                size: 20,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Spacing(isWidth: false, size: 8),
                        getCenterTextWidget(text: AppStrings().installedApps),
                        Spacing(isWidth: false, size: 8),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //         child: generateUPIView(
                        //             asset: 'assets/images/gpay_logo.png',
                        //             upiAppName: 'Google Pay')),
                        //     Spacing(size: 4),
                        //     Expanded(
                        //         child: generateUPIView(
                        //             asset: 'assets/images/phonepe_logo.png',
                        //             upiAppName: 'PhonePe')),
                        //   ],
                        // ),
                        Platform.isAndroid ? _androidApps() : _iosApps(),
                        Spacing(isWidth: false, size: 8),
                        getCenterTextWidget(text: AppStrings().orText),
                        Spacing(isWidth: false, size: 8),
                        Text(
                          AppStrings().UPIId,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 12),
                        ),
                        Spacing(isWidth: false, size: 4),
                        TextField(
                          expands: false,
                          decoration: InputDecoration(
                              isDense: true,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        AppColors.paymentButtonBackgroundColor,
                                    width: 0.5),
                                borderRadius: BorderRadius.zero,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.doctorExperienceColor,
                                    width: 0.5),
                                borderRadius: BorderRadius.zero,
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 0.5),
                                borderRadius: BorderRadius.zero,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              filled: false,
                              hintStyle: AppTextStyle.textLightStyle(
                                  color: AppColors.testColor, fontSize: 14),
                              hintText: AppStrings().UPIAddress,
                              fillColor: Colors.white70),
                        ),
                        Spacing(isWidth: false, size: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.paymentButtonBackgroundColor,
                            minimumSize: const Size.fromHeight(40),
                          ),
                          onPressed: isBtnPressed
                              ? null
                              : () async {
                                  setState(() {
                                    isLoadingIndicator = true;
                                    isBtnPressed = true;
                                  });
                                  await getConfirmResponse();

                                  // if (_confirmResponse != null) {
                                  //   Get.to(() => AppointmentStatusConfirmPage(
                                  //         bookingConfirmResponseModel:
                                  //             _confirmResponse,
                                  //         consultationType: _consultationType,
                                  //       ));
                                  // } else {
                                  // snackbarMessage(
                                  //   message: "Some error occurred",
                                  //   icon: Icons.error,
                                  // );
                                  // }
                                  //_onTap();
                                  // if (_confirmResponse?.message?.order?.state ==
                                  //     "FAILED") {
                                  //   DialogHelper.showErrorDialog(
                                  //       title: AppStrings().failureString,
                                  //       description:
                                  //           AppStrings().bookingFailedMsg);
                                  // } else if (_confirmResponse
                                  //         ?.message?.order?.state ==
                                  //     "CONFIRMED") {
                                  //   Get.to(() => AppointmentStatusConfirmPage(
                                  //         bookingConfirmResponseModel:
                                  //             _confirmResponse,
                                  //         consultationType: _consultationType,
                                  //       ));
                                  // }
                                },
                          child: isLoadingIndicator
                              ? CommonLoadingIndicator(
                                  size: 6, color: Colors.white)
                              : Text(
                                  widget.teleconsultationFees!,
                                  style: AppTextStyle.textBoldStyle(
                                      fontSize: 18, color: AppColors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI VPA is required.';
    }
    if (value.split('@').length != 2) {
      return 'Invalid UPI VPA';
    }
    return null;
  }

  Future<void> _onTap(ApplicationMeta applicationMeta) async {
    final err = _validateUpiAddress(widget.doctorsUPIaddress!);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });
    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");
    final a = await UpiPay.initiateTransaction(
      // amount: widget.teleconsultationFees!,
      amount: "2.00",
      app: applicationMeta.upiApplication,
      receiverName: 'UHI',
      //receiverUpiAddress: widget.doctorsUPIaddress!,
      receiverUpiAddress: "swanandmarathe89-1@okhdfcbank",
      transactionRef: transactionRef,
      transactionNote: 'UPI Payment',
      // merchantCode: '7372',
    );

    print(a);
  }

  Widget _iosApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Text(
              'One of these will be invoked automatically by your phone to '
              'make a payment',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Detected Installed Apps',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (_apps != null) _discoverableAppsGrid(),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              'Other Supported Apps (Cannot detect)',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (_apps != null) _nonDiscoverableAppsGrid(),
        ],
      ),
    );
  }

  Widget _androidApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Pay Using',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (_apps != null) _appsGrid(_apps!.map((e) => e).toList()),
        ],
      ),
    );
  }

  GridView _discoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    _apps!.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme != null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _nonDiscoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    _apps!.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme == null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication
        .getAppName()
        .toLowerCase()
        .compareTo(b.upiApplication.getAppName().toLowerCase()));
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      // childAspectRatio: 1.6,
      physics: NeverScrollableScrollPhysics(),
      children: apps
          .map(
            (it) => Material(
              key: ObjectKey(it.upiApplication),
              // color: Colors.grey[200],
              child: InkWell(
                onTap: Platform.isAndroid ? () => _onTap(it) : null,
                // onTap: () {
                //   setState(() {
                //     applicationMeta = it;
                //   });
                // },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    it.iconImage(48),
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      alignment: Alignment.center,
                      child: Text(
                        it.upiApplication.getAppName(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

generateHeadingCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              child: Text(
                'OP',
                style: AppTextStyle.textBoldStyle(
                    fontSize: 16, color: AppColors.white),
              ),
              radius: 20,
              backgroundColor: AppColors.paymentButtonBackgroundColor,
            ),
          ),
        ),
        Spacing(
          size: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings().UHIEUA,
              style: AppTextStyle.textMediumStyle(
                  fontSize: 14, color: AppColors.doctorNameColor),
            ),
            Spacing(
              isWidth: false,
              size: 4,
            ),
            Text(
              AppStrings().UPIIntend,
              style: AppTextStyle.textLightStyle(
                  fontSize: 12, color: AppColors.infoIconColor),
            ),
            Spacing(
              isWidth: false,
              size: 4,
            ),
            Text(
              '₹ 900/-',
              style: AppTextStyle.textBoldStyle(
                  fontSize: 18, color: AppColors.white),
            ),
          ],
        )
      ],
    ),
  );
}

generateUserDetailsCard() {
  return Container(
    child: ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: const Icon(
          Icons.account_circle_outlined,
          size: 24,
          color: AppColors.paymentButtonBackgroundColor,
        ),
        backgroundColor: AppColors.paymentButtonBackgroundColor.withAlpha(50),
        radius: 20,
      ),
      title: Text(
        'Demo Name',
        style: AppTextStyle.textMediumStyle(
            color: AppColors.testColor, fontSize: 12),
      ),
      subtitle: Text(
        '905*****89',
        style: AppTextStyle.textLightStyle(
            color: AppColors.testColor, fontSize: 12),
      ),
      trailing: TextButton(
        child: Text(
          AppStrings().editText,
          style: AppTextStyle.textBoldStyle(
              color: AppColors.primaryLightBlue007BFF, fontSize: 14),
        ),
        onPressed: () {},
      ),
    ),
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(width: 0.5, color: AppColors.doctorExperienceColor),
        bottom: BorderSide(width: 0.5, color: AppColors.doctorExperienceColor),
        right: BorderSide(width: 0.5, color: AppColors.doctorExperienceColor),
      ),
      color: Colors.white,
    ),
  );
}

getCenterTextWidget({required String text}) {
  return Center(
      child: Text(
    text,
    style:
        AppTextStyle.textMediumStyle(color: AppColors.testColor, fontSize: 12),
  ));
}

generateUPIView({required String asset, required String upiAppName}) {
  return Container(
    // height: 20,
    // width: 20,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          asset,
          height: 20,
          width: 20,
        ),
        Spacing(size: 8),
        Text(
          upiAppName,
          style: AppTextStyle.textLightStyle(
              color: AppColors.testColor, fontSize: 12),
        ),
      ],
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.zero,
      border: Border.all(color: AppColors.doctorExperienceColor, width: 0.5),
    ),
    padding: const EdgeInsets.all(12),
  );
}

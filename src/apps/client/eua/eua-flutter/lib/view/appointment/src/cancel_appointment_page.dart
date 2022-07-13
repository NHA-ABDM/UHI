import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

class CancelAppointment extends StatefulWidget {
  Fulfillment? discoveryFulfillments;
  CancelAppointment({Key? key, this.discoveryFulfillments}) : super(key: key);

  @override
  State<CancelAppointment> createState() => _CancelAppointmentState();
}

class _CancelAppointmentState extends State<CancelAppointment> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  String? _selectedDate;
  int? _selectedTimeSlotIndex;

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
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
          AppStrings().cancelAppointment,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    String? amount =
        widget.discoveryFulfillments!.agent!.tags!.firstConsultation!;
    String appointmentStartDate = "";
    String appointmentStartTime = "";
    var tmpStartDate;
    tmpStartDate = widget.discoveryFulfillments!.start!.time!.timestamp;
    appointmentStartDate =
        DateFormat("dd MMM y").format(DateTime.parse(tmpStartDate));
    appointmentStartTime =
        DateFormat("hh:mm a").format(DateTime.parse(tmpStartDate));
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  DoctorDetailsView(
                    doctorAbhaId: widget.discoveryFulfillments!.agent!.id!,
                    doctorName: widget.discoveryFulfillments!.agent!.name!,
                    tags: widget.discoveryFulfillments!.agent!.tags!,
                    gender: widget.discoveryFulfillments!.agent!.gender!,
                    profileImage: widget.discoveryFulfillments!.agent?.image,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      AppStrings().selectedTimeForConsultation,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          //"Monday April 17th 5pm",
                          appointmentStartDate + " at " + appointmentStartTime,
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.testColor, fontSize: 15),
                        ),
                        Text(
                          "Paid ₹ $amount/-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.amountColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      AppStrings().cancelAppointmentTerms,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                NewConfirmationDialog(
                    context: context,
                    title: AppStrings().cancelAppointment,
                    description: AppStrings().cancelAppointmentConfirmation,
                    submitButtonText: "",
                    onCancelTap: () {
                      // Navigator.pop(context);
                      Get.back();
                    },
                    onSubmitTap: () {
                      //Navigator.pop(context);
                      Get.back();
                    }).showAlertDialog();
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 50,
                width: width * 0.89,
                decoration: const BoxDecoration(
                  color: AppColors.amountColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings().cancelAppointmentCaps,
                    style: AppTextStyle.textSemiBoldStyle(
                        color: AppColors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

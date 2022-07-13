import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/src/calendar_date_range_picker.dart';
import 'package:uhi_flutter_app/widgets/src/doctor_details_view.dart';
import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

class UpdateAppointment extends StatefulWidget {
  Fulfillment? discoveryFulfillments;
  UpdateAppointment({Key? key, this.discoveryFulfillments}) : super(key: key);

  @override
  State<UpdateAppointment> createState() => _UpdateAppointmentPageState();
}

class _UpdateAppointmentPageState extends State<UpdateAppointment> {
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
    final DateFormat formatter = DateFormat('MMMM d');
    _selectedDate = formatter.format(DateTime.now());
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
          AppStrings().updateAppointment,
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
                  const SizedBox(
                    height: 5,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(30, 0, 16, 16),
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
                  //                   color: AppColors.infoIconColor,
                  //                   fontSize: 12),
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
                  //                   color: AppColors.infoIconColor,
                  //                   fontSize: 12),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 8, 3),
                        child: Text(
                          "₹ $amount /-",
                          style: AppTextStyle.textBoldStyle(
                              color: AppColors.amountColor, fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      // Center(
                      //   child: Image.asset(
                      //     'assets/images/Practo-logo.png',
                      //     height: 40,
                      //     width: 60,
                      //   ),
                      // ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: 1,
                    width: width,
                    color: const Color.fromARGB(255, 238, 238, 238),
                  ),
                  GestureDetector(
                    onTap: () {
                      datePicker();
                    },
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                          width: 154,
                          height: 36,
                          decoration: BoxDecoration(
                              color: AppColors.tileColors,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.tileColors)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  _selectedDate!,
                                  style: AppTextStyle.textSemiBoldStyle(
                                      color: AppColors.white, fontSize: 14),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 8, 10),
                    child: Text(
                      AppStrings().chooseTimeSlot,
                      style: AppTextStyle.textLightStyle(
                          color: AppColors.infoIconColor, fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 10),
                    height: height * 0.14,
                    child: GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: 8,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTimeSlotIndex = index;
                              });
                            },
                            child: Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                decoration: BoxDecoration(
                                    color: _selectedTimeSlotIndex == index
                                        ? AppColors.tileColors
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: AppShadows.shadow2,
                                    border: Border.all(
                                        color: AppColors.tileColors)),
                                child: Center(
                                  child: Text(
                                    AppStrings().showTime,
                                    style: _selectedTimeSlotIndex == index
                                        ? AppTextStyle.textSemiBoldStyle(
                                            color: AppColors.white,
                                            fontSize: 14)
                                        : AppTextStyle.textMediumStyle(
                                            color: AppColors.darkGrey323232,
                                            fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  //   height: 1,
                  //   width: width,
                  //   color: const Color.fromARGB(255, 238, 238, 238),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.fromLTRB(20, 0, 8, 10),
                  //   child: Text(
                  //     "Patient Feedback",
                  //     style: AppTextStyle.subHeading3TextStyle,
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 30,
                  // ),
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
                    title: AppStrings().updateAppointment,
                    description: AppStrings().updateAppointmentCost,
                    submitButtonText: "",
                    onCancelTap: () {
                      Navigator.pop(context);
                    },
                    onSubmitTap: () {
                      Get.back();
                      // Get.to(AppointmentDetailsDetailPage());
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
                    AppStrings().updateAppointmentCaps,
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

  datePicker() {
    //var tmpSelectedDate = Jiffy(_workoutDate, "dd MMM yyyy").local();
    CalendarDateRangePicker(
      context: context,
      isDateRange: false,
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
      minDateTime: DateTime.now(),
      onDateSubmit: (startDate, endDate) {
        final DateFormat formatter = DateFormat('dd MMM yyyy');
        setState(() {
          _selectedDate = DateFormat('MMMM d').format(startDate!);
          debugPrint("=====>$_selectedDate");
        });
      },
    ).sfDatePicker();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/view/doctor_setup/src/fees_page.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/doctor_setup_controller.dart';
import '../../../model/response/src/add_appointment_time_slot_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/alert_dialog_with_single_action.dart';
import '../../../widgets/src/calendar_date_range_picker.dart';
import '../../../widgets/src/new_confirmation_dialog.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';

class DayTimeSelectionPage extends StatefulWidget {
  const DayTimeSelectionPage({Key? key}) : super(key: key);

/*  const DayTimeSelectionPage(
      {Key? key, required this.consultType, this.isExisting = false})
      : super(key: key);
  final String consultType;
  final bool isExisting;*/

  @override
  State<DayTimeSelectionPage> createState() => _DayTimeSelectionPageState();
}

class _DayTimeSelectionPageState extends State<DayTimeSelectionPage> {

  late final String consultType;
  bool isExisting = false;

  bool isLoading = false;
  List<Days> days = <Days>[];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController fixedTimeController = TextEditingController();
  late bool isFixed;
  bool isExcludeWeekend = false;
  List<DateTime> dateTimeSlot = <DateTime>[];
  late DateTime startDate;
  late DateTime endDate;
  String? _selectedDateRange;
  final DateFormat formatter = DateFormat('dd-MMM-yyyy');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    fixedTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {

    /// Get arguments
    consultType = Get.arguments['consultType'];
    if(Get.arguments['isExisting'] != null) {
      isExisting = Get.arguments['isExisting'];
    }

    startDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 6));
    _selectedDateRange =
        '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    days.add(Days(intDay: 0, day: 'Mon', selected: true));
    days.add(Days(intDay: 1, day: 'Tue'));
    days.add(Days(intDay: 2, day: 'Wed'));
    days.add(Days(intDay: 3, day: 'Thu'));
    days.add(Days(intDay: 4, day: 'Fri'));
    days.add(Days(intDay: 5, day: 'Sat'));
    days.add(Days(intDay: 6, day: 'Sun'));

    startTimeController.text = AppStrings().labelStartTime;
    endTimeController.text = AppStrings().labelEndTime;
    isFixed = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Get.back(result: false);
        return true;
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          backgroundColor: AppColors.appBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.appBackgroundColor,
            shadowColor: Colors.black.withOpacity(0.1),
            titleSpacing: 0,
            title: Text(
              consultType,
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.black, fontSize: 18),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.black,
              ),
              onPressed: () {
                Get.back(result: false);
              },
            ),
          ),
          body: buildBody(),
        ),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isExisting)
                      const LinearProgressIndicator(
                        backgroundColor: AppColors.progressBarBackColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.amountColor,
                        ),
                        value: 0.40,
                        minHeight: 8,
                      ),
                    if (!isExisting)
                      VerticalSpacing(
                        size: 20,
                      ),
                    Text(
                      AppStrings().labelChooseDatesAndTime,
                      style: AppTextStyle.textSemiBoldStyle(
                          fontSize: 18, color: AppColors.titleTextColor),
                    ),
                    VerticalSpacing(),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        generateDayWidget(day: days[0]),
                        generateDayWidget(day: days[1]),
                        generateDayWidget(day: days[2]),
                        generateDayWidget(day: days[3]),
                        generateDayWidget(day: days[4]),
                        generateDayWidget(day: days[5]),
                        generateDayWidget(day: days[6]),
                      ],
                    ),*/

                    GestureDetector(
                      onTap: () {
                        datePicker();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        height: 36,
                        decoration: BoxDecoration(
                            color: AppColors.tileColors,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.tileColors)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDateRange!,
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
                    ),
                    VerticalSpacing(
                      size: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          /*child: showTimeViewController(
                              controller: startTimeController,
                              time: startTime,
                              labelText: AppStrings(.labelStartTime),*/
                          child: TextFormField(
                            controller: startTimeController,
                            readOnly: true,
                            onTap: () async {
                              startTime = await showTimePicker(
                                  context: context,
                                  initialTime: startTime ?? TimeOfDay.now(),
                                  onEntryModeChanged: null);

                              if (startTime != null) {
                                setState(() {
                                  debugPrint(
                                      'Picked time is ${startTime!.format(context)}');
                                  late String hourString, minuteString;
                                  if (startTime!.hourOfPeriod > 9) {
                                    hourString =
                                        startTime!.hourOfPeriod.toString();
                                  } else {
                                    hourString = '0' +
                                        startTime!.hourOfPeriod.toString();
                                  }

                                  if (startTime!.minute > 9) {
                                    minuteString = startTime!.minute.toString();
                                  } else {
                                    minuteString =
                                        '0' + startTime!.minute.toString();
                                  }
                                  startTimeController.text =
                                      '$hourString:$minuteString ${startTime!.period.name}';
                                });
                              }
                            },
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              decorationColor: AppColors.feesLabelTextColor,
                            ),
                          ),
                        ),
                        Spacing(
                          size: 20,
                        ),
                        Expanded(
                          /*child: showTimeViewController(
                              controller: endTimeController,
                              time: endTime,
                              labelText: AppStrings(.labelEndTime),*/
                          child: TextFormField(
                            controller: endTimeController,
                            readOnly: true,
                            onTap: () async {
                              endTime = await showTimePicker(
                                  context: context,
                                  initialTime: endTime ?? TimeOfDay.now(),
                                  onEntryModeChanged: null);

                              if (endTime != null) {
                                setState(() {
                                  debugPrint(
                                      'Picked time is ${endTime!.format(context)}');
                                  late String hourString, minuteString;
                                  if (endTime!.hourOfPeriod > 9) {
                                    hourString =
                                        endTime!.hourOfPeriod.toString();
                                  } else {
                                    hourString =
                                        '0' + endTime!.hourOfPeriod.toString();
                                  }

                                  if (endTime!.minute > 9) {
                                    minuteString = endTime!.minute.toString();
                                  } else {
                                    minuteString =
                                        '0' + endTime!.minute.toString();
                                  }
                                  endTimeController.text =
                                      '$hourString:$minuteString ${endTime!.period.name}';
                                });
                              }
                            },
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              decorationColor: AppColors.feesLabelTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    VerticalSpacing(
                      size: 20,
                    ),
                    CheckboxListTile(
                      dense: true,
                      value: isExcludeWeekend,
                      activeColor: AppColors.tileColors,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => const BorderSide(
                            width: 1.0, color: AppColors.tileColors),
                      ),
                      title: Text(AppStrings().labelExcludeWeekends,
                          style: AppTextStyle.textMediumStyle(
                              fontSize: 12,
                              color: AppColors.checkboxTitleTextColor)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onChanged: (bool? value) {
                        setState(() {
                          isExcludeWeekend = !isExcludeWeekend;
                        });
                      },
                    ),
                    VerticalSpacing(
                      size: 10,
                    ),
                    CheckboxListTile(
                      value: isFixed,
                      activeColor: AppColors.tileColors,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => const BorderSide(
                            width: 1.0, color: AppColors.tileColors),
                      ),
                      title: Text(AppStrings().labelFixed,
                          style: AppTextStyle.textMediumStyle(
                              fontSize: 12,
                              color: AppColors.checkboxTitleTextColor)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onChanged: (bool? value) {
                        /*setState(() {
                          isFixed = value ?? isFixed;
                        });*/
                      },
                    ),
                    if (isFixed) showFixedView()
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacing(
                isWidth: false,
                size: 16,
              ),
              SquareRoundedButtonWithIcon(
                  text: isExisting
                      ? AppStrings().btnSubmit
                      : AppStrings().btnNext,
                  assetImage: AssetImages.arrowLongRight,
                  onPressed: () async {
                    int? difference = getDifference();

                    if (endDate.difference(startDate).inDays > 6) {
                      Get.snackbar(AppStrings().alert,
                          AppStrings().errorInvalidDateRange);
                    } else if (startTime == null) {
                      Get.snackbar(AppStrings().alert,
                          AppStrings().errorSelectStartTime);
                    } else if (endTime == null) {
                      Get.snackbar(
                          AppStrings().alert, AppStrings().errorSelectEndTime);
                    } else if (difference != null && difference <= 0) {
                      Get.snackbar(AppStrings().alert,
                          AppStrings().errorInvalidTimeRange);
                    } else if (difference != null && difference < 10) {
                      Get.snackbar(AppStrings().alert,
                          AppStrings().errorNotMatchedMinimumTimeRange, duration: const Duration(seconds: 5));
                    } else if (isFixed && !_formKey.currentState!.validate()) {
                      setState(() {
                        _autoValidateMode = AutovalidateMode.always;
                      });
                    } else {
                      /// Below logic used to check if start date and time is not before current date and time.
                      DateTime startDateTime = DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          startTime!.hour,
                          startTime!.minute);
                      debugPrint(
                          'start date time is $startDateTime and current date time is ${DateTime.now()}');
                      if (startDateTime.isBefore(DateTime.now())) {
                        Get.snackbar(AppStrings().alert,
                            AppStrings().errorInvalidStartTimeRange);
                      } else {
                        dateTimeSlot.clear();
                        await createTimeSlots();
                        if (dateTimeSlot.isNotEmpty) {
                          DoctorSetupValues doctorSetupValues =
                              DoctorSetupValues();
                          doctorSetupValues.dateTimeSlot.clear();
                          doctorSetupValues.dateTimeSlot.addAll(dateTimeSlot);
                          doctorSetupValues.startDate = startDate;
                          doctorSetupValues.endDate = endDate;
                          doctorSetupValues.startTime = startTime;
                          doctorSetupValues.endTime = endTime;
                          doctorSetupValues.isFixed = isFixed;
                          doctorSetupValues.fixedDurationSlot =
                              int.parse(fixedTimeController.text.trim());
                          if (isExisting) {
                            showAlreadySlotsDiscardDialog(doctorSetupValues);
                            //handleAppointmentSlotsAPI(doctorSetupValues);
                          } else {
                            /*Get.to(
                              () => FeesPage(
                                consultType: consultType,
                              ),
                              transition: Utility.pageTransition,
                            );*/
                            Get.toNamed(AppRoutes.feesPage, arguments: {'consultType': consultType});
                          }
                        } else {
                          Get.snackbar(
                              AppStrings().alert,
                              AppStrings()
                                  .errorNoSlotsAvailableAsExcludeWeenEnds,
                              duration: const Duration(seconds: 5));
                        }
                      }
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }

  generateDayWidget({required Days day}) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          day.selected = !day.selected;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      mini: true,
      elevation: 0,
      child: Text(
        day.day,
        style: AppTextStyle.textSemiBoldStyle(
            fontSize: 14,
            color: day.selected ? AppColors.white : AppColors.tileColors),
      ),
      backgroundColor:
          day.selected ? AppColors.tileColors : AppColors.unselectedBackColor,
    );
  }

  showTimeView({required TimeOfDay? time, required String labelText}) {
    return GestureDetector(
      onTap: () async {
        time = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
            onEntryModeChanged: null);

        if (time != null) {
          setState(() {
            debugPrint('Picked time is $time');
          });
        }
      },
      child: Text(
        time != null ? time!.toString() : labelText,
        style: GoogleFonts.roboto(
          shadows: [
            const Shadow(
                color: AppColors.feesLabelTextColor, offset: Offset(0, -10))
          ],
          color: Colors.transparent,
          fontWeight: FontWeight.w300,
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.feesLabelTextColor,
        ),
      ),
    );
  }

  showTimeViewController(
      {required TextEditingController controller,
      required TimeOfDay? time,
      required String labelText}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        time = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
            onEntryModeChanged: null);

        if (time != null) {
          setState(() {
            debugPrint('Picked time is ${time!.format(context)}');
            late String hourString, minuteString;
            if (time!.hourOfPeriod > 9) {
              hourString = time!.hourOfPeriod.toString();
            } else {
              hourString = '0' + time!.hourOfPeriod.toString();
            }

            if (time!.minute > 9) {
              minuteString = time!.minute.toString();
            } else {
              minuteString = '0' + time!.minute.toString();
            }
            controller.text = '$hourString:$minuteString ${time!.period.name}';
          });
        }
      },
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.w300,
        fontSize: 14,
        decorationColor: AppColors.feesLabelTextColor,
      ),
    );
  }

  showFixedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing(),
        Text(
          AppStrings().labelFixedDurationSlot,
          style: AppTextStyle.textBoldStyle(
              fontSize: 16, color: AppColors.tileColors),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: fixedTimeController,
                keyboardType: TextInputType.number,
                autovalidateMode: _autoValidateMode,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings().errorEnterTimeInMinutes;
                  } else if (int.tryParse(value.trim()) == null) {
                    return AppStrings().errorEnterValidTime;
                  } else if (int.parse(value.trim()) <= 0) {
                    return AppStrings().errorEnterNonZeroTime;
                  } else if (int.parse(value.trim()) < 10) {
                    return AppStrings().errorMinimumSlotDuration;
                  } else {
                    if (startTime != null && endTime != null) {
                      int? difference = getDifference();
                      if (difference != null && difference < 10) {
                        return null;
                      } else if (difference != null &&
                          difference < int.parse(value.trim())) {
                        return AppStrings()
                            .errorEnterValidTimeRange(difference);
                      } else {
                        return null;
                      }
                    } else {
                      return null;
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: AppStrings().labelTimeInMin,
                  labelStyle: AppTextStyle.textLightStyle(
                      fontSize: 14, color: AppColors.feesLabelTextColor),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.titleTextColor),
                  ),
                ),
              ),
            ),
            // Spacing(),
            // Expanded(child: Container())
          ],
        )
      ],
    );
  }

  datePicker() {
    CalendarDateRangePicker(
      context: context,
      isDateRange: true,
      initialDate: startDate,
      lastDate: endDate,
      minDateTime: DateTime.now(),
      onDateSubmit: (startDate, endDate) {
        if (startDate != null) {
          endDate ??= startDate;
          setState(() {
            this.startDate = startDate;
            this.endDate =
                DateTime(endDate!.year, endDate.month, endDate.day, 23, 59, 59);
            _selectedDateRange =
                '${formatter.format(startDate)} - ${formatter.format(endDate)}';
          });
        }
      },
    ).sfDatePicker();
  }

  Future<void> createTimeSlots() async {
    Duration step =
        Duration(minutes: int.parse(fixedTimeController.text.trim()));
    DateTime localStartDate = startDate;
    debugPrint(
        'In create time slot start date $localStartDate and end Date is $endDate ${localStartDate.isBefore(endDate)}');

    if (!localStartDate.isBefore(endDate)) {
      if (localStartDate.weekday != 6 && localStartDate.weekday != 7) {
        createTimeSlotForDay(localStartDate: localStartDate, step: step);
      } else if (!isExcludeWeekend) {
        createTimeSlotForDay(localStartDate: localStartDate, step: step);
      }
    } else {
      while (localStartDate.isBefore(endDate)) {
        if (localStartDate.weekday != 6 && localStartDate.weekday != 7) {
          createTimeSlotForDay(localStartDate: localStartDate, step: step);
        } else if (!isExcludeWeekend) {
          createTimeSlotForDay(localStartDate: localStartDate, step: step);
        }
        localStartDate = localStartDate.add(const Duration(days: 1));
      }
    }
  }

  createTimeSlotForDay(
      {required DateTime localStartDate, required Duration step}) {
    DateTime startDateTime = DateTime(localStartDate.year, localStartDate.month,
        localStartDate.day, startTime!.hour, startTime!.minute, 00);
    DateTime endDateTime = DateTime(localStartDate.year, localStartDate.month,
        localStartDate.day, endTime!.hour, endTime!.minute, 00);
    debugPrint(
        'Start Date is $localStartDate and start date time is $startDateTime and end date time is $endDateTime');

    if (startDateTime.isAfter(endDateTime)) {
      /// Create time slot from start date time to midnight of the start date
      endDateTime = DateTime(localStartDate.year, localStartDate.month,
          localStartDate.day, 23, 59, 59);
      while (startDateTime.isBefore(endDateTime)) {
        debugPrint('Start Date is Created date time slot is $startDateTime');
        dateTimeSlot.add(startDateTime);
        startDateTime = startDateTime.add(step);
      }

      /// Here we will check and create time slot for next day till end time
      startDateTime = DateTime(startDateTime.year, startDateTime.month,
          startDateTime.day, 00, 00, 00);
      //startDateTime = startDateTime.add(const Duration(days: 1));
      endDateTime = DateTime(startDateTime.year, startDateTime.month,
          startDateTime.day, endTime!.hour, endTime!.minute, 00);
      debugPrint(
          'Nested Start Date is $startDateTime and start date time is $startDateTime and end date time is $endDateTime');
      if (endDateTime.isBefore(endDate)) {
        while (startDateTime.isBefore(endDateTime)) {
          debugPrint('Start Date is Created date time slot is $startDateTime');
          dateTimeSlot.add(startDateTime);
          startDateTime = startDateTime.add(step);
        }
      }
    } else {
      while (startDateTime.isBefore(endDateTime)) {
        debugPrint('Start Date is Created date time slot is $startDateTime');
        dateTimeSlot.add(startDateTime);
        startDateTime = startDateTime.add(step);
      }
    }
  }

  void handleAppointmentSlotsAPI(DoctorSetupValues doctorSetupValues) async {
    /// Create Provider Appointment slots API
    debugPrint(
        'date time slot value length is ${doctorSetupValues.dateTimeSlot}');
    if (doctorSetupValues.dateTimeSlot.isNotEmpty) {
      bool isConnected = await Utility.isInternetAvailable();
      if (isConnected) {
        setState(() {
          isLoading = true;
        });

        DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
        String providerUuid = doctorProfile?.uuid ?? '';
        DoctorSetUpController doctorSetUpController = DoctorSetUpController();

        /// Fetching service types so that we can create appointment slots for selected service type only
        List<String> serviceType = <String>[];
        if (consultType == AppStrings().labelTeleconsultation) {
          serviceType.add(ProviderAttributesLocal.teleconsultation);
        } else {
          serviceType.add(ProviderAttributesLocal.physicalConsultation);
        }

        for (DateTime dateTime in doctorSetupValues.dateTimeSlot) {
          String startDate = Utility.getAPIRequestDateFormatString(dateTime);
          String endDate = Utility.getAPIRequestDateFormatString(dateTime
              .add(Duration(minutes: doctorSetupValues.fixedDurationSlot!)));
          AddAppointmentTimeSlotResponse? addAppointmentSlotResponse =
          await doctorSetUpController.addProviderAppointmentTimeSlots(
              startDate: startDate,
              endDate: endDate,
              providerUUID: providerUuid,
              types: serviceType);
          debugPrint(
              'addAppointmentSlotResponse is ${addAppointmentSlotResponse
                  ?.uuid}');
        }

        setState(() {
          isLoading = false;
        });

        AlertDialogWithSingleAction(
          context: context,
          title: AppStrings().appointmentSlotsCreated,
          showIcon: true,
          iconAssetImage: AssetImages.appointments,
          onCloseTap: () {
            Navigator.of(context).pop();
            Get.back(result: true);
          },
          submitButtonText: AppStrings().close,
        ).showAlertDialog();
      } else {
        DialogHelper.showErrorDialog(description: 'No internet connection');
      }
    }
  }

  int? getDifference() {
    int? difference;
    if (startTime != null && endTime != null) {
      debugPrint(
          '$startDate and $endDate Date difference in days ${endDate.difference(startDate).inDays}');
      int doubleStartTime = startTime!.hour * 60 + startTime!.minute;
      int doubleEndTime = endTime!.hour * 60 + endTime!.minute;
      difference = doubleEndTime - doubleStartTime;
      debugPrint(
          '$doubleStartTime and $doubleEndTime and difference is $difference');
      if (endDate.difference(startDate).inDays > 0) {
        DateTime startDateTime = DateTime(startDate.year, startDate.month,
            startDate.day, startTime!.hour, startTime!.minute);
        DateTime endDateTime = DateTime(startDate.year, startDate.month,
            startDate.day, endTime!.hour, endTime!.minute);
        debugPrint(
            '$startDateTime and $endDateTime and ${startDateTime.isBefore(endDateTime)}');
        if (startDateTime.isAfter(endDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
          difference = endDateTime.difference(startDateTime).inMinutes;
          debugPrint(
              '$startDateTime and $endDateTime and ${startDateTime.isBefore(endDateTime)} and difference is $difference');
        }
      }
    }

    return difference;
  }

  void showAlreadySlotsDiscardDialog(DoctorSetupValues doctorSetupValues) {
    NewConfirmationDialog(
        context: context,
        title: AppStrings().alert,
        titleTextStyle:
            AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        showSubtitle: false,
        description: AppStrings().noteAlreadyAddedSlotsDiscarded,
        submitButtonText: AppStrings().confirm,
        onCancelTap: () {
          Navigator.pop(context);
        },
        onSubmitTap: () {
          Navigator.of(context).pop();
          handleAppointmentSlotsAPI(doctorSetupValues);
        }).showAlertDialog();
  }
}

class Days {
  late int intDay;
  late String day;
  bool selected = false;

  Days({required this.intDay, required this.day, this.selected = false});
}

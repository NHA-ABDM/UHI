///DEFAULT PACKAGES
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';

///USER DEFINED FILES

class CalendarDateRangePicker {
  ///DIALOG LAYOUT
  var width;
  late var height;

  ///PARENT CONTEXT
  BuildContext context;

  ///CALLBACK FUNCTIONS
  Function(DateTime? startDate, DateTime? endDate)? onDateSubmit;

  ///DIALOG CONTENTS
  bool? isDateRange = true;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? initialDate;
  DateTime? minDateTime;
  DateTime? maxDateTime;
  DateTime? lastDate;

  CalendarDateRangePicker(
      {required this.context,
      required this.isDateRange,
      this.initialDate,
      this.minDateTime,
      this.startDate,
      this.endDate,
      this.maxDateTime,
      this.onDateSubmit,
      this.lastDate});

  sfDatePicker() {
    ///ASSIGNING TO VARIABLES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (isDateRange == null) {
      isDateRange = true;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // var dialogHeight = MediaQuery.of(context).size.height;
        // var dialogWidth = MediaQuery.of(context).size.width;
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
              width: width * 0.95,
              height: height * 0.65,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: SfDateRangePicker(
                      view: DateRangePickerView.month,
                      showNavigationArrow: true,
                      headerHeight: 60,
                      minDate: minDateTime,
                      maxDate: maxDateTime,
                      initialSelectedRange: isDateRange!
                          ? new PickerDateRange(initialDate, lastDate)
                          : null,
                      initialDisplayDate:
                          initialDate != null ? initialDate : DateTime.now(),
                      initialSelectedDate:
                          initialDate != null ? initialDate : DateTime.now(),
                      selectionShape: DateRangePickerSelectionShape.rectangle,
                      selectionMode: isDateRange!
                          ? DateRangePickerSelectionMode.range
                          : DateRangePickerSelectionMode.single,
                      rangeSelectionColor: Color(0xFFBEC0D5),
                      startRangeSelectionColor: Color(0xFFBEC0D5),
                      endRangeSelectionColor: Color(0xFFBEC0D5),
                      selectionColor: Color(0xFFBEC0D5),
                      rangeTextStyle: const TextStyle(
                          color: AppColors.DARK_PURPLE,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      selectionTextStyle: const TextStyle(
                          color: AppColors.DARK_PURPLE,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      headerStyle: const DateRangePickerHeaderStyle(
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                            color: AppColors.DARK_PURPLE,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 18.0),
                      ),
                      monthViewSettings: const DateRangePickerMonthViewSettings(
                        showTrailingAndLeadingDates: true,
                        firstDayOfWeek: 1,
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          textStyle: TextStyle(
                              color: Color(0xFFBEC0D5),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.normal,
                              fontSize: 16.0),
                        ),
                      ),
                      monthCellStyle: DateRangePickerMonthCellStyle(
                        todayCellDecoration: BoxDecoration(
                            color: Color(0xFFB0DB5E),
                            borderRadius: BorderRadius.circular(10)),
                        todayTextStyle: const TextStyle(
                            color: AppColors.DARK_PURPLE,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        textStyle: const TextStyle(
                            color: AppColors.DARK_PURPLE,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        leadingDatesTextStyle: const TextStyle(
                            color: Color(0xFFBEC0D5),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        trailingDatesTextStyle: const TextStyle(
                            color: Color(0xFFBEC0D5),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                      ),
                      onSelectionChanged:
                          (dateRangePickerSelectionChangedArgs) {
                        if (isDateRange!) {
                          PickerDateRange pickerDateRange =
                              dateRangePickerSelectionChangedArgs.value;
                          startDate = pickerDateRange.startDate;
                          endDate = pickerDateRange.endDate;
                        } else {
                          startDate = dateRangePickerSelectionChangedArgs.value;
                          // print("${dateRangePickerSelectionChangedArgs.value}");
                        }

                        // print("${pickerDateRange.startDate}");
                        // print("${pickerDateRange.endDate}");
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onDateSubmit!(startDate, endDate);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: width,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.DARK_PURPLE,
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                          child: Text(
                        isDateRange! ? "SET DATE RANGE" : "SET DATE",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                      )),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}

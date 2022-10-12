
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../constants/src/get_pages.dart';
import '../../../constants/src/provider_attributes.dart';
import '../../../controller/src/appointment_slots_calender_view_controller.dart';
import '../../../model/response/src/appointment_slots_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_shadows.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../constants/src/strings.dart';

class CalendarWithSlotsPageOld extends StatefulWidget {
  const CalendarWithSlotsPageOld({Key? key}) : super(key: key);

  @override
  State<CalendarWithSlotsPageOld> createState() => _CalendarWithSlotsPageOldState();
}

class _CalendarWithSlotsPageOldState extends State<CalendarWithSlotsPageOld> {
  late final String consultType;
  bool isExisting = false;
  bool isLoading = false;
  DateTime get _now => DateTime.now();
  DateTime currentCalenderDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  CalendarFormat _selectedCalendarFormat = CalendarFormat.month;
  late final ValueNotifier<List<ProviderAppointmentSlots>> _selectedDayEvents;

  late AppointmentsSlotsCalenderViewController _appointmentsSlotsCalenderViewController;

  @override
  void initState() {
    /// Get arguments
    consultType = Get.arguments['consultType'];
    if(Get.arguments['isExisting'] != null) {
      isExisting = Get.arguments['isExisting'];
    }

    _appointmentsSlotsCalenderViewController = AppointmentsSlotsCalenderViewController();
    fetchSlotsAndSetEvents();
    _selectedDayEvents = ValueNotifier(_getEventsForDay(currentCalenderDate));
    super.initState();
  }

  @override
  void dispose() {
    _selectedDayEvents.dispose();
    super.dispose();
  }

  List<ProviderAppointmentSlots> _getEventsForDay(DateTime day) {
    List<ProviderAppointmentSlots> dayAppointmentSlots = <ProviderAppointmentSlots>[];
    if(_appointmentsSlotsCalenderViewController.listProviderAppointmentSlots.isNotEmpty) {
      for(ProviderAppointmentSlots slot in _appointmentsSlotsCalenderViewController.listProviderAppointmentSlots){
        DateTime startTime = DateTime.parse(slot.startDate!.split('.').first);
        if(day.year == startTime.year && day.month == startTime.month && day.day == startTime.day) {
          dayAppointmentSlots.add(slot);
        }
      }
    }
    return dayAppointmentSlots;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
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
              Get.back();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            bool isCreated = await Get.toNamed(AppRoutes.dayTimeSelectionPage, arguments: <String, dynamic>{
              'consultType' : consultType,
              'isExisting': true,
            });
            if(isCreated) {
              fetchProviderAppointmentSlots(currentCalenderDate);
            }
          },
          child: Icon(Icons.add, color: AppColors.white),
          backgroundColor: AppColors.tileColors,
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical:0),
      child: Column(
        children: [
          Card(
            elevation: 8,
            child: TableCalendar<ProviderAppointmentSlots>(
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: AppColors.tileColors,
                        //borderRadius: BorderRadius.circular(8.0),
                        shape: BoxShape.circle
                    ),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
                todayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.doctorNameColor.withAlpha(99),
                        //borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.circle
                    ),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              headerStyle: HeaderStyle(
                headerPadding:  const EdgeInsets.symmetric(vertical: 0),
                headerMargin: const EdgeInsets.only(bottom: 4),
                titleCentered: true,
                decoration: BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.circular(5),
                ),
                titleTextStyle: AppTextStyle.textSemiBoldStyle(color: AppColors.white, fontSize: 16),
                leftChevronIcon: Icon(Icons.keyboard_arrow_left, color: AppColors.white,),
                rightChevronIcon: Icon(Icons.keyboard_arrow_right, color: AppColors.white,),
              ),
              firstDay: DateTime(_now.year, _now.month, 1),//_now.add(const Duration(days: -7)),
              lastDay: DateTime(_now.year + 1),
              focusedDay: currentCalenderDate,
              selectedDayPredicate: (DateTime day){
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                debugPrint('SelectedDay is $selectedDay and FocusedDay is $focusedDay');
                setState(() {
                  selectedDate = selectedDay;
                  currentCalenderDate = focusedDay;
                  _selectedDayEvents.value = _getEventsForDay(focusedDay);
                });
              },
              calendarFormat: _selectedCalendarFormat,
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  _selectedCalendarFormat = format;
                });
              },
              onPageChanged: (DateTime day) {
                debugPrint('Page changed $day');
                currentCalenderDate = day;
                _selectedDayEvents.value = [];
                fetchProviderAppointmentSlots(day);
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              /*eventLoader: (DateTime day) {
                debugPrint('eventLoader $day');
                return <ProviderAppointmentSlots>[];
              },*/
              rowHeight: 45,
              availableCalendarFormats : const {
                CalendarFormat.month: 'Month',
                /*CalendarFormat.twoWeeks: '2 weeks',
                CalendarFormat.week: 'Week',*/
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ProviderAppointmentSlots>>(
              valueListenable: _selectedDayEvents,
              builder: (context, value, _) {
                return value.isEmpty
                      ? Center(
                          child: Text(
                            !isLoading ? AppStrings().errorNoSlotsAvailable : '',
                            style: AppTextStyle.textSemiBoldStyle(
                                color: AppColors.tileColors, fontSize: 18),
                          ),
                        )
                      : //showSlotGrids(value);
                  showSlotList(value);
                },
            ),
          ),
        ],
      )
    );
  }

  Future<void> fetchProviderAppointmentSlots(DateTime selectedDate) async{
    try {

      setState(() {
        isLoading = true;
      });
      DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
      DateTime startDate = DateTime(selectedDate.year, selectedDate.month, 1, 00, 00, 00);
      DateTime endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
      debugPrint('Calender events Start date is ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate)} and end date is ${endDate.toString()}');
      await _appointmentsSlotsCalenderViewController.getProviderAppointmentSlots(
          startDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate),
          endDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate),
          provider: doctorProfile!.uuid!,
          appointType: consultType == AppStrings().labelTeleconsultation
              ? ProviderAttributesLocal.teleconsultation
              : ProviderAttributesLocal.physicalConsultation,
          day: startDate.day);

      setState(() {
        isLoading = false;
      });
      
      if(startDate.isBefore(this.selectedDate) && endDate.isAfter(this.selectedDate)){
        _selectedDayEvents.value = _getEventsForDay(this.selectedDate);
      }
    } catch (e){
      debugPrint('Get provider Calender events appointment slots exception is ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSlotsAndSetEvents() async{
    await fetchProviderAppointmentSlots(selectedDate);
    _selectedDayEvents.value = _getEventsForDay(selectedDate);
  }

  showSlotList(List<ProviderAppointmentSlots> value) {
    return ListView.builder(
      itemCount: value.length,
      itemBuilder: (context, index) {
        ProviderAppointmentSlots slot = value[index];
        DateTime startDate = DateTime.parse(
            slot.startDate!.split('.').first);
        DateTime endDate = DateTime.parse(
            slot.endDate!.split('.').first);
        Color color = AppColors.amountColor;
        if (slot.countOfAppointments! == 0 && slot.unallocatedMinutes! > 0) {
          color = AppColors.appointmentStatusColor;
        }
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            dense: true,
            onTap: () => debugPrint('${value[index]}'),
            title: Text(
              Utility.getAppointmentDisplayTimeRange(
                  startDateTime: startDate,
                  endDateTime: endDate),
              //Utility.getAppointmentDisplayTime(startDateTime:providerAppointment.timeSlot!.startDate!, endDateTime: providerAppointment.timeSlot!.endDate!),
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.testColor, fontSize: 14),
            ),
            subtitle: Text(AppStrings().slotDuration(value: '${endDate.difference(startDate).inMinutes}'),
              style: AppTextStyle.textNormalStyle(
                  color: AppColors.testColor, fontSize: 12),
            ),
            trailing: Text(
                slot.countOfAppointments! == 0
                    && slot.unallocatedMinutes! > 0
                    ? AppStrings().labelNotBooked
                    : AppStrings().labelBooked,
                style: AppTextStyle.textMediumStyle(
                    color: color, fontSize: 12)
            ),
          ),
        );
      },
    );
  }

  showSlotGrids(List<ProviderAppointmentSlots> value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4, left: 5, right: 5),
      child: GridView.builder(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 6,
          ),
          itemCount: value.length,
          itemBuilder: (BuildContext context, int index) {
            ProviderAppointmentSlots slot = value[index];
            Color color = AppColors.amountColor;
            Color textColor = AppColors.darkGrey323232;
            if (slot.countOfAppointments! == 0 &&
                slot.unallocatedMinutes! > 0) {
              color = AppColors.appointmentStatusColor;
              textColor = AppColors.darkGrey323232;
            }
            return InkWell(
              onTap: () {},
              child: Center(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: AppShadows.shadow2,
                      border: Border.all(color: color)),
                  child: Center(
                    child: Text(
                      Utility.getTimeSlotDisplayTime(
                          startDateTime:
                              DateTime.parse(slot.startDate!.split('.').first)),
                      style: AppTextStyle.textMediumStyle(
                          color: textColor, fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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

enum LoadingState {
  initialFetch,
  topLoading,
  bottomLoading,
  success,
}

enum SlotType {
  present,
  past,
  future,
}

class CalendarWithSlotsPage extends StatefulWidget {
  const CalendarWithSlotsPage({Key? key}) : super(key: key);

  @override
  State<CalendarWithSlotsPage> createState() => _CalendarWithSlotsPageState();
}

class _CalendarWithSlotsPageState extends State<CalendarWithSlotsPage> {
  late final String consultType;
  bool isExisting = false;

  bool isFetchInProgress = false;
  bool isInitialCall = false;
  bool isManualScroll = false;

  DateTime get _now => DateTime.now();
  DateTime currentCalenderDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  CalendarFormat _selectedCalendarFormat = CalendarFormat.month;

  late final ValueNotifier<List<ProviderAppointmentSlots>> _selectedDayEvents;
  final ValueNotifier<List<ProviderAppointmentSlots>> _listOfSlotDisplay =
      ValueNotifier([]);

  final ValueNotifier<LoadingState> _loadingStateNotifier =
      ValueNotifier(LoadingState.initialFetch);

  late AppointmentsSlotsCalenderViewController
      _appointmentsSlotsCalenderViewController;

  late AutoScrollController _scrollController;

  final _renderKeys = {};
  var listViewKey = RectGetter.createGlobalKey();

  get mapMonthlyAppointmentSlots =>
      _appointmentsSlotsCalenderViewController.mapMonthlyAppointmentSlots;

  @override
  void initState() {
    /// Get arguments
    consultType = Get.arguments['consultType'];
    if (Get.arguments['isExisting'] != null) {
      isExisting = Get.arguments['isExisting'];
    }

    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );

    _appointmentsSlotsCalenderViewController =
        AppointmentsSlotsCalenderViewController();
    _selectedDayEvents = ValueNotifier([]);

    initializeSlotsForMonth();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await fetchAndUpdateDateForPresentDay();
    });

    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _selectedDayEvents.dispose();
    _listOfSlotDisplay.dispose();
    _scrollController.removeListener((_scrollListener));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isInitialCall,
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
          onPressed: () async {
            bool isCreated = await Get.toNamed(AppRoutes.dayTimeSelectionPage,
                arguments: <String, dynamic>{
                  'consultType': consultType,
                  'isExisting': true,
                });
            if (isCreated) {
              initializeSlotsForMonth();
              await fetchAndUpdateDateForPresentDay();
            }
          },
          child: Icon(Icons.add, color: AppColors.white),
          backgroundColor: AppColors.tileColors,
        ),
        body: buildBody(),
      ),
    );
  }

  Padding buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                        shape: BoxShape.circle),
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
                        shape: BoxShape.circle),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              headerStyle: HeaderStyle(
                headerPadding: const EdgeInsets.symmetric(vertical: 0),
                headerMargin: const EdgeInsets.only(bottom: 4),
                titleCentered: true,
                decoration: BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.circular(5),
                ),
                titleTextStyle: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.white, fontSize: 16),
                leftChevronIcon: Icon(
                  Icons.keyboard_arrow_left,
                  color: AppColors.white,
                ),
                rightChevronIcon: Icon(
                  Icons.keyboard_arrow_right,
                  color: AppColors.white,
                ),
              ),
              firstDay: DateTime(_now.year, _now.month, 1),
              //_now.add(const Duration(days: -7)),
              lastDay: DateTime(_now.year + 1),
              focusedDay: currentCalenderDate,
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                debugPrint(
                    'SelectedDay is $selectedDay and FocusedDay is $focusedDay');
                setState(() {
                  selectedDate = selectedDay;
                  currentCalenderDate = focusedDay;
                });

                if (_isDateAvailableForDay(selectedDay)) {
                  _selectedDayEvents.value = _getEventForDay(selectedDay);
                  int index = _listOfSlotDisplay.value.indexWhere((element) =>
                      isDateSame(selectedDay, getDateFromSlotTime(element)));
                  await _scrollToStartPosition(index,
                      duration: const Duration(milliseconds: 250));
                } else {
                  await fetchAndUpdateDataForSelectedDay(selectedDay);
                }
              },
              calendarFormat: _selectedCalendarFormat,
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  _selectedCalendarFormat = format;
                });
              },
              onPageChanged: (DateTime day) async {
                debugPrint('Page changed $day');
                DateTime changedDate =
                    isDateBelongsToSelectedMonth(day, DateTime.now())
                        ? DateTime.now()
                        : day;
                setState(() {
                  currentCalenderDate = changedDate;
                  selectedDate = changedDate;
                });
                initializeSlotsForMonth();
                _listOfSlotDisplay.value.clear();
                await fetchAndUpdateDataForSelectedDay(selectedDate);
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
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                /*CalendarFormat.twoWeeks: '2 weeks',
                CalendarFormat.week: 'Week',*/
              },
            ),
          ),
          NotificationListener(
            child: Expanded(
              child: ValueListenableBuilder<List<ProviderAppointmentSlots>>(
                valueListenable: _selectedDayEvents,
                builder: (context, value, _) {
                  return value.isEmpty
                      ? Center(
                          child: Text(
                            !isInitialCall
                                ? AppStrings().errorNoSlotsAvailable
                                : '',
                            style: AppTextStyle.textSemiBoldStyle(
                                color: AppColors.tileColors, fontSize: 18),
                          ),
                        )
                      : //showSlotGrids(value);
                      showSlotList();
                },
              ),
            ),
            onNotification: (notificationInfo) {
              if (notificationInfo is ScrollStartNotification) {
                setState(() {
                  if (notificationInfo.dragDetails != null) {
                    //set as true
                    isManualScroll = true;
                  } else {
                    // set as false
                    isManualScroll = false;
                  }
                });
              }
              return true;
            },
          )
        ],
      ),
    );
  }

  /// Return Widget which contains bottom view which having
  /// progressBar and List of slots for selected month.
  ValueListenableBuilder showSlotList() {
    return ValueListenableBuilder<LoadingState>(
      valueListenable: _loadingStateNotifier,
      builder: (context, slotModel, _) {
        return Column(
          children: [
            (slotModel == LoadingState.topLoading)
                ? progressBarView()
                : const SizedBox.shrink(),
            ValueListenableBuilder<List<ProviderAppointmentSlots>>(
              valueListenable: _listOfSlotDisplay,
              builder: (context, value, _) {
                var listView = RectGetter(
                  key: listViewKey,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: value.length,
                      padding: EdgeInsets.zero,
                      key: const PageStorageKey(0),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        ProviderAppointmentSlots slot = value.elementAt(index);
                        _renderKeys[index] = RectGetter.createGlobalKey();
                        DateTime startDate = getDateFromSlotTime(slot);
                        DateTime endDate =
                            DateTime.parse(slot.endDate!.split('.').first);
                        Color color = AppColors.amountColor;
                        if (slot.countOfAppointments! == 0 &&
                            slot.unallocatedMinutes! > 0) {
                          color = AppColors.appointmentStatusColor;
                        }

                        Widget child =
                            slotView(slot, startDate, endDate, color, index);

                        return RectGetter(
                          key: _renderKeys[index],
                          child: AutoScrollTag(
                            key: ValueKey(index),
                            controller: _scrollController,
                            index: index,
                            child: child,
                          ),
                        );
                      },
                    ),
                  ),
                );
                return listView;
              },
            ),
            (slotModel == LoadingState.bottomLoading)
                ? progressBarView()
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Padding slotCardView(Color color, DateTime startDate, DateTime endDate,
      ProviderAppointmentSlots slot) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          dense: true,
          onTap: () => debugPrint('$slot'),
          title: Text(
            Utility.getAppointmentDisplayTimeRange(
                startDateTime: startDate, endDateTime: endDate),
            style: AppTextStyle.textMediumStyle(
              color: AppColors.testColor,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            AppStrings().slotDuration(
                value: '${endDate.difference(startDate).inMinutes}'),
            style: AppTextStyle.textNormalStyle(
              color: AppColors.testColor,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            slot.countOfAppointments! == 0 && slot.unallocatedMinutes! > 0
                ? AppStrings().labelNotBooked
                : AppStrings().labelBooked,
            style: AppTextStyle.textMediumStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Container progressBarView() {
    return Container(
      height: 26,
      width: 26,
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.tileColors),
      ),
    );
  }

  Padding showSlotGrids(List<ProviderAppointmentSlots> value) {
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
          if (slot.countOfAppointments! == 0 && slot.unallocatedMinutes! > 0) {
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
                        startDateTime: getDateFromSlotTime(slot)),
                    style: AppTextStyle.textMediumStyle(
                        color: textColor, fontSize: 14),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget slotView(ProviderAppointmentSlots slot, DateTime startDate,
      DateTime endDate, Color color, int index) {
    if (index == 0) {
      return Column(
        children: [
          slotDayIndicator(startDate),
          slotCardView(color, startDate, endDate, slot)
        ],
      );
    } else {
      ProviderAppointmentSlots previousSlot =
          _listOfSlotDisplay.value[index - 1];
      if (isSameDay(startDate, getDateFromSlotTime(previousSlot))) {
        return slotCardView(color, startDate, endDate, slot);
      } else {
        return Column(
          children: [
            slotDayIndicator(startDate),
            slotCardView(color, startDate, endDate, slot)
          ],
        );
      }
    }
  }

  Container slotDayIndicator(DateTime startDate) {
    String day = "";
    DateTime currentDate = DateTime.now();
    if (isSameDay(currentDate, startDate)) {
      day = AppStrings().labelToday;
    } else {
      day = Utility.getSlotDividerDisplayDate(date: startDate);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        day,
        style: AppTextStyle.textMediumStyle(
          color: AppColors.testColor,
          fontSize: 14,
        ),
      ),
    );
  }

  /// This method initialize map of slots and set value to [NULL] for selected month.
  initializeSlotsForMonth() {
    mapMonthlyAppointmentSlots.clear();
    int lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    for (int i = 1; i <= lastDayOfMonth; i++) {
      mapMonthlyAppointmentSlots[i] = null;
    }
  }

  /// This method fetch data for present day and past days of current week
  Future<void> fetchAndUpdateDateForPresentDay() async {
    await fetchSlotsForSelectedAndPastDaysOfWeek(currentCalenderDate);
    _selectedDayEvents.value = _getEventForDay(currentCalenderDate);
    int index = _listOfSlotDisplay.value.indexWhere((element) =>
        isDateSame(currentCalenderDate, getDateFromSlotTime(element)));
    await _scrollToStartPosition(index);
  }

  /// Fetch data for selected date and past days of selected week.
  ///
  /// [date] : DateTime => Date for which data to be fetch.
  Future<void> fetchAndUpdateDataForSelectedDay(DateTime date) async {
    await fetchSlotsForSelectedAndPastDaysOfWeek(date);
    _selectedDayEvents.value = _getEventForDay(date);
    int index = _listOfSlotDisplay.value.indexWhere(
        (element) => isDateSame(date, getDateFromSlotTime(element)));
    await _scrollToStartPosition(index);
  }

  /// Return [List<ProviderAppointmentSlots>]  for the provided date and all past slots for month from local map
  ///
  /// [DateTime] : date => date for which data required
  List<ProviderAppointmentSlots> getSlotsForPastWeekFromLocal(DateTime date) {
    List<ProviderAppointmentSlots> tempSlotList = [];
    for (int i = date.day; i >= 1; i--) {
      List<ProviderAppointmentSlots>? slot = mapMonthlyAppointmentSlots[i];
      if (slot != null) {
        tempSlotList.addAll(slot);
      } else {
        break;
      }
    }
    return tempSlotList;
  }

  /// Return [List<ProviderAppointmentSlots>] for the provided date and all future slots for month from local map
  ///
  /// [DateTime] : date => date for which data required
  List<ProviderAppointmentSlots> getSlotsForFutureWeekFromLocal(DateTime date) {
    List<ProviderAppointmentSlots> tempSlotList = [];
    DateTime lastDay = lastDayOfMonth(date);
    if (!isSameDay(lastDay, date)) {
      for (int i = date.day + 1; i <= lastDay.day; i++) {
        List<ProviderAppointmentSlots>? slot = mapMonthlyAppointmentSlots[i];
        if (slot != null) {
          tempSlotList.addAll(slot);
        } else {
          break;
        }
      }
    }
    return tempSlotList;
  }

  /// Return [List<ProviderAppointmentSlots>] for the provided date and all slots for month from local map
  ///
  /// also set data to [_listOfSlotDisplay] required for display on screen
  /// [DateTime] : date => date for which data required
  List<ProviderAppointmentSlots> _getEventForDay(DateTime date) {
    List<ProviderAppointmentSlots>? slotsForDay =
        mapMonthlyAppointmentSlots[date.day];

    List<ProviderAppointmentSlots> slotsForMonth =
        getSlotsForPastWeekFromLocal(date);
    slotsForMonth.addAll(getSlotsForFutureWeekFromLocal(date));
    slotsForMonth.sort(
        (a, b) => getDateFromSlotTime(a).compareTo(getDateFromSlotTime(b)));

    _listOfSlotDisplay.value.clear();
    _listOfSlotDisplay.value.addAll(slotsForMonth);

    return slotsForDay ?? [];
  }

  /// Return [List<int>] which contains visible view on screen from list of slot.
  List<int> getVisibleViewsFromList() {
    var rect = RectGetter.getRectFromKey(listViewKey);
    var _items = <int>[];
    _renderKeys.forEach((index, key) {
      var itemRect = RectGetter.getRectFromKey(key);
      if (itemRect != null &&
          !(itemRect.top > (rect!.bottom) || itemRect.bottom < (rect.top))) {
        _items.add(index);
      }
    });
    return _items;
  }

  /// return [True] if slots available for provided date
  bool _isDateAvailableForDay(DateTime date) {
    return mapMonthlyAppointmentSlots[date.day] != null;
  }

  /// Fetch data for future slots
  Future<void> _fetchSlotForFutureDate(DateTime date) async {
    try {
      setState(() {
        isFetchInProgress = true;
      });
      _loadingStateNotifier.value = LoadingState.bottomLoading;
      await fetchSlotForDay(date);
      _selectedDayEvents.value = (_getEventForDay(date));
      setState(() {
        if (_selectedDayEvents.value.isEmpty) {
          selectedDate = date;
        }
        isFetchInProgress = false;
      });
    } catch (e) {
      debugPrint("Error [fetchSlotForFutureDate] => ${e.toString()}");
      setState(() {
        isFetchInProgress = false;
      });
    } finally {
      _loadingStateNotifier.value = LoadingState.success;
    }
  }

  /// Fetch data for provided date and all past days for selected week
  ///
  /// [DateTime] : date
  Future<void> fetchSlotsForSelectedAndPastDaysOfWeek(DateTime date) async {
    try {
      setState(() {
        isFetchInProgress = true;
        isInitialCall = true;
      });

      /// avoid to fetch past slots if provided date is start of month
      if (date.day == 1) {
        await fetchSlotForDay(date);
      } else {
        DateTime firstDateOfWeek =
            date.subtract(Duration(days: date.weekday - 1));
        int initialDay = firstDateOfWeek.day;
        if (!isDateBelongsToSelectedMonth(firstDateOfWeek, date)) {
          initialDay = 1;
        }
        for (int i = initialDay; i <= date.day; i++) {
          DateTime tempDate = DateTime(date.year, date.month, i);
          if (!_isDateAvailableForDay(tempDate)) {
            await fetchSlotForDay(tempDate);
          }
        }
      }
    } catch (e) {
      debugPrint(
          "Error [fetchSlotsForSelectedAndPastDaysOfWeek] => ${e.toString()}");
    } finally {
      setState(() {
        isFetchInProgress = false;
        isInitialCall = false;
      });
    }
  }

  /// Fetch slots for  provided date
  ///
  /// [DateTime]: date
  Future<void> fetchSlotForDay(DateTime date) async {
    DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
    DateTime startDate = DateTime(date.year, date.month, date.day, 00, 00, 00);
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    debugPrint(
        'Calender events Start date is ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate)} and end date is ${endDate.toString()}');
    await _appointmentsSlotsCalenderViewController.getProviderAppointmentSlots(
        startDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate),
        endDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate),
        provider: doctorProfile!.uuid!,
        appointType: consultType == AppStrings().labelTeleconsultation
            ? ProviderAttributesLocal.teleconsultation
            : ProviderAttributesLocal.physicalConsultation,
        day: startDate.day);
  }

  /// detect scroll position
  Future<void> _scrollListener() async {
    _detectVisibleScrollViews();
    ScrollPosition position = _scrollController.position;
    if (!isFetchInProgress && !_scrollController.isAutoScrolling) {

      debugPrint("Manual scroll");

      const double topThreshold = -80.0;
      double maxPosition =
          (position.maxScrollExtent < position.viewportDimension)
              ? position.viewportDimension
              : position.maxScrollExtent;

      if (maxPosition == position.pixels) {
        ProviderAppointmentSlots lastSlotInList = _listOfSlotDisplay.value.last;
        DateTime lastDay = lastDayOfMonth(selectedDate);
        if (!isSameDay(lastDay, getDateFromSlotTime(lastSlotInList))) {
          _fetchSlotForFutureDate(selectedDate.add(const Duration(days: 1)));
        }
      } else if (position.pixels < topThreshold) {
        if (selectedDate.day > 1) {
          DateTime pastDate = selectedDate.subtract(const Duration(days: 1));
          await fetchSlotsForSelectedAndPastDaysOfWeek(pastDate);
          _selectedDayEvents.value = _getEventForDay(pastDate);
          if (_selectedDayEvents.value.isEmpty) {
            setState(() {
              selectedDate = pastDate;
            });
          }
          int index = _listOfSlotDisplay.value.lastIndexWhere(
              (element) => isDateSame(pastDate, getDateFromSlotTime(element)));
          await _scrollToStartPosition(index);
        }
      }
    }
  }

  /// detect for which
  void _detectVisibleScrollViews() {
    List<int> visibleViews = getVisibleViewsFromList();
    if (!_scrollController.isAutoScrolling && isManualScroll) {
      ProviderAppointmentSlots secondVisibleSlot =
          _listOfSlotDisplay.value.elementAt(visibleViews.last);
      DateTime firstSlotDate = getDateFromSlotTime(secondVisibleSlot);
      setState(() {
        selectedDate = DateTime(
            firstSlotDate.year, firstSlotDate.month, firstSlotDate.day);
      });
    }
  }

  /// scroll to particular position
  ///
  /// [int] position
  /// [Duration]: duration (optional)
  /// [AutoScrollPosition] : preferPosition (optional)
  Future<void> _scrollToStartPosition(int position,
      {Duration? duration, AutoScrollPosition? preferPosition}) async {
    _scrollController.scrollToIndex(position,
        duration: duration ?? const Duration(milliseconds: 1),
        preferPosition: preferPosition ?? AutoScrollPosition.begin);
  }

  /// Return [DateTime] as lastDayOfMonth
  DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Return [True] if both date belongs to same month
  bool isDateBelongsToSelectedMonth(
      DateTime updatedDate, DateTime selectedDate) {
    return (updatedDate.month == selectedDate.month) &&
        (updatedDate.year == selectedDate.year);
  }

  /// Return [True] if both date are same
  bool isDateSame(DateTime updatedDate, DateTime selectedDate) {
    return (updatedDate.day == selectedDate.day) &&
        (updatedDate.month == selectedDate.month) &&
        (updatedDate.year == selectedDate.year);
  }

  /// Return [DateTime] for provided slot
  DateTime getDateFromSlotTime(ProviderAppointmentSlots slot) =>
      DateTime.parse(slot.startDate!.split('.').first);
}

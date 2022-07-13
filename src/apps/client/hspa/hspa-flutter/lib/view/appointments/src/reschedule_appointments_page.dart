import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/model/response/src/appointment_slots_response.dart';
import 'package:hspa_app/model/response/src/provider_appointments_response.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/provider_attributes.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/appointments_controller.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_shadows.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/calendar_date_range_picker.dart';
import '../../../widgets/src/new_confirmation_dialog.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';

class RescheduleAppointmentPage extends StatefulWidget {
  const RescheduleAppointmentPage({Key? key, required this.appointment}) : super(key: key);
  final ProviderAppointments appointment;

  @override
  State<RescheduleAppointmentPage> createState() => _RescheduleAppointmentPageState();
}

class _RescheduleAppointmentPageState extends State<RescheduleAppointmentPage> {
  String? _selectedDate;
  late DateTime initialDateTime;
  int? _selectedTimeSlotIndex;
  final DateFormat formatter = DateFormat('MMMM d');
  late DateTime appointmentDateTime;
  late AppointmentsController _appointmentsController;
  bool isLoading = false;

  @override
  void initState() {
    _appointmentsController = AppointmentsController();

    appointmentDateTime = DateTime.parse(widget.appointment.timeSlot!.startDate!.split('.').first);
    initialDateTime = appointmentDateTime;
    _selectedDate = formatter.format(appointmentDateTime);

    fetchProviderAppointmentSlots();

    super.initState();
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
            AppStrings().labelReschedule,
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
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(AppStrings().labelRequestingReschedule, style: AppTextStyle.textSemiBoldStyle(fontSize: 18, color: AppColors.titleTextColor),),
                VerticalSpacing(size: 20,),
                Text(AppStrings().labelSelectAlternateSlot, style: AppTextStyle.textSemiBoldStyle(fontSize: 18, color: AppColors.titleTextColor),),
                VerticalSpacing(),
                GestureDetector(
                  onTap: () {
                    datePicker();
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
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
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Text(
                    AppStrings().labelChooseTimeSlot,
                    style: AppTextStyle.textLightStyle(
                        color: AppColors.infoIconColor, fontSize: 12),
                  ),
                ),
                _appointmentsController.filteredListProviderAppointmentSlots.isNotEmpty ?
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 4 ),
                    child: GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: _appointmentsController.filteredListProviderAppointmentSlots.length,
                        itemBuilder: (BuildContext context, int index) {
                          ProviderAppointmentSlots slot = _appointmentsController.filteredListProviderAppointmentSlots[index];
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
                                    Utility.getTimeSlotDisplayTime(startDateTime: DateTime.parse(slot.startDate!.split('.').first)),
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
                ) :
                Expanded(
                  child: Center(
                    child: Text(
                      isLoading ? '' :
                       AppStrings().errorNoSlotsAvailable
                      , style: AppTextStyle.textBoldStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalSpacing(),
          SquareRoundedButtonWithIcon(text: AppStrings().btnSubmit, assetImage: AssetImages.arrowLongRight, onPressed: (){
            NewConfirmationDialog(
                context: context,
                title: AppStrings().labelRescheduleAlertTitle,
                description: AppStrings().labelRescheduleAlertDescription,
                submitButtonText: AppStrings().confirm,
                showDate: true,
                dateText: DateFormat('dd-MMM-yyyy').format(appointmentDateTime),
                showTime: true,
                timeText: Utility.getTimeSlotDisplayTime(startDateTime: DateTime.parse(_appointmentsController.filteredListProviderAppointmentSlots[_selectedTimeSlotIndex!].startDate!.split('.').first)),
                onCancelTap: () {
                  Navigator.pop(context);
                },
                onSubmitTap: () {
                  Navigator.of(context).pop();
                  Get.back();
                }).showAlertDialog();
          }),
        ],
      ),
    );
  }

  datePicker() {
    CalendarDateRangePicker(
      context: context,
      isDateRange: false,
      initialDate: appointmentDateTime,
      lastDate: DateTime(2100),
      minDateTime: initialDateTime,
      onDateSubmit: (startDate, endDate) {
        if(startDate != null) {
          setState(() {
            appointmentDateTime = startDate;
            _selectedDate = formatter.format(startDate);
            _selectedTimeSlotIndex = null;
            fetchProviderAppointmentSlots();
          });
        }

      },
    ).sfDatePicker();
  }

  void fetchProviderAppointmentSlots() async{
    try {
      setState(() {
        isLoading = true;
      });
      DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
      DateTime startDate = DateTime(appointmentDateTime.year, appointmentDateTime.month, appointmentDateTime.day, 00, 00, 00);
      DateTime endDate = DateTime(appointmentDateTime.year, appointmentDateTime.month, appointmentDateTime.day, 23, 59, 59);
      debugPrint('Start date is ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate)} and end date is ${endDate.toString()}');
      await _appointmentsController.getProviderAppointmentSlots(startDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate), endDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate), provider: doctorProfile!.uuid!, appointType: ProviderAttributesLocal.teleconsultation, appointment: widget.appointment);

      /// Below logic is to check selected slot by provider at the first time so that we can show it as selected in list
      if(_appointmentsController.filteredListProviderAppointmentSlots.isNotEmpty) {
        for (ProviderAppointmentSlots slots in _appointmentsController.filteredListProviderAppointmentSlots) {
          if(widget.appointment.timeSlot!.uuid == slots.uuid){
            _selectedTimeSlotIndex = _appointmentsController.filteredListProviderAppointmentSlots.indexOf(slots);
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e){
      debugPrint('Get provider appointment slots exception is ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/appointment_status.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/constants/src/strings.dart';
import 'package:hspa_app/model/response/src/provider_appointments_response.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/utils/src/utility.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../controller/src/appointments_controller.dart';
import '../../../model/request/src/provider_service_type.dart';
import '../../../model/src/appointment_reschedule.dart';
import '../../../model/src/appointments.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button.dart';
import 'previous_appointments_page.dart';
import 'today_appointment_page.dart';
import 'upcoming_appointments_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

/*  const AppointmentsPage({Key? key, required this.isTeleconsultation, required this.providerServiceTypes}) : super(key: key);
  final bool isTeleconsultation;
  final ProviderServiceTypes providerServiceTypes;*/

  @override
  State<AppointmentsPage> createState() => AppointmentsPageState();
}

class AppointmentsPageState extends State<AppointmentsPage> with SingleTickerProviderStateMixin{

  /// Arguments
  late final bool isTeleconsultation;
  late final ProviderServiceTypes providerServiceTypes;

  List<Appointments> listAppointments = <Appointments>[];
  List<AppointmentReschedule> listAppointmentReschedule = <AppointmentReschedule>[];
  late AppointmentsController _appointmentsController;
  bool isLoading = false;
  late TabController _controller;
  int _currentIndex = 0;

  _handleTabSelection() {
    setState(() {
      _currentIndex = _controller.index;
    });
    debugPrint('selected tab is $_currentIndex');
  }

  @override
  void initState() {

    /// Get Arguments
    isTeleconsultation = Get.arguments['isTeleconsultation'];
    providerServiceTypes = Get.arguments['providerServiceTypes'];

    _controller = TabController(vsync: this, length: 3);
    _controller.addListener(_handleTabSelection);

    _appointmentsController = AppointmentsController();
    fetchProviderAppointments(isInitial: true);

    listAppointments.add(Appointments(name: 'Arya Mahajan', visitType: 'First Consultation', appointmentDate: '13th April', appointmentTime: '10AM - 10:30 AM', appointmentDateTime: DateTime.utc(2022, 4, 13, 10, 0,0)));
    listAppointments.add(Appointments(name: 'Tarak Mehta', visitType: 'First Consultation', appointmentDate: '18th April', appointmentTime: '10AM - 10:30 AM', appointmentDateTime: DateTime.utc(2022, 4, 18, 10, 0,0)));

    listAppointmentReschedule.add(AppointmentReschedule(name: 'Tarak Mehta', visitType: 'Lab Report Consultation', originalAppointmentDate: '19 April 22', originalAppointmentTime: '8:00pm', rescheduleAppointmentDate: '21 April 22', rescheduleAppointmentTime: '7:00pm', status: 'Requested'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.appBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.appBackgroundColor,
            shadowColor: Colors.black.withOpacity(0.1),
            titleSpacing: 0,
            title: Text(
              AppStrings().labelAppointments,
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
            bottom: TabBar(
              controller: _controller,
              isScrollable: true,
              indicatorColor: AppColors.tileColors,
              labelColor: AppColors.tileColors,
              unselectedLabelColor: AppColors.unselectedTextColor,
              unselectedLabelStyle: AppTextStyle.textSemiBoldStyle(
                  fontSize: 17, color: AppColors.unselectedTextColor),
              labelStyle: AppTextStyle.textSemiBoldStyle(
                  fontSize: 17, color: AppColors.tileColors),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              tabs: [
                //Tab(child: Text(AppStrings(.labelNew)),
                Tab(child: Text(AppStrings().labelToday)),
                Tab(child: Text(AppStrings().labelUpcoming)),
                Tab(child: Text(AppStrings().labelPrevious)),
              ],
            ),
          ),
          body: buildBody(),
        ),
      ),
    );
  }

  buildBody() {
    return TabBarView(
      // physics: const NeverScrollableScrollPhysics(),
      controller: _controller,
      children: [
        //generateAllTabView(),
        TodayAppointmentPage(appointmentsController: _appointmentsController, isTeleconsultation: isTeleconsultation,),
        UpcomingAppointmentsPage(appointmentsController: _appointmentsController, isTeleconsultation: isTeleconsultation,),
        PreviousAppointmentsPage(appointmentsController: _appointmentsController, isTeleconsultation: isTeleconsultation,),
      ],
    );
  }

  generateAllTabView(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //showPatientListView(),
          showProviderAppointments(),
          VerticalSpacing(),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 8),
            child: Text(AppStrings().labelRequestReschedule, style: AppTextStyle.textBoldStyle(fontSize: 18, color: AppColors.black),),
          ),
          VerticalSpacing(),
          showRescheduleAppointments()
        ],
      ),
    );
  }

  showPatientListView(){
    return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        itemCount: listAppointments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: patientCardView
    );
  }

  Widget patientCardView(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(top: 2, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listAppointments[index].name,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                      const Spacing(),
                      Text(
                        listAppointments[index].appointmentDate,
                        style: AppTextStyle
                            .textNormalStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                    ],
                  ),
                  VerticalSpacing(size: 6,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listAppointments[index].visitType,
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                      const Spacing(),
                      Text(
                        listAppointments[index].appointmentTime,
                        style: AppTextStyle
                            .textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacing(isWidth: false, size: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: isTeleconsultation ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                      children: [
                        if(!isTeleconsultation)
                          SquareRoundedButton(
                            text: AppStrings().btnStartConsultation,
                            textStyle: AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 14),
                            onPressed: () {
                            showAlertDialog(appointment: listAppointments[index]);
                          },),
                        IconButton(
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                          icon: Image.asset(
                          AssetImages.chat,
                          height: 24,
                          width: 24,
                          ),
                        ),
                        if(isTeleconsultation)
                        IconButton(
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                          icon: Image.asset(
                            AssetImages.audio,
                            height: 24,
                            width: 24,
                          ),
                        ),

                        if(isTeleconsultation)
                        IconButton(
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                          icon: Image.asset(
                            AssetImages.video,
                            height: 24,
                            width: 24,
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F3F4),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  showDoctorActionView(
                      assetImage: AssetImages.view,
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().labelViewDetails,
                      onTap: () {
                        //Get.to(AppointmentDetailsPage(appointment: listAppointments[index], isTeleconsultation: isTeleconsultation,));
                      }),
                  //Spacing(isWidth: true),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 60,
                    width: 1,
                  ),
                  showDoctorActionView(
                      assetImage: AssetImages.cancel,
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().labelCancel,
                      onTap: () {
                        //Get.to(CancelAppointmentPage(appointment: listAppointments[index],));
                      }),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 60,
                    width: 1,
                  ),
                  showDoctorActionView(
                      assetImage: AssetImages.reschedule,
                      color: AppColors
                          .infoIconColor,
                      actionText: AppStrings().labelReschedule,
                      onTap: () {
                        //Get.to(RescheduleAppointmentPage(appointment: listAppointments[index],));
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDoctorActionView(
      {required String assetImage,
        required Color color,
        required String actionText,
        required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetImage,
            height: 16,
            width: 16,
          ),
          const Spacing(size: 5),
          Text(
            actionText,
            style: AppTextStyle.textNormalStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  showRescheduleAppointments() {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        itemCount: listAppointmentReschedule.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: rescheduledAppointmentsCardView
    );
  }

  Widget rescheduledAppointmentsCardView(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(top: 2, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listAppointmentReschedule[index].name,
                    style: AppTextStyle.textSemiBoldStyle(
                        color: AppColors.testColor, fontSize: 16),
                  ),
                  VerticalSpacing(size: 4,),
                  Text(
                    listAppointmentReschedule[index].visitType,
                    style: AppTextStyle
                        .textNormalStyle(
                        color: AppColors.testColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.appointmentStatusColor,
                    ),
                    height: 20,
                    width: 20,
                  ),
                  Container(
                    color: AppColors.appointmentStatusColor,
                    height: 2,
                    width: 90,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.appointmentStatusColor,
                    ),
                    height: 20,
                    width: 20,
                  ),
                  Container(
                    color: AppColors.appointmentStatusColor,
                    height: 2,
                    width: 90,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.appointmentStatusColor,
                    ),
                    height: 20,
                    width: 20,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: generateRescheduleDatesRow(listAppointmentReschedule[index]),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: generateBottomLabelRow(),
            ),
          ],
        ),
      ),
    );
  }

  generateRescheduleDatesRow(AppointmentReschedule appointmentReschedule){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '${appointmentReschedule.originalAppointmentDate}\n${appointmentReschedule.originalAppointmentTime}',
            textAlign: TextAlign.center,
            style: AppTextStyle.textMediumStyle(
                color:
                AppColors.testColor,
                fontSize: 12),
          ),
        ),

        Expanded(
          child: Text(
            '${appointmentReschedule.rescheduleAppointmentDate}\n${appointmentReschedule.rescheduleAppointmentTime}',
            textAlign: TextAlign.center,
            style: AppTextStyle.textMediumStyle(
                color:
                AppColors.testColor,
                fontSize: 12),
          ),
        ),

        Expanded(
          child: Text(
            appointmentReschedule.status,
            textAlign: TextAlign.center,
            style: AppTextStyle.textMediumStyle(
                color:
                AppColors.requestedStatusColor,
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  generateBottomLabelRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(
          AppStrings().labelOriginalAppointment,
          textAlign: TextAlign.center,
          style: AppTextStyle.textNormalStyle(
              color:
              AppColors.testColor,
              fontSize: 11),
        ),),

        Expanded(
          child: Text(
            AppStrings().labelRescheduledAppointment,
            textAlign: TextAlign.center,
            style: AppTextStyle.textNormalStyle(
                color:
                AppColors.testColor,
                fontSize: 11),
          ),
        ),

        Expanded(
          child: Text(
            AppStrings().labelStatus,
            textAlign: TextAlign.center,
            style: AppTextStyle.textNormalStyle(
                color:
                AppColors.testColor,
                fontSize: 11),
          ),
        ),
      ],
    );
  }

  showAlertDialog({required Appointments appointment}) {

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          buttonPadding: EdgeInsets.zero,
          insetPadding:  const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            AppStrings().labelEnterBookingIdTitle ,
            style: AppTextStyle.textMediumStyle(color: AppColors.black, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerticalSpacing(),
              TextFormField(
                cursorColor: AppColors.titleTextColor,
                textInputAction: TextInputAction.done,
                style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.titleTextColor),
                decoration: InputDecoration(
                    labelText: AppStrings().labelEnterPatientId,
                    labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.feesLabelTextColor),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.feesLabelTextColor))
                ),
                keyboardType: TextInputType.text,
              ),
              VerticalSpacing(),
            ],
          ),
          actions: [
            Container(
              height: 1,
              color: const Color.fromARGB(255, 238, 238, 238),
            ),
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.cross,
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppStrings().cancel,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.testColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 50,
                    width: 1,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        /*Get.to(AppointmentOngoingPage(
                          appointment: appointment,
                          isTeleconsultation: isTeleconsultation,),
                          transition: Utility.pageTransition,
                        );*/
                        Get.toNamed(AppRoutes.appointmentOngoingPage, arguments: <String, dynamic>{
                          'appointment': appointment,
                          'isTeleconsultation': isTeleconsultation
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.checked,
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppStrings().startConsultation,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.testColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///SUBMIT BUTTON
          ],
        );
      },
    );
  }

  Future<void> fetchProviderAppointments({bool isInitial = false}) async{
    try {
      if(isInitial) {
        _appointmentsController.listProviderAppointments.clear();
      }
      setState(() {
        isLoading = true;
      });
      DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
        await _appointmentsController.getProviderAppointments(fromDate: null, toDate: null, provider: doctorProfile!.uuid!, appointType: providerServiceTypes.uuid!);
      setState(() {
        isLoading = false;
      });
    } catch (e){
      debugPrint('Get provider appointments exception is ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  showProviderAppointments(){
    return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        itemCount: _appointmentsController.listProviderAppointments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return providerAppointmentCard(_appointmentsController.listProviderAppointments[index]);
        }
    );
  }

  Widget providerAppointmentCard(ProviderAppointments providerAppointment) {
    debugPrint('Appointment start date is ${providerAppointment.timeSlot!.startDate!} and end date is ${providerAppointment.timeSlot!.endDate!}');
    return (providerAppointment.status == AppointmentStatus.scheduled) ?
     Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(top: 2, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        providerAppointment.patient!.person!.display!,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                      const Spacing(),
                      Text(
                        Utility.getAppointmentDisplayDate(date: DateTime.parse(providerAppointment.timeSlot!.startDate!)),
                        style: AppTextStyle
                            .textNormalStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                    ],
                  ),
                  VerticalSpacing(size: 6,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        providerAppointment.reason ?? '',
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                      const Spacing(),
                      Text(
                        Utility.getAppointmentDisplayTimeRange(startDateTime: DateTime.parse(providerAppointment.timeSlot!.startDate!.split('.').first), endDateTime: DateTime.parse(providerAppointment.timeSlot!.endDate!.split('.').first)),
                        //Utility.getAppointmentDisplayTime(startDateTime:providerAppointment.timeSlot!.startDate!, endDateTime: providerAppointment.timeSlot!.endDate!),
                        style: AppTextStyle
                            .textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacing(isWidth: false, size: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: isTeleconsultation ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                      children: [
                        if(!isTeleconsultation)
                          SquareRoundedButton(
                            text: AppStrings().btnStartConsultation,
                            textStyle: AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 14),
                            onPressed: () {
                              //showAlertDialog(appointment: listAppointments[index]);
                            },),
                        IconButton(
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                          icon: Image.asset(
                            AssetImages.chat,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        if(isTeleconsultation)
                          IconButton(
                            onPressed: () {},
                            visualDensity: VisualDensity.compact,
                            icon: Image.asset(
                              AssetImages.audio,
                              height: 24,
                              width: 24,
                            ),
                          ),

                        if(isTeleconsultation)
                          IconButton(
                            onPressed: () {},
                            visualDensity: VisualDensity.compact,
                            icon: Image.asset(
                              AssetImages.video,
                              height: 24,
                              width: 24,
                            ),
                          ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F3F4),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  showDoctorActionView(
                      assetImage: AssetImages.view,
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().labelViewDetails,
                      onTap: () {
                        //Get.to(AppointmentDetailsPage(appointment: listAppointments[index], isTeleconsultation: isTeleconsultation,));
                      }),
                  //Spacing(isWidth: true),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 60,
                    width: 1,
                  ),
                  showDoctorActionView(
                      assetImage: AssetImages.cancel,
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().labelCancel,
                      onTap: () {
                        //Get.to(CancelAppointmentPage(appointment: listAppointments[index],));
                      }),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 60,
                    width: 1,
                  ),
                  showDoctorActionView(
                      assetImage: AssetImages.reschedule,
                      color: AppColors
                          .infoIconColor,
                      actionText: AppStrings().labelReschedule,
                      onTap: () {
                        /*Get.to(() => RescheduleAppointmentPage(appointment: providerAppointment),
                          transition: Utility.pageTransition,);*/
                        Get.toNamed(AppRoutes.rescheduleAppointmentPage, arguments: {'appointment': providerAppointment});
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    ) : Container();
  }
}

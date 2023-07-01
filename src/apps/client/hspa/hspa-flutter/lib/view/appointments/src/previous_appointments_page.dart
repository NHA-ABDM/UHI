import 'package:flutter/material.dart';
import 'package:hspa_app/controller/src/appointments_controller.dart';

import '../../../../constants/src/strings.dart';
import '../../../../model/src/appointment_reschedule.dart';
import '../../../../theme/src/app_colors.dart';
import '../../../../theme/src/app_text_style.dart';
import '../../../../widgets/src/vertical_spacing.dart';
import '../../../widgets/src/appointments_view.dart';
import 'appointments_page.dart';

class PreviousAppointmentsPage extends StatefulWidget {
  const PreviousAppointmentsPage({Key? key, required this.appointmentsController, required this.isTeleconsultation}) : super(key: key);
  final AppointmentsController appointmentsController;
  final bool isTeleconsultation;

  @override
  State<PreviousAppointmentsPage> createState() => _PreviousAppointmentsPageState();
}

class _PreviousAppointmentsPageState extends State<PreviousAppointmentsPage> with AutomaticKeepAliveClientMixin{
  List<AppointmentReschedule> listAppointmentReschedule = <AppointmentReschedule>[];

  @override
  initState(){
    listAppointmentReschedule.add(AppointmentReschedule(name: 'Tarak Mehta', visitType: 'Lab Report Consultation', originalAppointmentDate: '19 April 22', originalAppointmentTime: '8:00pm', rescheduleAppointmentDate: '21 April 22', rescheduleAppointmentTime: '7:00pm', status: 'Requested'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final appointmentsPageState = context.findAncestorStateOfType<AppointmentsPageState>()!;
        return appointmentsPageState.fetchProviderAppointments(isInitial: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.appointmentsController.listPreviousProviderAppointments
                    .isNotEmpty
                ? showProviderAppointments()
                : SizedBox(
                    height: MediaQuery.of(context).size.height - 96,
                    child: Center(
                      child: Text(
                        AppStrings().errorNoPreviousAppointments,
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 16, color: AppColors.tileColors),
                      ),
                    ),
                  ),
            VerticalSpacing(),
            /// Hiding reschedule appointments list view
            /*Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 8),
              child: Text(AppStrings(.labelRequestReschedule, style: AppTextStyle.textBoldStyle(fontSize: 18, color: AppColors.black),),
            ),
            VerticalSpacing(),
            showRescheduleAppointments()*/
          ],
        ),
      ),
    );
  }


  showProviderAppointments(){
    return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        itemCount: widget.appointmentsController.listPreviousProviderAppointments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return AppointmentsView(
            providerAppointment: widget.appointmentsController.listPreviousProviderAppointments[index],
            isTeleconsultation: widget.isTeleconsultation,
            isPrevious: true,
            cancelAppointment: () {
              setState(() {
                widget.appointmentsController.listProviderAppointments.remove(widget.appointmentsController.listPreviousProviderAppointments[index]);
                widget.appointmentsController.listPreviousProviderAppointments.removeAt(index);
              });
            },
          );
        }
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

  @override
  bool get wantKeepAlive => true;
}

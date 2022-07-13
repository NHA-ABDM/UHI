import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/appointment_status.dart';
import 'package:hspa_app/services/services.dart';

import '../../constants/src/request_urls.dart';
import '../../model/response/src/appointment_details_response.dart';
import '../../model/response/src/appointment_slots_response.dart';
import '../../model/response/src/cancel_appointment_response.dart';
import '../../model/response/src/provider_appointments_response.dart';

class AppointmentsController extends GetxController with ExceptionHandler{
  ///ERROR STRING
  var errorString = '';
  List<ProviderAppointments> listProviderAppointments = <ProviderAppointments>[];
  List<ProviderAppointments> listTodayProviderAppointments = <ProviderAppointments>[];
  List<ProviderAppointments> listUpcomingProviderAppointments = <ProviderAppointments>[];
  List<ProviderAppointments> listPreviousProviderAppointments = <ProviderAppointments>[];
  List<ProviderAppointmentSlots> listProviderAppointmentSlots = <ProviderAppointmentSlots>[];
  List<ProviderAppointmentSlots> filteredListProviderAppointmentSlots = <ProviderAppointmentSlots>[];

  Future<void> getProviderAppointments({required String? fromDate, required String? toDate, required String provider, required String appointType, int limit = 100}) async{
    String requestUrl = '${RequestUrls.getProviderAppointments}?limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default';
    if(fromDate != null && toDate != null) {
      requestUrl += '&fromDate=$fromDate&toDate=$toDate';
    }
    await BaseClient(
        url: requestUrl)
        .get()
        .then(
          (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint('GET Provider appointments response is $response');

          ProviderAppointmentsResponse providerAppointmentsResponse =
          ProviderAppointmentsResponse.fromJson(json.decode(response!));

          if(providerAppointmentsResponse.providerAppointments != null && providerAppointmentsResponse.providerAppointments!.isNotEmpty){
            debugPrint('get provider appointment parsed successfully');
            listProviderAppointments.addAll(providerAppointmentsResponse.providerAppointments!);
            filterTodayAppointments();
            filterUpcomingAppointments();
            filterPreviousAppointments();
          }
        }
      },
    ).catchError(
          (onError) {
        debugPrint('GET Provider appointments error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  Future<void> getProviderAppointmentSlots({
    required String startDate,
    required String endDate,
    required String provider,
    required String appointType,
    required ProviderAppointments appointment
  }) async{
    listProviderAppointmentSlots.clear();
    filteredListProviderAppointmentSlots.clear();
    await BaseClient(url: "${RequestUrls.getProviderAppointmentSlots}?fromDate=$startDate&toDate=$endDate&limit=100&q=&provider=$provider&appointmentType=$appointType&v=default&includeFull=true")
        .get()
        .then(
          (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint('GET Provider appointment time slots response is $response');

          AppointmentSlots? appointmentSlots =
          AppointmentSlots.fromJson(json.decode(response!));
          if(appointmentSlots.providerAppointmentSlots != null && appointmentSlots.providerAppointmentSlots!.isNotEmpty){
            debugPrint('get provider appointment slots parsed successfully');
            listProviderAppointmentSlots = appointmentSlots.providerAppointmentSlots!;

            await filterAppointmentSlots(appointment);
          }
        }
      },
    ).catchError(
          (onError) {
        debugPrint('GET Provider appointment time slots error $onError');

        errorString = onError.toString();

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  Future<void> filterAppointmentSlots(ProviderAppointments appointment) async{
    filteredListProviderAppointmentSlots.clear();
    if(listProviderAppointmentSlots.isNotEmpty){
      for (ProviderAppointmentSlots slots in listProviderAppointmentSlots) {
        if (slots.countOfAppointments! == 0 && slots.unallocatedMinutes! > 0) {
            filteredListProviderAppointmentSlots.add(slots);
        } else if(appointment.timeSlot!.uuid == slots.uuid){
          filteredListProviderAppointmentSlots.add(slots);
        }
      }
    }
  }

  void filterTodayAppointments() {
    listTodayProviderAppointments.clear();
    for(ProviderAppointments providerAppointments in listProviderAppointments){
      DateTime startDate = DateTime.parse(providerAppointments.timeSlot!.startDate!.split('.').first);
      bool isToday = true;
      if(DateTime.now().year != startDate.year){
        isToday = false;
      } else if(DateTime.now().month != startDate.month){
        isToday = false;
      } else if(DateTime.now().day != startDate.day){
        isToday = false;
      }
      if(isToday && providerAppointments.status == AppointmentStatus.scheduled) {
        listTodayProviderAppointments.add(providerAppointments);
      }
    }
  }

  void filterPreviousAppointments() {
    listPreviousProviderAppointments.clear();
    for(ProviderAppointments providerAppointments in listProviderAppointments){
      DateTime startDate = DateTime.parse(providerAppointments.timeSlot!.startDate!.split('.').first);
      if(startDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00)) && providerAppointments.status == AppointmentStatus.scheduled){
        listPreviousProviderAppointments.add(providerAppointments);
      }
    }
  }

  void filterUpcomingAppointments() {
    listUpcomingProviderAppointments.clear();
    for(ProviderAppointments providerAppointments in listProviderAppointments){
      DateTime startDate = DateTime.parse(providerAppointments.timeSlot!.startDate!.split('.').first);
      if(startDate.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59)) && providerAppointments.status == AppointmentStatus.scheduled){
        listUpcomingProviderAppointments.add(providerAppointments);
      }
    }
  }

  Future<CancelAppointmentResponse?> cancelProviderAppointment(
      {required String appointmentUUID,
        required String status,
        required dynamic cancelReason}) async {
    Map<String, dynamic> requestBody = {
      'status': status,
      'cancelReason': cancelReason.toString()
    };
    debugPrint('cancel appointment request body is $requestBody');
    CancelAppointmentResponse? attributeResponse = await BaseClient(
      url: '${RequestUrls.getProviderAppointments}/$appointmentUUID',
      body: requestBody,
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            CancelAppointmentResponse? cancelAppointmentResponse = CancelAppointmentResponse
                .fromJson(json.decode(response));
            debugPrint('Cancel appointment response parsed successfully ${cancelAppointmentResponse.uuid}');
            return cancelAppointmentResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Cancel appointment error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return attributeResponse;
  }

  Future<AppointmentDetailsResponse?> getAppointmentDetails(
      {required String appointmentUUID}) async {
    String requestUrl = '${RequestUrls.getProviderAppointmentHistory}?appointment=$appointmentUUID&v=full';
    debugPrint('Appointment details request body is $requestUrl');
    AppointmentDetailsResponse? appointmentDetailsResponse = await BaseClient(
      url: requestUrl,
    ).get()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            AppointmentDetailsResponse? appointmentDetailsResponse = AppointmentDetailsResponse
                .fromJson(json.decode(response));
            debugPrint('Appointment details response parsed successfully');
            return appointmentDetailsResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Appointment details error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return appointmentDetailsResponse;
  }

  Future<bool?> purgeCanceledAppointmentSlot(
      {required String appointmentUUID}) async {
    bool? attributeResponse = await BaseClient(
      url: '${RequestUrls.getProviderAppointments}/$appointmentUUID?!purge&reason=NA',
    ).delete()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          bool? response = value;
          if(response != null) {
            debugPrint('Purge appointment slot response value is  $response');
            return response;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Purge appointment slot error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return attributeResponse;
  }
}
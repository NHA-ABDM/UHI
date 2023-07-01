import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/src/request_urls.dart';
import '../../model/response/src/appointment_slots_response.dart';
import '../../services/src/exception_handler.dart';
import 'package:get/get.dart';

import '../../services/src/service.dart';

class AppointmentsSlotsCalenderViewController extends GetxController
    with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';

  List<ProviderAppointmentSlots> listProviderAppointmentSlots =
      <ProviderAppointmentSlots>[];
  List<ProviderAppointmentSlots> filteredListProviderAppointmentSlots =
      <ProviderAppointmentSlots>[];

  Future<void> getProviderAppointmentSlots(
      {required String startDate,
      required String endDate,
      required String provider,
      required String appointType,
      int startIndex = 0}) async {
    int limit = 100;
    if(startIndex == 0) {
      listProviderAppointmentSlots.clear();
      filteredListProviderAppointmentSlots.clear();
    }
    await BaseClient(
            url:
                "${RequestUrls.getProviderAppointmentSlots}?fromDate=$startDate&toDate=$endDate&limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default&includeFull=true&startIndex=$startIndex")
        .get()
        .then(
      (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint(
              'GET Provider Calender events appointment time slots response is $response');

          AppointmentSlots? appointmentSlots =
              AppointmentSlots.fromJson(json.decode(response!));
          if (appointmentSlots.providerAppointmentSlots != null &&
              appointmentSlots.providerAppointmentSlots!.isNotEmpty) {
            debugPrint(
                'get provider Calender events appointment slots parsed successfully');
            listProviderAppointmentSlots.addAll(appointmentSlots.providerAppointmentSlots!);
          }

          if(appointmentSlots.links != null && appointmentSlots.links!.isNotEmpty) {
              //if(appointmentSlots.providerAppointmentSlots!.isNotEmpty && appointmentSlots.providerAppointmentSlots!.length == limit) {
            for(Links link in appointmentSlots.links!) {
              if (link.rel == 'next') {
                startIndex = startIndex + limit;
                await getProviderAppointmentSlots(startDate: startDate,
                    endDate: endDate,
                    provider: provider,
                    appointType: appointType,
                    startIndex: startIndex);
                break;
              }
            }
          }
        }
      },
    ).catchError(
      (onError) {
        debugPrint(
            'GET Provider Calender events appointment time slots error $onError');

        errorString = onError.toString();

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

}

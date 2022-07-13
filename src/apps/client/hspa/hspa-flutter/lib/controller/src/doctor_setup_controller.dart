import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/constants/src/request_urls.dart';
import 'package:hspa_app/model/response/src/add_appointment_time_slot_response.dart';
import 'package:hspa_app/services/services.dart';

import '../../model/response/src/add_provider_attribute_response.dart';

class DoctorSetUpController extends GetxController with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';

  Future<AddProviderAttributeResponse?> addAttributeToProvider(
      {required String providerUUID,
      required String attributeTypeUUID,
      required dynamic value}) async {
    Map<String, dynamic> requestBody = {
      'attributeType': attributeTypeUUID,
      'value': value.toString()
    };
    AddProviderAttributeResponse? attributeResponse = await BaseClient(
      url: '${RequestUrls.addAttributeToProvider}/$providerUUID/attribute',
      body: requestBody,
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          //debugPrint('add provider attribute response is $value');
          String? response = value;
          if(response != null) {
            AddProviderAttributeResponse? attributeResponse = AddProviderAttributeResponse
                .fromJson(json.decode(response));
            debugPrint('add provider attribute response parsed successfully ${attributeResponse.uuid}');
            return attributeResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Add Provider attribute error $onError');

        errorString = onError.toString();

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return attributeResponse;
  }

  Future<AddAppointmentTimeSlotResponse?> addProviderAppointmentTimeSlots(
      {
        required String startDate,
        required String endDate,
        required String providerUUID,
        required List<String> types,
        String location = ProviderAttributesLocal.outPatient,
      }) async {
    Map<String, dynamic> requestBody = {
      'startDate': startDate,
      'endDate': endDate,
      'provider': providerUUID,
      'location': location,
      'types': types.toList(),
    };
    debugPrint('Save appointment slot request body is $requestBody');
    AddAppointmentTimeSlotResponse? addAppointmentSlotResponse =
    await BaseClient(
      url: RequestUrls.addProviderAppointmentSlots,
      body: requestBody,
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            debugPrint('Add provider appointment slots api response is $response');
            AddAppointmentTimeSlotResponse? addProviderAppointmentSlots = AddAppointmentTimeSlotResponse
                .fromJson(json.decode(response));
            debugPrint('add provider appointment slot response parsed successfully ${addProviderAppointmentSlots.uuid}');
            return addProviderAppointmentSlots;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Add Provider attribute error $onError');

        errorString = onError.toString();

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return addAppointmentSlotResponse;
  }
}

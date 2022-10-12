import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/strings.dart';
import '../../constants/src/appointment_status.dart';
import '../../constants/src/provider_attributes.dart';
import '../../model/response/src/hspa_appointments_response.dart';
import '../../services/services.dart';

import '../../constants/src/request_urls.dart';
import '../../model/request/src/cancel_appointment_request.dart';
import '../../model/response/src/acknowledgement_response_model.dart';
import '../../model/response/src/appointment_details_response.dart';
import '../../model/response/src/appointment_slots_response.dart';
import '../../model/response/src/cancel_appointment_response.dart';
import '../../model/response/src/provider_appointments_response.dart';
import '../../utils/src/utility.dart';

class AppointmentsController extends GetxController with ExceptionHandler{
  ///ERROR STRING
  var errorString = '';
  List<ProviderAppointments> listProviderAppointments = <ProviderAppointments>[];
  List<ProviderAppointments> listTodayProviderAppointments = <ProviderAppointments>[];
  List<HSPAAppointments> listTodayProviderHSPAAppointments = <HSPAAppointments>[];
  List<ProviderAppointments> listUpcomingProviderAppointments = <ProviderAppointments>[];
  List<HSPAAppointments> listUpcomingProviderHSPAAppointments = <HSPAAppointments>[];
  List<ProviderAppointments> listPreviousProviderAppointments = <ProviderAppointments>[];
  List<HSPAAppointments> listPreviousProviderHSPAAppointments = <HSPAAppointments>[];
  List<ProviderAppointmentSlots> listProviderAppointmentSlots = <ProviderAppointmentSlots>[];
  List<ProviderAppointmentSlots> filteredListProviderAppointmentSlots = <ProviderAppointmentSlots>[];

  DateTime? upcomingStartDate;
  DateTime? upcomingEndDate;
  DateTime? previousStartDate;
  DateTime? previousEndDate;
  bool isTodayDataLoading = false;
  bool isUpcomingDataLoading = false;
  bool isPreviousDataLoading = false;

  /// Flags used to check if list to be fetched from OpenMrs or from HSPA Backend
  bool isOpenMrsAppointments = false;

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
    ).put()
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

  Future<AcknowledgementMessage?> cancelProviderAppointmentWrapper(
      {required String appointmentUUID,
        required CancelAppointmentRequestModel cancelAppointmentRequestModel}) async {

    debugPrint('cancel appointment wrapper request body is ${cancelAppointmentRequestModel.toJson()}');
    AcknowledgementMessage? acknowledgementMessage = await BaseClient(
      url: RequestUrls.cancelProviderAppointment,
      body: cancelAppointmentRequestModel.toJson(),
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if (response != null) {
            Map<String, dynamic> jsonMap = json.decode(response);
            AcknowledgementMessage? acknowledgementMessage;
            if (jsonMap.containsKey('message')) {
              acknowledgementMessage = AcknowledgementMessage.fromJson(jsonMap['message']);
            }
            debugPrint(
                'Cancel appointment wrapper response parsed successfully ${acknowledgementMessage?.ack?.status}');
            return acknowledgementMessage;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Cancel appointment wrapper error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return acknowledgementMessage;
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

  Future<void> getProviderUpcomingFilterAppointments({required String? fromDate, required String? toDate, required String provider, required String appointType, int limit = 100, required String hprAddress, isOpenMrs = true, String sort = 'ASC'}) async{

    if(isOpenMrs) {
      String requestUrl = '${RequestUrls
          .getProviderAppointments}?limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default';
      if (fromDate != null) {
        requestUrl += '&fromDate=$fromDate';
      }
      if (toDate != null) {
        requestUrl += '&toDate=$toDate';
      }
      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint(
              'GET Provider upcoming appointments response is $response');

          ProviderAppointmentsResponse providerAppointmentsResponse =
          ProviderAppointmentsResponse.fromJson(json.decode(response!));
          listUpcomingProviderAppointments.clear();
          if (providerAppointmentsResponse.providerAppointments != null &&
              providerAppointmentsResponse.providerAppointments!.isNotEmpty) {
            debugPrint('get provider upcoming appointment parsed successfully');
            for (ProviderAppointments providerAppointments in providerAppointmentsResponse
                .providerAppointments!) {
              if (providerAppointments.status == AppointmentStatus.scheduled) {
                listUpcomingProviderAppointments.add(providerAppointments);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider upcoming appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    } else {
      String appointmentType = AppStrings.teleconsultation;
      if(appointType == ProviderAttributesLocal.physicalConsultation){
        appointmentType = AppStrings.physicalConsultation;
      }

      DateTime tomorrowDate = DateTime.now().add(const Duration(days: 1));
      DateTime upcomingLastDate = DateTime.now().add(const Duration(days: 365));
      fromDate ??= Utility.getAPIRequestDateFormatString(tomorrowDate);
      toDate ??= Utility.getAPIRequestDateFormatString(upcomingLastDate);

      String requestUrl = '${RequestUrls
          .getProviderHSPAAppointments}$hprAddress?limit=$limit&sort=$sort&aType=$appointmentType';
      requestUrl += '&startDate=$fromDate&endDate=$toDate';

      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint('GET Provider upcoming HSPA appointments response is $response');

          HSPAAppointmentsResponse hspaAppointmentsResponse =
          HSPAAppointmentsResponse.fromJson(json.decode(response!));
          listUpcomingProviderHSPAAppointments.clear();
          if (hspaAppointmentsResponse.listHSPAAppointments != null &&
              hspaAppointmentsResponse.listHSPAAppointments!.isNotEmpty) {
            debugPrint('get provider upcoming hspa appointment parsed successfully');
            for (HSPAAppointments hspaAppointment in hspaAppointmentsResponse
                .listHSPAAppointments!) {
              if (hspaAppointment.isServiceFulfilled == AppointmentStatus.confirmed) {
                listUpcomingProviderHSPAAppointments.add(hspaAppointment);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider upcoming HSPA appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    }
  }

  Future<void> getProviderTodayFilterAppointments({required String? fromDate, required String? toDate, required String provider, required String appointType, int limit = 100, required String hprAddress, isOpenMrs = true, String sort = 'ASC'}) async{

    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime(now.year, now.month, now.day, 00, 00, 00);
    DateTime endDateTime = DateTime(now.year, now.month, now.day, 23, 59, 59);

    fromDate = Utility.getAPIRequestDateFormatString(startDateTime);
    toDate = Utility.getAPIRequestDateFormatString(endDateTime);

    if(isOpenMrs) {
      String requestUrl = '${RequestUrls
          .getProviderAppointments}?limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default';
      requestUrl += '&fromDate=$fromDate&toDate=$toDate';

      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint('GET Provider today appointments response is $response');

          ProviderAppointmentsResponse providerAppointmentsResponse =
          ProviderAppointmentsResponse.fromJson(json.decode(response!));
          listTodayProviderAppointments.clear();
          if (providerAppointmentsResponse.providerAppointments != null &&
              providerAppointmentsResponse.providerAppointments!.isNotEmpty) {
            debugPrint('get provider today appointment parsed successfully');
            for (ProviderAppointments providerAppointments in providerAppointmentsResponse
                .providerAppointments!) {
              if (providerAppointments.status == AppointmentStatus.scheduled) {
                listTodayProviderAppointments.add(providerAppointments);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider today appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    } else {
      String appointmentType = AppStrings.teleconsultation;
      if(appointType == ProviderAttributesLocal.physicalConsultation){
        appointmentType = AppStrings.physicalConsultation;
      }
      String requestUrl = '${RequestUrls
          .getProviderHSPAAppointments}$hprAddress?limit=$limit&sort=$sort&aType=$appointmentType';
      requestUrl += '&startDate=$fromDate&endDate=$toDate';

      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint('GET Provider today HSPA appointments response is $response');

          HSPAAppointmentsResponse hspaAppointmentsResponse =
          HSPAAppointmentsResponse.fromJson(json.decode(response!));
          listTodayProviderHSPAAppointments.clear();
          if (hspaAppointmentsResponse.listHSPAAppointments != null &&
              hspaAppointmentsResponse.listHSPAAppointments!.isNotEmpty) {
            debugPrint('get provider today hspa appointment parsed successfully');
            for (HSPAAppointments hspaAppointment in hspaAppointmentsResponse
                .listHSPAAppointments!) {
              if (hspaAppointment.isServiceFulfilled == AppointmentStatus.confirmed) {
                listTodayProviderHSPAAppointments.add(hspaAppointment);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider today HSPA appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    }
  }

  Future<void> getProviderPreviousFilterAppointments({required String? fromDate, required String? toDate, required String provider, required String appointType, int limit = 100, required String hprAddress, isOpenMrs = true, String sort = 'DESC'}) async {
    if (isOpenMrs) {
      String requestUrl = '${RequestUrls
          .getProviderAppointments}?limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default';
      if (fromDate != null) {
        requestUrl += '&fromDate=$fromDate';
      }
      if (toDate != null) {
        requestUrl += '&toDate=$toDate';
      }
      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint(
              'GET Provider previous appointments response is $response');

          ProviderAppointmentsResponse providerAppointmentsResponse =
          ProviderAppointmentsResponse.fromJson(json.decode(response!));
          listPreviousProviderAppointments.clear();
          if (providerAppointmentsResponse.providerAppointments != null &&
              providerAppointmentsResponse.providerAppointments!.isNotEmpty) {
            debugPrint('get provider previous appointment parsed successfully');
            for (ProviderAppointments providerAppointments in providerAppointmentsResponse
                .providerAppointments!) {
              if (providerAppointments.status == AppointmentStatus.scheduled) {
                listPreviousProviderAppointments.add(providerAppointments);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider previous appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    } else {
      String appointmentType = AppStrings.teleconsultation;
      if(appointType == ProviderAttributesLocal.physicalConsultation){
        appointmentType = AppStrings.physicalConsultation;
      }

      DateTime yesterdayDate = DateTime.now().subtract(const Duration(days: 1));
      fromDate ??= '2022-01-01T00:00:00';
      toDate ??= Utility.getAPIRequestDateFormatString(yesterdayDate);

      String requestUrl = '${RequestUrls
          .getProviderHSPAAppointments}$hprAddress?limit=$limit&sort=$sort&aType=$appointmentType';
      requestUrl += '&startDate=$fromDate&endDate=$toDate';

      await BaseClient(url: requestUrl).get().then((value) async {
        if (value == null) {} else {
          String? response = value;
          debugPrint('GET Provider previous HSPA appointments response is $response');

          HSPAAppointmentsResponse hspaAppointmentsResponse =
          HSPAAppointmentsResponse.fromJson(json.decode(response!));
          listPreviousProviderHSPAAppointments.clear();
          if (hspaAppointmentsResponse.listHSPAAppointments != null &&
              hspaAppointmentsResponse.listHSPAAppointments!.isNotEmpty) {
            debugPrint('get provider previous hspa appointment parsed successfully');
            for (HSPAAppointments hspaAppointment in hspaAppointmentsResponse
                .listHSPAAppointments!) {
              if (hspaAppointment.isServiceFulfilled == AppointmentStatus.confirmed) {
                listPreviousProviderHSPAAppointments.add(hspaAppointment);
              }
            }
          }
        }
      },
      ).catchError(
            (onError) {
          debugPrint('GET Provider previous HSPA appointments error $onError');
          errorString = onError.toString();
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    }
  }
}
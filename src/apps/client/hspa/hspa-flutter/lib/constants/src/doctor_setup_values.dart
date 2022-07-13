import 'package:flutter/material.dart';

class DoctorSetupValues {
  static final DoctorSetupValues _singleton = DoctorSetupValues._internal();

  factory DoctorSetupValues() {
    return _singleton;
  }

  DoctorSetupValues._internal();

  String? firstConsultation;
  String? followUp;
  String? labReportConsultation;
  String? psFirstConsultation;
  String? psFollowUp;
  String? psLabReportConsultation;
  String? upiId;
  String? receivePayment;
  String? signature;
  bool? isTeleconsultation;
  bool? isPhysicalConsultation;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool? isFixed;
  int? fixedDurationSlot;
  List<DateTime> dateTimeSlot = <DateTime>[];
  List<String> serviceTypes = <String>[];

  void clear() {
    firstConsultation = null;
    followUp = null;
    labReportConsultation = null;
    psFirstConsultation = null;
    psFollowUp = null;
    psLabReportConsultation = null;
    upiId = null;
    receivePayment = null;
    signature = null;
    isTeleconsultation = null;
    isPhysicalConsultation = null;
    startDate = null;
    endDate = null;
    startTime = null;
    endTime = null;
    isFixed = null;
    fixedDurationSlot = null;
    dateTimeSlot.clear();
    serviceTypes.clear();
  }

}
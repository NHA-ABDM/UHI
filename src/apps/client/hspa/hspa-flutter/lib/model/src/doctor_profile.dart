import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hspa_app/constants/src/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfile {
  String? uuid;
  String? displayName;
  String? gender;
  String? profilePhoto;
  String? speciality;
  String? medicineType;
  String? experience;
  String? education;
  String? languages;
  String? hprAddress;
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
  List<ConsultType>? consultTypes;

  DoctorProfile({
    required this.uuid,
    required this.displayName,
    this.gender,
    this.profilePhoto,
    this.speciality,
    this.medicineType,
    this.experience,
    this.education,
    this.languages,
    this.hprAddress,
    this.firstConsultation,
    this.followUp,
    this.labReportConsultation,
    this.psFirstConsultation,
    this.psFollowUp,
    this.psLabReportConsultation,
    this.upiId,
    this.receivePayment,
    this.signature,
    this.isTeleconsultation,
    this.isPhysicalConsultation
  });

  DoctorProfile.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        displayName = json['displayName'],
        gender = json['gender'],
        profilePhoto = json['profilePhoto'],
        speciality = json['speciality'],
        medicineType = json['medicineType'],
        experience = json['experience'],
        education = json['education'],
        languages = json['languages'],
        hprAddress = json['hprAddress'],
        firstConsultation = json['firstConsultation'],
        followUp = json['followUp'],
        labReportConsultation = json['labReportConsultation'],
        psFirstConsultation = json['psFirstConsultation'],
        psFollowUp = json['psFollowUp'],
        psLabReportConsultation = json['psLabReportConsultation'],
        upiId = json['upiId'],
        receivePayment = json['receivePayment'],
        signature = json['signature'],
        isTeleconsultation = json['isTeleconsultation'],
        isPhysicalConsultation = json['isPhysicalConsultation']
  ;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'displayName': displayName,
    'gender': gender,
    'profilePhoto': profilePhoto,
    'speciality': speciality,
    'medicineType': medicineType,
    'experience': experience,
    'education': education,
    'languages': languages,
    'hprAddress': hprAddress,
    'firstConsultation' : firstConsultation,
    'followUp' : followUp,
    'labReportConsultation' : labReportConsultation,
    'psFirstConsultation' : psFirstConsultation,
    'psFollowUp' : psFollowUp,
    'psLabReportConsultation' : psLabReportConsultation,
    'upiId' : upiId,
    'receivePayment' : receivePayment,
    'signature' : signature,
    'isTeleconsultation' : isTeleconsultation,
    'isPhysicalConsultation' : isPhysicalConsultation,
  };

  @override
  String toString() {
    return 'DoctorProfile{uuid: $uuid, displayName: $displayName, gender: $gender, profilePhoto: $profilePhoto, speciality: $speciality, medicineType: $medicineType, experience: $experience, education: $education, languages: $languages, hprAddress: $hprAddress, firstConsultation: $firstConsultation, followUp: $followUp, labReportConsultation: $labReportConsultation, psFirstConsultation: $psFirstConsultation, psFollowUp: $psFollowUp, psLabReportConsultation: $psLabReportConsultation, upiId: $upiId, receivePayment: $receivePayment, signature: $signature, consultTypes: $consultTypes, isTeleconsultation: $isTeleconsultation, isPhysicalConsultation: $isPhysicalConsultation}';
  }
  
  Future<void> saveDoctorProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(AppStrings.doctorProfile, json.encode(toJson()));
    debugPrint('Doctor Profile saved ${json.encode(toJson())}');
  }

  static Future<DoctorProfile?> getSavedProfile() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? profile = preferences.getString(AppStrings.doctorProfile);
    if(profile != null && profile.isNotEmpty){
      return DoctorProfile.fromJson(json.decode(profile));
    }
      return null;
  }

  static void emptyDoctorProfile() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(AppStrings.doctorProfile, '');
  }
}

enum ConsultationType { teleconsultation, physicalConsultation }

class ConsultType {
  late ConsultationType consultationType;
  Double? firstConsultationFees;
  Double? followUpFees;
  Double? labReportFees;
  String? upiId;
  bool afterConsultation;
  bool withInWeek;
  bool enabled;

  ConsultType({
    required this.consultationType,
    required this.firstConsultationFees,
    required this.followUpFees,
    required this.labReportFees,
    required this.upiId,
    this.afterConsultation = false,
    this.withInWeek = false,
    required this.enabled,
  });
}

import 'package:flutter/material.dart';

import '../../constants/src/strings.dart';

class Validator {

  static RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
  static RegExp stringWithCommaRegex = RegExp(r'^[a-zA-Z ,]+$');

  static String? validateMobileNumber(String? number){
    debugPrint('Mobile number entered is $number');
    if(number != null){
      if(number.isEmpty) {
        return AppStrings().errorEnterMobileNumber;
      } if(number.trim().length != 10){
        return AppStrings().errorEnterValidMobile;
      } else if(int.tryParse(number.trim()) == null){
        return AppStrings().errorEnterValidMobile;
      } else {
        return null;
      }
    } else {
      return AppStrings().errorEnterMobileNumber;
    }
  }

  static String? validateOtp(String? otp){
    if(otp != null){
      if(otp.isEmpty) {
        return AppStrings().errorEnterOTP;
      } else if(otp.trim().length != 6){
        return AppStrings().invalidOTP;
      } else if(int.tryParse(otp.trim()) == null){
        return AppStrings().invalidOTP;
      } else {
        return null;
      }
    } else {
      return AppStrings().errorEnterOTP;
    }
  }

  static String? validateAadhaar(String? aadhaar){
    if(aadhaar != null){
      if(aadhaar.trim().length != 12){
        return AppStrings().invalidAadhaar;
      } else if(int.tryParse(aadhaar.trim()) == null){
        return AppStrings().invalidAadhaar;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateHprAddress(String? hprAddress){
    if(hprAddress != null){
      if(hprAddress.isEmpty){
        return AppStrings().errorEnterHprAddress;
      } else if (!RegExp(r"^[A-Za-z0-9._%+-]+@hpr.(abdm|ndhm|sbx)$").hasMatch(hprAddress)) {
        return AppStrings().errorInvalidHprAddress;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateHprId(String? hprId){
    if(hprId != null){
      if(hprId.isEmpty){
        return AppStrings().errorEnterHprId;
      }  else if(hprId.trim().length != 14){
        return AppStrings().errorInvalidHprId;
      } else if(int.tryParse(hprId.trim()) == null){
        return AppStrings().errorInvalidHprId;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateFees(String? fees){
    if(fees != null){
      if(fees.isEmpty) {
        return AppStrings().errorProvideFees;
      } else if (double.tryParse(fees.trim()) == null) {
        return AppStrings().errorProvideProperFees;
      } else if (double.parse(fees.trim()) <= 0) {
        return AppStrings().errorProvideNonZeroFees;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateUpiId(String? upiId){
    var upiMatch = RegExp(r"^[\w.-]+@[\w.-]+$");
    if(upiId != null){
      if(upiId.isEmpty) {
        return AppStrings().errorProvideUpi;
      } else if (!upiMatch.hasMatch(upiId)) {
        return AppStrings().errorProvideValidUpi;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateAge(String? age){
    if(age != null){
      if(age.isEmpty) {
        return AppStrings().errorProvideAge;
      } else if (age.startsWith(' ') || age.trim().contains(' ')) {
        return AppStrings().errorShouldNotContainSpace;
      } else if (double.tryParse(age.trim()) == null) {
        return AppStrings().errorProvideValidAge;
      } else if (double.parse(age.trim()) <= 0) {
        return AppStrings().errorProvideNonZeroAge;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String? validateExperience(String? experience){
    if(experience != null){
      if(experience.isEmpty) {
        return AppStrings().errorProvideExperience;
      } else if (double.tryParse(experience.trim()) == null) {
        return AppStrings().errorProvideValidExperience;
      } else if (double.parse(experience.trim()) <= 0) {
        return AppStrings().errorProvideNonZeroExperience;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
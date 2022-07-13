import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyle {
  static textBoldStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 14}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      );

  static textSemiBoldStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 14, TextDecoration decoration = TextDecoration.none}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        decoration: decoration
      );

  static textMediumStyle(
          {Color color = AppColors.appointmentConfirmDoctorActionsTextColor,
          double fontSize = 14}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
      );

  static textNormalStyle(
      {Color color = AppColors.doctorNameColor, double fontSize = 12, TextDecoration decoration = TextDecoration.none}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        decoration: decoration,
      );

  static textLightStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 12}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
      );

  static get resendOTPText => GoogleFonts.roboto(
        color: Colors.blue[300],
        fontWeight: FontWeight.w300,
        fontSize: 16,
        decoration: TextDecoration.underline,
      );
}

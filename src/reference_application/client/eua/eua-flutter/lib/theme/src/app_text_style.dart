import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyle {
  static appointmentConfirmedBoldTextStyle(
          {Color color = AppColors.appointmentStatusColor}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      );
  static appointmentConfirmedBold14TextStyle(
          {Color color = AppColors.appointmentConfirmTextColor}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      );
  static appointmentConfirmedLightTextStyle(
          {Color color = AppColors.appointmentConfirmTextColor}) =>
      GoogleFonts.roboto(
        color: AppColors.appointmentConfirmTextColor,
        fontWeight: FontWeight.w300,
        fontSize: 14,
      );

  static appointmentDoctorActionsTextStyle(
          {Color color = AppColors.appointmentConfirmDoctorActionsTextColor}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w300,
        fontSize: 12,
      );

  static textBoldStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 14}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      );

  static textSemiBoldStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 14}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
      );
  static textMediumStyle(
          {Color color = AppColors.appointmentConfirmDoctorActionsTextColor,
          double fontSize = 14}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
      );
  static textLightStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 12}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
      );

  static textNormalStyle(
          {Color color = AppColors.doctorNameColor, double fontSize = 12}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      );

  static get resendOTPText => GoogleFonts.roboto(
        color: Colors.blue[300],
        fontWeight: FontWeight.w300,
        fontSize: 16,
        decoration: TextDecoration.underline,
      );
}

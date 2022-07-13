import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  ///INITIALIZE THEME MODE CONTROLLER
  static final ThemeModeController themeModeController =
      Get.put(ThemeModeController());

  ///White
  static get white => themeModeController.themeMode
      ? _lightThemeWhiteColor
      : darkThemeWhiteColor;

  static const Color _lightThemeWhiteColor = Color(0xFFFFFFFF);
  static const Color testColor = Color(0xFF394050);
  static const Color appBackgroundColor = Color(0xFFFFFFFF);
  static const Color innerBoxColor = Color(0xFFDDDDDD);
  static const Color textColor = Color(0xFF363636);
  static const Color titleTextColor = Color(0xFF171717);
  static const Color drNameTextColor = Color(0xFF222B45);
  static const Color drDetailsTextColor = Color(0xFF8F9BB3);
  static const Color labelTextColor = Color(0xFF8F92A1);
  static const Color darkThemeWhiteColor = Colors.red;
  static const Color confirmTextColor = Color(0xFF00CC39);
  static const Color doctorNameColor = Color(0xFF334856);
  static const Color doctorExperienceColor = Color(0xFF798186);
  static const Color amountColor = Color(0xFFE8705A);
  static const Color tileColors = Color(0xFF264488);
  static const Color infoIconColor = Color(0xFF324755);
  static const Color linkTextColor = Color(0xFF0052CC);
  static const Color loginBackgroundColor = Color.fromARGB(255, 245, 247, 252);
  static const Color appointmentStatusColor = Color(0xFF8ACB96);
  static const Color DARK_PURPLE = Color(0xFF203746);
  static const Color paymentButtonBackgroundColor = Color(0xFF479CFB);
  static const Color appointmentConfirmTextColor = Color(0xFF1B1C20);
  static const Color appointmentConfirmDoctorActionsTextColor =
      Color(0xFFA6AEC1);
  static const Color appointmentConfirmDoctorActionsEnabledTextColor =
      Color(0xFF264488);
  static const Color dividerColor = Color(0xFFF0F3F4);
  static const Color drawerDividerColor = Color(0xFFEDF1F7);
  static const Color lightTextColor = Color(0xFFC8C8C8);
  static const Color progressBarBackColor = Color(0xFFEAEAEA);
  static const Color hintTextColor = Color(0xFF9A9A9A);
  static const Color unselectedTextColor = Color(0xFF9A9A9D);
  static const Color feesLabelTextColor = Color(0xFF616673);
  static const Color unselectedBackColor = Color(0xFFF0F0F0);
  static const Color checkboxTitleTextColor = Color(0xFF474747);
  static const Color requestedStatusColor = Color(0xFFFF9900);
  static const Color senderBackColor = Color(0xFFF3F3F3);
  static const Color senderTextColor = Color(0xFF525252);

  //Login page colors
  static const Color mobileNumberTextColor = Color(0xFF343434);

  ///Black
  static get black => themeModeController.themeMode
      ? _lightThemeBlackColor
      : _darkThemeBlackColor;

  static const Color _lightThemeBlackColor = Color(0xFF000000);

  static const Color _darkThemeBlackColor = Colors.red;

  ///Background White Color
  static get backgroundWhiteColorFBFCFF => themeModeController.themeMode
      ? _lightThemeBackgroundWhiteColorFBFCFF
      : _darkThemeBackgroundWhiteColor;

  static const Color _lightThemeBackgroundWhiteColorFBFCFF = Color(0xFFFBFCFF);

  static const Color _darkThemeBackgroundWhiteColor = Colors.red;

  ///Primary Light Blue
  static get primaryLightBlue007BFF => themeModeController.themeMode
      ? _lightThemePrimaryLightBlueColor
      : _darkThemePrimaryGreyColor;

  static const Color _lightThemePrimaryLightBlueColor = Color(0xFF007BFF);

  static const Color _darkThemePrimaryGreyColor = Colors.grey;

  ///Secondary Orange
  static get secondaryOrangeFF8A07 => themeModeController.themeMode
      ? _lightThemeSecondaryOrangeColor
      : _darkThemeSecondaryOrangeColor;

  static const Color _lightThemeSecondaryOrangeColor = Color(0xFFFF8A07);

  static const Color _darkThemeSecondaryOrangeColor = Colors.grey;

  ///Grey Text Color
  static get grey8B8B8B => themeModeController.themeMode
      ? _lightThemeGreyColor8B8B8B
      : _darkThemeGreyColor;

  static const Color _lightThemeGreyColor8B8B8B = Color(0xFF8B8B8B);

  static const Color _darkThemeGreyColor = Colors.grey;

  ///Light Grey Text Color
  static get grey787878 => themeModeController.themeMode
      ? _lightThemeLightGreyColor787878
      : _darkThemeGreyColor;

  static const Color _lightThemeLightGreyColor787878 = Color(0xFF787878);

  static const Color _darkThemeLightGreyColor = Colors.grey;

  ///Grey Hint Text Color
  static get greyHint828282 => themeModeController.themeMode
      ? _lightThemeGreyHintColor828282
      : _darkThemeGreyHintColor;

  static const Color _lightThemeGreyHintColor828282 = Color(0xFF828282);

  static const Color _darkThemeGreyHintColor = Colors.grey;

  ///Grey Divider Color
  static get greyDDDDDD => themeModeController.themeMode
      ? _lightThemeGreyColorDDDDDD
      : _darkThemeGreyColorDDDDDD;

  static const Color _lightThemeGreyColorDDDDDD = Color(0xFFDDDDDD);

  static const Color _darkThemeGreyColorDDDDDD = Colors.grey;

  ///Dark Grey Icon Color
  static get darkGrey323232 => themeModeController.themeMode
      ? _lightThemeDarkGreyColor323232
      : _darkThemeDarkGreyColor323232;

  static const Color _lightThemeDarkGreyColor323232 = Color(0xFF323232);

  static const Color _darkThemeDarkGreyColor323232 = Colors.grey;

  ///Dark Grey Text Color
  static get darkGrey363636 => themeModeController.themeMode
      ? _lightThemeDarkGreyColor363636
      : _darkThemeDarkGreyColor363636;

  static const Color _lightThemeDarkGreyColor363636 = Color(0xFF363636);

  static const Color _darkThemeDarkGreyColor363636 = Colors.grey;
}

class ThemeModeController extends GetxController {
  ///`themeMode` boolean variable used to toggle the theme
  bool themeMode = true;

  toggleThemeMode() {
    themeMode = !themeMode;
    update();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

snackbarMessage({
  required String message,
  required IconData icon,
  Color? statusColor,
  SnackPosition snackPosition = SnackPosition.TOP,
  Color backgroundColor = AppColors.tileColors,
  Color textAndIconColor = Colors.white,
  int duration = 3
}) async {
  Get.closeAllSnackbars();
  Get.snackbar(
    "",
    "",
    messageText: Row(
      children: [
        ///ICON INFO
        Icon(icon, color: textAndIconColor),

        ///SPACE
        SizedBox(width: Get.width * 0.02),

        ///TEXT
        Expanded(
          child: Text(
            message,
            style: AppTextStyle.textBoldStyle(
                color: textAndIconColor, fontSize: 15),
          ),
        ),
      ],
    ),
    titleText: const SizedBox.shrink(),
    margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.035, vertical: Get.width * 0.02),
    borderRadius: 7,
    backgroundColor: backgroundColor,
    snackPosition: snackPosition,
    duration: Duration(seconds: duration),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

snackbarMessage({
  required String message,
  required IconData icon,
  Color? statusColor,
}) {
  Get.snackbar(
    "",
    "",
    messageText: Row(
      children: [
        ///ICON INFO
        Icon(icon, color: AppColors.white),

        ///SPACE
        SizedBox(width: Get.width * 0.02),

        ///TEXT
        Expanded(
          child: Text(
            message,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.testColor, fontSize: 15),
          ),
        ),
      ],
    ),
    titleText: const SizedBox.shrink(),
    margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.035, vertical: Get.width * 0.02),
    borderRadius: 7,
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 6),
  );
}

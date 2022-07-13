import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/strings.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';
import 'snackbar_message.dart';

class DialogHelper {
  //show error dialog
  static void showErrorDialog(
      {String? title, String? description}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? AppStrings().error,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 16),
              ),

              ///SPACE
              const SizedBox(
                height: 10,
              ),

              ///DESCRIPTION
              Text(
                description ?? AppStrings().somethingWentWrong,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 16),
              ),

              ///SPACE
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 1.0),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  AppStrings().close,
                  style: AppTextStyle.textBoldStyle(
                      color: AppColors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///SHOW LOADING
  static void showLoading([String? message]) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 5,
              ),
              const SizedBox(height: 8),
              Text(message ?? AppStrings().loading),
            ],
          ),
        ),
      ),
    );
  }

  ///SHOW LOADING CIRCULAR INDICATOR
  static void showLoadingIndicator() {
    ///LOADING DIALOG OPENED
    Get.dialog(
      WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
              ),
            ),
          )),
      barrierDismissible: false,
    );
  }

  ///HIDE LOADING
  static void hideLoading() {
    if (Get.isDialogOpen!) Get.back();
  }

  /// SHOW COMING SOON VIEW
  static void showComingSoonView() {
    snackbarMessage(message: AppStrings().comingSoon, icon: Icons.info_outline, snackPosition: SnackPosition.TOP);
  }
}

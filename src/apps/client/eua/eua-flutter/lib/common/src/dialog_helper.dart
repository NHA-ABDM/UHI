import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class DialogHelper {
  ///ERROR DIALOG
  static void showErrorDialog(
      {String title = 'Error',
      String description = 'Something went wrong',
      Function()? onTap}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.amountColor, fontSize: 18),
              ),

              ///SPACE
              const SizedBox(
                height: 10,
              ),

              ///DESCRIPTION
              Text(
                description,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 16),
              ),

              ///SPACE
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      onTap != null ? onTap() : null;
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.amountColor,
                      ),
                      child: Text(
                        AppStrings().okString,
                        style: AppTextStyle.textMediumStyle(
                            color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///INFO DIALOG
  static void showInfoDialog({
    String title = "Info",
    String description = "Coming soon.",
    Function()? onTap,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.primaryLightBlue007BFF, fontSize: 18),
              ),

              ///SPACE
              const SizedBox(
                height: 10,
              ),

              ///DESCRIPTION
              Text(
                description,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.testColor, fontSize: 16),
              ),

              ///SPACE
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      onTap != null ? onTap() : null;
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.primaryLightBlue007BFF,
                      ),
                      child: Text(
                        AppStrings().okString,
                        style: AppTextStyle.textMediumStyle(
                            color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///INFO DIALOG WITH OPTIONS
  static void showDialogWithOptions({
    String title = "Info",
    String description = "Coming soon.",
    String submitBtnText = "Submit",
    String cancelBtnText = "Cancel",
    Function()? onSubmit,
    Function()? onCancel,
  }) {
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0)), //this right here
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                title,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.primaryLightBlue007BFF, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Text(
                description,
                style: AppTextStyle.textMediumStyle(
                    color: AppColors.black, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    onSubmit != null ? onSubmit() : null;
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue007BFF,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        submitBtnText,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                      // color: Color(0xFFE8705A),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: AppColors.secondaryOrangeFF8A07, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        cancelBtnText,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.secondaryOrangeFF8A07,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  ///LOADING DIALOG
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
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  ///LOADING CIRCULAR INDICATOR
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
}

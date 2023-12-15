///DEFAULT PACKAGES
import 'package:flutter/material.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import '../../constants/src/strings.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

///USER DEFINED FILES

class NewConfirmationDialog {
  ///PARENT CONTEXT
  BuildContext context;

  ///CALLBACK FUNCTIONS
  Function() onCancelTap;
  Function() onSubmitTap;

  ///DIALOG CONTENTS
  String title;
  String description;
  String submitButtonText;
  late String? cancelButtonText;
  late String dateText;
  late String timeText;
  late bool showSubtitle;
  late bool showDate;
  late bool showTime;
  late String subTitle;
  TextStyle? titleTextStyle;



  NewConfirmationDialog(
      {required this.context,
      required this.title,
      required this.description,
      required this.onCancelTap,
      required this.onSubmitTap,
      required this.submitButtonText,
      this.cancelButtonText,
        this.showSubtitle = false,
        this.showDate = false,
        this.showTime = false,
        this.dateText = '',
        this.timeText = '',
        this.titleTextStyle,
        this.subTitle = '',
      });

  ///SHOW DIALOG FUNCTION
  showAlertDialog() {

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          buttonPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            title,
          ),
          titleTextStyle: titleTextStyle ?? AppTextStyle.textMediumStyle(color: AppColors.black, fontSize: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(showSubtitle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(subTitle, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.black),),
                ),
              if(showDate)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetImages.calendar,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        dateText,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.tileColors, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              if(showTime)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4, bottom: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetImages.clock,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        timeText,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.tileColors, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              Text(
                description,
                style: AppTextStyle.textNormalStyle(fontSize: 14, color: AppColors.testColor)
              ),
            ],
          ),
          actions: [
            Container(
              height: 1,
              color: const Color.fromARGB(255, 238, 238, 238),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InkWell(
                      overlayColor: MaterialStateProperty.resolveWith((states){
                        return states.contains(MaterialState.pressed)
                            ? AppColors.tileColors.withAlpha(50)
                            : null;
                      }),
                      onTap: onCancelTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.cross,
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            cancelButtonText ?? AppStrings().cancel,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.testColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF0F3F4),
                    height: 50,
                    width: 1,
                  ),
                  //Spacing(isWidth: true),
                  Expanded(
                    child: InkWell(
                      overlayColor: MaterialStateProperty.resolveWith((states){
                        return states.contains(MaterialState.pressed)
                            ? AppColors.tileColors.withAlpha(50)
                            : null;
                      }),
                      onTap: onSubmitTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.checked,
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            submitButtonText,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.testColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///SUBMIT BUTTON
          ],
        );
      },
    );
  }
}

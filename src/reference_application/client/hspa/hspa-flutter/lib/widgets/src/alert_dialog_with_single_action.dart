import 'package:flutter/material.dart';
import 'package:hspa_app/constants/src/strings.dart';

import '../../constants/src/asset_images.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class AlertDialogWithSingleAction extends StatelessWidget {
  AlertDialogWithSingleAction({
    Key? key,
    required this.context,
    required this.title,
    required this.onCloseTap,
    this.description = '',
    this.submitButtonText,
    this.showIcon = false,
    this.iconAssetImage = AssetImages.appointmentCanceled
  }) : super(key: key);

  ///PARENT CONTEXT
  BuildContext context;

  ///CALLBACK FUNCTIONS
  Function() onCloseTap;

  ///DIALOG CONTENTS
  String title;
  String description;
  String? submitButtonText;
  bool showIcon;
  String iconAssetImage;

  @override
  Widget build(BuildContext context) {
    return showAlertDialog();
  }

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
            style: AppTextStyle.textMediumStyle(color: AppColors.black, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(showIcon)
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    iconAssetImage,
                    height: 72,
                    width: 72,
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
            SizedBox(
              height: 48,
              child: InkWell(
                overlayColor: MaterialStateProperty.resolveWith((states){
                  return states.contains(MaterialState.pressed)
                      ? AppColors.tileColors.withAlpha(50)
                      : null;
                }),
                onTap: onCloseTap,
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
                      submitButtonText ?? AppStrings().close,
                      style: AppTextStyle.textNormalStyle(
                          color: AppColors.testColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            ///SUBMIT BUTTON
          ],
        );
      },
    );
  }
}

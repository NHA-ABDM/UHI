import 'package:flutter/material.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_shadows.dart';
import '../../theme/src/app_text_style.dart';

class BottomButtonWithFees extends StatelessWidget {
  final double width;
  final double height;
  final String fees;
  final String buttonName;
  final Function() onButtonTap;

  const BottomButtonWithFees({
    Key? key,
    required this.width,
    required this.height,
    required this.fees,
    required this.buttonName,
    required this.onButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height * 0.06,
        decoration: BoxDecoration(
          boxShadow: AppShadows.shadow2,
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fees",
                    style: AppTextStyle.textNormalStyle(
                        color: AppColors.black, fontSize: 10),
                  ),
                  Text(
                    fees,
                    style: AppTextStyle.textSemiBoldStyle(
                        color: AppColors.secondaryOrangeFF8A07, fontSize: 20),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onButtonTap,
              child: Container(
                width: width * 0.5,
                height: height * 0.08,
                color: AppColors.secondaryOrangeFF8A07,
                child: Center(
                  child: Text(
                    buttonName,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

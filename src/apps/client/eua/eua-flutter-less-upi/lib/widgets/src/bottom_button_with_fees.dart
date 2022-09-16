import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/view.dart';

class BottomButtonWithFees extends StatelessWidget {
  var width;
  var height;
  String fees;
  String buttonName;
  Function() onButtonTap;

  BottomButtonWithFees({
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
              padding: EdgeInsets.only(left: 30, top: 5),
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

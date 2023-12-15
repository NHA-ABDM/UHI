import 'package:flutter/material.dart';
import '../../constants/src/strings.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_shadows.dart';
import '../../theme/src/app_text_style.dart';
import 'spacing.dart';

class FulfillmentImageAndLocation extends StatelessWidget {
  final double width;
  final String imageUrl;
  final String hospitalName;
  final String distance;

  const FulfillmentImageAndLocation({
    Key? key,
    required this.width,
    required this.imageUrl,
    required this.hospitalName,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.shadow2,
      ),
      child: Column(
        children: [
          Container(
            width: width * 0.5,
            height: width * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: Image.network(AppStrings.femaleDoctorImage).image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const Spacing(isWidth: false),
          Text(
            "Max Hospital, Skin Specialist",
            style: AppTextStyle.textNormalStyle(
                color: AppColors.black, fontSize: 14),
          ),
          const Spacing(isWidth: false),
          Text(
            "1.2 km away",
            style: AppTextStyle.textSemiBoldStyle(
                color: AppColors.black, fontSize: 14),
          ),
          const Spacing(isWidth: false),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class FulfillmentImageAndLocation extends StatelessWidget {
  double width;
  String imageUrl;
  String hospitalName;
  String distance;

  FulfillmentImageAndLocation({
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
      padding: EdgeInsets.all(10),
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
                image: Image.network(AppStrings().femaleDoctorImage).image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Spacing(isWidth: false),
          Container(
            child: Text(
              "Max Hospital, Skin Specialist",
              style: AppTextStyle.textNormalStyle(
                  color: AppColors.black, fontSize: 14),
            ),
          ),
          Spacing(isWidth: false),
          Container(
            child: Text(
              "1.2 km away",
              style: AppTextStyle.textSemiBoldStyle(
                  color: AppColors.black, fontSize: 14),
            ),
          ),
          Spacing(isWidth: false),
        ],
      ),
    );
  }
}

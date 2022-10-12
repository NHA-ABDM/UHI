import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';

import '../../../../theme/src/app_colors.dart';
import '../../../../theme/src/app_text_style.dart';

class ProminentDisclosures extends StatefulWidget {
  const ProminentDisclosures({Key? key}) : super(key: key);

  @override
  State<ProminentDisclosures> createState() => _ProminentDisclosuresState();
}

class _ProminentDisclosuresState extends State<ProminentDisclosures> {
  var width;
  var height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 50,
                width: width * 0.39,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings().decline,
                    style: AppTextStyle.textMediumStyle(
                        color: AppColors.DARK_PURPLE, fontSize: 16),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 50,
                width: width * 0.39,
                decoration: const BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings().accept,
                    style: AppTextStyle.textMediumStyle(
                        color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            SizedBox(
              height: 30,
            ),
            ListTile(
              subtitle: Text(
                AppStrings().generalDisclosure,
                textAlign: TextAlign.left,
                style: AppTextStyle.textNormalStyle(
                    color: AppColors.textColor, fontSize: 14),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().camera,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().cameraDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().microPhone,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().microphoneDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().Storage,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().storageDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().sms,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().smsDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().geoLocation,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().geoLocationDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text(
                AppStrings().sharingOfData,
                textAlign: TextAlign.left,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.tileColors, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings().sharingOfDataDisclosure,
                  textAlign: TextAlign.left,
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.textColor, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

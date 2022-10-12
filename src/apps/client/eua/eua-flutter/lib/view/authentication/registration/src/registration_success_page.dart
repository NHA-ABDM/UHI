import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/common/src/get_pages.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class RegistrationSuccessPage extends StatefulWidget {
  final CreatePhrAddressResponseModel phrAddress;
  const RegistrationSuccessPage({Key? key, required this.phrAddress})
      : super(key: key);

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  var width;
  var height;
  var isPortrait;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;
    if (validatePhrAddres()) {
      return AlertDialog(title: Text('Error creating ABHA Address'));
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.darkGrey323232,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          title: Text(
            AppStrings().registration,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: buildWidgets(),
      );
    }
  }

  buildWidgets() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings().congratulations,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 22),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              AppStrings().yourABHAAddress +
                  ' ' +
                  widget.phrAddress.phrAddress! +
                  ' ' +
                  AppStrings().isCreated,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              AppStrings().loginToContinue,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 16),
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              child: Container(
                width: width,
                child: loginToContinueButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector loginToContinueButton() {
    return GestureDetector(
      onTap: () {
        Get.until((route) => Get.currentRoute == AppRoutes.baseLoginPage);
      },
      child: Container(
        height: 40,
        width: width * 0.89,
        decoration: const BoxDecoration(
          color: AppColors.tileColors,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Center(
          child: Text(
            AppStrings().btnLogin,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  bool validatePhrAddres() {
    if (widget.phrAddress.phrAddress != null &&
        widget.phrAddress.phrAddress != "") {
      return false;
    }
    return true;
  }
}

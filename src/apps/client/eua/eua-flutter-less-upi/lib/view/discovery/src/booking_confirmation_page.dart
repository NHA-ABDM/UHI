import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({Key? key}) : super(key: key);

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
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
        titleSpacing: 0,
        title: Text(
          AppStrings().bookingConfirmPageTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                practoLogoView(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dividerColor,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings().bookingPurposeOfRequest,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.appointmentConfirmTextColor,
                            fontSize: 14),
                      ),
                      Spacing(isWidth: false, size: 8),
                      Text(
                        'Care Management',
                        style: AppTextStyle.textLightStyle(
                            color: AppColors.doctorNameColor, fontSize: 14),
                      ),
                      Spacing(isWidth: false, size: 16),
                      Text(
                        AppStrings().bookingInfoRequestValidity,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.appointmentConfirmTextColor,
                            fontSize: 14),
                      ),
                      Spacing(isWidth: false, size: 8),
                      RichText(
                        text: TextSpan(
                          text: AppStrings().bookingFrom,
                          style: AppTextStyle.textLightStyle(
                              color: AppColors.doctorNameColor, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' 5th Jan 2022 ',
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: AppStrings().bookingTo,
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: ' 12th Jan 2022 ',
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.doctorNameColor,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Spacing(isWidth: false, size: 16),
                      Text(
                        AppStrings().bookingInfoRequestType,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.appointmentConfirmTextColor,
                            fontSize: 14),
                      ),
                      Spacing(isWidth: false, size: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          customRoundedElevatedButton(
                              text: 'Diagnostic Report', onPressed: () {}),
                          customRoundedElevatedButton(
                              text: 'Prescription', onPressed: () {}),
                        ],
                      ),
                      Spacing(isWidth: false, size: 16),
                      Text(
                        AppStrings().bookingConsentExpiry,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.appointmentConfirmTextColor,
                            fontSize: 14),
                      ),
                      Spacing(isWidth: false, size: 8),
                      Text(
                        '4pm 1st feb 2022',
                        style: AppTextStyle.textLightStyle(
                            color: AppColors.doctorNameColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.dividerColor,
          ),
          getBottomView(),
        ],
      ),
    );
  }

  practoLogoView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image.asset(
              //   'assets/images/practo_logo.png',
              //   height: 24,
              //   width: 90,
              // ),
              TextButton.icon(
                onPressed: () {},
                icon: Text(
                  AppStrings().btnEdit,
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.tileColors, fontSize: 14),
                ),
                label: const Icon(Icons.info_outline,
                    size: 20, color: AppColors.tileColors),
              ),
            ],
          ),
          Spacing(isWidth: false, size: 8),
          Text(
            AppStrings().bookingConsentRequest,
            style: AppTextStyle.textLightStyle(
                color: AppColors.doctorNameColor, fontSize: 14),
          ),
          Spacing(isWidth: false, size: 8),
        ],
      ),
    );
  }

  getBottomView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().bookingConsentText,
            style: AppTextStyle.textLightStyle(
                color: AppColors.doctorNameColor, fontSize: 14),
          ),
          Spacing(isWidth: false, size: 12),
          Row(
            children: [
              Expanded(
                child: customSquareElevatedButton(
                    onPressed: () {},
                    text: AppStrings().btnDeny,
                    textColor: AppColors.tileColors,
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.tileColors,
                    foregroundColor: AppColors.white),
              ),
              Spacing(),
              Expanded(
                child: customSquareElevatedButton(
                    onPressed: () {},
                    text: AppStrings().btnGrantConsent,
                    textColor: AppColors.white,
                    backgroundColor: AppColors.amountColor,
                    borderColor: AppColors.amountColor,
                    foregroundColor: AppColors.amountColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  customRoundedElevatedButton(
      {required String text,
      Color textColor = AppColors.tileColors,
      Color borderColor = AppColors.tileColors,
      Color foregroundColor = Colors.white,
      Color backgroundColor = Colors.white,
      required Function() onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyle.textLightStyle(color: textColor, fontSize: 12),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
        visualDensity: VisualDensity.compact,
        elevation: MaterialStateProperty.all<double>(0),
        foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: borderColor)),
        ),
      ),
    );
  }

  customSquareElevatedButton(
      {required String text,
      Color textColor = AppColors.tileColors,
      Color borderColor = AppColors.tileColors,
      Color foregroundColor = Colors.white,
      Color backgroundColor = Colors.white,
      required Function() onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyle.textBoldStyle(color: textColor, fontSize: 12),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        visualDensity: VisualDensity.standard,
        elevation: MaterialStateProperty.all<double>(0),
        foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: borderColor)),
        ),
      ),
    );
  }
}

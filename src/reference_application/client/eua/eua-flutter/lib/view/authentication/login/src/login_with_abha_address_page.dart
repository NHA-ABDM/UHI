import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class LoginWithAbhaAddressPage extends StatefulWidget {
  const LoginWithAbhaAddressPage({Key? key}) : super(key: key);

  @override
  State<LoginWithAbhaAddressPage> createState() =>
      _LoginWithAbhaAddressPageState();
}

class _LoginWithAbhaAddressPageState extends State<LoginWithAbhaAddressPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool? _isChecked = false;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final _abhaAddressTextField = TextEditingController();
  final _passwordTextField = TextEditingController();
  String _selectedOption = 'ABHA Number';

  ///DATA VARIABLES

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

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
          AppStrings().loginWithABHAAddress,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterABHAAddress,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.doctorExperienceColor,
              ),
            ),
            child: TextFormField(
              controller: _abhaAddressTextField,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: InputBorder.none,
                hintText: AppStrings().ABHAAddress,
                hintStyle: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            AppStrings().enterPassword,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.doctorExperienceColor,
              ),
            ),
            child: TextFormField(
              obscureText: true,
              controller: _passwordTextField,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: InputBorder.none,
                hintText: AppStrings().passwordHint,
                hintStyle: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              SizedBox(
                height: 30,
                width: 20,
                child: Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(AppStrings().rememberMe),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              AppStrings().orText,
              style: AppTextStyle.textMediumStyle(
                  color: AppColors.mobileNumberTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            AppStrings().validateUsing,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          ListTile(
            dense: true,
            leading: Radio<String>(
              value: AppStrings().emailOTP,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-16, 0),
              child: Text(AppStrings().emailOTP),
            ),
          ),
          ListTile(
            dense: true,
            leading: Radio<String>(
              value: AppStrings().mobileOTP,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-16, 0),
              child: Text(AppStrings().mobileOTP),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 50,
                width: width * 0.89,
                decoration: const BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings().btnContinue,
                    style: AppTextStyle.textMediumStyle(
                        color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/new_dialog_screen.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class CreateNewAbhaAddress extends StatefulWidget {
  const CreateNewAbhaAddress({Key? key}) : super(key: key);

  @override
  State<CreateNewAbhaAddress> createState() => _CreateNewAbhaAddressState();
}

enum searchOption { doctorsName, hpID }

class _CreateNewAbhaAddressState extends State<CreateNewAbhaAddress> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  ///CONTROLLERS
  final _abhaAddressTextEditingController = TextEditingController();
  final _newPasswordTextEditingController = TextEditingController();
  final _lastNameTextEditingController = TextEditingController();
  String suggestedABHAAdress = "ganesh235, ganeshborse2351992, ganeshborse1992";
  bool _obscureTextPassword = true;

  bool _loading = false;
  bool? checkedValue = false;

  void showProgressDialog() {
    setState(() {
      _loading = true;
    });
  }

  void hideProgressDialog() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _togglePassword() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

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
          AppStrings().registrationWithMobileNumber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        dismissible: false,
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: AppColors.DARK_PURPLE,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
        ),
        child: Container(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        AppStrings().createAbhaAddress,
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.black, fontSize: 16),
                      ),
                      TextFormField(
                        controller: _abhaAddressTextEditingController,
                        decoration: InputDecoration(
                          suffixText: "@sbx",
                          suffixStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          hintText: AppStrings().ABHAAddress,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 8, isWidth: false),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings().suggestions,
                            style: AppTextStyle.textLightStyle(
                                color: AppColors.textColor, fontSize: 12),
                          ),
                          Expanded(
                            child: Text(
                              suggestedABHAAdress,
                              style: AppTextStyle.textMediumStyle(
                                  color: AppColors.linkTextColor, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _newPasswordTextEditingController,
                        obscureText: _obscureTextPassword,
                        decoration: InputDecoration(
                          hintText: AppStrings().middleNameHint,
                          suffix: InkWell(
                            onTap: _togglePassword,
                            child: Icon(
                              _obscureTextPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                      TextFormField(
                        obscureText: _obscureTextPassword,
                        controller: _lastNameTextEditingController,
                        decoration: InputDecoration(
                          hintText: AppStrings().lastNameHint,
                          hintStyle: AppTextStyle.textLightStyle(
                              color: AppColors.testColor, fontSize: 14),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Spacing(size: 20, isWidth: false),
                    ],
                  ),
                ),
                Spacing(size: 20, isWidth: false),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: width * 0.92,
                    height: height * 0.06,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8705A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings().submit,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

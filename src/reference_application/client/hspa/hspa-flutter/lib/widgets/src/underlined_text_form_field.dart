import 'package:flutter/material.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class UnderlinedTextFormField extends StatefulWidget {
  UnderlinedTextFormField(
      {
        Key? key,
        required this.controller,
        required this.labelText,
        required this.validate,
        this.keyboardType = TextInputType.number,
        this.autoValidateMode = AutovalidateMode.disabled,
        this.textInputAction = TextInputAction.next
      })
      : super(key: key);
  TextEditingController controller;
  Color textColor = AppColors.titleTextColor;
  Color hintTextColor = AppColors.feesLabelTextColor;
  String labelText;
  TextInputAction textInputAction = TextInputAction.next;
  TextInputType keyboardType = TextInputType.number;
  late AutovalidateMode autoValidateMode;
  String? Function(String? value) validate;

  @override
  State<UnderlinedTextFormField> createState() =>
      _UnderlinedTextFormFieldState();
}

class _UnderlinedTextFormFieldState extends State<UnderlinedTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: AppColors.titleTextColor,
      textInputAction: widget.textInputAction,
      style:
          AppTextStyle.textNormalStyle(fontSize: 16, color: widget.textColor),
      decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: AppTextStyle.textLightStyle(
              fontSize: 14, color: widget.hintTextColor),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.titleTextColor))),
      keyboardType: widget.keyboardType,
      autovalidateMode: widget.autoValidateMode,
      validator: widget.validate,
    );
  }
}

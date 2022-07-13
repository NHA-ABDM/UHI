import 'package:flutter/material.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class SquareRoundedButton extends StatefulWidget {
  SquareRoundedButton(
      {Key? key,
      required this.text,
      this.textColor = Colors.white,
      this.borderColor = AppColors.amountColor,
      this.foregroundColor = AppColors.amountColor,
      this.backgroundColor = AppColors.amountColor,
      required this.onPressed,
      this.textStyle})
      : super(key: key);

  String text;
  Color textColor;
  Color borderColor;
  Color foregroundColor;
  Color backgroundColor;
  Function() onPressed;
  TextStyle? textStyle;

  @override
  State<SquareRoundedButton> createState() => _SquareRoundedButtonState();
}

class _SquareRoundedButtonState extends State<SquareRoundedButton> {
  late double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.text,
        style:
            widget.textStyle ?? AppTextStyle.textNormalStyle(color: widget.textColor, fontSize: 16)
        ,
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
        visualDensity: VisualDensity.standard,
        elevation: MaterialStateProperty.all<double>(0),
        overlayColor: MaterialStateProperty.resolveWith((states){
          return states.contains(MaterialState.pressed)
              ? widget.textColor.withAlpha(50)
              : null;
        }),
        foregroundColor:
            MaterialStateProperty.all<Color>(widget.foregroundColor),
        backgroundColor:
            MaterialStateProperty.all<Color>(widget.backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: widget.borderColor)),
        ),
      ),
    );
  }
}

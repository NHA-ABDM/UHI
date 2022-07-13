import 'package:flutter/material.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class SquareRoundedButtonWithIcon extends StatefulWidget {
  SquareRoundedButtonWithIcon({
    Key? key,
    required this.text,
    this.textColor = Colors.white,
    this.borderColor = AppColors.amountColor,
    this.foregroundColor = AppColors.amountColor,
    this.backgroundColor = AppColors.amountColor,
    required this.assetImage,
    required this.onPressed,
    this.icon = Icons.clear,
  }) : super(key: key);

  String text;
  Color textColor;
  Color borderColor;
  Color foregroundColor;
  Color backgroundColor;
  String? assetImage;
  Function() onPressed;
  IconData icon;

  @override
  State<SquareRoundedButtonWithIcon> createState() =>
      _SquareRoundedButtonWithIconState();
}

class _SquareRoundedButtonWithIconState
    extends State<SquareRoundedButtonWithIcon> {
  late double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: width - 40,
            height: 40,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              child: Text(
                widget.text,
                style: AppTextStyle.textBoldStyle(
                    color: widget.textColor, fontSize: 14),
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
            ),
          ),
          SizedBox(
            width: width - 40,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: widget.assetImage != null
                      ? Image.asset(
                          widget.assetImage!,
                          color: widget.textColor,
                        )
                      : Icon(
                          widget.icon,
                          size: 24,
                          color: widget.textColor,
                        )),
            ),
          )
        ],
      ),
    );
  }
}

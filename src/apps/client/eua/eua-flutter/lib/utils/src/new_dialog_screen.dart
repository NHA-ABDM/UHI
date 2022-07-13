///DEFAULT PACKAGES
import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';

///USER DEFINED FILES

class NewMessageDialog {
  ///PARENT CONTEXT
  BuildContext context;

  ///DIALOG CONTENTS
  String title;
  String description;

  ///DIALOG LAYOUT
  var width;
  var height;

  NewMessageDialog(
      {required this.context, required this.title, required this.description});

  ///SHOW DIALOG FUNCTION
  showAlertDialog() {
    ///ASSIGNING TO VARIABLES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // Future.delayed(Duration(milliseconds: 4000), () {
    //   Navigator.pop(context);
    // });

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.DARK_PURPLE,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            description,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: AppColors.DARK_PURPLE,
            ),
            textAlign: TextAlign.left,
          ),
          actions: [
            ///CANCEL BUTTON

            ///SUBMIT BUTTON
          ],
        );
      },
    );
  }
}

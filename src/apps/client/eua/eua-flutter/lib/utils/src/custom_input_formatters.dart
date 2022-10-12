import 'package:flutter/services.dart';

class CustomInputFormatters extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    text = text.replaceAll(RegExp(r'(\s)|(\D)'), '');

    int offset = newValue.selection.start;
    var subText =
        newValue.text.substring(0, offset).replaceAll(RegExp(r'(\s)|(\D)'), '');
    int realTrimOffset = subText.length;

    // if (newValue.selection.baseOffset == 0) {
    //   return newValue;
    // }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(
            ' '); // Replace this with anything you want to put after each 4 numbers
      }

      if (nonZeroIndex % 4 == 0 &&
          subText.length == nonZeroIndex &&
          nonZeroIndex > 4) {
        int moveCursorToRigth = nonZeroIndex ~/ 4 - 1;
        realTrimOffset += moveCursorToRigth;
      }

      if (nonZeroIndex % 4 != 0 && subText.length == nonZeroIndex) {
        int moveCursorToRigth = nonZeroIndex ~/ 4;
        realTrimOffset += moveCursorToRigth;
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: realTrimOffset));
  }
}

import 'package:flutter/material.dart';

class Spacing extends StatelessWidget {
  bool? isWidth;
  double? size;

  Spacing({Key? key, this.isWidth, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    isWidth = isWidth ?? true;

    return isWidth!
        ? SizedBox(
            width: size ?? 10,
          )
        : SizedBox(
            height: size ?? 10,
          );
  }
}

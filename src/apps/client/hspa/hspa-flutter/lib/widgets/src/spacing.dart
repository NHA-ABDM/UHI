import 'package:flutter/material.dart';

class Spacing extends StatelessWidget {
  final bool isWidth;
  final double? size;

  const Spacing({Key? key, this.isWidth = true, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isWidth
        ? SizedBox(
            width: size ?? 10,
          )
        : SizedBox(
            height: size ?? 10,
          );
  }
}

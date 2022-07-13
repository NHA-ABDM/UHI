import 'package:flutter/material.dart';

class VerticalSpacing extends StatelessWidget {
  VerticalSpacing({Key? key, this.size = 10}) : super(key: key);
  double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
    );
  }
}

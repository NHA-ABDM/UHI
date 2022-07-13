import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class AppShadows {
  static List<BoxShadow> shadow1 = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.10),
      blurRadius: 10,
      offset: const Offset(2, 2),
    ),
  ];

  static List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10.0,
      offset: const Offset(2.0, 2.0),
    ),
  ];

  static List<BoxShadow> shadow3 = [
    BoxShadow(
      //spreadRadius: 2,
      blurRadius: 3,
      offset: const Offset(0, 6),
      color: Colors.black.withOpacity(0.10),
    ),
  ];
}

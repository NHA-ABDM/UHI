import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class AppbarBottomLine extends StatelessWidget implements PreferredSizeWidget {
  const AppbarBottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: AppColors.primaryLightBlue007BFF,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(2);
}

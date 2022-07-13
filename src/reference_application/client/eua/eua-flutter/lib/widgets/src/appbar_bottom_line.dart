import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class AppbarBottomLine extends StatelessWidget with PreferredSizeWidget {
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

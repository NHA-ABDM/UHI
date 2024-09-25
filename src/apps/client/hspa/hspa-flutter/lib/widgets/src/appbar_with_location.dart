import 'package:flutter/material.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';
import 'spacing.dart';

class AppbarWithLocation extends StatelessWidget
    implements PreferredSizeWidget {
  final Function() onTap;

  const AppbarWithLocation({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.place_outlined,
            color: AppColors.primaryLightBlue007BFF,
            size: 28,
          ),
          const Spacing(),
          InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Location",
                  style: AppTextStyle.textNormalStyle(
                      color: AppColors.black, fontSize: 10),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Pune, Maharashtra",
                      style: AppTextStyle.textNormalStyle(
                          color: AppColors.black, fontSize: 12),
                    ),
                    const Spacing(),
                    Icon(
                      Icons.expand_more,
                      color: AppColors.primaryLightBlue007BFF,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

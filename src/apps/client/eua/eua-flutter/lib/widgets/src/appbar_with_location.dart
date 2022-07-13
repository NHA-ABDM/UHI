import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/widgets.dart';

class AppbarWithLocation extends StatelessWidget with PreferredSizeWidget {
  final Function() onTap;

  AppbarWithLocation({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.place_outlined,
              color: AppColors.primaryLightBlue007BFF,
              size: 28,
            ),
            Spacing(),
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
                      Spacing(),
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
      ),
    );
  }
}

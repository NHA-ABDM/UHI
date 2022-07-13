import 'package:flutter/material.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class PullToRefresh extends StatelessWidget {
  final String errorString;
  const PullToRefresh({Key? key, this.errorString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ///SPACE
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
            ),

            ///ICON
            const Icon(
                Icons.signal_wifi_statusbar_connected_no_internet_4_sharp),

            ///SPACE
            const SizedBox(
              height: 10.0,
            ),

            ///ERROR MESSAGE
            Text(
              errorString,
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.testColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            ///SPACE
            const SizedBox(
              height: 10.0,
            ),

            ///PULL TO REFRESH TEXT
            Text(
              "Pull to refresh",
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.testColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

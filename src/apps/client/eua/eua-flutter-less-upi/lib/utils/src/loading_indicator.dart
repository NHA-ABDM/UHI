import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/theme/theme.dart';

class CommonLoadingIndicator extends StatelessWidget {
  double? size;
  Color? color;
  CommonLoadingIndicator({Key? key, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(size ?? 10.0),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 5.0,
          color: color ?? AppColors.DARK_PURPLE,
        ),
      ),
    );
  }
}

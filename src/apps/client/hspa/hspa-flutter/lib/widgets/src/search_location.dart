import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';
import 'appbar_bottom_line.dart';
import 'spacing.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key? key}) : super(key: key);

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  ///SIZE
  var width;
  var height;
  var isPortrait;

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.darkGrey323232,
            size: 32,
          ),
        ),
        titleSpacing: 0,
        title: Container(
          width: width * 0.9,
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            // controller: _textEditingController,
            style: AppTextStyle.textNormalStyle(
                color: AppColors.black, fontSize: 12),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search location",
              hintStyle: AppTextStyle.textNormalStyle(
                  color: AppColors.black, fontSize: 12),
            ),
          ),
        ),
        bottom: const AppbarBottomLine(),
      ),
      body: Container(
        width: width,
        height: height,
        color: AppColors.backgroundWhiteColorFBFCFF,
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: AppColors.greyDDDDDD,
                ),
              )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_outlined,
                    color: AppColors.greyDDDDDD,
                    size: 20,
                  ),
                  const Spacing(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pune",
                        style: AppTextStyle.textBoldStyle(
                            color: AppColors.testColor, fontSize: 15),
                      ),
                      const Spacing(size: 5, isWidth: false),
                      Text(
                        "Pune, Maharashtra",
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.grey787878, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

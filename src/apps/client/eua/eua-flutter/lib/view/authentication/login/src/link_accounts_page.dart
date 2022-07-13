import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/view.dart';

class LinkAccountsPage extends StatefulWidget {
  List<String>? mappedPhrAddress;
  LinkAccountsPage(this.mappedPhrAddress, {Key? key}) : super(key: key);

  @override
  State<LinkAccountsPage> createState() => _LinkAccountsPageState();
}

class _LinkAccountsPageState extends State<LinkAccountsPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool firstDetailsSelected = false;
  bool secondDetailsSelected = false;

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: AppColors.white,
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
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        titleSpacing: 0,
        title: Text(
          AppStrings().loginWithMobileNumber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            AppStrings().weFoundAccounts,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              firstDetailsSelected = !firstDetailsSelected;
              if (firstDetailsSelected) {
                secondDetailsSelected = false;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            color: !firstDetailsSelected
                ? Colors.white
                : AppColors.textColor.withOpacity(0.30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manu Parvesh",
                      style: AppTextStyle.textMediumStyle(
                          color: AppColors.mobileNumberTextColor, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      AppStrings().ABHANumberLinkToABHAAddress,
                      style: TextStyle(
                          color: AppColors.mobileNumberTextColor,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 10.0),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Text(
                          AppStrings().kycComplete,
                          style: TextStyle(
                              color: AppColors.mobileNumberTextColor,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 10.0),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SizedBox(
                          height: 10,
                          width: 10,
                          child: Center(
                            child: Image.asset(
                              'assets/images/done_icon.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      AppStrings().ABHANumber + "- 98-3234-3234-5432",
                      style: TextStyle(
                          color: AppColors.mobileNumberTextColor,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 10.0),
                    ),
                    Row(
                      children: [
                        Text(
                          AppStrings().ABHAAddress + ":",
                          style: TextStyle(
                              color: AppColors.mobileNumberTextColor,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 10.0),
                        ),
                        Text(
                          " manu.parvesh@abdm",
                          style: TextStyle(
                              color: AppColors.tileColors,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 16.0),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 50,
                    //   width: width * 0.6,
                    //   child: Row(
                    //     children: [
                    //       Flexible(
                    //         child: Center(
                    //           child: ListTileTheme(
                    //             contentPadding:
                    //                 const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //             child: ListTile(
                    //               dense: true,
                    //               leading: Radio<String>(
                    //                 value: 'xxxxxx@abdm',
                    //                 groupValue: _selectedOption,
                    //                 onChanged: (value) {
                    //                   setState(() {
                    //                     _selectedOption = value!;
                    //                   });
                    //                 },
                    //               ),
                    //               title: Transform.translate(
                    //                 offset: Offset(-20, 0),
                    //                 child: const Text('xxxxxx@abdm'),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: Image.network("https://picsum.photos/200").image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(height: 1, width: width, color: Colors.grey[300]),
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              secondDetailsSelected = !secondDetailsSelected;
              if (secondDetailsSelected) {
                firstDetailsSelected = false;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            color: !secondDetailsSelected
                ? Colors.white
                : AppColors.textColor.withOpacity(0.30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mohan Sharma",
                      style: AppTextStyle.textMediumStyle(
                          color: AppColors.mobileNumberTextColor, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Text(
                          AppStrings().ABHAAddress + ":",
                          style: TextStyle(
                              color: AppColors.mobileNumberTextColor,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 10.0),
                        ),
                        Text(
                          " Mohan.Sharma@abdm",
                          style: TextStyle(
                              color: AppColors.tileColors,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 16.0),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 50,
                    //   width: width * 0.6,
                    //   child: Row(
                    //     children: [
                    //       Flexible(
                    //         child: ListTileTheme(
                    //           contentPadding:
                    //               const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //           child: ListTile(
                    //             dense: true,
                    //             leading: Radio<String>(
                    //               value: 'xxxxxxxxxx@abdm',
                    //               groupValue: _selectedOption,
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _selectedOption = value!;
                    //                 });
                    //               },
                    //             ),
                    //             title: Transform.translate(
                    //               offset: Offset(-25, 0),
                    //               child: const Text('xxxxxxxxxx@abdm'),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: Image.network("https://picsum.photos/200").image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(height: 1, width: width, color: Colors.grey[300]),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: () {
            Get.to(HomePage());
          },
          child: Center(
            child: Container(
              height: 50,
              width: width * 0.89,
              decoration: const BoxDecoration(
                color: AppColors.tileColors,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings().btnLogin,
                  style: AppTextStyle.textMediumStyle(
                      color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

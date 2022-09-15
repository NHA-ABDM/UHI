import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/widgets/src/square_rounded_button.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../model/src/appointments.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'package:dotted_border/dotted_border.dart';

class SharePhysicalPrescriptionPage extends StatefulWidget {
  const SharePhysicalPrescriptionPage({Key? key}) : super(key: key);

  /*const SharePhysicalPrescriptionPage({Key? key, required this.appointment})
      : super(key: key);
  final Appointments appointment;*/

  @override
  State<SharePhysicalPrescriptionPage> createState() =>
      _SharePhysicalPrescriptionPageState();
}

class _SharePhysicalPrescriptionPageState
    extends State<SharePhysicalPrescriptionPage> {
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();

  /// Arguments
  late final Appointments appointment;

  @override
  void initState() {
    /// Get Arguments
    appointment = Get.arguments['appointment'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().labelSharePrescription,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings().labelSharePrescriptionHead,
                    style: AppTextStyle.textSemiBoldStyle(
                        fontSize: 18, color: AppColors.titleTextColor),
                  ),
                  VerticalSpacing(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DottedBorder(
                            color: AppColors.tileColors,
                            strokeWidth: 1,
                            dashPattern: const [8, 8],
                            child: Container(
                              height: pickedFile == null
                                  ? MediaQuery.of(context).size.width / 1.4
                                  : MediaQuery.of(context).size.height / 2,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: pickedFile == null
                                  ? takePhotoWidget()
                                  : previewPhotoWidget(),
                            ),
                          ),
                          VerticalSpacing(),
                          Text(
                            AppStrings().labelEnsurePrescriptionHasSignature,
                            style: AppTextStyle.textLightStyle(
                                fontSize: 14,
                                color: AppColors.feesLabelTextColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  VerticalSpacing(),
                ],
              ),
            ),
          ),
          getBottomButtons(),
        ],
      ),
    );
  }

  takePhotoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              AssetImages.camera,
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
            ),
          ),
        ),
        SquareRoundedButton(
            text: AppStrings().btnTakePhoto,
            borderColor: AppColors.tileColors,
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.white,
            textColor: AppColors.tileColors,
            textStyle: AppTextStyle.textBoldStyle(
                fontSize: 14, color: AppColors.tileColors),
            onPressed: () {
              openSortBottomSheetDialog();
            })
      ],
    );
  }

  previewPhotoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.file(
                  File(pickedFile!.path),
                  fit: BoxFit.cover,
                ),
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              Positioned(
                right: -8,
                top: -8,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      pickedFile = null;
                    });
                  },
                  icon: Image.asset(AssetImages.cancelFilled, height: 24, width: 24,),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  getBottomButtons() {
    return Column(
      children: [
        Spacing(
          isWidth: false,
          size: 16,
        ),
        pickedFile == null
            ? SquareRoundedButtonWithIcon(
                text: AppStrings().btnContinue,
                assetImage: AssetImages.arrowLongRight,
                onPressed: () {
                  if (pickedFile == null) {
                    Get.snackbar(AppStrings().alert, AppStrings().errorSelectImage);
                  } else {}
                },
              )
            : Row(
                children: [
                  Expanded(
                    child: SquareRoundedButton(
                        text: AppStrings().btnCancel,
                        textStyle: AppTextStyle.textBoldStyle(
                            fontSize: 14, color: AppColors.tileColors),
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.tileColors,
                        borderColor: AppColors.tileColors,
                        onPressed: () {
                          Get.back();
                        }),
                  ),
                  Spacing(
                    size: 16,
                  ),
                  Expanded(
                    child: SquareRoundedButton(
                        text: AppStrings().btnShare,
                        textStyle: AppTextStyle.textBoldStyle(
                            fontSize: 14, color: AppColors.white),
                        onPressed: () {}),
                  ),
                ],
              ),
      ],
    );
  }

  void openSortBottomSheetDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _onImageButtonPressed(source: ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.amountColor,
                          child: Icon(
                            Icons.camera,
                            color: AppColors.white,
                          ),
                        ),
                        VerticalSpacing(),
                        Text(
                          AppStrings().camera,
                          style: AppTextStyle.textMediumStyle(
                              fontSize: 16, color: AppColors.titleTextColor),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _onImageButtonPressed(source: ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.amountColor,
                          child: Icon(
                            Icons.folder,
                            color: AppColors.white,
                          ),
                        ),
                        VerticalSpacing(),
                        Text(
                          AppStrings().gallery,
                          style: AppTextStyle.textMediumStyle(
                              fontSize: 16, color: AppColors.titleTextColor),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> _onImageButtonPressed({required ImageSource source}) async {
    try {
      pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        setState(() {
          debugPrint('Picked image path is ${pickedFile!.path}');
        });
      }
    } catch (e) {
      debugPrint('Pick image error is ${e.toString()}');
      setState(() {});
    }
  }
}

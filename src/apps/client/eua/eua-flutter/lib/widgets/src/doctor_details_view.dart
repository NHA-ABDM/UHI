import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/theme/src/app_text_style.dart';

class DoctorDetailsView extends StatefulWidget {
  String? doctorName;
  String? doctorAbhaId;
  Tags? tags;
  String? gender;
  String? profileImage;

  DoctorDetailsView(
      {Key? key,
      this.doctorName,
      this.doctorAbhaId,
      this.tags,
      this.gender,
      this.profileImage})
      : super(key: key);

  @override
  _DoctorDetailsViewState createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  SuperTooltip? tooltip;
  bool imageNull = false;
  late var decodedBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String doctorName = "";
    String hprId = "";
    String? profileImage;
    if (widget.profileImage != null && widget.profileImage != "") {
      profileImage = widget.profileImage;
      decodedBytes = base64Decode(profileImage!);
      imageNull = true;
    } else {
      imageNull = false;
    }
    if (widget.doctorName != null) {
      var StringArray = widget.doctorName!.split("-");
      doctorName = StringArray.length > 1
          ? StringArray[1].replaceFirst(" ", "")
          : StringArray[0];
      hprId = StringArray[0];
    }
    String? education = "";
    String? specialty = "";
    String? languageSpoken = "";
    String? experience = "";
    if (widget.tags != null) {
      education = widget.tags!.education;
      specialty = widget.tags!.specialtyTag;
      languageSpoken = widget.tags!.languageSpokenTag;
      experience = widget.tags!.experience;
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   width: 60,
              //   height: 60,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(30),
              //     image: DecorationImage(
              //       image: Image.network(widget.gender == "M"
              //               ? AppStrings().maleDoctorImage
              //               : AppStrings().femaleDoctorImage)
              //           .image,
              //       fit: BoxFit.fill,
              //     ),
              //   ),
              // ),
              CircleAvatar(
                radius: 30,
                backgroundImage: imageNull == false
                    ? AssetImage(widget.gender == "M"
                        ? 'assets/images/male_doctor_avatar.png'
                        : 'assets/images/female_doctor_avatar.jpeg')
                    : Image.memory(decodedBytes).image,
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    maxLines: 2,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.doctorNameColor, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        education ?? "-",
                        style: AppTextStyle.textLightStyle(
                            color: AppColors.doctorNameColor, fontSize: 14),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          onEducationTap();
                        },
                        child: const Icon(
                          Icons.info,
                          color: AppColors.doctorNameColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        specialty ?? "-",
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.doctorExperienceColor,
                            fontSize: 10),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          onSpecialtyTap();
                        },
                        child: const Icon(
                          Icons.info,
                          color: AppColors.doctorNameColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    hprId,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.doctorNameColor, fontSize: 12),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    languageSpoken ?? "-",
                    style: AppTextStyle.textLightStyle(
                        color: AppColors.infoIconColor, fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "$experience Years of experience",
                    style: AppTextStyle.textLightStyle(
                        color: AppColors.infoIconColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              height: 16,
              width: 16,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {},
                icon: const Icon(
                  Icons.verified_user_rounded,
                  size: 24,
                  color: AppColors.appointmentStatusColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onSpecialtyTap() {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = SuperTooltip(
      arrowLength: 0,
      left: 50,
      popupDirection: TooltipDirection.down,
      content: const Material(
          child: Text(
        "Lorem ipsum dolor sit amet, consetetur sadipscingelitr, ",
        softWrap: true,
      )),
    );

    tooltip!.show(context);
  }

  void onEducationTap() {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = SuperTooltip(
      arrowLength: 0,
      left: 50,
      popupDirection: TooltipDirection.down,
      content: const Material(
          child: Text(
        "Lorem ipsum dolor sit amet, consetetur sadipscingelitr, ",
        softWrap: true,
      )),
    );

    tooltip!.show(context);
  }
}

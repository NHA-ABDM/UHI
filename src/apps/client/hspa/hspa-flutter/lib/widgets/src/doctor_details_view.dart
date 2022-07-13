import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../constants/src/strings.dart';
import '../../theme/src/app_colors.dart';
import '../../theme/src/app_text_style.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({Key? key}) : super(key: key);

  @override
  _DoctorDetailsViewState createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  SuperTooltip? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: Image.network(AppStrings.femaleDoctorImage).image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. Sana Bhatt",
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.doctorNameColor, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "MBBS/MS Cardiology",
                    style: AppTextStyle.textLightStyle(
                        color: AppColors.doctorNameColor, fontSize: 14),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        "Pediatric Cardiology",
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.doctorExperienceColor,
                            fontSize: 10),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          onTap();
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
                    "Sana.bhatt@hpr.abdm",
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.doctorNameColor, fontSize: 12),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Marathi/Hindi/English",
                    style: AppTextStyle.textLightStyle(
                        color: AppColors.infoIconColor, fontSize: 12),
                  ),
                  Text(
                    "12Years of experience",
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

  void onTap() {
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

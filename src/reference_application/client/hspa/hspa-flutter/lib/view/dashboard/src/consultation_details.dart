import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/common.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../model/request/src/provider_service_type.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/vertical_spacing.dart';
import '../../appointments/src/appointments_page.dart';

class ConsultationDetailsPage extends StatefulWidget {
  const ConsultationDetailsPage({Key? key, required this.consultType, required this.isTeleconsultation, required this.providerServiceTypes}) : super(key: key);
  final String consultType;
  final bool isTeleconsultation;
  final ProviderServiceTypes providerServiceTypes;

  @override
  State<ConsultationDetailsPage> createState() => _ConsultationDetailsPageState();
}

class _ConsultationDetailsPageState extends State<ConsultationDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          widget.consultType,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              VerticalSpacing(),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacing(size: 16),
                    Expanded(child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1
                          )
                      ),
                      child: InkWell(
                        overlayColor: MaterialStateProperty.resolveWith((states){
                          return states.contains(MaterialState.pressed)
                              ? AppColors.tileColors.withAlpha(50)
                              : null;
                        }),
                        onTap: (){
                          DialogHelper.showComingSoonView();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Column(
                            children: [
                              Image.asset(
                                AssetImages.accountStatement, height: 80,
                                width: 80,),
                              VerticalSpacing(size: 4,),
                              Text(AppStrings().labelAccountStatement,
                                style: AppTextStyle.textMediumStyle(
                                    fontSize: 16, color: AppColors.tileColors),
                                textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      ),
                    )),
                    Spacing(size: 16),
                    Expanded(child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1
                          )
                      ),
                      child: InkWell(
                        overlayColor: MaterialStateProperty.resolveWith((states){
                          return states.contains(MaterialState.pressed)
                              ? AppColors.tileColors.withAlpha(50)
                              : null;
                        }),
                        onTap: (){
                          Get.to(() => AppointmentsPage(isTeleconsultation: widget.isTeleconsultation, providerServiceTypes: widget.providerServiceTypes),
                            transition: Utility.pageTransition,);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Column(
                            children: [
                              Image.asset(
                                AssetImages.appointments, height: 80,
                                width: 80,),
                              VerticalSpacing(size: 4,),
                              Text(AppStrings().labelAppointments,
                                  style: AppTextStyle.textMediumStyle(
                                      fontSize: 16, color: AppColors.tileColors),
                                  textAlign: TextAlign.center)
                            ],
                          ),
                        ),
                      ),
                    )),
                    Spacing(size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
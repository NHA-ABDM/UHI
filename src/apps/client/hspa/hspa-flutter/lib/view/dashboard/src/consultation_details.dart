import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../model/request/src/provider_service_type.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/vertical_spacing.dart';

class ConsultationDetailsPage extends StatefulWidget {
  const ConsultationDetailsPage({Key? key}) : super(key: key);

  /*const ConsultationDetailsPage({Key? key, required this.consultType, required this.isTeleconsultation, required this.providerServiceTypes}) : super(key: key);
  final String consultType;
  final bool isTeleconsultation;
  final ProviderServiceTypes providerServiceTypes;*/

  @override
  State<ConsultationDetailsPage> createState() => _ConsultationDetailsPageState();
}

class _ConsultationDetailsPageState extends State<ConsultationDetailsPage> {

  late String consultType;
  late bool isTeleconsultation;
  late ProviderServiceTypes providerServiceTypes;

  @override
  void initState() {
    consultType = Get.arguments['consultType']!;
    isTeleconsultation = Get.arguments['isTeleconsultation']! as bool;
    providerServiceTypes = Get.arguments['providerServiceTypes']! as ProviderServiceTypes;
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
          consultType,
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
                    const Spacing(size: 16),
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
                          // DialogHelper.showComingSoonView();
                          Get.toNamed(AppRoutes.accountStatementPage, arguments: <String, dynamic>{'isTeleconsultation': isTeleconsultation, 'providerServiceTypes': providerServiceTypes});
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
                    const Spacing(size: 16),
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
                          /*Get.to(() => AppointmentsPage(isTeleconsultation: isTeleconsultation, providerServiceTypes: providerServiceTypes),
                            transition: Utility.pageTransition,);*/
                          Get.toNamed(AppRoutes.appointmentsPage, arguments: <String, dynamic>{'isTeleconsultation': isTeleconsultation, 'providerServiceTypes': providerServiceTypes});
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
                    const Spacing(size: 16),
                  ],
                ),
              ),
              VerticalSpacing(),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacing(size: 16),
                    Expanded(child:
                    Card(
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
                        onTap: () {
                          Get.toNamed(
                              AppRoutes.calendarWithSlotsPage,
                              arguments: <String, dynamic>{
                                'consultType': isTeleconsultation
                                    ? AppStrings().labelTeleconsultation
                                    : AppStrings().labelPhysicalConsultation,
                                'isExisting': true,
                              },
                          );
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
                              Text('${AppStrings().labelSchedule}\n ',
                                  style: AppTextStyle.textMediumStyle(
                                      fontSize: 16, color: AppColors.tileColors),
                                  maxLines: 2,
                                  textAlign: TextAlign.center)
                            ],
                          ),
                        ),
                      ),
                    )),
                    const Spacing(size: 16),
                    Expanded(child:
                    Container()),
                    const Spacing(size: 16),
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
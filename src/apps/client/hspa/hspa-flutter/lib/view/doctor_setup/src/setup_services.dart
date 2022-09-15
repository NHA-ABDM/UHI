import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';
import 'package:hspa_app/widgets/widgets.dart';

import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/get_pages.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import 'days_time_selection_page.dart';

enum Type { teleconsultation, physicalConsultation }

class SetUpServicesPage extends StatefulWidget {
  const SetUpServicesPage({Key? key}) : super(key: key);

  @override
  State<SetUpServicesPage> createState() => _SetUpServicesPageState();
}

class _SetUpServicesPageState extends State<SetUpServicesPage> {

  List<Type> consultType = <Type>[];
  DoctorProfile? _doctorProfile;

  @override
  void initState() {
    getDoctorDetails();
    super.initState();
  }

  void getDoctorDetails() async{
    _doctorProfile = await DoctorProfile.getSavedProfile();
    if(_doctorProfile != null){
      setState(() {
      });
    }
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
          _doctorProfile?.displayName ?? '',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(
                  backgroundColor: AppColors.progressBarBackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.amountColor,
                  ),
                  value: 0.2,
                  minHeight: 8,
                ),
                VerticalSpacing(
                  size: 20,
                ),
                Text(
                  AppStrings().labelSelectServices,
                  style: AppTextStyle.textSemiBoldStyle(
                      fontSize: 18, color: AppColors.titleTextColor),
                ),
                VerticalSpacing(
                  size: 4,
                ),
                Text(
                  AppStrings().labelCanSelectMultipleServices,
                  style: AppTextStyle.textLightStyle(
                      fontSize: 14, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(),

                GridView.count(
                  //padding: const EdgeInsets.only(bottom: 16),
                  shrinkWrap: true,
                  childAspectRatio: 0.8,
                  clipBehavior: Clip.none,
                  crossAxisSpacing: 8,
                  crossAxisCount: 2, children: [
                  buildGridCardView(drProfile: 'https://etimg.etb2bimg.com/photo/89261641.cms', isSelected: true, type: AppStrings().labelTeleconsultation, placeholder: AssetImages.teleconsultationPlaceholder),
                  buildGridCardView(drProfile: 'https://www.homecareassistancelincolnca.com/wp-content/uploads/2018/05/Doctor-and-Senior-Male.jpg', isSelected: false, type: AppStrings().labelPhysicalConsultationNewLine, placeholder: AssetImages.physicalConsultationPlaceholder),
                ],),
                VerticalSpacing(),
              ],
            ),
          ),
          Column(
            children: [
              Spacing(isWidth: false, size: 16,),
              SquareRoundedButtonWithIcon(text: AppStrings().btnNext, assetImage: AssetImages.arrowLongRight, onPressed: (){
                if(consultType.isEmpty) {
                  Get.snackbar(AppStrings().alert, AppStrings().errorProvideServiceType);
                } else {
                  DoctorSetupValues doctorSetupValues = DoctorSetupValues();
                  doctorSetupValues.isTeleconsultation = false;
                  doctorSetupValues.isPhysicalConsultation = false;
                  doctorSetupValues.serviceTypes.clear();
                  String displayString = '';

                  if(consultType.contains(Type.teleconsultation)){
                    doctorSetupValues.isTeleconsultation = true;
                    doctorSetupValues.serviceTypes.add(ProviderAttributesLocal.teleconsultation);
                    displayString = AppStrings().labelTeleconsultation;
                  }
                  if(consultType.contains(Type.physicalConsultation)){
                    doctorSetupValues.isPhysicalConsultation = true;
                    doctorSetupValues.serviceTypes.add(ProviderAttributesLocal.physicalConsultation);
                    displayString = AppStrings().labelPhysicalConsultation;
                  }

                  if(consultType.length == 2){
                    displayString = AppStrings().labelBoth;
                  }
                  /*Get.to(() => DayTimeSelectionPage(consultType: displayString,),
                    transition: Utility.pageTransition,);*/
                  Get.toNamed(AppRoutes.dayTimeSelectionPage, arguments: <String, dynamic>{
                    'consultType' : displayString,
                    'isExisting': false,
                  });
                }
              }),
            ],
          ),        ],
      ),
    );
  }

  buildGridCardView({required String drProfile, required bool isSelected, required String type, required String placeholder}) {
    return GestureDetector(
      onTap: (){
        setState(() {
          if(type == AppStrings().labelTeleconsultation){
            if(consultType.contains(Type.teleconsultation)){
              consultType.remove(Type.teleconsultation);
            } else {
              consultType.add(Type.teleconsultation);
            }
          } else {
            if(consultType.contains(Type.physicalConsultation)){
              consultType.remove(Type.physicalConsultation);
            } else {
              consultType.add(Type.physicalConsultation);
            }
          }
        });
      },
      child: Stack(
          clipBehavior: Clip.none,

          children: [
            Card(
              color: Colors.white,
              //margin: const EdgeInsets.only(right: 0, top: 16),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // if you need this
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft:  Radius.circular(20), topRight:  Radius.circular(20)),
                    child: FadeInImage(
                        //width: MediaQuery.of(context).size.width / 2 - 32,
                        height: MediaQuery.of(context).size.width / 2.22 - 32 ,
                        fit: BoxFit.cover,
                        image:  Image.network(drProfile,).image,
                        imageErrorBuilder: (context, obj, stackTrace) {
                          return Image.asset(placeholder);
                        },
                        placeholder: AssetImage(placeholder)),
                  ),
                  Container(
                    height: (MediaQuery.of(context).size.width / 4) - 32,
                    alignment: Alignment.center,
                    //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    child: Text(
                      type,
                      style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.tileColors),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top:-32.0,
              right: -32.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    iconSize: 50,
                    icon: Image.asset(
                        getAssetImage(type),
                    ),
                    onPressed: () {
                      setState(() {
                        if(type == AppStrings().labelTeleconsultation){
                          if(consultType.contains(Type.teleconsultation)){
                            consultType.remove(Type.teleconsultation);
                          } else {
                            consultType.add(Type.teleconsultation);
                          }
                        } else {
                          if(consultType.contains(Type.physicalConsultation)){
                            consultType.remove(Type.physicalConsultation);
                          } else {
                            consultType.add(Type.physicalConsultation);
                          }
                        }
                      });
                    },
                ),
              ),
            ),
          ],
      ),
    );
  }

  String getAssetImage(String type){
    String assetImage = AssetImages.unselectedRound;
    if(type == AppStrings().labelTeleconsultation){
      if(consultType.contains(Type.teleconsultation)){
        assetImage = AssetImages.selectedRound;
      } else {
        assetImage = AssetImages.unselectedRound;
      }
    } else {
      if(consultType.contains(Type.physicalConsultation)){
        assetImage = AssetImages.selectedRound;
      } else {
        assetImage = AssetImages.unselectedRound;
      }
    }
    return assetImage;
  }
}

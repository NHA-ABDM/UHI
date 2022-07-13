import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../doctor_setup/src/days_time_selection_page.dart';

class UpdateConsultationDetailsPage extends StatefulWidget {
  const UpdateConsultationDetailsPage({Key? key, required this.isTeleconsultation}) : super(key: key);
  final bool isTeleconsultation;

  @override
  State<UpdateConsultationDetailsPage> createState() => _UpdateConsultationDetailsPageState();
}

class _UpdateConsultationDetailsPageState extends State<UpdateConsultationDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          widget.isTeleconsultation ? AppStrings().labelTeleconsultation : AppStrings().labelPhysicalConsultation,
          style:
          AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
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
      return ListView(
        shrinkWrap: true,
        children: [
          generateListItem(label: AppStrings().labelEditAvailability, onPressed: (){
            Get.to(() => DayTimeSelectionPage(
              consultType: widget.isTeleconsultation
                  ? AppStrings().labelTeleconsultation
                  : AppStrings().labelPhysicalConsultation,
              isExisting: true,
            ),
              transition: Utility.pageTransition,);
          }),
          generateListItem(label: AppStrings().labelEditFees, onPressed: (){
            DialogHelper.showComingSoonView();
          }),
          generateListItem(label: AppStrings().labelEditPayments, onPressed: (){
            DialogHelper.showComingSoonView();
          }),
        ],
      );
  }

  generateListItem({required String label, required Function() onPressed}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: ListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            onTap: onPressed,
          ),
        ),
        const Divider(color: AppColors.drawerDividerColor, thickness: 1, height: 1,),
      ],
    );
  }
}

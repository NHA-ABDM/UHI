import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {

  bool newAppointmentValue = true;
  bool rescheduledAppointmentValue = true;
  bool cancelledAppointmentValue = false;
  bool chatsValue = false;
  bool paymentsValue = true;
  bool ratingsValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().labelNotificationSettings,
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
        generateListItem(label: AppStrings().labelNewAppointments, value: newAppointmentValue, onChanged: (bool value) {
          setState(() {
            newAppointmentValue = !newAppointmentValue;
          });
        }),
        generateListItem(label: AppStrings().labelRescheduledAppointments, value: rescheduledAppointmentValue, onChanged: (bool value) {
          setState(() {
            rescheduledAppointmentValue = !rescheduledAppointmentValue;
          });
        }),
        generateListItem(label: AppStrings().labelCancelledAppointments, value:  cancelledAppointmentValue, onChanged: (bool value) {
          setState(() {
            cancelledAppointmentValue = !cancelledAppointmentValue;
          });
        }),
        generateListItem(label: AppStrings().labelChats, value:  chatsValue, onChanged: (bool value) {
          setState(() {
            chatsValue = !chatsValue;
          });
        }),
        generateListItem(label: AppStrings().labelPayments, value:  paymentsValue, onChanged: (bool value) {
          setState(() {
            paymentsValue = !paymentsValue;
          });
        }),
        generateListItem(label: AppStrings().labelRatingsAndFeedback, value:  ratingsValue, onChanged: (bool value) {
          setState(() {
            ratingsValue = !ratingsValue;
          });
        }),
      ],
    );
  }

  generateListItem({required String label, required bool value, required Function(bool value) onChanged}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: SwitchListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.tileColors,
            inactiveTrackColor: AppColors.grey8B8B8B,
            inactiveThumbColor: AppColors.white,
          ),
        ),

        /*Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: ListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            trailing: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.tileColors,
              trackColor: AppColors.grey8B8B8B,
              thumbColor: AppColors.white,
            ),
            onTap: (){
              onChanged(value);
            },
          ),
        ),*/
        const Divider(color: AppColors.drawerDividerColor, thickness: 1, height: 1,),
      ],
    );
  }
}

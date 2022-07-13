import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({Key? key}) : super(key: key);

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {

  List<CallDetails> listCallDetails = <CallDetails>[];
  
  @override
  void initState() {
    listCallDetails.add(CallDetails(name: 'Arya Mahajan', callerId: '123'));
    listCallDetails.add(CallDetails(name: 'Tarak Mehta', callerId: '456'));
    listCallDetails.add(CallDetails(name: 'John Wick', callerId: '789'));
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
          AppStrings().labelWaitingRoom,
          style: AppTextStyle.textBoldStyle(
              color: AppColors.black, fontSize: 18),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shrinkWrap: true,
      itemCount: listCallDetails.length,
      itemBuilder: buildListRow,
    );
  }

  Widget buildListRow(BuildContext context, int index){
    return Card(
      elevation: 5,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            child: Text('${index + 1}', style: AppTextStyle.textSemiBoldStyle(fontSize: 16, color: AppColors.white),),
          ),
          title: Text(listCallDetails[index].name, style: AppTextStyle.textSemiBoldStyle(fontSize: 16, color: AppColors.testColor),),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: Image.asset(
                  AssetImages.chat,
                  height: 24,
                  width: 24,
                ),
              ),
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  icon: Image.asset(
                    AssetImages.audio,
                    height: 24,
                    width: 24,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  icon: Image.asset(
                    AssetImages.video,
                    height: 24,
                    width: 24,
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}

class CallDetails{
  late String name;
  late String callerId;

  CallDetails({required this.name, required this.callerId});
}

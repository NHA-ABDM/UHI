import 'package:flutter/material.dart';

class WaitingRoomScreen extends StatefulWidget {
  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  ///SCREEN WIDTH
  var width;

  ///SCREEN HEIGHT
  var height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF324755),
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: Text(
          "Waiting Room",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You are in Dr. Sana Bhatt’s Waiting Room",
                      style: TextStyle(
                        color: Color(0xFF264488),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text("Please wait, Dr Sana Beat will let you in soon."),
                  ],
                ),
              ),
            ),
            Container(
              width: width * 0.92,
              // height: height * 0.08,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xFFE8705A),
              ),
              child: Center(
                child: Text(
                  "LEAVE ROOM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

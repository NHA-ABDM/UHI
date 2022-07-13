import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/model/response/src/response_model.dart';

class StompSocketConnection {
  StompClient? stompClient;
  ResponseModel? responseModel;
  int messageQueueNum = 0;
  Function()? postApi;
  Function(ResponseModel? responseModel)? onResponse;
  Timer? timer;

  connect({
    required String uniqueId,
    required Function() api,
  }) async {
    // log("Name : $uniqueId");
    postApi = await api;
    stompClient = StompClient(
      config: StompConfig(
        //url: 'ws://100.65.158.41:8081/eua-client',
        // url: 'ws://uhieuabeta.abdm.gov.in/eua-client',
        url: RequestUrls.euaClientStompSocketUrl,
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(Duration(milliseconds: 200));
          print('connecting...');
        },
        // connectionTimeout: Duration(seconds: 6),
        // reconnectDelay: Duration(milliseconds: 0),
        onStompError: (dynamic error) =>
            print("On Stomp Error " + error.toString()),
        onWebSocketError: (dynamic error) {
          print("On Websocket Error " + error.toString());

          onResponse?.call(responseModel);
        },
        onDebugMessage: (dynamic error) {
          print("On Debug Message " + error.toString());
          timer = Timer.periodic(Duration(seconds: 1), (timer) async {
            if (timer.tick == 10) {
              timer.cancel();
              onResponse?.call(responseModel);
            }
          });
        },
        onUnhandledFrame: (dynamic error) =>
            print("On Unhandled Frame " + error.toString()),
        onUnhandledMessage: (dynamic error) =>
            print("On Unhandled Message " + error.toString()),
        onUnhandledReceipt: (dynamic error) =>
            print("On Unhandled Receipt " + error.toString()),
        onDisconnect: (dynamic data) =>
            print("On Disconnect " + data.toString()),
        onWebSocketDone: () => log("Websocket closed"),
        stompConnectHeaders: {'name': uniqueId},
        webSocketConnectHeaders: {'name': uniqueId},
      ),
    );
    stompClient?.activate();
  }

  Future<void> onConnect(StompFrame frame) async {
    print("connected");
    // createAckWithProfessionalName();
    postApi!();
    stompClient?.subscribe(
      destination: '/user/queue/specific-user',
      callback: (frame) {
        if (frame.body != null) {
          // log("${frame.body}", name: "FRAME BODY");
          timer = Timer.periodic(Duration(seconds: 1), (timer) async {
            if (timer.tick == 10) {
              timer.cancel();
              messageQueueNum = 0;
              onResponse?.call(responseModel);
              stompClient?.deactivate();
            }
          });

          if (messageQueueNum == 0) {
            messageQueueNum++;
            AcknowledgementResponseModel acknowledgementModel =
                AcknowledgementResponseModel.fromJson(json.decode(frame.body!));
            if (acknowledgementModel.message?.ack?.status == "NACK") {
              messageQueueNum = 0;
              onResponse?.call(responseModel);
              stompClient?.deactivate();
            }
          } else if (messageQueueNum == 1) {
            messageQueueNum++;
            responseModel = ResponseModel.fromJson(json.decode(frame.body!));
            onResponse?.call(responseModel!);
            messageQueueNum = 0;
            stompClient?.deactivate();
          }
        }
      },
    );
  }

  void disconnect() {
    stompClient?.deactivate();
    responseModel = null;
    messageQueueNum = 0;
    postApi = null;
  }
}

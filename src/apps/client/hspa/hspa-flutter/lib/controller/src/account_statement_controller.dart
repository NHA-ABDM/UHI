import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hspa_app/services/src/exception_handler.dart';

import '../../constants/src/request_urls.dart';
import '../../model/response/src/payment_status_response.dart';
import '../../services/src/service.dart';

class AccountStatementController extends GetxController with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';
  List<PaymentStatus> listPaymentStatus = <PaymentStatus>[];

  Future<void> getAccountStatements({required String? fromDate, required String? toDate, required String hprAddress, required String serviceType, int limit = 100}) async{
    String requestUrl = '${RequestUrls.getPaymentStatus}/$hprAddress/$serviceType';
    /// We will use this once we start filter logic implementation using date range
    /*if(fromDate != null && toDate != null) {
      requestUrl += '&fromDate=$fromDate&toDate=$toDate';
    }*/
    await BaseClient(
        url: requestUrl)
        .get()
        .then(
          (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint('GET Provider Account Statements response is $response');

          PaymentStatusResponse paymentStatusResponse =
          PaymentStatusResponse.fromJson(json.decode(response!));

          if(paymentStatusResponse.paymentStatusList != null && paymentStatusResponse.paymentStatusList!.isNotEmpty){
            listPaymentStatus.clear();
            debugPrint('GET Provider Account Statements parsed successfully');
            listPaymentStatus.addAll(paymentStatusResponse.paymentStatusList!);
          }
        }
      },
    ).catchError(
          (onError) {
        debugPrint('GET Provider Account Statements error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }
}
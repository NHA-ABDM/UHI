import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/src/utility.dart';
import 'app_exception.dart';
import 'hpid_bad_request_exception.dart';

class BaseClient {
  ///Timeout duration
  static const int timeOutDuration = 5;

  final String? url;
  final dynamic body;
  dynamic headers;

  var client = http.Client();

  BaseClient({
    this.url,
    this.body,
    this.headers
  }) {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    debugPrint(basicAuth);
    headers ??= {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Content-Language': 'mobile',
        'authorization': basicAuth,
      };
  }

  String username = 'Admin';
  String password = 'Admin123';


  //Get request to server
  Future<dynamic> get({bool decode = false}) async {
    debugPrint('Calling API ${Uri.parse(url!)}');
    bool isConnected = await Utility.isInternetAvailable();
    if(isConnected) {
      try {
        var response = await client.get(
          Uri.parse(url!),
          headers: headers,
        );
        //.timeout(const Duration(seconds: timeOutDuration));

        return _processResponse(response, decode: decode);
        //return response;
      } on SocketException {
        throw SocketConnectionError('Socket connection error', url);
      } on TimeoutException {
        throw RequestTimeoutException('Request timeout', url);
      } on FormatException {
        throw FetchDataException("Something went wrong", url);
      } on HandshakeException {
        debugPrint('In HandshakeException');
        throw NoInternetConnectionException("No internet connection", url);
      }
    } else {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  //Post request to server
  Future<dynamic> post({bool decode = false}) async {
    bool isConnected = await Utility.isInternetAvailable();
    if(isConnected) {
      try {
        var response = await client
            .post(
              Uri.parse(url!),
              headers: headers,
              body: jsonEncode(body),
            );
            //.timeout(const Duration(seconds: timeOutDuration));

        return _processResponse(response, decode: decode);
      } on SocketException {
        throw SocketConnectionError('Socket connection error', url);
      } on TimeoutException {
        throw RequestTimeoutException('Request timeout', url);
      } on FormatException {
        throw FetchDataException("Something went wrong", url);
      } on HandshakeException {
        throw NoInternetConnectionException("No internet connection", url);
      }
    } else {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  //PUT request to server
  Future<dynamic> put({bool decode = false}) async {
    bool isConnected = await Utility.isInternetAvailable();
    if(isConnected) {
      try {
        var response = await client
            .put(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        //.timeout(const Duration(seconds: timeOutDuration));

        return _processResponse(response, decode: decode);
      } on SocketException {
        throw SocketConnectionError('Socket connection error', url);
      } on TimeoutException {
        throw RequestTimeoutException('Request timeout', url);
      } on FormatException {
        throw FetchDataException("Something went wrong", url);
      } on HandshakeException {
        throw NoInternetConnectionException("No internet connection", url);
      }
    } else {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  //Get request to server
  Future<dynamic> delete({bool decode = false}) async {
    debugPrint('Calling API ${Uri.parse(url!)}');
    bool isConnected = await Utility.isInternetAvailable();
    if(isConnected) {
      try {
        var response = await client.delete(
          Uri.parse(url!),
          headers: headers,
        );
        //.timeout(const Duration(seconds: timeOutDuration));

        return _processResponse(response, decode: decode);
        //return response;
      } on SocketException {
        throw SocketConnectionError('Socket connection error', url);
      } on TimeoutException {
        throw RequestTimeoutException('Request timeout', url);
      } on FormatException {
        throw FetchDataException("Something went wrong", url);
      } on HandshakeException {
        debugPrint('In HandshakeException');
        throw NoInternetConnectionException("No internet connection", url);
      }
    } else {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  ///DECODE JSON IF SUCCESS ELSE THROWS AN EXCEPTION
  dynamic _processResponse(http.Response response, {bool decode = false}) {
    log("Url ${response.request!.url}", name: "URL");
    log("Response ${response.body}", name: "RESPONSE");

    switch (response.statusCode) {
      case 200:
        if(decode) {
          var responseJson = json.decode(utf8.decode(response.bodyBytes));
          return responseJson;
        }
        return response.body;
      case 201:
        if(decode) {
          var responseJson = json.decode(utf8.decode(response.bodyBytes));
          return responseJson;
        }
        return response.body;
      case 204:
        return true;
      case 400:
        String exceptionString = 'Servers are busy, Please try again or contact support';
        try{
          HPIDBadRequest? hpIdBadRequest = HPIDBadRequest.fromJson(json.decode(response.body));
          if(hpIdBadRequest.details != null && hpIdBadRequest.details!.isNotEmpty) {
            exceptionString = hpIdBadRequest.details![0].message!;
          }
        } catch (e) {
          debugPrint('Exception is ${e.toString()}');
        }
        throw FetchDataException(
          exceptionString,
          response.request!.url.toString(),
        );

      case 401:
        throw UnAuthorizedException(
          json.decode(response.body)['message'],
          response.request!.url.toString(),
        );

      case 403:
        throw ForbiddenException(
          json.decode(response.body)['message'],
          response.request!.url.toString(),
        );

      case 409:
        throw BadRequestException(
          json.decode(response.body)['message'],
          response.request!.url.toString(),
        );

      case 422:
        String exceptionString = json.decode(response.body)['message'];
        try{
          HPIDBadRequest? hpIdBadRequest = HPIDBadRequest.fromJson(json.decode(response.body));
          if(hpIdBadRequest.details != null && hpIdBadRequest.details!.isNotEmpty) {
            exceptionString = hpIdBadRequest.details![0].message!;
          }
        } catch (e) {
          debugPrint('Exception is ${e.toString()}');
        }
        throw BadRequestException(
          exceptionString,
          response.request!.url.toString(),
        );

      case 500:
        throw BadRequestException(
          "Servers are busy, Please try again or contact support",
          response.request!.url.toString(),
        );

      default:
        throw FetchDataException(
          "Servers are busy, Please try again or contact support",
          response.request!.url.toString(),
        );
    }
  }
}

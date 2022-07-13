import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'app_exception.dart';

class BaseClient {
  ///Timout duration
  static const int timeOutDuration = 20;

  final String? url;
  final dynamic body;
  final String? authToken;

  var client = http.Client();

  BaseClient({
    this.url,
    this.body,
    this.authToken,
  });

  Map<String, String>? _getDefaultHeaders() {
    var headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      'Content-Language': 'mobile',
    };
    return headers;
  }

  Map<String, String>? _getDefaultWithGatewayHeader() {
    var headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      'Content-Language': 'mobile',
      "X-Gateway-Authorization": "uhi"
    };
    return headers;
  }

  Future<Map<String, String>?> _getAuthTokenHeader() async {
    var headers = _getDefaultHeaders();
    String? authTokenHeader =
        await SharedPreferencesHelper.getAuthHeaderToken();
    headers!.putIfAbsent("X-AUTH-TOKEN", () => authTokenHeader!);
    return headers;
  }

  Future<Map<String, String>?> _getAuthHeaders(
      {bool? withoutAccessToken}) async {
    var headers = _getDefaultHeaders();

    if (withoutAccessToken == true) {
      return headers;
    }

    String? accessToken = await SharedPreferencesHelper.getAccessToken();
    headers!.putIfAbsent("Authorization", () => "bearer " + accessToken!);
    return headers;
  }

  //Get request to server
  Future<dynamic> get() async {
    try {
      var response = await client
          .get(Uri.parse(url!))
          .timeout(const Duration(seconds: timeOutDuration));

      return _processResponse(response);
    } on SocketException {
      throw SocketExceptionHandler('Socket connection error', url);
    } on TimeoutException {
      throw RequestTimeoutException('Request timeout', url);
    } on FormatException {
      throw FetchDataException("Something went wrong", url);
    } on HandshakeException {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  //Get request to server
  Future<dynamic> getWithHeaders() async {
    try {
      var response = await client
          .get(
            Uri.parse(url!),
            headers: await (_getAuthTokenHeader()),
          )
          .timeout(const Duration(seconds: timeOutDuration));

      return _processResponse(response);
    } on SocketException {
      throw SocketExceptionHandler('Socket connection error', url);
    } on TimeoutException {
      throw RequestTimeoutException('Request timeout', url);
    } on FormatException {
      throw FetchDataException("Something went wrong", url);
    } on HandshakeException {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  //Post request to server
  Future<dynamic> post() async {
    try {
      log("Url ${url}", name: "URL");

      var response = await client
          .post(
            Uri.parse(url!),
            headers: await (_getAuthHeaders()),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeOutDuration));

      return _processResponse(response);
    } on SocketException {
      throw SocketExceptionHandler('Socket connection error', url);
    } on TimeoutException {
      throw RequestTimeoutException('Request timeout', url);
    } on FormatException {
      throw FetchDataException("Something went wrong", url);
    } on HandshakeException {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  Future<dynamic> postAccessToken() async {
    try {
      var response = await client
          .post(
            Uri.parse(url!),
            headers: (_getDefaultHeaders()),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeOutDuration));

      return _processResponse(response);
    } on SocketException {
      throw SocketExceptionHandler('Socket connection error', url);
    } on TimeoutException {
      throw RequestTimeoutException('Request timeout', url);
    } on FormatException {
      throw FetchDataException("Something went wrong", url);
    } on HandshakeException {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  Future<dynamic> postWithGatewayHeader() async {
    try {
      var response = await client
          .post(
            Uri.parse(url!),
            headers: (_getDefaultWithGatewayHeader()),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeOutDuration));

      return _processResponse(response);
    } on SocketException {
      throw SocketExceptionHandler('Socket connection error', url);
    } on TimeoutException {
      throw RequestTimeoutException('Request timeout', url);
    } on FormatException {
      throw FetchDataException("Something went wrong", url);
    } on HandshakeException {
      throw NoInternetConnectionException("No internet connection", url);
    }
  }

  ///DECODE JSON IF SUCCESS ELSE THROWS AN EXCEPTION
  dynamic _processResponse(http.Response response) {
    log("Url ${response.request!.url}", name: "URL");
    log("Response ${response.body}", name: "RESPONSE");

    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) {
          return;
        }
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        return responseJson;

      case 201:
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        return responseJson;

      case 400:
        throw FetchDataException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 401:
        throw UnAuthorizedException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 403:
        throw ForbiddenException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 405:
        throw ForbiddenException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 409:
        throw BadRequestException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 422:
        throw BadRequestException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      case 500:
        throw BadRequestException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );

      default:
        throw FetchDataException(
          json.decode(response.body)['error']['message'],
          response.request!.url.toString(),
        );
    }
  }
}

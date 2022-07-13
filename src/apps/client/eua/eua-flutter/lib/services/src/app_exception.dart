class AppException implements Exception {
  final String? requestName;
  final String? message;
  final String? prefix;
  final String? url;

  AppException([this.message, this.prefix, this.url, this.requestName]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, String? url, String? requestName])
      : super(message, 'Bad request', url, requestName);
}

class FetchDataException extends AppException {
  FetchDataException([String? message, String? url, String? requestName])
      : super(message, 'Unable to process', url, requestName);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException([String? message, String? url, String? requestName])
      : super(message, 'Api not responded in time', url, requestName);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, String? url, String? requestName])
      : super(message, 'Unauthorized request', url, requestName);
}

class ForbiddenException extends AppException {
  ForbiddenException([String? message, String? url, String? requestName])
      : super(message, "Forbidden exception", url);
}

class NoInternetConnectionException extends AppException {
  NoInternetConnectionException(
      [String? message, String? url, String? requestName])
      : super(message, "No internet connection", url);
}

class RequestTimeoutException extends AppException {
  RequestTimeoutException([String? message, String? url, String? requestName])
      : super(message, "Time out exception", url);
}

class SocketExceptionHandler extends AppException {
  SocketExceptionHandler([String? message, String? url, String? requestName])
      : super(message, "Socket connection error", url);
}

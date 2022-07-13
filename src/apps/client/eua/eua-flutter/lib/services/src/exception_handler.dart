import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/services/services.dart';

class ExceptionHandler {
  ///HANDLE ERROR
  void handleError(error,
      {required bool isShowDialog, required bool isShowSnackbar}) async {
    hideLoading();
    if (isShowDialog) {
      if (error is BadRequestException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      } else if (error is FetchDataException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      } else if (error is ApiNotRespondingException) {
        DialogHelper.showErrorDialog(
            description: 'Oops! It took longer to respond.\n ${error.message}');
      } else if (error is UnAuthorizedException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      } else if (error is ForbiddenException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      } else if (error is SocketExceptionHandler) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      } else if (error is RequestTimeoutException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      }
      if (error is NoInternetConnectionException) {
        DialogHelper.showErrorDialog(description: '${error.message}');
      }
    } else if (isShowSnackbar) {
    } else {}
  }

  showLoadingIndicator() {
    DialogHelper.showLoadingIndicator();
  }

  showLoading([String? message]) {
    DialogHelper.showLoading(message);
  }

  hideLoading() {
    DialogHelper.hideLoading();
  }
}

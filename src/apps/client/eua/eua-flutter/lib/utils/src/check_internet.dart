import 'package:connectivity/connectivity.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class CheckInternet {
  static Transition pageTransition = Transition.rightToLeft;
  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}

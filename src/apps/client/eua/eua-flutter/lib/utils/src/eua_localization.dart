import 'package:uhi_flutter_app/utils/src/shared_pref.dart';

class EUALocalization {
  EUALocalization._privateConstructor();

  static final EUALocalization _instance =
      EUALocalization._privateConstructor();
  static EUALocalization get instance => _instance;
  final SharedPref _sharedPref = SharedPref();

  SharedPref getSharedPref() {
    return _sharedPref;
  }
}

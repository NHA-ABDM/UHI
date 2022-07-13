import 'dart:ui';

class LanguageConstant{
  static const String defaultLan="Default", defaultCode="";
  static const String english="English", englishCode="en";
  static const String hindi="Hindi", hindiCode="hi";
  static const List<String> languageCodeArray=[englishCode, hindiCode];
  static const List<Locale> supportedLanguages=[Locale(englishCode), Locale(hindiCode)];
  static const Locale fallBackLocale = Locale(englishCode);
}
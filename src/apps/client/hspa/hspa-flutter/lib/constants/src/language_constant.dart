import 'dart:ui';

class LanguageConstant{
  static const String defaultLan="Default", defaultCode="";
  static const String english="English", englishCode="en";
  static const String hindi="Hindi", hindiCode="hi";
  static const List<String> languageCodeArray=[englishCode, hindiCode];
  static const List<Locale> supportedLanguages=[Locale(englishCode), Locale(hindiCode)];
  static const Locale fallBackLocale = Locale(englishCode);

  static List<String> indianLanguages = <String>[
    'Assamese',
    'Bengali',
    'Bodo',
    'Dogri',
    'English',
    'Gujarati',
    'Hindi',
    'Kannada',
    'Kashmiri',
    'Konkani',
    'Maithili',
    'Malayalam',
    'Manipuri',
    'Marathi',
    'Nepali',
    'Oriya',
    'Punjabi',
    'Sanskrit',
    'Santhali',
    'Sindhi',
    'Tamil',
    'Telugu',
    'Urdu',
  ];
}
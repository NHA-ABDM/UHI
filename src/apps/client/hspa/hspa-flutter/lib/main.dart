import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hspa_app/controller/src/dashboard_controller.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/theme/src/app_colors.dart';
import 'package:hspa_app/utils/src/utility.dart';

import 'constants/src/get_pages.dart';
import 'constants/src/language_constant.dart';
import 'constants/src/strings.dart';
import 'firebase_options.dart';
import 'settings/src/preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chat_channel_id', // id
    'Chat Notifications', // title
    importance: Importance.high, //
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("A bg message just showed up : ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  await EasyLocalization.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  runApp(
    EasyLocalization(
        saveLocale: true,
        child: const MyApp(),
        supportedLocales: LanguageConstant.supportedLanguages,
        fallbackLocale: LanguageConstant.fallBackLocale,
        path: 'assets/lang'),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  //final Locale? locale;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              /*await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );*/
            },
          )
        ],
      ),
    );
  }

  // Get device token from firebase
  Future<String?> _getDeviceToken() async {
    String? deviceToken = '@';
    try {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("could not get the token");
      debugPrint(e.toString());
    }
    if (deviceToken != null) {
      debugPrint('---------Device Token---------$deviceToken');
    }
    return deviceToken;
  }

  @override
  void initState() {
    super.initState();
    checkLocalAuth();
    _getDeviceToken();
    initializeSettings();
    listenNotifications();
  }

  initializeSettings() async{
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      Map<String, dynamic> messageMap =  json.decode(payload);
      RemoteMessage message = RemoteMessage.fromMap(messageMap);
      checkMessageTypeAndOpenPage(message);
    }
  }

  String initialRoute = AppRoutes.splashPage;

  void checkLocalAuth() {
    bool? isAuth = Preferences.getBool(key: AppStrings.isLocalAuth);
    if(isAuth != null && isAuth) {
      initialRoute = AppRoutes.localAuthPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HSPA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          unselectedWidgetColor: Colors.black),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // home: const SplashScreenPage(),
      initialRoute: initialRoute,
      getPages: appRoutes(),
    );
  }

  Future<void> handleAndShowNotification(RemoteMessage message) async{

    DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
    if(doctorProfile != null) {
      
      Map<String, dynamic> data = message.data;
      if(data.containsKey('type') && data['type'] == 'chat') {
        String? receiverabhaAddress = data['ReceiverabhaAddress'];
        String? senderabhaAddress = data['SenderabhaAddress'];

        if(receiverabhaAddress != null && receiverabhaAddress == doctorProfile.hprAddress) {
          String appRoute = Get.currentRoute;
          debugPrint('Current open route is $appRoute');
          if(appRoute == AppRoutes.chatPage) {

            String? doctorHprId = Get.arguments['doctorHprId'];
            String? patientAbhaId = Get.arguments['patientAbhaId'];

            if(doctorHprId == receiverabhaAddress && patientAbhaId == senderabhaAddress) {
              debugPrint('Chat window between user is already open');
            } else {
              showNotification(message);
            }
          } else {
            showNotification(message);
          }
        }
      } else {
        showNotification(message);
      }
    }
  }

  void showNotification(RemoteMessage message) async{

    Map<String, dynamic> data = message.data;
    String? chatMessage;
    if(data.containsKey('type') && data['type'] == 'chat') {
      String? publicKey = data['sharedKey'];
      String? privateKey = Preferences.getString(key: AppStrings.encryptionPrivateKey);
      if(publicKey != null && privateKey != null) {
        SecretKey? secretKey = await Utility.getSecretKey(
            publicKey: publicKey, privateKey: privateKey);

        if(secretKey != null) {
          chatMessage = await Utility.decryptMessage(message: message.notification?.body, secretKey: secretKey);
        }
      }
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          chatMessage ?? notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                color: AppColors.tileColors,
                playSound: true,
                icon: '@mipmap/ic_launcher'),
          ),
        payload: json.encode(message.toMap())
      );
    }
  }

  void listenNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('onMessage message is ${message.toMap()}');
      handleAndShowNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      debugPrint('onMessageOpenedApp message is ${message?.toMap()}');
      checkMessageTypeAndOpenPage(message);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((event) async{
      debugPrint('onTokenRefresh event is $event');
      /*DashboardController controller = DashboardController();
      controller.saveFirebaseToken();*/
    });

  }
}

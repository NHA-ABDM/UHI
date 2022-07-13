import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:uhi_flutter_app/model/common/common.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // await Firebase.initializeApp();

  // ///PUSH NOTIFICATIONS
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  HttpOverrides.global = MyHttpOverrides();
  runApp(
    EasyLocalization(
        saveLocale: true,
        child: MyApp(),
        supportedLocales: [Locale('en'), Locale('hi')],
        fallbackLocale: Locale('en'),
        path: 'assets/lang'),
  );
}

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   description:
//       'This channel is used for important notifications.', // description
//   importance: Importance.high,
// );
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${jsonEncode(message.data)}');
// }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? fcmToken;
  String? city = "";
  String location = 'Null, Press Button';
  String address = 'search';

  @override
  void initState() {
    super.initState();
    getAllPermissions();

    ///REQUESTING FOR NOTIFICATIONS PERMISSIONS
    //   _requestPermissions();

    //   ///INITIALIZE PLATFORM SPECIFIC PUSH NOTIFICATIONS
    //   var initialzationSettingsAndroid =
    //       AndroidInitializationSettings('@mipmap/ic_launcher');
    //   final IOSInitializationSettings initializationSettingsIOS =
    //       IOSInitializationSettings(
    //     requestAlertPermission: false,
    //     requestBadgePermission: false,
    //     requestSoundPermission: false,
    //   );
    //   var initializationSettings = InitializationSettings(
    //       android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);
    //   flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //   ///NOTIFICATIONS DETAILS
    //   const IOSNotificationDetails iosNotificationDetails =
    //       IOSNotificationDetails();
    //   AndroidNotificationDetails androidNotificationDetails =
    //       AndroidNotificationDetails(
    //     channel.id,
    //     channel.name,
    //     channelDescription: channel.description,
    //     color: Colors.blue,

    //     ///ANDROID NOTIFICATIONS ICON
    //     icon: "@mipmap/ic_launcher",
    //   );

    //   ///SHOW NOTIFICATIONS IN NOTIFICATIONS TRAY
    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //     RemoteNotification notification = message.notification!;

    //     NotificationMessageModel notificationMessageModel =
    //         NotificationMessageModel.fromJson(message.data);
    //     log("${jsonEncode(notificationMessageModel)}",
    //         name: "NOTIFICATION MESSAGE MODEL");

    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: androidNotificationDetails,
    //           iOS: iosNotificationDetails,
    //         ));
    //   });

    ///AFTER OPENED NOTIFICATIONS EVENT
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification!;

    //   NotificationMessageModel notificationMessageModel =
    //       NotificationMessageModel.fromJson(message.data);
    //   // log("${jsonEncode(message)}", name: "NOTIFICATION MESSAGE MODEL");

    //   if (notificationMessageModel.type == "chat") {
    //     Get.to(() => ChatPage(
    //           doctorHprId: notificationMessageModel.doctorAbhaAddress,
    //           patientAbhaId: notificationMessageModel.patientAbhaAddress,
    //           doctorName: notification.title,
    //           doctorGender: notificationMessageModel.doctorGender,
    //           providerUri: notificationMessageModel.providerUri,
    //         ));
    //   }
    // });

    //   ///FCM TOKEN
    //   getFCMToken();
  }

  // void _requestPermissions() {
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           MacOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  // }

  // getFCMToken() async {
  //   fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
  //   log("$fcmToken", name: "FCM TOKEN");

  //   setState(() {});
  // }

  getAllPermissions() {
    getLocationPermission();
  }

  getLocationPermission() async {
    try {
      Position position = await _getGeoLocationPosition();
      location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
      await getAddressFromLatLong(position);
    } catch (e) {}
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    city = place.locality;
    SharedPreferencesHelper.setCity(city);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UHI EUA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          unselectedWidgetColor: Colors.black),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: SplashScreenPage(fcmToken: fcmToken),
    );
  }
}

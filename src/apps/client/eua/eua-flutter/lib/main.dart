import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:uhi_flutter_app/common/src/get_pages.dart';
import 'package:uhi_flutter_app/firebase_options.dart';
import 'package:uhi_flutter_app/observer/home_page_obsevable.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ///FIREBASE CRASHLYTICS
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    ///PUSH NOTIFICATIONS
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    HttpOverrides.global = MyHttpOverrides();
    runApp(
      EasyLocalization(
          saveLocale: true,
          child: MyApp(),
          supportedLocales: [Locale('en'), Locale('hi')],
          fallbackLocale: Locale('en'),
          path: 'assets/lang'),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${jsonEncode(message.data)}');
}

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

  String? fcmToken;
  String? city = "";
  String location = 'Null, Press Button';
  String address = 'search';
  String initialRoute = AppRoutes.splashPage;
  bool _isLocalAuth = false;

  @override
  void initState() {
    super.initState();
    checkLocalAuth();
    getAllPermissions();
    initializeSettings();
    listenNotifications();
  }

  void checkLocalAuth() {
    SharedPreferencesHelper.getLocalAuth().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference _isLocalAuth : $value");
            if (value != null) {
              _isLocalAuth = value;
              if (_isLocalAuth) {
                initialRoute = AppRoutes.localAuthPage;
              }
            }
          });
        }));
  }

  initializeSettings() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      Map<String, dynamic> messageMap = json.decode(payload);
      RemoteMessage message = RemoteMessage.fromMap(messageMap);
      checkMessageTypeAndOpenPage(message);
    }
  }

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
      //home: SplashScreenPage(fcmToken: fcmToken),
      initialRoute: initialRoute,
      getPages: appRoutes(),
    );
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

    FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
      debugPrint('onTokenRefresh event is $event');
      /*DashboardController controller = DashboardController();
      controller.saveFirebaseToken();*/
    });
  }

  Future<void> handleAndShowNotification(RemoteMessage message) async {
    String? patientAbhaAddress = await SharedPreferencesHelper.getABhaAddress();
    debugPrint('patientAbhaAddress is $patientAbhaAddress');
    Map<String, dynamic> data = message.data;
    if (patientAbhaAddress != null) {
      if (data.containsKey('type') && data['type'] == 'chat') {
        String? receiverabhaAddress = data['receiverAbhaAddress'];
        String? senderabhaAddress = data['senderAbhaAddress'];
        debugPrint('receiverabhaAddress is $receiverabhaAddress');

        if (receiverabhaAddress != null &&
            receiverabhaAddress == patientAbhaAddress) {
          String appRoute = Get.currentRoute;
          debugPrint('Current open route is $appRoute');
          if (appRoute == AppRoutes.chatPage) {
            String? doctorHprId = Get.arguments['doctorHprId'];
            String? patientAbhaId = Get.arguments['patientAbhaId'];

            if (doctorHprId == senderabhaAddress &&
                patientAbhaId == receiverabhaAddress) {
              debugPrint('Chat window between user is already open');
            } else {
              showNotification(message);
            }
          } else if (appRoute == AppRoutes.homePage ||
              appRoute == AppRoutes.upcomingAppointmentsPage) {
            showNotification(message);
            final HomeScreenObservable observable = HomeScreenObservable();
            observable.notifyUpdateAppointmentData();
          } else {
            showNotification(message);
          }
        }
      } else {
        showNotification(message);
      }
    }
  }

  void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                color: AppColors.tileColors,
                playSound: true,
                icon: '@mipmap/ic_launcher'),
          ),
          payload: json.encode(message.toMap()));
    }
  }
}

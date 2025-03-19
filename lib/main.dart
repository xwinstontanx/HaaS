import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_senzehub.dart';
import 'firebase_options_senzepact.dart';
import 'messaging_service.dart'; // Generated file

MessagingService _msgService = MessagingService();

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log or handle the error details
    print(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(
      options: SecondaryFirebaseOptions.currentPlatform, name: "secondary");

  // Example to get the data from Senzehub firestore
  // var collection =
  // FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
  //     .collection('Users');

  await _msgService.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('zh'), Locale('ms')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const App()),
  );

  EasyLocalization.logger.enableBuildModes = [];
}

/// Top level function to handle incoming messages when the app is in the background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:senzepact/src/screens/flashscreen.dart';
import 'package:senzepact/src/screens/forgot_password.dart';
import 'package:senzepact/src/screens/BottomNavIcons.dart';
import 'package:senzepact/src/screens/login.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..loadingStyle = EasyLoadingStyle.custom
      ..textStyle = const TextStyle(
        color: Colors.blue,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      )
      ..backgroundColor = Colors.grey.shade100
      ..textColor = Colors.black
      ..indicatorColor = Colors.blue
      ..maskColor = Colors.black
      ..userInteractions = false
      ..dismissOnTap = false;

    return MaterialApp(
      title: "SenzePact",
      theme: ThemeData(
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        // '/': (context) => kIsWeb ? const FlashScreen() : const LoginScreen(),
        '/': (context) => const LoginScreen(),
        '/flash': (context) => const FlashScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/volunteering': (context) => const BottomNavIcons(),
      },
      builder: EasyLoading.init(),
    );
  }
}

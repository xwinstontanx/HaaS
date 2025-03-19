import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:senzepact/src/screens/BottomNavIcons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account.dart';
import 'forgot_password.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_version_update/app_version_update.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final phonenumberController = TextEditingController();
  final codeController = TextEditingController();
  String verificationReceived = '';
  bool sendCode = false;

  // Initially password is obscure
  bool _obscureText = true;
  String version = "";
  var userUid = "";
  bool isSignedIn = false;

  bool showLoginWithEmail = false;
  bool showLoginWithPhoneNumber = false;

  late ConfirmationResult confirmationResult;

  final String appStoreUrl =
      'https://apps.apple.com/sg/app/senzepact/id6444587798';
  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.senzehub.senzepact';

  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
    _verifyVersion();
    getVersion();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      return true;
    } else {
      dialog(DialogType.error, 'Error'.tr(), 'No internet is available'.tr());
      return false;
    }
  }

  late final AnimationController _controller = AnimationController(
    lowerBound: 0.4,
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInSine,
  );

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verifyVersion() async {
    await AppVersionUpdate.checkForUpdates(
            appleId: '6444587798',
            playStoreId: 'com.senzehub.senzepact',
            country: 'sg')
        .then((data) async {
      if (data.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: data,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'New Version Available'.tr(),
          content: 'Do you want to proceed for update?'.tr(),
          updateButtonText: 'Yes'.tr(),
          cancelButtonText: 'No'.tr(),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20.0),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
        );

        getUser();
      } else {
        getUser();
      }
    });
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool hasRunBefore = prefs.getBool('hasRunBefore') ?? false;

    if (hasRunBefore) {
      FirebaseAuth auth = FirebaseAuth.instance;

      // Check if user has logged in
      if (auth.currentUser != null) {
        var uid = prefs.getString('userUid');
        if (uid != null) {
          setState(() {
            isSignedIn = true;
            userUid = uid;
          });
        }
      } else {
        setState(() {
          isSignedIn = false;
        });
      }
    } else {
      await prefs.setBool('hasRunBefore', true);
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
      setState(() {
        isSignedIn = false;
      });
    }
  }

  Future<void> setUser(uid, name, orgID, role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userUid', uid);
    prefs.setString('userName', name);
    prefs.setString('userOrgId', orgID);
    prefs.setString('userRole', role);
  }

  Future<void> _launchEmail() async {
    if (!await launchUrl(Uri.parse(
        "mailto:contact@senzehub.com?subject=Enquiry From SenzePact App&body="))) {
      throw 'Could not launch contact@senzehub.com';
    }
  }

  Future<void> getDeviceInfo(String userUid) async {
    if (!kIsWeb) {
      FirebaseFirestore.instance.collection('Users').doc(userUid).update({
        'DeviceModel': "Web",
      });
    } else if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      FirebaseFirestore.instance.collection('Users').doc(userUid).update({
        'DeviceModel': androidInfo.model,
        'DeviceSystemVersion': androidInfo.version.release
      });
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      FirebaseFirestore.instance.collection('Users').doc(userUid).update({
        'DeviceModel': iosInfo.model,
        'DeviceSystemVersion': iosInfo.systemVersion
      });
    }
  }

  Future<void> login(email, password) async {
    if (email != "" && password != "" && password.length > 5) {
      EasyLoading.show(status: 'Loading'.tr());

      await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: email.toString().toLowerCase())
          .where("SignUpWithEmail", isEqualTo: true)
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          try {
            EasyLoading.dismiss();
            EasyLoading.show(status: 'SIGNING IN'.tr());
            UserCredential userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);

            final user = userCredential.user;
            if (user?.emailVerified == true) {
              if (user != null) {
                // Get user details (uid, name, orgID)
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .get()
                    .then((profile) async => {
                          if (profile.exists)
                            {
                              if (profile.data()!['Role'] != null)
                                {
                                  FirebaseFirestore.instance
                                      .collection('RoleList')
                                      .doc(profile.data()!['Role'])
                                      .get()
                                      .then((roleDetails) async => {
                                            // print("OrganizationId: " +
                                            //     roleDetails
                                            //         .data()!['OrganizationId']),
                                            await setUser(
                                                user.uid,
                                                profile.data()!['Name'],
                                                roleDetails.data()![
                                                            'OrganizationId'] !=
                                                        null
                                                    ? roleDetails.data()![
                                                        'OrganizationId']
                                                    : "",
                                                profile.data()!['Role'] != null
                                                    ? profile.data()!['Role']
                                                    : ""),
                                            await FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(user.uid)
                                                .update({
                                              'OrganizationId': roleDetails
                                                  .data()!['OrganizationId']
                                            }),
                                            if (profile.data()![
                                                    'TotalPointEarned'] ==
                                                null)
                                              {
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(user.uid)
                                                    .update({
                                                  'TotalPointEarned': 0
                                                }),
                                              }
                                          }),
                                }
                              else
                                {
                                  await setUser(user.uid,
                                      profile.data()!['Name'], "", ""),
                                  if (profile.data()!['TotalPointEarned'] ==
                                      null)
                                    {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(user.uid)
                                          .update({'TotalPointEarned': 0}),
                                    }
                                },
                            }
                        });

                // Update fcm token
                var fcmToken;
                if (!kIsWeb) {
                  //   fcmToken = await FirebaseMessaging.instance
                  //       .getToken(vapidKey: "BKb0TA6SP2efD29Swhk9MfAmJUi3sYrwCBQLiJ2K6S3e7kkBG8HQVC_DRlnKBW5VqyjPkD2YVwTp6q8glw3QWTc");
                  // } else {
                  fcmToken = await FirebaseMessaging.instance.getToken();
                }

                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .update(
                        {'LastLoginAt': DateTime.now(), 'FcmToken': fcmToken});

                // await getDeviceInfo(user.uid);

                // Update log history
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .collection('LogHistory')
                    .add({
                  'CreatedAt': DateTime.now(),
                  'From': 'Mobile',
                  'Action': 'Login'
                });

                // Update FCM in senior's caregiver list
                var collection = FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .collection("ElderlyUnderCare");
                var querySnapshot = await collection.get();
                for (var queryDocumentSnapshot in querySnapshot.docs) {
                  Map<String, dynamic> data = queryDocumentSnapshot.data();

                  await FirebaseFirestore.instanceFor(
                          app: Firebase.app("secondary"))
                      .collection('Users')
                      .doc(data['Uid'])
                      .collection('CaregiversList')
                      .where("Uid", isEqualTo: user.uid)
                      .get()
                      .then((value) async => {
                            if (value.docs.isNotEmpty)
                              {
                                await FirebaseFirestore.instanceFor(
                                        app: Firebase.app("secondary"))
                                    .collection('Users')
                                    .doc(data['Uid'])
                                    .collection('CaregiversList')
                                    .doc(value.docs.first.id)
                                    .update({'FcmToken': fcmToken})
                              }
                          });
                }

                EasyLoading.dismiss();

                // Navigate to Volunteering Bottom Navigation
                if (!mounted) return;
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const BottomNavIcons(),
                );
              }
            } else {
              EasyLoading.dismiss();
              dialog(DialogType.info, '',
                  'Please check your inbox/junk to verfiy your email'.tr());
            }
          } on FirebaseAuthException catch (e) {
            EasyLoading.dismiss();
            if ((e.code == 'user-not-found') || (e.code == 'wrong-password')) {
              dialog(DialogType.error, 'Error'.tr() + " 100",
                  'Incorrect login credential'.tr());
            }
          }
        } else {
          EasyLoading.dismiss();
          dialog(DialogType.error, 'Error'.tr() + " 200",
              'Make sure you have created account with Email'.tr());
        }
      });
    } else {
      dialog(
          DialogType.error, 'Error'.tr(), 'Kindly fill up all the fields'.tr());
    }
  }

  void dialog(type, title, desc) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   // Deferred execution inside the build context
    //   if (kIsWeb &&
    //       showLoginWithEmail == false &&
    //       showLoginWithPhoneNumber == false) {
    //     String redirectUrl = "";
    //     if (defaultTargetPlatform == TargetPlatform.iOS) {
    //       redirectUrl = appStoreUrl;
    //     } else if (defaultTargetPlatform == TargetPlatform.android) {
    //       redirectUrl = playStoreUrl;
    //     }
    //     AwesomeDialog(
    //       context: context,
    //       dialogType: DialogType.question,
    //       animType: AnimType.scale,
    //       title: 'Do you want to download our mobile app'.tr(),
    //       // desc: ''.tr(),
    //       btnOkText: "Yes".tr(),
    //       btnOkColor: Colors.blueAccent,
    //       btnOkOnPress: () {
    //         launch(redirectUrl);
    //         Navigator.pop(context);
    //       },
    //       btnCancelText: "No".tr(),
    //       btnCancelColor: Colors.blueAccent,
    //       btnCancelOnPress: () {
    //         Navigator.pop(context);
    //       },
    //     ).show();
    //   }
    // });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (isSignedIn) {
        // Navigate to Volunteering Bottom Navigation
        // if (!mounted)
        //   return;
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const BottomNavIcons(),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? 600.0 : double.infinity,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 16, right: 16),
                    child: Container(
                      color: Colors.white,
                      child: FadeTransition(
                        opacity: _animation,
                        child: Center(
                            child: Image.asset(
                                'assets/images/senzepact_slogan.png',
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black26, width: 1),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    elevation: 7,
                    child: showLoginWithPhoneNumber == false &&
                            showLoginWithEmail == false
                        ? SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Text(
                                    'Existing User'.tr(),
                                    style: TextStyle(
                                        color: Colors.indigo[900],
                                        fontSize: 18,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 50,
                                    width: 300,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextButton(
                                      onPressed: () => setState(() {
                                        showLoginWithEmail = true;
                                        showLoginWithPhoneNumber = false;
                                      }),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                12.0, 0.0, 12.0, 0.0),
                                            child: Icon(
                                              Icons.email,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Login with Email'.tr(),
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 8.0, 8.0, 24.0),
                                  child: Container(
                                    height: 50,
                                    width: 300,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextButton(
                                      onPressed: () => setState(() {
                                        showLoginWithEmail = false;
                                        showLoginWithPhoneNumber = true;
                                      }),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                12.0, 0.0, 12.0, 0.0),
                                            child: Icon(
                                              Icons.phone,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Login with Phone Number'.tr(),
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : showLoginWithEmail == true
                            ? Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text(
                                      'Existing User'.tr(),
                                      style: TextStyle(
                                          color: Colors.indigo[900],
                                          fontSize: 18,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 15,
                                        bottom: 0),
                                    child: TextField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Email'.tr(),
                                        hintText: '',
                                        prefixIcon:
                                            const Icon(Icons.email, size: 24),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 15,
                                        bottom: 0),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Password'.tr(),
                                        hintText: '',
                                        prefixIcon: const Icon(
                                            Icons.lock_rounded,
                                            size: 24),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 4, 0),
                                          child: GestureDetector(
                                            onTap: _toggle,
                                            child: Icon(
                                              _obscureText
                                                  ? Icons.visibility_rounded
                                                  : Icons
                                                      .visibility_off_rounded,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: 250,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextButton(
                                      onPressed: () => login(
                                          emailController.text,
                                          passwordController.text),
                                      child: Text(
                                        'Login'.tr(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showLoginWithEmail = false;
                                        showLoginWithPhoneNumber = true;
                                      });
                                    },
                                    child: Text(
                                      'LOGIN WITH PHONE NUMBER'.tr(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 15),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ForgotPasswordScreen()));
                                    },
                                    child: Text(
                                      'FORGOT PASSWORD'.tr(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 15),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text(
                                      'Existing User'.tr(),
                                      style: TextStyle(
                                          color: Colors.indigo[900],
                                          fontSize: 18,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 15,
                                        bottom: 0),
                                    child: TextField(
                                        controller: phonenumberController,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: 'PHONE NUMBER'.tr(),
                                          hintText: '',
                                          prefixIcon:
                                              const Icon(Icons.phone, size: 24),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(8),
                                        ]),
                                  ),
                                  sendCode == true
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 20.0,
                                              top: 15,
                                              bottom: 0),
                                          child: TextField(
                                              controller: codeController,
                                              obscureText: _obscureText,
                                              decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(),
                                                labelText:
                                                    'Verification Code'.tr(),
                                                hintText: '',
                                                prefixIcon: const Icon(
                                                    Icons.lock_rounded,
                                                    size: 24),
                                                suffixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 4, 0),
                                                  child: GestureDetector(
                                                    onTap: _toggle,
                                                    child: Icon(
                                                      _obscureText
                                                          ? Icons
                                                              .visibility_rounded
                                                          : Icons
                                                              .visibility_off_rounded,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    6),
                                              ]),
                                        )
                                      : const Padding(
                                          padding: EdgeInsets.only(),
                                        ),
                                  sendCode == false
                                      ? Container(
                                          height: 50,
                                          width: 250,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: TextButton(
                                            onPressed: () =>
                                                verifyPhoneNumber(),
                                            child: Text(
                                              'Get Verification Code'.tr(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 50,
                                          width: 250,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: TextButton(
                                            onPressed: () =>
                                                signInWithPhoneNumber(
                                                    codeController.text),
                                            child: Text(
                                              'SUBMIT'.tr(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showLoginWithEmail = true;
                                        showLoginWithPhoneNumber = false;
                                      });
                                    },
                                    child: Text(
                                      'LOGIN WITH EMAIL ADDRESS'.tr(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(0, 20, 0, 30),
                  //   child: Text(
                  //     '-------------------- or --------------------',
                  //     style: TextStyle(color: Colors.grey, fontSize: 20),
                  //   ),
                  // ),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black26, width: 1),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    elevation: 7,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              'New User'.tr(),
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.question,
                                  animType: AnimType.scale,
                                  title: 'CREATE ACCOUNT'.tr(),
                                  desc: 'With using'.tr(),
                                  btnOkText: "With Phone Number".tr(),
                                  btnOkColor: Colors.blueAccent,
                                  btnOkOnPress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateAccountScreen(
                                                    "phone")));
                                  },
                                  btnCancelText: "With Email".tr(),
                                  btnCancelColor: Colors.blueAccent,
                                  btnCancelOnPress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateAccountScreen(
                                                    "email")));
                                  },
                                ).show(),
                              },
                              child: Text(
                                'CREATE ACCOUNT'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context1) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('ENGLISH'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('en'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text('CHINESE'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('zh'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text('MALAY'.tr()),
                                    onTap: () async {
                                      context.setLocale(const Locale('ms'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Change Language".tr()),
                            const Icon(Icons.language,
                                size: 30, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Column(
                      children: [
                        Text(
                          'For enquiries'.tr(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15, height: 0.0),
                        ),
                        GestureDetector(
                          onTap: _launchEmail,
                          child: const Text(
                            'contact@senzehub.com',
                            style: TextStyle(
                                color: Colors.blue, fontSize: 15, height: 0.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'V$version',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhoneNumber() async {
    EasyLoading.show(status: 'Loading'.tr());
    try {
      if (phonenumberController.text.length == 8) {
        FirebaseFirestore.instance
            .collection('Users')
            .where('PhoneNumber', isEqualTo: phonenumberController.text)
            .where("SignUpWithEmail", isEqualTo: false)
            .get()
            .then((userSnapshot) async => {
                  if (userSnapshot.docs.isNotEmpty)
                    {
                      EasyLoading.dismiss(),
                      EasyLoading.show(
                          status: 'Getting Verification Code...'.tr()),
                      if (kIsWeb)
                        {
                          await FirebaseAuth.instance
                              .signInWithPhoneNumber(
                                  "+65${phonenumberController.text}")
                              .then((result) => {
                                    EasyLoading.dismiss(),
                                    confirmationResult = result,
                                    setState(() {
                                      sendCode = true;
                                      confirmationResult = result;
                                    }),
                                  }),
                        }
                      else
                        {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: "+65${phonenumberController.text}",
                            verificationCompleted:
                                (PhoneAuthCredential credential) async {
                              // await FirebaseAuth.instance
                              //     .signInWithCredential(credential);
                            },
                            verificationFailed: (FirebaseAuthException e) {
                              EasyLoading.dismiss();
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: 'Error'.tr(),
                                desc: e.code,
                                btnOkOnPress: () {
                                  Navigator.of(context).pop();
                                },
                              ).show();
                              if (e.code == 'invalid-phone-number') {
                                print(
                                    'The provided phone number is not valid.');
                              }
                              // Handle other errors
                            },
                            codeSent:
                                (String verificationId, int? resendToken) {
                              EasyLoading.dismiss();
                              setState(() {
                                sendCode = true;
                              });
                              verificationReceived = verificationId;
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {
                              print('Code auto retrieval timeout');
                            },
                          )
                        }
                    }
                  else
                    {
                      EasyLoading.dismiss(),
                      dialog(
                          DialogType.error,
                          'Error'.tr() + " 300",
                          'Make sure you have created account with Phone Number'
                              .tr())
                      // AwesomeDialog(
                      //   context: context,
                      //   dialogType: DialogType.error,
                      //   animType: AnimType.bottomSlide,
                      //   title: 'Error'.tr(),
                      //   desc:
                      //       'Phone number does not exists in our records, kindly proceed to create account with phone number'
                      //           .tr(),
                      //   btnOkOnPress: () {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) => const LoginScreen()));
                      //   },
                      // ).show()
                    }
                });
      } else {
        EasyLoading.dismiss();
        dialog(
            DialogType.error, 'Error'.tr(), 'Invalid Phone Number Length'.tr());
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      setState(() {
        sendCode = false;
      });
      print('Error sending SMS verification code: $e');
      if (e.code == "invalid-verification-id") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else if (e.code == "code-expired") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'The verification code has expired. Please try again.'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else if (e.code == "invalid-verification-code") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: e.code,
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> signInWithPhoneNumber(String codeEntered) async {
    EasyLoading.show(status: 'Loading...'.tr());

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await confirmationResult.confirm(codeEntered);
        print(userCredential);
        print(userCredential.user);
      } else {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationReceived,
          smsCode: codeEntered,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        // Get user details (uid, name, orgID)
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get()
            .then((profile) async => {
                  if (profile.exists)
                    {
                      if (profile.data()!['Role'] != null)
                        {
                          FirebaseFirestore.instance
                              .collection('RoleList')
                              .doc(profile.data()!['Role'])
                              .get()
                              .then((roleDetails) async => {
                                    // print("OrganizationId: " +
                                    //     roleDetails
                                    //         .data()!['OrganizationId']),
                                    await setUser(
                                        user.uid,
                                        profile.data()!['Name'],
                                        roleDetails.data()!['OrganizationId'] !=
                                                null
                                            ? roleDetails
                                                .data()!['OrganizationId']
                                            : "",
                                        profile.data()!['Role'] != null
                                            ? profile.data()!['Role']
                                            : ""),
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(user.uid)
                                        .update({
                                      'OrganizationId':
                                          roleDetails.data()!['OrganizationId']
                                    }),
                                    if (profile.data()!['TotalPointEarned'] ==
                                        null)
                                      {
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(user.uid)
                                            .update({'TotalPointEarned': 0}),
                                      }
                                  }),
                        }
                      else
                        {
                          await setUser(
                              user.uid, profile.data()!['Name'], "", ""),
                          if (profile.data()!['TotalPointEarned'] == null)
                            {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .update({'TotalPointEarned': 0}),
                            }
                        },
                    }
                });

        // Update fcm token
        var fcmToken;
        if (!kIsWeb) {
          //   fcmToken = await FirebaseMessaging.instance
          //       .getToken(vapidKey: "BKb0TA6SP2efD29Swhk9MfAmJUi3sYrwCBQLiJ2K6S3e7kkBG8HQVC_DRlnKBW5VqyjPkD2YVwTp6q8glw3QWTc");
          // } else {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }

        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({'LastLoginAt': DateTime.now(), 'FcmToken': fcmToken});

        // Update log history
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('LogHistory')
            .add({
          'CreatedAt': DateTime.now(),
          'From': 'Mobile',
          'Action': 'Login'
        });

        // Update FCM in senior's caregiver list
        var collection = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection("ElderlyUnderCare");
        var querySnapshot = await collection.get();
        for (var queryDocumentSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data = queryDocumentSnapshot.data();

          FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
              .collection('Users')
              .doc(data['Uid'])
              .collection('CaregiversList')
              .where("Uid", isEqualTo: user.uid)
              .get()
              .then((value) => {
                    if (value.docs.isNotEmpty)
                      {
                        FirebaseFirestore.instanceFor(
                                app: Firebase.app("secondary"))
                            .collection('Users')
                            .doc(data['Uid'])
                            .collection('CaregiversList')
                            .doc(value.docs.first.id)
                            .update({'FcmToken': fcmToken})
                      }
                  });
        }
        EasyLoading.dismiss();

        // Navigate to Volunteering Bottom Navigation
        if (!mounted) return;
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const BottomNavIcons(),
        );
      }
      setState(() {
        sendCode = false;
      });
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      setState(() {
        sendCode = false;
      });
      if (e.code == "invalid-verification-id") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else if (e.code == "code-expired") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'The verification code has expired. Please try again.'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else if (e.code == "invalid-verification-code") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: e.code,
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      print('Error signing in with SMS code: $e');
    }
  }
}

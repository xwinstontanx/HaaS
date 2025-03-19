import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import '../Responsive/FormFactor.dart';
import 'package:http/http.dart' as http;

class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({Key? key}) : super(key: key);

  @override
  State<PaymentDemoPage> createState() => _PaymentDemoState();
}

class _PaymentDemoState extends State<PaymentDemoPage> {
  String url = ''; // Initialize with an empty URL

  var userUid = "";
  var userName = "";
  var userEmail = "";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        // print(user.uid);
        print('User is signed in!');
        await getUser();
        setState(() {
          userEmail = user.email ?? "";
        });
        createPayment(); //PaymentDemo
      }
    });
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  void createPayment() async {
    final name = userName;
    final email = userEmail;
    final userID = userUid;
    final itemID = 'itemID'; // Replace with ItemID
    final combinedString = userID + "_" + itemID;
    print(combinedString);
    final redirectUrl =
        'https://asia-southeast1-senzepact.cloudfunctions.net/SenzePactApiForHitPayPayment/api/paymentStatus';
    final keyId = 'keyID'; // Replace with keyID
    final amount = '3.00'; // Replace with your desired amount

    final postData =
        'name=$name&email=$email&send_email=true&redirect_url=${Uri.encodeComponent(redirectUrl)}&reference_number=$keyId&purpose=$combinedString&currency=SGD&amount=$amount';

    final apiKey =
        '026812624f4590fda7953c0d72d53065d345f25711bee6c6ebbe86231259077a';

    final headers = {
      'X-BUSINESS-API-KEY': apiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
    };

    final response = await http.post(
      Uri.parse('https://api.hit-pay.com/v1/payment-requests'),
      headers: headers,
      body: postData,
    );
    // print('Response status code: ${response.statusCode}');
    // print('Response body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        url = data['url'];
      });
      print('url');
      print(url);
    } else {
      throw Exception('Failed to fetch URL');
    }
  }

  void openUrlInWebViewOrLaunchBrowser() {
    if (kIsWeb) {
      // Running on the web, open the URL using the launch function
      launch(url);
    } else {
      // Running on mobile, open the URL in a WebView
      // FIXME: WK disable this due to conflict of library
      // WebView(
      //   initialUrl: url,
      //   javascriptMode: JavascriptMode.unrestricted,
      //   onWebResourceError: (error) {
      //     print('WebView error: ${error.description}');
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PaymentDemo Example'),
      ),
      // FIXME: WK disable this due to conflict of library
      // body: url.isNotEmpty
      //     ? Center(
      //         child: WebView(
      //           initialUrl: url,
      //           javascriptMode: JavascriptMode.unrestricted,
      //           onWebResourceError: (error) {
      //             print('WebView error: ${error.description}');
      //           },
      //         ),
      //       )
      //     : Center(child: CircularProgressIndicator()),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:senzepact/src/screens/Home/TotalPointEarned/PointEarnedHistory.dart';
import 'package:senzepact/src/screens/Home/TotalPointEarned/Redemption.dart';
import 'package:senzepact/src/screens/homefuture.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../BottomNavIcons.dart';

class PointEarnedPage extends StatefulWidget {
  const PointEarnedPage({Key? key}) : super(key: key);

  @override
  State<PointEarnedPage> createState() => _PointEarnedPage();
}

class _PointEarnedPage extends State<PointEarnedPage> {
  late double _responsiveCoefficient;

  var userUid = "";
  var userName = "";

  var totalPointEarned = "0";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getTotalPointEarned();
  }

  Future<void> getTotalPointEarned() async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .get()
        .then((profile) async => {
              if (profile.exists)
                {
                  setState(() {
                    totalPointEarned =
                        profile.data()!['TotalPointEarned'].toString();
                  }),
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

  @override
  Widget build(BuildContext context) {
    _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) *
        sqrt(MediaQuery.of(context).size.height);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const BottomNavIcons(),
                  )
                }),
        title: Text("POINT EARNED".tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PointEarnedHistoryPage()));
            },
            color: Colors.white,
          )
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                int.parse(totalPointEarned!) > 0
                    ? Text(
                        "Congratulation, ".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _responsiveCoefficient / pow(4.5, 2),
                          color: Colors.blueAccent,
                        ),
                      )
                    : Text(
                        "Keep it up, ".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _responsiveCoefficient / pow(4.5, 2),
                          color: Colors.blueAccent,
                        ),
                      ),
                Text(
                  "you have collected:".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveCoefficient / pow(4.5, 2),
                    color: Colors.blueAccent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    totalPointEarned,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _responsiveCoefficient / pow(3.5, 2),
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Text(
                  "points".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveCoefficient / pow(4.5, 2),
                    color: Colors.blueAccent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 8.0),
                  child: Text(
                    "Points can be collected by participating in quizzes and games. Higher points will give you higher chance to win in lucky draw"
                        .tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _responsiveCoefficient / pow(6.5, 2),
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => RedemptionPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('I want redeem item'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

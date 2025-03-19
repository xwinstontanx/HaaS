import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyDrawIndividualPage extends StatefulWidget {
  final String luckyDrawId;
  final Timestamp startDateTime;
  final Timestamp endDateTime;

  const LuckyDrawIndividualPage(
      this.luckyDrawId, this.startDateTime, this.endDateTime,
      {super.key});

  @override
  State<LuckyDrawIndividualPage> createState() =>
      _LuckyDrawIndividualPage();
}

class _LuckyDrawIndividualPage
    extends State<LuckyDrawIndividualPage> {
  late double _responsiveCoefficient;

  var userUid = "";
  var userName = "";

  var totalPointEligible = "0";

  var luckyDrawResult = "Coming Soon";
  var luckyDrawShowResult = false;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getTotalPointEligible();
    await getLuckyDrawResult();
  }

  Future<void> getTotalPointEligible() async {
    DateTime startDateTime = widget.startDateTime.toDate();
    DateTime endDateTime = widget.endDateTime.toDate();

    int eligiblePoints = 0;
    //QuizHistory
    var quizHistoryRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('QuizHistory')
        .where('CreatedAt', isGreaterThanOrEqualTo: startDateTime)
        .where('CreatedAt', isLessThanOrEqualTo: endDateTime);
    var quizHistorySnapshot = await quizHistoryRef.get();
    for (var quizDoc in quizHistorySnapshot.docs) {
      var quizData = quizDoc.data();

      if (quizData['PointEarned'] != null) {
        setState(() {
          eligiblePoints += int.parse(quizData['PointEarned']);
          totalPointEligible = eligiblePoints.toString();
        });
      }
    }

    //GamesHistory
    var gamesHistoryRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('GamesHistory')
        .where('CreatedAt', isGreaterThanOrEqualTo: startDateTime)
        .where('CreatedAt', isLessThanOrEqualTo: endDateTime);
    var gamesHistorySnapshot = await gamesHistoryRef.get();
    for (var gamesDoc in gamesHistorySnapshot.docs) {
      var gamesData = gamesDoc.data();

      if (gamesData['PointEarned'] != null) {
        setState(() {
          eligiblePoints += int.parse(gamesData['PointEarned']);
          totalPointEligible = eligiblePoints.toString();
        });
      }
    }

    // setState(() {
    //   totalPointEligible = eligiblePoints.toString();
    // });
  }

  Future<void> getLuckyDrawResult() async {
    FirebaseFirestore.instance
        .collection('LuckyDraw')
        .doc(widget.luckyDrawId)
        .get()
        .then((luckyDrawData) async => {
              if (luckyDrawData.exists)
                {
                  if (luckyDrawData.data()!.containsKey('Result'))
                    {
                      processResult(luckyDrawData.data()!['Result']),
                      // setState(() {
                      //   luckyDrawResult =
                      //       luckyDrawData.data()!['Result'].toString();
                      // }),
                    },

                  if (luckyDrawData.data()!.containsKey('ShowResult'))
                    {
                      setState(() {
                        luckyDrawShowResult =
                            luckyDrawData.data()!['ShowResult'];
                      }),
                    }
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
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Lucky Draw".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: boxDecoration(Colors.blue),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
                              child: Text(
                                "Prizes".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _responsiveCoefficient / pow(4.5, 2),
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              "(worth more than SGD250)".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _responsiveCoefficient / pow(6.0, 2),
                                color: Colors.blueAccent,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/prizes.png'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: boxDecoration(Colors.blue),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
                              child: Text(
                                "Your Chance(s)".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _responsiveCoefficient / pow(4.5, 2),
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            int.parse(totalPointEligible!) > 0
                                ? Text(
                                    "Congratulation, ".tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          _responsiveCoefficient / pow(5.5, 2),
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                : Text(
                                    "Keep it up, ".tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          _responsiveCoefficient / pow(5.5, 2),
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                            Text(
                              "you have collected:".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _responsiveCoefficient / pow(5.5, 2),
                                color: Colors.blueAccent,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                totalPointEligible,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _responsiveCoefficient / pow(4.5, 2),
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            Text(
                              "eligible point(s)".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _responsiveCoefficient / pow(5.5, 2),
                                color: Colors.blueAccent,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                              child: Text(
                                "Points can be accumulated by participating in quizzes and games from 10 Jun 2023 12:00am to 11 Jun 2023 3:00pm. 1 point is entitled to 1 lucky draw chance. "
                                    .tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _responsiveCoefficient / pow(6.5, 2),
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: boxDecoration(Colors.blue),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 10.0, 8.0, 8.0),
                              child: Text(
                                "Result".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      _responsiveCoefficient / pow(4.5, 2),
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: luckyDrawShowResult
                                  ? Text(
                                      luckyDrawResult,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _responsiveCoefficient /
                                            pow(6.5, 2),
                                        color: Colors.blueAccent,
                                      ),
                                    )
                                  : Text(
                                      "Lucky draw result will be announced by emcee around 3pm and you can check the result from the app. Prize can be claimed on the spot or collect from CC on Monday during office hours."
                                          .tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _responsiveCoefficient /
                                            pow(6.5, 2),
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                            ),
                          ],
                        ),
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

  BoxDecoration boxDecoration(Color color) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: color,
        width: 2,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }

  processResult(result) {
    List<String> name = result.split('"Name":"');
    List<String> first = name[1].split('"}');
    List<String> second = name[2].split('"}');
    List<String> third = name[3].split('"}');

    String prize = "";

    if (first.isNotEmpty) {
      prize = "Redmi A1: ${first[0]}\n";
    }
    if (second.isNotEmpty) {
      prize = "${prize}Contour Plus One: ${second[0]}\n";
    }

    if (third.isNotEmpty) {
      prize = "${prize}Contour Plus One: ${third[0]}\n";
    }

    setState(() {
      luckyDrawResult = prize;
    });
  }
}

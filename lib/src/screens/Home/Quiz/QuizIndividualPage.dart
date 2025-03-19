import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Responsive/FormFactor.dart';
import 'QuizPage.dart';
import 'QuizResultPage.dart';

class QuizIndividualPage extends StatefulWidget {
  final String quizId;

  const QuizIndividualPage(this.quizId, {super.key});

  @override
  State<QuizIndividualPage> createState() =>
      _QuizIndividualPageState();
}

class _QuizIndividualPageState
    extends State<QuizIndividualPage> {
  var userUid = "";
  var userName = "";
  var userAttemptedMsg = "";
  var userChoicesList = [];
  int totalCorrect = 0;
  var quizList = [];
  String quizTitle = "";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getQuizData();
    await checkUserAttempted();
  }

  Future<void> checkUserAttempted() async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('QuizHistory')
        .where('QuizId', isEqualTo: widget.quizId)
        .get()
        .then((quizSnapshot) => {
              for (var queryDocumentSnapshot in quizSnapshot.docs)
                {
                  if (queryDocumentSnapshot.exists)
                    {
                      // if (quizSnapshot.size >=
                      //     int.parse(quizList[0]['data']['NumberOfAttempts']))
                      //   {
                          setState(() {
                            userChoicesList =
                                queryDocumentSnapshot.data()['UserChoices'];
                            totalCorrect = int.parse(
                                queryDocumentSnapshot.data()['Score']);
                            userAttemptedMsg =
                                "You had attempted this quiz".tr();
                          }),
                        // }
                    }
                }

              // print(quizSnapshot.size),
              // print(quizList),
              // print(int.parse(quizList[0]['data']['NumberOfAttempts'])),
              // // if (quizSnapshot.size ==
              // //     int.parse(quizList[0]['data']['NumberOfAttempts']))
              // if (quizSnapshot.size ==
              //     int.parse(quizList[0]['data']['NumberOfAttempts']))
              //   {
              //     setState(() {
              //       userAttemptedMsg = "You had attempted this quiz".tr();
              //     }),
              //     for (var queryDocumentSnapshot in quizSnapshot.docs)
              //       {
              //         setState(() {
              //           userChoicesList =
              //           queryDocumentSnapshot.data()['UserChoices'];
              //           totalCorrect = queryDocumentSnapshot.data()['Score'];
              //         }),
              //       }
              //   }
            });
  }

  Future<void> getQuizData() async {
    FirebaseFirestore.instance
        .collection('Quiz')
        .doc(widget.quizId)
        .get()
        .then((quizSnapshot) => {
              quizList = [],
              if (quizSnapshot.exists)
                {
                  setState(() {
                    quizList.add({
                      'docID': quizSnapshot.id,
                      'data': quizSnapshot.data(),
                    });
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title:
            Text(quizList.isNotEmpty ? quizList[0]['data']['QuizTitle'] : ""),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Text(
                    //   quizList.isNotEmpty
                    //       ? 'Welcome to '.tr() + quizList[0]['data']['QuizTitle']
                    //       : "",
                    //   textAlign: TextAlign.center,
                    //   style: const TextStyle(
                    //       fontSize: 25,
                    //       color: Colors.blueAccent,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
                      child: Text(
                        quizList.isNotEmpty
                            ? 'There will be '.tr() +
                                quizList[0]['data']['NumberOfQuestions'] +
                                ' Multiple-Choice Questions in this quiz'.tr()
                            : "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    userAttemptedMsg == ""
                        ? Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        QuizPage(quizList[0]['docID'])))
                              },
                              child: Text(
                                'Start'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 30.0, 0.0, 30.0),
                                  child: Text(
                                    " ** $userAttemptedMsg ** ",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 250,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20)),
                                child: TextButton(
                                  onPressed: () => {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                QuizResultPage(
                                                    widget.quizId,
                                                    userChoicesList,
                                                    totalCorrect,
                                                    true)))
                                  },
                                  child: Text(
                                    'View Attempted Result'.tr(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

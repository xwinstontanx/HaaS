import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../Responsive/FormFactor.dart';
import 'QuizResultPage.dart';

class QuizPage extends StatefulWidget {
  final String quizId;

  const QuizPage(this.quizId, {super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  var userUid = "";
  var userName = "";
  var quizList = [];

  List<Map<String, dynamic>> questionsList = [];
  var answersList = [];
  var userChoicesList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getQuizData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
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
                  for (var i = 1;
                      i <= int.parse(quizList[0]['data']['NumberOfQuestions']);
                      i++)
                    {
                      questionsList.add({
                        'Question': quizSnapshot.data()!['Question$i'],
                        'Options': quizSnapshot.data()!['Question$i' 'Options']
                      }),
                      answersList
                          .add(quizSnapshot.data()!['Question$i' 'Answer']),
                      userChoicesList.add(null)
                    }
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text(
              quizList.isNotEmpty ? '${quizList[0]['data']['QuizTitle']}' : ""),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Answer all the questions carefully before submitting'
                            .tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Ink(
                        color: Colors.blue[50],
                        child: ListView.builder(
                          itemCount: questionsList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 0.0, 4.0, 0.0),
                                  child: Text(
                                    '${index + 1}. ${'${questionsList[index]['Question']}'.tr()}',
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount:
                                      questionsList[index]['Options'].length,
                                  itemBuilder: (context, optionIndex) {
                                    return RadioListTile<String>(
                                      title: Text(questionsList[index]
                                              ['Options'][optionIndex]
                                          .toString()
                                          .tr()),
                                      value: questionsList[index]['Options']
                                          [optionIndex],
                                      groupValue: userChoicesList[index],
                                      onChanged: (String? value) {
                                        setState(() {
                                          userChoicesList[index] = value!;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                            ));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () => SubmitAnswers(),
                          child: Text(
                            'SUBMIT'.tr(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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

  Future<void> SubmitAnswers() async {
    bool containsNull = userChoicesList.contains(null);
    if (containsNull == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.bottomSlide,
        desc: 'Proceed to submit?'.tr(),
        btnOkOnPress: () {
          int totalCorrect = 0;
          for (var i = 0; i < answersList.length; i++) {
            if (userChoicesList[i] == answersList[i]) {
              totalCorrect = totalCorrect + 1;
            }
          }
          FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .get()
              .then((profile) async => {
                    if (profile.exists)
                      {
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userUid)
                            .update({
                          'TotalPointEarned':
                              profile.data()!['TotalPointEarned'] + 1
                        }),
                      }
                  })
              .then((value) => FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userUid)
                      .collection("QuizHistory")
                      .add({
                    'CreatedAt': DateTime.now(),
                    'UserChoices': userChoicesList,
                    'Score': totalCorrect.toString(),
                    'QuizId': widget.quizId,
                    'PointEarned': "1"
                  }).then(
                    (value) => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Result".tr()),
                            content: Text(
                                "${"You got ".tr()}$totalCorrect correct answer(s)"),
                            actions: [
                              TextButton(
                                child: Text("Ok".tr()),
                                onPressed: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => QuizResultPage(
                                          widget.quizId,
                                          userChoicesList,
                                          totalCorrect,
                                          false)));
                                },
                              )
                            ],
                          );
                        }),
                  ));
        },
        btnCancelOnPress: () {},
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Error'.tr(),
        desc: 'Please answer all the questions'.tr(),
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
      ).show();
    }
  }
}

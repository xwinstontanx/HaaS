import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Responsive/FormFactor.dart';

class QuizResultPage extends StatefulWidget {
  final String quizId;
  final List userChoicesList;
  final int totalCorrect;
  final bool viewPastResult;

  const QuizResultPage(
      this.quizId, this.userChoicesList, this.totalCorrect, this.viewPastResult,
      {super.key});

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  var userUid = "";
  var userName = "";
  var quizList = [];
  var viewPastResult = false;

  List<Map<String, dynamic>> questionsList = [];
  var answersList = [];
  var userChoicesList = [];
  var resultList = [];

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
                        'Options': quizSnapshot.data()!['Question$i' 'Options'],
                        'Result': quizSnapshot.data()!['Question$i' 'Answer']
                      }),
                      if (widget.userChoicesList[i - 1] ==
                          quizSnapshot.data()!['Question$i' 'Answer'])
                        {
                          resultList.add(
                              "You have answered this question correctly:" +
                                  quizSnapshot.data()!['Question$i' 'Answer'])
                        },
                      if (widget.userChoicesList[i - 1] !=
                          quizSnapshot.data()!['Question$i' 'Answer'])
                        {
                          resultList
                              .add(quizSnapshot.data()!['Question$i' 'Answer'])
                        },
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
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Result'.tr(),
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
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
                              padding:
                                  const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                              child: Text(
                                '${index + 1}. ${'${questionsList[index]['Question']}'.tr()}',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: questionsList[index]['Options'].length,
                              itemBuilder: (context, optionIndex) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 6.0, 0, 0.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12.0, 0, 12.0, 0),
                                        child: Icon(widget
                                                    .userChoicesList[index].toString()
                                            .tr() ==
                                                questionsList[index]['Options']
                                                        [optionIndex]
                                                    .toString()
                                                    .tr()
                                            ? Icons.circle
                                            : Icons.circle_outlined),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              questionsList[index]['Options']
                                                      [optionIndex]
                                                  .toString()
                                                  .tr(),
                                              style: TextStyle(
                                                  color: questionsList[index]['Result']
                                                              .toString()
                                                              .tr() ==
                                                          questionsList[index]
                                                                      ['Options']
                                                                  [optionIndex]
                                                              .toString()
                                                              .tr()
                                                      ? Colors.green
                                                      : ((widget.userChoicesList[index].toString()
                                                      .tr() ==
                                                                  questionsList[index]
                                                                              ['Options']
                                                                          [
                                                                          optionIndex]
                                                                      .toString()
                                                                      .tr()) &&
                                                              (widget.userChoicesList[
                                                                      index].toString()
                                                                  .tr() !=
                                                                  questionsList[index]
                                                                          ['Result']
                                                                      .toString()
                                                                      .tr()))
                                                          ? Colors.red
                                                          : Colors.black),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
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
                      onPressed: () => BacktoQuizPage(),
                      child: Text(
                        'Ok'.tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
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

  Future<void> BacktoQuizPage() async {
    int count = 0;
    if (widget.viewPastResult) {
      Navigator.pop(context);
    } else {
      Navigator.popUntil(context, (route) {
        return count++ == 4;
      });
    }
  }
}

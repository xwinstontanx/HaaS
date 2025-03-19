import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/Quiz/QuizIndividualPage.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainQuizPage extends StatefulWidget {
  const MainQuizPage({Key? key}) : super(key: key);

  @override
  State<MainQuizPage> createState() => _MainQuizPageState();
}

class _MainQuizPageState extends State<MainQuizPage> {
  var userUid = "";
  var userName = "";
  var quizList = [];

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
    DateTime currentDateTime;
    FirebaseFirestore.instance
        .collection('Quiz')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((quizSnapshot) => {
              quizList = [],
              if (quizSnapshot.docs.isNotEmpty)
                {
                  currentDateTime = DateTime.now(),
                  for (var qEvents in quizSnapshot.docs)
                    {
                      if (qEvents.data()["Display"] == "yes")
                        {
                          if ((qEvents
                                      .data()["StartDateTime"]
                                      .toDate()
                                      .isBefore(currentDateTime) &&
                                  qEvents
                                      .data()["EndDateTime"]
                                      .toDate()
                                      .isAfter(currentDateTime)) ||
                              (qEvents
                                      .data()["StartDateTime"]
                                      .toDate()
                                      .isAtSameMomentAs(currentDateTime) &&
                                  qEvents
                                      .data()["EndDateTime"]
                                      .toDate()
                                      .isAtSameMomentAs(currentDateTime)))
                            {
                              setState(() {
                                quizList.add({
                                  'docID': qEvents.id,
                                  'data': qEvents.data(),
                                });
                              })
                            }
                        }
                    }
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("Quizzes".tr()),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                    physics: const ScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: kIsWeb ? 0.8 : 0.8,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      ...quizList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          //apply padding to all four sides
                          child: Container(
                            decoration: boxDecoration(Colors.blue),
                            child: InkWell(
                              splashColor: Colors.green,
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            QuizIndividualPage(item['docID'])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    const Icon(Icons.quiz,
                                        color: Colors.blueAccent, size: 50.0),
                                    Text(
                                        item['data']['QuizTitle'].toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    // Text(
                                    //     "${"Available until".tr()}: ${DateFormat('d MMM yyyy (EEE) h:mm a').format(item['data']['EndDateTime'].toDate())}",
                                    //     textAlign: TextAlign.center,
                                    //     style: const TextStyle(
                                    //         color: Colors.blue,
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ]),
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
}

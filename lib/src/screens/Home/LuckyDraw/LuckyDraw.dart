import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/LuckyDraw/LuckyDrawIndividual.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyDraw extends StatefulWidget {
  const LuckyDraw({Key? key}) : super(key: key);

  @override
  State<LuckyDraw> createState() => _LuckyDraw();
}

class _LuckyDraw extends State<LuckyDraw> {
  var userUid = "";
  var userName = "";
  var luckyDrawList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getLuckyDrawData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  Future<void> getLuckyDrawData() async {
    DateTime currentDateTime;
    FirebaseFirestore.instance
        .collection('LuckyDraw')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((luckyDrawSnapshot) => {
              luckyDrawList = [],
              if (luckyDrawSnapshot.docs.isNotEmpty)
                {
                  currentDateTime = DateTime.now(),
                  for (var ldEvents in luckyDrawSnapshot.docs)
                    {
                      if (ldEvents.data()["Display"] == "yes")
                        {
                          // if ((ldEvents
                          //             .data()["StartDateTime"]
                          //             .toDate()
                          //             .isBefore(currentDateTime) &&
                          //         ldEvents
                          //             .data()["EndDateTime"]
                          //             .toDate()
                          //             .isAfter(currentDateTime)) ||
                          //     (ldEvents
                          //             .data()["StartDateTime"]
                          //             .toDate()
                          //             .isAtSameMomentAs(currentDateTime) &&
                          //         ldEvents
                          //             .data()["EndDateTime"]
                          //             .toDate()
                          //             .isAtSameMomentAs(currentDateTime)))
                          // {
                          setState(() {
                            luckyDrawList.add({
                              'docID': ldEvents.id,
                              'data': ldEvents.data(),
                            });
                          })
                          // }
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
          title: Text("Lucky Draw".tr()),
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
                    childAspectRatio: kIsWeb? 0.6: 0.6,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      ...luckyDrawList.map((item) {
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
                                            LuckyDrawIndividualPage(
                                                item['docID'],
                                                item['data']['StartDateTime'],
                                                item['data']['EndDateTime'])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    const Icon(Icons.event,
                                        color: Colors.blueAccent, size: 50.0),
                                    Text(
                                        item['data']['LuckyDrawTitle']
                                            .toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        " ${DateFormat('d MMM yyyy (EEE) h:mm a').format(item['data']['StartDateTime'].toDate())} - ${DateFormat('d MMM yyyy (EEE) h:mm a').format(item['data']['EndDateTime'].toDate())}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
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

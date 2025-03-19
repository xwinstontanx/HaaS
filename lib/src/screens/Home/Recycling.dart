import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/PaymentDemo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Responsive/FormFactor.dart';

class RecyclingPage extends StatefulWidget {
  const RecyclingPage({Key? key}) : super(key: key);

  @override
  State<RecyclingPage> createState() => _RecyclingPageState();
}

class _RecyclingPageState extends State<RecyclingPage> {
  var userUid = "";
  var userName = "";
  var recyclingList = [];

  // Group Value for Radio Button.
  int id = 1;
  int selectedDate = 0;
  int selectedTime = 0;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getRecyclingData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  Future<void> getRecyclingData() async {
    FirebaseFirestore.instance
        .collection('Recycling')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((recyclingSnapshot) => {
              recyclingList = [],
              if (recyclingSnapshot.docs.isNotEmpty)
                {
                  for (var rEvents in recyclingSnapshot.docs)
                    {
                      if (rEvents.data()["Display"] == "yes")
                        {
                          setState(() {
                            recyclingList.add({
                              'docID': rEvents.id,
                              'data': rEvents.data(),
                            });
                          })
                        }
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
        title: Text("RECYCLING".tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // IconButton(
          //     icon: Icon(Icons.help),
          //     onPressed: () {
          //       Navigator.of(context, rootNavigator: true).push(
          //           MaterialPageRoute(builder: (context) => PaymentDemoPage()));
          //     }),
        ],
      ),
      body: recyclingList.isEmpty
          ? Center(
              child: Text(
                'Coming Soon'.tr(),
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
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
                          ...recyclingList.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              //apply padding to all four sides
                              child: Container(
                                decoration: boxDecoration(Colors.blue),
                                child: InkWell(
                                  splashColor: Colors.green,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Center(
                                                        child: Text(
                                                            item['data']
                                                                ['ItemName'],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, null);
                                                    },
                                                    child: Text('CANCEL'.tr()),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('OK'.tr()),
                                                  ),
                                                ],
                                                content: SizedBox(
                                                  width: double.minPositive,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            boxDecoration(
                                                                Colors.orange),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Column(
                                                            children: [
                                                              const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                      width: 5),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child: Image(
                                                                  image:
                                                                      NetworkImage(
                                                                    item['data']
                                                                        [
                                                                        'FilePath'],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            boxDecoration(
                                                                Colors.green),
                                                        child: const Row(
                                                          children: [
                                                            Flexible(
                                                              child: Center(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Text(
                                                                      'Contact George 9647 5422 if you know someone who needs item(s) as shown Self pick-up from donor, or transport to be arranged.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .green,
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Image.network(item['data']['FilePath'],
                                            height: 55, fit: BoxFit.fill),
                                        Text(
                                            item['data']['ItemName']
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "Available as of \n${DateFormat('d MMM yyyy (EEE) h:mm a').format(item['data']['CreatedAt'].toDate())}",
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

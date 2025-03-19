import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/TotalPointEarned/PointEarned.dart';
import 'package:senzepact/src/screens/Home/TotalPointEarned/RedemptionHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Responsive/FormFactor.dart';
import 'package:email_sender/email_sender.dart';

class RedemptionPage extends StatefulWidget {
  const RedemptionPage({Key? key}) : super(key: key);

  @override
  State<RedemptionPage> createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  var userUid = "";
  var userName = "";
  var userPhoneNumber = "";
  var redemptionList = [];
  var totalPointEarned = 0;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getRedemptionData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .get()
        .then((data) {
      setState(() {
        totalPointEarned = data['TotalPointEarned'];
        userPhoneNumber = data['PhoneNumber'];
      });
    });
  }

  Future<void> getRedemptionData() async {
    FirebaseFirestore.instance
        .collection('RedemptionItems')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((redemptionSnapshot) => {
              redemptionList = [],
              if (redemptionSnapshot.docs.isNotEmpty)
                {
                  for (var rEvents in redemptionSnapshot.docs)
                    {
                      if (rEvents.data()["Display"] == "yes")
                        {
                          setState(() {
                            redemptionList.add({
                              'docID': rEvents.id,
                              'data': rEvents.data(),
                            });
                          })
                        }
                    }
                }
            });
  }

  Future<void> sendMailer(String userUID, String userName,
      String userPhoneNumber, String itemId, String itemName) async {
    EmailSender emailsender = EmailSender();
    var response = await emailsender.sendMessage(
        "winston@senzehub.com",
        "SenzePact Redemption",
        userUID,
        userName +
            " " +
            userPhoneNumber +
            " " +
            itemId +
            " " +
            itemName); //title subject body
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointEarnedPage(),
                  ),
                )),
        title: Text("Redemption".tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => RedemptionHistoryPage()));
              }),
        ],
      ),
      body: redemptionList.isEmpty
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
                          ...redemptionList.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              //apply padding to all four sides
                              child: Container(
                                decoration: boxDecoration(Colors.blue),
                                child: InkWell(
                                  splashColor: Colors.green,
                                  onTap: () {
                                    if (totalPointEarned >=
                                        int.parse(
                                            item['data']['PointsNeeded'])) {
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
                                                              textAlign:
                                                                  TextAlign
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
                                                      child:
                                                          Text('CANCEL'.tr()),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Users')
                                                            .doc(userUid)
                                                            .get()
                                                            .then(
                                                                (profile) async =>
                                                                    {
                                                                      if (profile
                                                                          .exists)
                                                                        {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('Users')
                                                                              .doc(userUid)
                                                                              .update({
                                                                            'TotalPointEarned':
                                                                                profile.data()!['TotalPointEarned'] - int.parse(item['data']['PointsNeeded'])
                                                                          }),
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('Users')
                                                                              .doc(userUid)
                                                                              .collection("RedemptionHistory")
                                                                              .add({
                                                                            'CreatedAt':
                                                                                DateTime.now(),
                                                                            'ItemId':
                                                                                item['data']['ItemId'],
                                                                            'ItemName':
                                                                                item['data']['ItemName'],
                                                                            'PointsDeducted':
                                                                                item['data']['PointsNeeded'],
                                                                          })
                                                                        },
                                                                      setState(
                                                                          () {
                                                                        totalPointEarned =
                                                                            -int.parse(item['data']['PointsNeeded']);
                                                                      }),
                                                                      sendMailer(
                                                                          userUid,
                                                                          userName,
                                                                          userPhoneNumber,
                                                                          item['data']
                                                                              [
                                                                              'ItemId'],
                                                                          item['data']
                                                                              [
                                                                              'ItemName']),
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              const SnackBar(
                                                                        content:
                                                                            Text("Redeem Successfully"),
                                                                      )),
                                                                      Navigator.pop(
                                                                          context),
                                                                    });
                                                      },
                                                      child:
                                                          Text('Redeem'.tr()),
                                                    ),
                                                  ],
                                                  content: SizedBox(
                                                    width: double.minPositive,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          decoration:
                                                              boxDecoration(
                                                                  Colors.blue),
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'Point will be deducted after clicking Redeem.'
                                                                            .tr(),
                                                                        textAlign:
                                                                            TextAlign
                                                                                .justify,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue,
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 12)),
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
                                    } else {
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
                                                              textAlign:
                                                                  TextAlign
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
                                                      child:
                                                          Text('CANCEL'.tr()),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Ok'.tr()),
                                                    ),
                                                  ],
                                                  content: SizedBox(
                                                    width: double.minPositive,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          decoration:
                                                              boxDecoration(
                                                                  Colors.red),
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'Insufficient Points'
                                                                            .tr(),
                                                                        textAlign:
                                                                            TextAlign
                                                                                .justify,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 12)),
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
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        // Image.network(item['data']['FilePath'],
                                        //     height: 55, fit: BoxFit.fill),
                                        Text(
                                            item['data']['ItemName']
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                  item['data']['PointsNeeded'] +
                                                      " Points",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
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

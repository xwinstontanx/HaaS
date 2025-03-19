import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointEarnedHistory {
  String? createdAt;
  String? gameName;
  String? pointEarned;

  PointEarnedHistory({this.createdAt, this.gameName, this.pointEarned});
}

class PointEarnedHistoryPage extends StatefulWidget {
  const PointEarnedHistoryPage({Key? key}) : super(key: key);

  @override
  State<PointEarnedHistoryPage> createState() => _PointEarnedHistoryPage();
}

class _PointEarnedHistoryPage extends State<PointEarnedHistoryPage> {
  var userUid = "";
  var userName = "";

  List<PointEarnedHistory> pointEarnedHistoryList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getPointEarnedHistory();
  }

  Future<void> getPointEarnedHistory() async {
    pointEarnedHistoryList = [];
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('GamesHistory')
        //     .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) async {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        DateTime myDateTime =
            DateTime.parse(data['CreatedAt'].toDate().toString());
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        pointEarnedHistoryList.add(PointEarnedHistory(
          createdAt: formattedDateTime,
          gameName: data['GameName'].toString(),
          pointEarned: data['PointEarned'].toString(),
        ));
      }

      pointEarnedHistoryList.sort(
          (b, a) => a.createdAt.toString().compareTo(b.createdAt.toString()));
      setState(() {
        pointEarnedHistoryList = pointEarnedHistoryList;
      });
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('QuizHistory')
        .get()
        .then((querySnapshot) async {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        DateTime myDateTime = DateTime.parse(
          data['CreatedAt'].toDate().toString(),
        );
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        final quizData = await FirebaseFirestore.instance
            .collection('Quiz')
            .doc(data['QuizId'].toString())
            .get();

        if (quizData.exists) {
          pointEarnedHistoryList.add(
            PointEarnedHistory(
              createdAt: formattedDateTime,
              gameName: quizData.data()!['QuizTitle'].toString(),
              pointEarned: data['PointEarned'].toString(),
            ),
          );
        }
      }

      pointEarnedHistoryList.sort(
        (b, a) => a.createdAt.toString().compareTo(b.createdAt.toString()),
      );

      setState(() {
        pointEarnedHistoryList = pointEarnedHistoryList;
      });
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
        title: Text("POINT EARNED HISTORY".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (pointEarnedHistoryList.isNotEmpty)
                  DataTable(
                      // Datatable widget that have the property columns and rows.
                      columnSpacing: 25,
                      border: TableBorder.all(width: 1),
                      columns: [
                        DataColumn(
                            label: Flexible(
                          fit: FlexFit.tight,
                          child: Text("RECORDED AT".tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                        DataColumn(
                            label: Flexible(
                          fit: FlexFit.tight,
                          child: Text('NAME'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                        DataColumn(
                            label: Flexible(
                          fit: FlexFit.tight,
                          child: Text('Point(s)'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                      ],
                      rows: pointEarnedHistoryList
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(Center(
                                  child: Text(
                                    e.createdAt.toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                )),
                                DataCell(Text(
                                  e.gameName.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontStyle: FontStyle.normal,
                                  ),
                                )),
                                DataCell(Center(
                                  child: Text(
                                    e.pointEarned.toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          )
                          .toList()),
                if (pointEarnedHistoryList.isEmpty)
                  Center(child: Text("NO DATA AVAILABLE".tr())),
              ],
            ),
          ),
        ),
      ),
    );
    // ),
  }
}

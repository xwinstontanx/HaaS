import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameHistory {
  String? createdAt;
  String? score;
  String? pointEarned;

  GameHistory({this.createdAt, this.score, this.pointEarned});
}

class SnakeGameHistoryPage extends StatefulWidget {
  const SnakeGameHistoryPage({Key? key}) : super(key: key);

  @override
  State<SnakeGameHistoryPage> createState() => _SnakeGameHistoryPageState();
}

class _SnakeGameHistoryPageState extends State<SnakeGameHistoryPage> {
  var userUid = "";
  var userName = "";

  List<GameHistory> gameHistoryList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getGameHistory();
  }

  Future<void> getGameHistory() async {
    gameHistoryList = [];
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('GamesHistory')
        .where('GameName', isEqualTo: 'Snake')
        .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        DateTime myDateTime =
            DateTime.parse(data['CreatedAt'].toDate().toString());
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        gameHistoryList.add(GameHistory(
          createdAt: formattedDateTime,
          score: data['Score'].toString(),
          pointEarned: data['PointEarned'].toString(),
        ));
      }
      // gameHistoryList.sort(
      //     (b, a) => a.createdAt.toString().compareTo(b.createdAt.toString()));
      setState(() {
        gameHistoryList = gameHistoryList;
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
        title: Text("SNAKE HISTORY".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (gameHistoryList.isNotEmpty)
                  DataTable(
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
                          child: Text("Score".tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                        DataColumn(
                            label: Flexible(
                          fit: FlexFit.tight,
                          child: Text("Point(s)".tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                      ],
                      rows: gameHistoryList
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
                                DataCell(Center(
                                  child: Text(
                                    e.score.toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.normal,
                                    ),
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
                if (gameHistoryList.isEmpty)
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

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RedemptionHistory {
  String? createdAt;
  String? itemName;
  String? pointsDeducted;

  RedemptionHistory({this.createdAt, this.itemName, this.pointsDeducted});
}

class RedemptionHistoryPage extends StatefulWidget {
  const RedemptionHistoryPage({Key? key}) : super(key: key);

  @override
  State<RedemptionHistoryPage> createState() => _RedemptionHistoryPage();
}

class _RedemptionHistoryPage extends State<RedemptionHistoryPage> {
  var userUid = "";
  var userName = "";

  List<RedemptionHistory> redemptionHistoryList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getRedemptionHistory();
  }

  Future<void> getRedemptionHistory() async {
    redemptionHistoryList = [];
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('RedemptionHistory')
        //     .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) async {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        DateTime myDateTime =
            DateTime.parse(data['CreatedAt'].toDate().toString());
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        redemptionHistoryList.add(RedemptionHistory(
          createdAt: formattedDateTime,
          itemName: data['ItemName'].toString(),
          pointsDeducted: data['PointsDeducted'].toString(),
        ));
      }

      redemptionHistoryList.sort(
          (b, a) => a.createdAt.toString().compareTo(b.createdAt.toString()));
      setState(() {
        redemptionHistoryList = redemptionHistoryList;
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
        title: Text("REDEMPTION HISTORY".tr()),
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
                if (redemptionHistoryList.isNotEmpty)
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
                          child: Text('Item Name'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                        DataColumn(
                            label: Flexible(
                          fit: FlexFit.tight,
                          child: Text('Point(s) Deducted'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        )),
                      ],
                      rows: redemptionHistoryList
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
                                  e.itemName.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontStyle: FontStyle.normal,
                                  ),
                                )),
                                DataCell(Center(
                                  child: Text(
                                    e.pointsDeducted.toString(),
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
                if (redemptionHistoryList.isEmpty)
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

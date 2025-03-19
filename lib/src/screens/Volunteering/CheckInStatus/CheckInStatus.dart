import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../firebase_options_senzehub.dart';

class CheckInStatusPage extends StatefulWidget {
  final String elderlyUid;

  const CheckInStatusPage(this.elderlyUid, {super.key});

  @override
  State<CheckInStatusPage> createState() => CheckInStatusPageState();
}

class CheckInStatusPageState extends State<CheckInStatusPage> {
  List<DataRow> allRows = [];
  List<DataRow> filteredRows = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  Future<void> retrieveData() async {
    await generateDataRows();
    setState(() {
      filteredRows = allRows;
      isLoading = false;
    });
  }

  Future<List<DataRow>> generateDataRows() async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('CheckInHistory')
        .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> dataCheckIn = queryDocumentSnapshot.data();
        DateTime myDateTime =
            DateTime.parse(dataCheckIn['CreatedAt'].toDate().toString());
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        DateTime currentTime = DateTime.now();
        Duration difference = currentTime.difference(myDateTime);

        String formattedTime = formatDuration(difference);

        allRows.add(
          DataRow(
            cells: [
              // DataCell(Text(data['Name'])),
              DataCell(Text('$formattedDateTime ($formattedTime)')),
            ],
          ),
        );
      }
    });

    return allRows;
  }

  String formatDuration(Duration duration) {
    if (duration.inDays >= 365) {
      return '${(duration.inDays / 365).floor()} years ago';
    } else if (duration.inDays >= 30) {
      return '${(duration.inDays / 30).floor()} months ago';
    } else if (duration.inDays >= 7) {
      return '${(duration.inDays / 7).floor()} weeks ago';
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void filterRows(String searchText) {
    List<DataRow> filteredList = [];

    if (searchText.isNotEmpty) {
      for (var row in allRows) {
        for (var cell in row.cells) {
          if (cell.child is Text &&
              (cell.child as Text)
                  .data!
                  .toLowerCase()
                  .contains(searchText.toLowerCase())) {
            filteredList.add(row);
            break;
          }
        }
      }
    } else {
      filteredList = allRows;
    }

    setState(() {
      filteredRows = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget dataTable;

    if (filteredRows.isEmpty) {
      dataTable = Text("NO DATA AVAILABLE".tr());
    } else {
      dataTable = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,80.0),
          child: DataTable(
            border: TableBorder.all(width: 1),
            dataRowMinHeight: 45.0,
            dataRowMaxHeight: 60.0,
            columns: [
              // DataColumn(label: Text('Name')),
              // DataColumn(label: Text('Created At')),
              DataColumn(
                  label: Flexible(
                    fit: FlexFit.tight,
                    child: Center(
                      child: Text("Triggered On".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
            rows: filteredRows,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In Status'.tr()),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
              color: Colors.blue,
              size: 50,
            ))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      filterRows(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(child: dataTable),
              ],
            ),
    );
  }
}

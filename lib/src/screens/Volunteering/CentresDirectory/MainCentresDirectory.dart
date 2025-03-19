import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../firebase_options_senzehub.dart';
import '../VolunteeringService.dart';

class MainCentresDirectoryPage extends StatefulWidget {
  final VolunteeringService service;

  const MainCentresDirectoryPage({Key? key, required this.service})
      : super(key: key);

  @override
  State<MainCentresDirectoryPage> createState() =>
      MainCentresDirectoryPageState();
}

class MainCentresDirectoryPageState extends State<MainCentresDirectoryPage> {
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
    await FirebaseFirestore.instance
        .collection('CentresList')
        .orderBy('CenterName', descending: false)
        .get()
        .then((querySnapshot) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> dataCentre = queryDocumentSnapshot.data();
        if (dataCentre != null) {
          // DateTime myDateTime =
          //     DateTime.parse(dataCentre['CreatedAt'].toDate().toString());
          // String formattedDateTime =
          //     DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);
          //
          // DateTime currentTime = DateTime.now();
          // Duration difference = currentTime.difference(myDateTime);
          //
          // String formattedTime = formatDuration(difference);

          allRows.add(
            DataRow(
              cells: [
                DataCell(
                  GestureDetector(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.link),
                        SizedBox(width: 6),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dataCentre['CenterName'],
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Uri uri = Uri.parse(
                          'https://www.google.com/search?q=${dataCentre['CenterName']}');
                      launchUrl(uri);
                    },
                  ),
                ),

                DataCell(
                  GestureDetector(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 6),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dataCentre['Address'],
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: dataCentre['Address']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Copied to clipboard:${dataCentre['Address']}'),
                        ),
                      );
                    },
                  ),
                ),
                // DataCell(Text(dataCentre['OperationHours'])),
                // DataCell(Text(dataCentre['ContactNumber'])),
                DataCell(
                    Text(dataCentre['Cluster'], textAlign: TextAlign.center,)),
                DataCell(
                    Text(dataCentre['Area'], textAlign: TextAlign.center,)),
                // DataCell(Text('$formattedDateTime ($formattedTime)')),
              ],
            ),
          );
        }
      }
    });

    return allRows;
  }

  // String formatDuration(Duration duration) {
  //   if (duration.inDays >= 365) {
  //     return '${(duration.inDays / 365).floor()} years ago';
  //   } else if (duration.inDays >= 30) {
  //     return '${(duration.inDays / 30).floor()} months ago';
  //   } else if (duration.inDays >= 7) {
  //     return '${(duration.inDays / 7).floor()} weeks ago';
  //   } else if (duration.inDays >= 1) {
  //     return '${duration.inDays} days ago';
  //   } else if (duration.inHours >= 1) {
  //     return '${duration.inHours} hours ago';
  //   } else if (duration.inMinutes >= 1) {
  //     return '${duration.inMinutes} minutes ago';
  //   } else {
  //     return 'Just now';
  //   }
  // }

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
        child: Center(
          child: InteractiveViewer(
            child: Card(
              elevation: 5, // Adjust the elevation as needed
              margin: EdgeInsets.all(16.0), // Adjust the margin as needed
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DataTable(columns: <DataColumn>[
                          DataColumn(label: Text('Center Name')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('Cluster')),
                          DataColumn(label: Text('Area')),
                        ], rows: filteredRows),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card(
          //   elevation: 5, // Adjust the elevation as needed
          //   margin: EdgeInsets.all(16.0), // Adjust the margin as needed
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
          //     child: DataTable(
          //       border: TableBorder.all(width: 1),
          //       dataRowMinHeight: 45.0,
          //       dataRowMaxHeight: 60.0,
          //       columns: [
          //         DataColumn(label: Text('Center Name')),
          //         DataColumn(label: Text('Address')),
          //         DataColumn(label: Text('Cluster')),
          //         DataColumn(label: Text('Area')),
          //       ],
          //       rows: filteredRows,
          //     ),
          //   ),
          // ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Centres Directory'.tr()),
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

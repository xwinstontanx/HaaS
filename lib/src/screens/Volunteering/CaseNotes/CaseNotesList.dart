import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Volunteering/CaseNotes/MainCaseNotes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../firebase_options_senzehub.dart';
import 'NewCaseNote.dart';
import 'CaseNotes.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

class CaseNotesList extends StatefulWidget {
  final String elderlyUid;

  const CaseNotesList(this.elderlyUid, {super.key});

  @override
  State<CaseNotesList> createState() => CaseNotesListPageState();
}

class CaseNotesListPageState extends State<CaseNotesList> {
  TextEditingController searchController = TextEditingController();
  var caseNoteList = [];

  List<DataRow> filteredRows = [];
  List<DataRow> allRows = [];

  bool showSettings = false;
  List csType = [
    {'id': 'Befriending', 'label': 'Befriending'},
    {'id': 'Buddying', 'label': 'Buddying'},
    {'id': 'Home Nursing', 'label': 'Home Nursing'},
  ];
  List csFollowUp = [
    {'id': 'Follow-up: Yes', 'label': 'Follow-up: Yes'.tr()},
    {'id': 'Follow-up: No', 'label': 'Follow-up: No'.tr()},
  ];
  List selectedCS = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCS = csFollowUp;
    });
    retrieveData();
  }

  Future<void> retrieveData() async {
    await generateDataRows();
  }

  Future<void> generateDataRows() async {
    caseNoteList = [];
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('CaseNotesHistory')
        .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> dataCaseNote = queryDocumentSnapshot.data();
        DateTime myDateTime =
            DateTime.parse(dataCaseNote['CreatedAt'].toDate().toString());
        String formattedDateTime =
            DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

        caseNoteList
            .add({'docID': queryDocumentSnapshot.id, 'data': dataCaseNote});

        // DateTime currentTime = DateTime.now();
        // Duration difference = currentTime.difference(myDateTime);
        // String formattedTime = formatDuration(difference);

        setState(() {
          caseNoteList;
        });
      }
    });
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

  void handleRowTap(List<DataCell> cells) {
    String caseNoteId = (cells[2].child as Text).data!;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CaseNotesPage(widget.elderlyUid, caseNoteId)));
  }

  @override
  Widget build(BuildContext context) {
    Padding ShowSetting(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
        child: InkWell(
          onTap: () {
            setState(() {
              showSettings = !showSettings;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings, size: 30),
                onPressed: () {
                  setState(() {
                    showSettings = !showSettings;
                  });
                },
                color: Colors.white,
              ),
              // Text("Profile Badge".tr()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("Case Notes".tr()),
          actions: <Widget>[ShowSetting(context)],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => NewCaseNote(widget.elderlyUid)))
                  .then((_) => {retrieveData()});
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              retrieveData();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
              child: Column(
                children: [
                  showSettings
                      ? MultiSelectDropdown(
                          list: csFollowUp,
                          initiallySelected: csFollowUp,
                          includeSelectAll: true,
                          onChange: (newList) {
                            setState(() {
                              selectedCS = newList;
                            });
                          },
                          numberOfItemsLabelToShow: 3,
                          // label to be shown for 2 items
                          whenEmpty: 'Follow-up Selection'
                              .tr(), // text to show when selected list is empty
                        )
                      : SizedBox(height: 0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: caseNoteList.length,
                      itemBuilder: (context, index) {
                        return selectedCS
                                .map((item) =>
                                    item['id'].toString().substring(11))
                                .contains(
                                    caseNoteList[index]['data']['FollowUp'])
                            ? ShowContent(caseNoteList, index)
                            : SizedBox(
                                height: 0,
                              );
                        // return ShowContent(caseNoteList, index);
                      },
                    ),
                  ),
                ],
              ),
            )));
  }

  Card ShowContent(caseNoteList, index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // if you need this
          side: BorderSide(
            color: Colors.blue,
            // color: caseNoteList[index]['data']['FollowUp'] == "Yes"
            //     ? Colors.deepOrangeAccent
            //     : Colors.blue,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
              title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              caseNoteList[index]['data']['FollowUp'] == "Yes"
                  ? Center(
                      child: Text("*** Follow-up is required ***".tr(),
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.normal,
                          )))
                  : SizedBox(
                      height: 0,
                    ),
              caseNoteList[index]['data']['FileURL'] == "" ||
                      caseNoteList[index]['data']['FileURL'] == null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 0,
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                            caseNoteList[index]['data']['FileURL'] ?? "",
                            height: 150,
                            fit: BoxFit.fill, loadingBuilder:
                                (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        }, errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                          return SizedBox(
                            height: 0,
                          );
                        }),
                      ),
                    ),
              cnContent("Visited By ".tr(),
                  caseNoteList[index]['data']['VisitByName']),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                child: Column(
                  children: [
                    cnContent(
                        "TIME IN".tr(), caseNoteList[index]['data']['TimeIn']),
                    cnContent("TIME OUT".tr(),
                        caseNoteList[index]['data']['TimeOut']),
                    cnContent("Duration ".tr(),
                        caseNoteList[index]['data']['Duration']),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: Text("Activities ".tr(),
                              style: TextStyle(color: Colors.blue))),
                      Text(": ", style: TextStyle(color: Colors.blue)),
                      Column(
                        children: [
                          Container(
                              width: 200,
                              child: Text(caseNoteList[index]['data']
                                      ['Activities']
                                  .toString()
                                  .replaceAll("[", "")
                                  .replaceAll("]", ""))),
                        ],
                      ),
                    ],
                  )),
              cnContent("Remarks ".tr(), caseNoteList[index]['data']['Remark']),
            ],
          )),
        ));
  }

  Widget cnContent(title, content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: TextStyle(color: Colors.blue),
          ),
        ),
        Text(": ", style: TextStyle(color: Colors.blue)),
        Flexible(
          child: Text(
            content,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

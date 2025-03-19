import 'dart:async';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';
import '../../../../firebase_options_senzehub.dart';
import '../Chat/Chat.dart';
import '../VolunteeringService.dart';

class EmergencyPage extends StatefulWidget {
  final VolunteeringService service;
  var senior;

  EmergencyPage({Key? key, required this.senior, required this.service})
      : super(key: key);

  @override
  State<EmergencyPage> createState() => EmergencyPageState();
}

class EmergencyPageState extends State<EmergencyPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool showSettings = false;
  List csAttended = [
    {'id': 'Status: open', 'label': 'Status: open'.tr()},
    {'id': 'Status: close', 'label': 'Status: close'.tr()},
    {'id': 'Status: No Checkin', 'label': 'Status: No Checkin'.tr()},
  ];
  List selectedCS = [];
  var emergencyList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCS = csAttended;
    });
    retrieveData();
  }

  Future<void> retrieveData() async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('Notification')
        .where('NotifyStatus', whereIn: ["open", "close", "No Checkin"])
        .where('SeniorUid', isEqualTo: widget.senior['Uid'])
        .orderBy('CreatedAt', descending: true)
        .get()
        .then((querySnapshot) {
          emergencyList = [];
          for (var queryDocumentSnapshot in querySnapshot.docs) {
            print(queryDocumentSnapshot.id);
            Map<String, dynamic> dataEmergency = queryDocumentSnapshot.data();
            setState(() {
              emergencyList.add(
                  {'docID': queryDocumentSnapshot.id, 'data': dataEmergency});
            });
          }
        });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateData(docUid) async {
    setState(() {
      isLoading = true;
    });
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('Notification')
        .doc(docUid)
        .update({
      "NotifyStatus": "close",
      "AttendedAt": DateTime.now(),
      "Attendee": widget.service.userName,
      "Status": 1
    }).then((_) async => {
              await FirebaseFirestore.instanceFor(app: secondaryApp)
                  .collection('VolunteerChats')
                  .doc(widget.senior['Uid'])
                  .collection('Chats')
                  .add({
                "Content": "Attended By".tr() + " " + widget.service.userName,
                "CreatedAt": DateTime.now(),
                "IsSystem": true,
                "Name": widget.service.userName,
                "Uid": widget.service.userUid
              }),
              retrieveData()
            });
  }

  @override
  Widget build(BuildContext context) {
    Widget dataTable;

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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ALERTS'.tr()),
        actions: <Widget>[ShowSetting(context)],
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
              color: Colors.blue,
              size: 50,
            ))
          : RefreshIndicator(
              onRefresh: () async {
                retrieveData();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 80.0),
                child: Column(
                  children: [
                    showSettings
                        ? MultiSelectDropdown(
                            list: csAttended,
                            initiallySelected: csAttended,
                            includeSelectAll: true,
                            onChange: (newList) {
                              setState(() {
                                selectedCS = newList;
                              });
                            },
                            numberOfItemsLabelToShow: 3,
                            // label to be shown for 2 items
                            whenEmpty: 'Attended Status'
                                .tr(), // text to show when selected list is empty
                          )
                        : SizedBox(height: 0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => ChatPage(
                                    service: widget.service,
                                    senior: widget.senior)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Container(
                          height: 60,
                          child: Card(
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              // if you need this
                              side: BorderSide(
                                color: Colors.blue,
                                width: 3,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.chat, color: Colors.white),
                                ),
                                Text(
                                  'Chat / Update Others'.tr(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    emergencyList.length > 0
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: emergencyList.length,
                              itemBuilder: (context, index) {
                                return selectedCS
                                        .map((item) =>
                                            item['id'].toString().substring(8))
                                        .contains(emergencyList[index]['data']
                                            ['NotifyStatus'])
                                    ? ShowContent(emergencyList, index)
                                    : SizedBox(
                                        height: 0,
                                      );
                              },
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            child: Card(
                                child: Center(
                                    child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("NO DATA AVAILABLE".tr(),
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 15)),
                            ))),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Card ShowContent(emergencyList, index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // if you need this
          side: BorderSide(
            color: emergencyList[index]['data']['NotifyStatus'] == "open" ||
                    emergencyList[index]['data']['NotifyStatus'] == "No Checkin"
                ? Colors.redAccent
                : Colors.green,
            width: 2,
          ),
        ),
        child: ListTile(
            title: emergencyList[index]['data']['NotifyStatus'] == "open" ||
                    emergencyList[index]['data']['NotifyStatus'] == "No Checkin"
                ? SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.error_outline_outlined,
                                  color: Colors.red),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                emergencyContent(
                                    "ALERTS".tr(),
                                    emergencyList[index]['data']
                                                ['NotifyStatus'] ==
                                            "No Checkin"
                                        ? "No check in for 3 days".tr()
                                        : "EMERGENCY TRIGGERED".tr()),
                                emergencyContent(
                                    "TRIGGERED ON".tr(),
                                    DateFormat('yyyy-MM-dd hh:mma').format(
                                        emergencyList[index]['data']
                                                ['CreatedAt']
                                            .toDate())),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 90,
                                        child: Text("Status".tr(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12))),
                                    Text(": ",
                                        style: TextStyle(color: Colors.grey)),
                                    Text("Pending".tr(),
                                        style: TextStyle(color: Colors.blue)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => {
                            updateData(emergencyList[index]['docID']),
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child:
                                    Icon(Icons.thumb_up, color: Colors.white),
                              ),
                              Text(
                                'Click here if you have attended'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.check, color: Colors.green),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          emergencyContent(
                              "TRIGGERED ON".tr(),
                              DateFormat('yyyy-MM-dd hh:mma').format(
                                  emergencyList[index]['data']['CreatedAt']
                                      .toDate())),
                          emergencyContent("Attended By".tr(),
                              emergencyList[index]['data']['Attendee']),
                        ],
                      ),
                    ],
                  )));
  }

  Row emergencyContent(title, content) {
    return Row(
      children: [
        SizedBox(
            width: 90,
            child: Text(title,
                style: TextStyle(color: Colors.grey, fontSize: 12))),
        Text(": ", style: TextStyle(color: Colors.grey)),
        Text(content, style: TextStyle(color: Colors.blue, fontSize: 15)),
      ],
    );
  }
}

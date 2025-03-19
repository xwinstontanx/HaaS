import 'dart:io' show Platform;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  var userUid = "";

  var elderlyUidList = [];
  var newAlerts = [];
  var attendedAlerts = [];

  @override
  void initState() {
    super.initState();
    getUser().then((value) => getData());
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
    });
  }

  getData() {
    // 1. Get Elderly list
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('ElderlyUnderCare')
        .get()
        .then((seniorUnderCareSnapshot) => {
              if (seniorUnderCareSnapshot.docs.isNotEmpty)
                {
                  for (var elderlyList in seniorUnderCareSnapshot.docs)
                    {
                      elderlyUidList.add({
                        'docID': elderlyList.id,
                        'data': elderlyList.data(),
                      }),
                    }
                },
              for (var elderly in elderlyUidList)
                {
                  // 2. Get alerts
                  FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
                      .collection('Notification')
                      .where('SeniorUid', isEqualTo: elderly['data']['Uid'])
                      .orderBy('CreatedAt', descending: true)
                      .snapshots()
                      .listen((alertsSnapshot) => {
                            if (alertsSnapshot.docs.isNotEmpty)
                              {
                                newAlerts = [],
                                attendedAlerts = [],
                                for (var alert in alertsSnapshot.docs)
                                  {
                                    //Check attended or not
                                    if (alert.data()['NotifyStatus'] ==
                                            "open" ||
                                        alert.data()['NotifyStatus'] ==
                                                'healthdDataOFR' &&
                                            alert.data()['Attendee'] == "")
                                      {
                                        newAlerts.add({
                                          'id': alert.id,
                                          'alert': alert.data(),
                                          'datetime': alert.data()['CreatedAt']
                                              as Timestamp
                                        }),
                                      }
                                    else if (alert.data()['NotifyStatus'] ==
                                        "close")
                                      {
                                        //Get Comments
                                        attendedAlerts.add({
                                          'id': alert.id,
                                          'alert': alert.data(),
                                          'datetime': alert.data()['CreatedAt']
                                              as Timestamp
                                        }),
                                      },
                                  },
                                newAlerts.sort((b, a) {
                                  var adate = a['datetime'];
                                  var bdate = b['datetime'];
                                  return adate.compareTo(bdate);
                                }),
                                attendedAlerts.sort((b, a) {
                                  var adate = a['datetime'];
                                  var bdate = b['datetime'];
                                  return adate.compareTo(bdate);
                                }),
                                setState(() {
                                  newAlerts;
                                  attendedAlerts;
                                }),
                              },
                          }),
                },
            });
  }

  TabBar get _tabBar => TabBar(
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: 'NEW'.tr()),
          Tab(text: 'ATTENDED'.tr()),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: Colors.blue.shade700,
              child: _tabBar,
            ),
          ),
          title: Text('ALERTS'.tr()),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              // To prvent content blocking by buttomNavIcons
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: newAlerts.length,
                itemBuilder: (BuildContext context, int index) {
                  return AlertCard(alertData: newAlerts, index: index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              // To prvent content blocking by buttomNavIcons
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: attendedAlerts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AttendedCard(
                        alertData: attendedAlerts, index: index);
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({Key? key, required this.alertData, required this.index})
      : super(key: key);

  final List alertData;
  final int index;

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<void> displayTextInputDialog(
      BuildContext context, notificationDocId) async {
    final TextEditingController textFieldController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userName = prefs.getString('userName')!;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Text("Leave message here so other carers can be seen".tr()),
                TextField(
                  controller: textFieldController,
                  maxLines: 3, //or null
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => {
                          if (textFieldController.text != "")
                            {
                              FirebaseFirestore.instanceFor(
                                  app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .update({
                                'Attendee': userName,
                                'NotifyStatus': 'close'
                              }),
                              FirebaseFirestore.instanceFor(
                                  app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .collection('Comments')
                                  .add({
                                'AttendedAt': DateTime.now(),
                                'Attendee': userName,
                                'Comments': textFieldController.text
                              }),
                              Navigator.pop(context)
                            }
                          else
                            {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: 'Error'.tr(),
                                desc: 'Kindly fill up the fields'.tr(),
                                btnOkOnPress: () {},
                              ).show()
                            },
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(side: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          "SUBMIT".tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => {Navigator.pop(context)},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                  style: BorderStyle.solid
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          "CANCEL".tr(),
                          style: const TextStyle(color: Colors.white),
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

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          width: MediaQuery.of(context).size.width,
          child: Card(
            color: Colors.white,
            child: Card(
              child: Column(
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Message"),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                              "Leave message here so other carers can be seen"),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: <Widget>[
                  Center(
                      child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: textFieldController,
                              maxLines: 8, //or null
                              decoration: const InputDecoration.collapsed(
                                  hintText: "Enter your text here"),
                            ),
                          ))),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => {
                          if (textFieldController.text != "")
                            {
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .update({
                                'Attendee': userName,
                                'NotifyStatus': 'close'
                              }),
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .collection('Comments')
                                  .add({
                                'AttendedAt': DateTime.now(),
                                'Attendee': userName,
                                'Comments': textFieldController.text
                              }),
                              Navigator.pop(context)
                            }
                          else
                            {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: 'Error'.tr(),
                                desc: 'Kindly fill up the fields'.tr(),
                                btnOkOnPress: () {},
                              ).show()
                            },
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => {
                          if (textFieldController.text != "")
                            {
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .update({
                                'Attendee': userName,
                                'NotifyStatus': 'close'
                              }),
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .collection('Comments')
                                  .add({
                                'AttendedAt': DateTime.now(),
                                'Attendee': userName,
                                'Comments': textFieldController.text
                              }),
                              Navigator.pop(context)
                            }
                          else
                            {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: 'Error'.tr(),
                                desc: 'Kindly fill up the fields'.tr(),
                                btnOkOnPress: () {},
                              ).show()
                            },
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "CANCEL".tr(),
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 30, color: Colors.yellow),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          'From'.tr() + " " + alertData[index]['alert']['Name'],
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white)),
                    ),
                  ],
                ),
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(width: 3, color: Colors.redAccent),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ALERT TRIGGERED ON:".tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          DateFormat('d MMM yyyy (EEE) h:mm a').format(
                              alertData[index]['alert']['CreatedAt'].toDate()),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'LAST KNOWN LOCATION:'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            var formattedAddress =
                                alertData[index]['alert']['Address'];

                            var url = "";
                            if (Platform.isAndroid) {
                              url = 'geo:?q=' + formattedAddress;
                            } else if (Platform.isIOS) {
                              url = 'maps:?q=' + formattedAddress;
                            }

                            final Uri toLaunch = Uri(
                                scheme: 'https',
                                host: 'www.google.com',
                                path: 'maps/search/' +
                                    alertData[index]['alert']['Address']);

                            _launchInBrowser(toLaunch);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 22),
                              Text(
                                'MAP'.tr(),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: [
                          Text(
                            'REMARK'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          alertData[index]['alert']['NotifyStatus'] == 'open'
                              ? Text(
                                  'EMERGENCY TRIGGERED'.tr(),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )
                              : alertData[index]['alert']['NotifyStatus'] ==
                                      'healthdDataOFR'
                                  ? Text(
                                      alertData[index]['alert']['ReadingName'] +
                                          ": " +
                                          alertData[index]['alert']
                                              ['ReadingValue'],
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const Text(
                                      '',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                          child: TextButton(
                            onPressed: () => {
                              // launch("tel://" +
                              //     alertData[index]['alert']['PhoneNumber']))
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                const Icon(Icons.call, color: Colors.white),
                                Text(
                                  "CALL".tr(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                          child: TextButton(
                            onPressed: () => {
                              displayTextInputDialog(
                                  context, alertData[index]['id'])
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Colors.lightGreenAccent,
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                const Icon(Icons.thumb_up,
                                    color: Colors.indigo),
                                Text(
                                  "ATTENDED".tr(),
                                  style: const TextStyle(
                                      color: Colors.indigo, fontSize: 20.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AttendedCard extends StatelessWidget {
  const AttendedCard({Key? key, required this.alertData, required this.index})
      : super(key: key);

  final List alertData;
  final int index;

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 30, color: Colors.yellow),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          'From'.tr() + " " + alertData[index]['alert']['Name'],
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white)),
                    ),
                  ],
                ),
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(width: 2, color: Colors.green),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ALERT TRIGGERED ON:".tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          DateFormat('d MMM yyyy (EEE) h:mm a').format(
                              alertData[index]['alert']['CreatedAt'].toDate()),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LAST KNOWN LOCATION:'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            var formattedAddress =
                                alertData[index]['alert']['Address'];

                            var url = "";
                            if (Platform.isAndroid) {
                              url = 'geo:?q=' + formattedAddress;
                            } else if (Platform.isIOS) {
                              url = 'maps:?q=' + formattedAddress;
                            }

                            final Uri toLaunch = Uri(
                                scheme: 'https',
                                host: 'www.google.com',
                                path: 'maps/search/' +
                                    alertData[index]['alert']['Address']);

                            _launchInBrowser(toLaunch);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 22),
                              Text(
                                'MAP'.tr(),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REMARK'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          alertData[index]['alert']['NotifyStatus'] ==
                                      'close' &&
                                  alertData[index]['alert']['ReadingName'] !=
                                      null &&
                                  alertData[index]['alert']['ReadingValue'] !=
                                      null
                              ? Text(
                                  alertData[index]['alert']['ReadingName'] +
                                      ": " +
                                      alertData[index]['alert']['ReadingValue'],
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                )
                              : Text(
                                  'EMERGENCY TRIGGERED'.tr(),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ATTENDED BY'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            alertData[index]['alert']['Attendee'],
                            style: const TextStyle(
                                color: Colors.black, fontSize: 17),
                          )
                        ],
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => {
                            displayTextInputDialog(
                                context, alertData[index]['id'])
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.green,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10.0)),
                            padding: const EdgeInsets.all(10.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Add Message".tr(),
                                style: const TextStyle(color: Colors.green),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => {
                            displayAllMessageDialog(
                                context, alertData[index]['id'])
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.green,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10.0)),
                            padding: const EdgeInsets.all(10.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "View All Message".tr(),
                                style: const TextStyle(color: Colors.green),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> displayAllMessageDialog(
      BuildContext context, notificationDocId) async {
    final TextEditingController textFieldController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userName = prefs.getString('userName')!;
    var comments = [];
    FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('Notification')
        .doc(notificationDocId)
        .collection('Comments')
        .orderBy('AttendedAt', descending: true)
        .get()
        .then((commentsSnapshot) => {
              if (commentsSnapshot.docs.isNotEmpty)
                {
                  for (var comment in commentsSnapshot.docs)
                    {
                      if (comment.data()['Attendee'] != userName)
                        {
                          //Get Comments
                          comments.add({
                            'id': comment.id,
                            'attendee': comment.data()['Attendee'] + ": ",
                            'comment': comment.data()['Comments'],
                            'datetime':
                                comment.data()['AttendedAt'] as Timestamp
                          }),
                        }
                      else
                        {
                          //Get Comments
                          comments.add({
                            'id': comment.id,
                            'attendee': 'You: ',
                            'comment': comment.data()['Comments'],
                            'datetime':
                                comment.data()['AttendedAt'] as Timestamp
                          }),
                        },
                    },
                  comments.sort((b, a) {
                    var adate = a['datetime'];
                    var bdate = b['datetime'];
                    return bdate.compareTo(adate);
                  }),
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.60,
                          width: double.infinity,
                          child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                                    'd MMM yyyy (EEE) h:mm a')
                                                .format(comments[index]
                                                        ['datetime']
                                                    .toDate()),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 17),
                                          ),
                                          Text(comments[index]['attendee'] +
                                              comments[index]['comment'])
                                        ]),
                                  ),
                                );
                              }),
                        ),
                      );
                    },
                  ),
                },
            });
  }

  Future<void> displayTextInputDialog(
      BuildContext context, notificationDocId) async {
    final TextEditingController textFieldController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userName = prefs.getString('userName')!;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Text("Leave message here so other carers can be seen".tr()),
                TextField(
                  controller: textFieldController,
                  maxLines: 3, //or null
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => {
                          if (textFieldController.text != "")
                            {
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .update({
                                'Attendee': userName,
                                'NotifyStatus': 'close'
                              }),
                              FirebaseFirestore.instanceFor(
                                      app: Firebase.app("secondary"))
                                  .collection('Notification')
                                  .doc(notificationDocId)
                                  .collection('Comments')
                                  .add({
                                'AttendedAt': DateTime.now(),
                                'Attendee': userName,
                                'Comments': textFieldController.text
                              }),
                              Navigator.pop(context)
                            }
                          else
                            {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: 'Error'.tr(),
                                desc: 'Kindly fill up all the fields'.tr(),
                                btnOkOnPress: () {},
                              ).show()
                            },
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(side: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          "SUBMIT".tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => {Navigator.pop(context)},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                  style: BorderStyle.solid
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          "CANCEL".tr(),
                          style: const TextStyle(color: Colors.white),
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
  }

  setState(Null Function() param0, item) {
    setState() {
      item;
    }
  }
}

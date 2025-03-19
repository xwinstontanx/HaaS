import 'dart:convert';
import 'dart:io' show Platform;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:core';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';

class MainSchedulePage extends StatefulWidget {
  const MainSchedulePage({Key? key}) : super(key: key);

  @override
  State<MainSchedulePage> createState() => MainSchedulePageState();
}

class MainSchedulePageState extends State<MainSchedulePage> {
  var userUid = "";
  var userOrgId = "";

  var activityUpcomingData = [];
  var activityPastData = [];

  bool firstLoading = false;

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorColor = Colors.blue;
    EasyLoading.instance.textColor = Colors.blue;
    //Get userUid and fetch events details
    getUser().then((value) => {
          getBBEvent().then((value) => {getEvent()})
        });
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userOrgId = prefs.getString('userOrgId')!;
    });
  }

  Future<void> getBBEvent() async {
    FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('BefriendBuddyDetails')
        .where('Volunteer', isEqualTo: userUid)
        .snapshots()
        .listen((value) => {
              // To prevent loading twice at the beginning
              if (!firstLoading)
                {
                  firstLoading = true,
                }
              else
                {getData()}
            });
  }

  Future<void> getEvent() async {
    if (userOrgId != "") {
      FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
          .collection('EventDetails')
          .where('OrganizationId', isEqualTo: userOrgId)
          .snapshots()
          .listen((value) => {getData()});
    }
  }

  Future<void> getData() async {
    EasyLoading.show(status: 'Loading...');
    // 1. Get bb events details for this volunteer
    DateTime eventDateTime;
    FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('BefriendBuddyDetails')
        .where('Volunteer', isEqualTo: userUid)
        .get()
        .then((bbSnapshot) => {
              activityUpcomingData = [],
              activityPastData = [],

              if (bbSnapshot.docs.isNotEmpty)
                {
                  for (var bbEvents in bbSnapshot.docs)
                    {
                      eventDateTime = DateTime.parse(bbEvents.data()['Date'] +
                          'T' +
                          bbEvents.data()['Time'] +
                          'Z'),
                      // 2. Check upcoming or past event
                      if (DateTime.now().isBefore(eventDateTime))
                        {
                          activityUpcomingData.add({
                            'id': bbEvents.id,
                            'event': bbEvents.data(),
                            'datetime': eventDateTime
                          }),
                        }
                      else
                        {
                          activityPastData.add({
                            'id': bbEvents.id,
                            'event': bbEvents.data(),
                            'datetime': eventDateTime
                          }),
                        }
                    }
                },

              // 3. Get general events details for this volunteer
              FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
                  .collection('EventDetails')
                  .where('OrganizationId', isEqualTo: userOrgId)
                  .get()
                  .then((value) => {
                        value.docs.forEach((event) async {
                          var getSignedup = await FirebaseFirestore.instanceFor(
                                  app: Firebase.app("secondary"))
                              .collection('JoinEvents')
                              .where('OrganizationId', isEqualTo: userOrgId)
                              .where('EventDetails', isEqualTo: event.id)
                              .where('CreatedBy', isEqualTo: userUid)
                              .get();

                          if (getSignedup.docs.isEmpty) {
                            DateTime eventDateTime = DateTime.parse(
                                event.data()['Date'] +
                                    'T' +
                                    event.data()['Time'] +
                                    'Z');

                            if (DateTime.now().isBefore(eventDateTime)) {
                              activityUpcomingData.add({
                                'id': event.id,
                                'event': event.data(),
                                'datetime': eventDateTime,
                                'signUpStatus': false
                              });
                            } else {
                              activityPastData.add({
                                'id': event.id,
                                'event': event.data(),
                                'datetime': eventDateTime,
                                'signUpStatus': false
                              });
                            }
                            setState(() {
                              activityUpcomingData;
                              activityPastData;
                            });
                          } else {
                            for (var signedup in getSignedup.docs) {
                              DateTime eventDateTime = DateTime.parse(
                                  event.data()['Date'] +
                                      'T' +
                                      event.data()['Time'] +
                                      'Z');
                              if (DateTime.now().isBefore(eventDateTime)) {
                                activityUpcomingData.add({
                                  'id': event.id,
                                  'event': event.data(),
                                  'datetime': eventDateTime,
                                  'signUpId': getSignedup.docs.last.id,
                                  'signUpStatus': true,
                                });
                              } else {
                                activityPastData.add({
                                  'id': event.id,
                                  'event': event.data(),
                                  'datetime': eventDateTime,
                                  'signUpId': getSignedup.docs.last.id,
                                  'signUpStatus': true,
                                });
                              }
                              setState(() {
                                activityUpcomingData;
                                activityPastData;
                              });
                            }
                          }
                        }),
                        activityUpcomingData.sort((a, b) {
                          var adate = a['datetime'];
                          var bdate = b['datetime'];
                          return adate.compareTo(bdate);
                        }),
                        activityPastData.sort((a, b) {
                          var adate = a['datetime'];
                          var bdate = b['datetime'];
                          return adate.compareTo(bdate);
                        }),
                        EasyLoading.dismiss(),
                        setState(() {
                          activityUpcomingData;
                          activityPastData;
                        }),
                      }),
            });
  }

  TabBar get _tabBar => TabBar(
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: 'UPCOMING'.tr()),
          Tab(text: 'PAST'.tr()),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: Colors.blue.shade700,
              child: _tabBar,
            ),
          ),
          title: Text('Schedules'.tr()),
        ),
        body: TabBarView(
          children: [
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: kIsWeb ? FormFactor.desktop : double.infinity,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    // To prvent content blocking by buttomNavIcons
                    child: activityUpcomingData.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: getData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: activityUpcomingData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return EventCard(
                                    eventData: activityUpcomingData,
                                    onRefresh: getData,
                                    index: index,
                                    isPast: false);
                              },
                            ))
                        : emptyEvents()),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: kIsWeb ? FormFactor.desktop : double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  // To prvent content blocking by buttomNavIcons
                  child: activityPastData.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: getData,
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: activityPastData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return EventCard(
                                    eventData: activityPastData,
                                    onRefresh: getData,
                                    index: index,
                                    isPast: true);
                              }),
                        )
                      : emptyEvents(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Center emptyEvents() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                // if you need this
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 50, color: Colors.blue),
                    Text("No Events".tr(),
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          "Relevant events will appear in this space".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  EventCard(
      {Key? key,
      required this.eventData,
      required this.onRefresh,
      required this.index,
      required this.isPast})
      : super(key: key);

  final List eventData;
  final int index;
  final bool isPast;
  String? dateTime = "";
  late DateTime dateTimeV;
  final Future<void> Function() onRefresh;

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
              decoration: BoxDecoration(
                  color: eventData[index]['event']['Type'] ==
                              'Befriending (Weekly)' ||
                          eventData[index]['event']['Type'] ==
                              'Buddying (Monthly)' ||
                          eventData[index]['event']['Type'] ==
                              'Befriending (Biweekly)'
                                  ""
                      ? Colors.yellow
                      : Colors.orange.shade300,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: eventData[index]['event']['Type'] ==
                          'Befriending (Weekly)' ||
                      eventData[index]['event']['Type'] ==
                          'Befriending (Biweekly)' ||
                      eventData[index]['event']['Type'] ==
                          'Buddying (Monthly)'
                              ""
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.people, size: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(eventData[index]['event']['Type'],
                                  style: const TextStyle(fontSize: 19)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          eventData[index]['signUpStatus'] == true
                              ? const Icon(Icons.check, size: 30)
                              : const Icon(Icons.calendar_month, size: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(eventData[index]['event']['Title'],
                                  style: const TextStyle(fontSize: 19)),
                            ),
                          ),
                        ],
                      ),
                    )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: eventData[index]['event']['Type'] ==
                            'Befriending (Weekly)' ||
                        eventData[index]['event']['Type'] ==
                            'Buddying (Monthly)' ||
                        eventData[index]['event']['Type'] ==
                            'Befriending (Biweekly)'
                                ""
                    ? Colors.yellow.shade50
                    : Colors.orange.shade50,
                border: Border.all(
                    width: 3,
                    color: eventData[index]['event']['Type'] ==
                                'Befriending (Weekly)' ||
                            eventData[index]['event']['Type'] ==
                                'Buddying (Monthly)' ||
                            eventData[index]['event']['Type'] ==
                                'Befriending (Biweekly)'
                                    ""
                        ? Colors.yellow
                        : Colors.orange.shade300),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eventData[index]['event'].toString().contains('Brochure')
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                showImageViewer(
                                    context,
                                    Image.network(eventData[index]['event']
                                            ['Brochure'])
                                        .image,
                                    onViewerDismissed: () {});
                              },
                              child: Center(
                                  child: Image.network(
                                      eventData[index]['event']['Brochure']))),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${'DATE'.tr()} / ${'TIME'.tr()}:",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Wrap(
                          children: [
                            Text(
                              DateFormat('d MMM yyyy (EEE) h:mm a')
                                  .format(eventData[index]['datetime']),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    DatePicker.showDateTimePicker(context,
                                        showTitleActions: true,
                                        currentTime: eventData[index]
                                            ['datetime'], onConfirm: (date) {
                                      FirebaseFirestore.instanceFor(
                                              app: Firebase.app("secondary"))
                                          .collection('BefriendBuddyDetails')
                                          .doc(eventData![index]['id'])
                                          .update({
                                        'Date': DateFormat('yyyy-MM-dd')
                                            .format(date),
                                        'Time':
                                            DateFormat('HH:mm').format(date),
                                      }).then((value) => {});
                                    });
                                  },
                                  child: isPast
                                      ? const SizedBox(width: 0)
                                      : eventData[index]['event']['Type'] ==
                                                  'Befriending (Weekly)' ||
                                              eventData[index]['event']
                                                      ['Type'] ==
                                                  'Buddying (Monthly)' ||
                                              eventData[index]['event']
                                                      ['Type'] ==
                                                  'Befriending (Biweekly)'
                                                      ""
                                          ? const Icon(Icons.edit_outlined,
                                              size: 22)
                                          : const SizedBox(width: 0)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: eventData[index]['event']['Type'] ==
                                'Befriending (Weekly)' ||
                            eventData[index]['event']['Type'] ==
                                'Buddying (Monthly)' ||
                            eventData[index]['event']['Type'] ==
                                'Befriending (Biweekly)'
                                    ""
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${'DETAILS'.tr()}:",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    'Visiting'.tr() +
                                        " " +
                                        eventData[index]['event']
                                            ['ElderlyName'],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${'DETAILS'.tr()}:",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    eventData[index]['event']['Details'],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 17),
                                  ),
                                ],
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
                          "${'ADDRESS'.tr()}:",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            var formattedAddress =
                                eventData[index]['event']['Address'];

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
                                    eventData[index]['event']['Address']);

                            _launchInBrowser(toLaunch);
                          },
                          child: Wrap(
                            children: [
                              eventData[index]['event']['Type'] ==
                                          'Befriending (Weekly)' ||
                                      eventData[index]['event']['Type'] ==
                                          'Buddying (Monthly)' ||
                                      eventData[index]['event']['Type'] ==
                                          'Befriending (Biweekly)'
                                              ""
                                  ? Text(
                                      eventData[index]['event']['Address'] +
                                          ", " +
                                          eventData[index]['event']
                                              ['PostalCode'],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 17),
                                    )
                                  : Wrap(
                                      children: [
                                        Text(
                                          eventData[index]['event']['Address'] +
                                              ", " +
                                              eventData[index]['event']
                                                  ['Postal'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                              Row(
                                children: [
                                  const Icon(Icons.my_location,
                                      size: 22, color: Colors.orange),
                                  Text(
                                    "${'MAP'.tr()}",
                                    style: const TextStyle(
                                        color: Colors.orange, fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //     padding: const EdgeInsets.only(bottom: 8.0),
                  //     child: eventData[index]['event']['Type'] ==
                  //                 'Befriending (Weekly)' ||
                  //             eventData[index]['event']['Type'] ==
                  //                 'Buddying (Monthly)' ||
                  //             eventData[index]['event']['Type'] ==
                  //                 'Befriending (Biweekly)'
                  //                     ""
                  //         ? const SizedBox(height: 0)
                  //         : Column(
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 "${'Remark'.tr()}:",
                  //                 style: const TextStyle(color: Colors.grey),
                  //               ),
                  //               //FIXME: Match the content to the attandance status
                  //               Text(
                  //                 eventData[index]['event']['Details'],
                  //                 style: const TextStyle(
                  //                     color: Colors.black, fontSize: 17),
                  //               ),
                  //             ],
                  //           )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                    child: Container(
                      child: isPast
                          ? SizedBox(
                              height: 0,
                            )
                          // ? SizedBox(
                          //     width: double.infinity,
                          //     child: eventData[index]['event']['Type'] ==
                          //                 'Befriending (Weekly)' ||
                          //             eventData[index]['event']['Type'] ==
                          //                 'Buddying (Monthly)' ||
                          //             eventData[index]['event']['Type'] ==
                          //                 'Befriending (Biweekly)'
                          //                     ""
                          //         ? SizedBox(
                          //             width: double.infinity,
                          //             child: TextButton(
                          //               onPressed: () => {
                          //                 Navigator.push(
                          //                     context,
                          //                     MaterialPageRoute(
                          //                         builder: (context) =>
                          //                             CaseNotePage(
                          //                                 event: eventData[
                          //                                     index])))
                          //               },
                          //               style: TextButton.styleFrom(
                          //                 backgroundColor: Colors.yellow,
                          //                 shape: RoundedRectangleBorder(
                          //                     side: const BorderSide(
                          //                         color: Colors.yellow,
                          //                         width: 1,
                          //                         style: BorderStyle.solid),
                          //                     borderRadius:
                          //                         BorderRadius.circular(10.0)),
                          //                 padding: const EdgeInsets.all(10.0),
                          //               ),
                          //               child: Column(
                          //                 children: <Widget>[
                          //                   Text(
                          //                     "Case Note".tr(),
                          //                     style: const TextStyle(
                          //                         color: Colors.black),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           )
                          //         : const SizedBox(height: 0),
                          //   )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: eventData[index]['event']['Type'] ==
                                          'Befriending (Weekly)' ||
                                      eventData[index]['event']['Type'] ==
                                          'Buddying (Monthly)' ||
                                      eventData[index]['event']['Type'] ==
                                          'Befriending (Biweekly)'
                                              ""
                                  ? [
                                      // SizedBox(
                                      //   width: double.infinity,
                                      //   child: TextButton(
                                      //     onPressed: () => {
                                      //       startSession(
                                      //           context, eventData[index])
                                      //     },
                                      //     style: TextButton.styleFrom(
                                      //       backgroundColor: Colors.yellow,
                                      //       shape: RoundedRectangleBorder(
                                      //           side: const BorderSide(
                                      //               color: Colors.yellow,
                                      //               width: 1,
                                      //               style: BorderStyle.solid),
                                      //           borderRadius:
                                      //               BorderRadius.circular(
                                      //                   10.0)),
                                      //       padding: const EdgeInsets.all(10.0),
                                      //     ),
                                      //     child: Column(
                                      //       children: <Widget>[
                                      //         Text(
                                      //           "Start Session".tr(),
                                      //           style: const TextStyle(
                                      //               color: Colors.black),
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width: double.infinity,
                                      //   child: TextButton(
                                      //     onPressed: eventData[index]['event']
                                      //                     ['Status'] ==
                                      //                 1 ||
                                      //             eventData[index]['event']
                                      //                     ['Status'] ==
                                      //                 2
                                      //         ? () => {
                                      //               Navigator.push(
                                      //                   context,
                                      //                   MaterialPageRoute(
                                      //                       builder: (context) =>
                                      //                           CaseNotePage(
                                      //                               event: eventData[
                                      //                                   index])))
                                      //             }
                                      //         : null,
                                      //     style: TextButton.styleFrom(
                                      //       backgroundColor: eventData[index]
                                      //                   ['event']['Status'] ==
                                      //               1
                                      //           ? Colors.yellow
                                      //           : Colors.yellow,
                                      //       shape: RoundedRectangleBorder(
                                      //           side: BorderSide(
                                      //               color: eventData[index]
                                      //                               ['event']
                                      //                           ['Status'] ==
                                      //                       1
                                      //                   ? Colors.yellow
                                      //                   : Colors.yellow,
                                      //               width: 1,
                                      //               style: BorderStyle.solid),
                                      //           borderRadius:
                                      //               BorderRadius.circular(
                                      //                   10.0)),
                                      //       padding: const EdgeInsets.all(10.0),
                                      //     ),
                                      //     child: Column(
                                      //       children: <Widget>[
                                      //         Text(
                                      //           "Case Note".tr(),
                                      //           style: const TextStyle(
                                      //               color: Colors.black),
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ]
                                  : [
                                      SizedBox(
                                        width: double.infinity,
                                        child: eventData[index]
                                                    ['signUpStatus'] ==
                                                true
                                            ? TextButton(
                                                onPressed: () => {
                                                  EasyLoading.show(
                                                      status: 'Updating...'),
                                                  onClickCancelSignUpEvent(
                                                      context, eventData[index])
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange.shade300,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .orange.shade300,
                                                          width: 1,
                                                          style: BorderStyle
                                                              .solid),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "CANCEL".tr(),
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : TextButton(
                                                onPressed: () => {
                                                  EasyLoading.show(
                                                      status: 'Updating...'),
                                                  onClickSignUpEvent(
                                                      context,
                                                      eventData[index],
                                                      onRefresh)
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange.shade300,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .orange.shade300,
                                                          width: 1,
                                                          style: BorderStyle
                                                              .solid),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "SIGN UP".tr(),
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Future<void> startSession(BuildContext context, eventData) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   var userName = prefs.getString('userName')!;
  //   var userOrgId = prefs.getString('userOrgId')!;
  //   var userUid = prefs.getString('userUid')!;
  //
  //   final qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  //
  //   var userPhoneNumber;
  //   // print(eventData['id']);
  //   FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(userUid)
  //       .get()
  //       .then((data) {
  //
  //     // setState(() {
  //     //   userPhoneNumber: data['PhoneNumber']
  //     // });
  //   });
  //   return showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20.0),
  //     ),
  //     builder: (BuildContext context) {
  //       return SizedBox(
  //         height: MediaQuery.of(context).size.height * 0.6,
  //         width: double.infinity,
  //         child: Center(
  //           child: ElevatedButton(
  //               onPressed: () {
  //                 qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
  //                     context: context,
  //                     onCode: (code) async {
  //                       var originalText =
  //                           decryptAESCryptoJS(code!, 'SenzeHub is the best');
  //                       if (originalText.contains("-")) {
  //                         var splited = originalText.split("-");
  //                         var currentDateTime = DateTime.now();
  //
  //                         DateTime dateToCompare =
  //                             DateFormat('EEE MMM dd yyyy HH:mm:ss')
  //                                 .parse(splited[1]);
  //                         final Duration difference =
  //                             currentDateTime.difference(dateToCompare);
  //                         // print(difference.inMinutes);
  //
  //                         if (difference.inMinutes < 1.0) {
  //                           var checkUserExists =
  //                               await FirebaseFirestore.instanceFor(
  //                                       app: Firebase.app("secondary"))
  //                                   .collection('Users')
  //                                   .doc(splited[0])
  //                                   .get();
  //                           if (checkUserExists.exists &&
  //                               splited[0] == eventData['event']['Elderly']) {
  //                             var checkVolunteerinList =
  //                                 await FirebaseFirestore.instanceFor(
  //                                         app: Firebase.app("secondary"))
  //                                     .collection('Users')
  //                                     .doc(splited[0])
  //                                     .collection('VolunteersList')
  //                                     .where('PhoneNumber',
  //                                         isEqualTo: userPhoneNumber)
  //                                     .get();
  //                             if (checkVolunteerinList.docs.isNotEmpty) {
  //                               var dbRefCaseNote =
  //                                   FirebaseFirestore.instanceFor(
  //                                           app: Firebase.app("secondary"))
  //                                       .collection('Users')
  //                                       .doc(splited[0])
  //                                       .collection('CaseNotesHistory');
  //
  //                               dbRefCaseNote
  //                                   .orderBy("CreatedAt", descending: true)
  //                                   .limit(1)
  //                                   .get()
  //                                   .then((caseNoteSnapshot) => {
  //                                         dbRefCaseNote
  //                                             .doc(eventData['id'])
  //                                             .set({
  //                                           'TimeIn': DateTime.now().toString(),
  //                                           'CreatedAt': DateTime.now(),
  //                                           'VisitBy': userUid,
  //                                           'Type': "Befriending"
  //                                         }).then((value) => {
  //                                                   // Update event status and casenote ID
  //                                                   FirebaseFirestore.instanceFor(
  //                                                           app: Firebase.app(
  //                                                               "secondary"))
  //                                                       .collection(
  //                                                           'BefriendBuddyDetails')
  //                                                       .doc(eventData['id'])
  //                                                       .update({
  //                                                     'CasenoteID':
  //                                                         eventData['id'],
  //                                                     'Status': 1
  //                                                   }).then((value) => {
  //                                                             AwesomeDialog(
  //                                                               context:
  //                                                                   context,
  //                                                               dialogType:
  //                                                                   DialogType
  //                                                                       .success,
  //                                                               animType: AnimType
  //                                                                   .bottomSlide,
  //                                                               title: '',
  //                                                               desc:
  //                                                                   'Everything is good now'
  //                                                                       .tr(),
  //                                                               btnOkOnPress:
  //                                                                   () {
  //                                                                 Navigator.pop(
  //                                                                     context);
  //                                                               },
  //                                                             ).show()
  //                                                           })
  //                                                 })
  //                                       });
  //                             } else {
  //                               AwesomeDialog(
  //                                 context: context,
  //                                 dialogType: DialogType.error,
  //                                 animType: AnimType.bottomSlide,
  //                                 title: 'Error'.tr(),
  //                                 desc:
  //                                     'You are not granted to visit this senior'
  //                                         .tr(),
  //                                 btnOkOnPress: () {
  //                                   Navigator.pop(context);
  //                                 },
  //                               ).show();
  //                             }
  //                           } else {
  //                             AwesomeDialog(
  //                               context: context,
  //                               dialogType: DialogType.error,
  //                               animType: AnimType.bottomSlide,
  //                               title: 'Error'.tr(),
  //                               desc: 'Senior not found'.tr(),
  //                               btnOkOnPress: () {
  //                                 Navigator.pop(context);
  //                               },
  //                             ).show();
  //                           }
  //                         } else {
  //                           AwesomeDialog(
  //                             context: context,
  //                             dialogType: DialogType.error,
  //                             animType: AnimType.bottomSlide,
  //                             title: 'Error'.tr(),
  //                             desc: 'Kindly use the latest QR code'.tr(),
  //                             btnOkOnPress: () {
  //                               Navigator.pop(context);
  //                             },
  //                           ).show();
  //                         }
  //                       } else {
  //                         AwesomeDialog(
  //                           context: context,
  //                           dialogType: DialogType.error,
  //                           animType: AnimType.bottomSlide,
  //                           title: 'Error'.tr(),
  //                           desc: 'Invalid QR code'.tr(),
  //                           btnOkOnPress: () {
  //                             Navigator.pop(context);
  //                           },
  //                         ).show();
  //                       }
  //                     });
  //               },
  //               child: const Text(
  //                   "Click me to senior's QR code to start the session")),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> onClickSignUpEvent(
      BuildContext context, eventData, onRefresh) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userName = prefs.getString('userName')!;

    var userOrgId = prefs.getString('userOrgId')!;

    var userUid = prefs.getString('userUid')!;

    FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('JoinEvents')
        .add({
      'EventDetails': eventData['id'],
      'AttendedStatus': 'false',
      'CreatedBy': userUid,
      'CreatedAt': DateTime.now(),
      'Address': eventData['event']['Address'],
      'OrganizationId': eventData['event']['OrganizationId'],
      'Postal': eventData['event']['Postal'],
      'SignUpStatus': true
    }).then((vale) => {
              onRefresh
              //   AwesomeDialog(
              //     context: context,
              //     dialogType: DialogType.success,
              //     animType: AnimType.bottomSlide,
              //     dismissOnTouchOutside: true,
              //     title: '',
              //     desc: 'Sign up successfully'.tr(),
              //     btnOkOnPress: () {
              //       // onRefresh;
              //     },
              //   ).show()
            });
  }

  String decryptAESCryptoJS(String encrypted, String passphrase) {
    try {
      Uint8List encryptedBytesWithSalt = base64.decode(encrypted);

      Uint8List encryptedBytes =
          encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
      final salt = encryptedBytesWithSalt.sublist(8, 16);
      var keyndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyndIV.item1);
      final iv = encrypt.IV(keyndIV.item2);

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
      final decrypted =
          encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
      return decrypted;
    } catch (error) {
      rethrow;
    }
  }

  Tuple2<Uint8List, Uint8List> deriveKeyAndIV(
      String passphrase, Uint8List salt) {
    var password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash = Uint8List(0);

    while (!enoughBytesForKey) {
      int preHashLength = currentHash.length + password.length + salt.length;
      if (currentHash.isNotEmpty) {
        preHash = Uint8List.fromList(currentHash + password + salt);
      } else {
        preHash = Uint8List.fromList(password + salt);
      }

      // currentHash = md5.convert(preHash).bytes;
      currentHash = Uint8List.fromList(md5.convert(preHash).bytes);
      concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
      if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
    }

    var keyBtyes = concatenatedHashes.sublist(0, 32);
    var ivBtyes = concatenatedHashes.sublist(32, 48);
    return Tuple2(keyBtyes, ivBtyes);
  }

  Uint8List createUint8ListFromString(String s) {
    var ret = Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  onClickCancelSignUpEvent(BuildContext context, eventData) {
    FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('JoinEvents')
        .doc(eventData['signUpId'])
        .update({
      'Delete': "true",
    }).then((vale) => {
              onRefresh
              //   AwesomeDialog(
              //     context: context,
              //     dialogType: DialogType.success,
              //     animType: AnimType.bottomSlide,
              //     dismissOnTouchOutside: true,
              //     title: '',
              //     desc: 'Cancel successfully'.tr(),
              //     btnOkOnPress: () {
              //       // onRefresh;
              //     },
              //   ).show()
            });
  }
}

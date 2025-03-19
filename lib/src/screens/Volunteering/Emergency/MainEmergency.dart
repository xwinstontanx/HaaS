import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import '../../../../firebase_options_senzehub.dart';
import '../VolunteeringService.dart';
import 'Emergency.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:badges/badges.dart' as badges;

class MainEmergencyPage extends StatefulWidget {
  final VolunteeringService service;

  const MainEmergencyPage({Key? key, required this.service}) : super(key: key);

  @override
  State<MainEmergencyPage> createState() => MainEmergencyPageState();
}

class MainEmergencyPageState extends State<MainEmergencyPage> {
  var elderlyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getElderlyList();
  }

  Future<void> getElderlyList() async {
    elderlyList = [];
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    if (widget.service.elderlyUnderCareList.length > 0) {
      for (var elderly in widget.service.elderlyUnderCareList) {
        await FirebaseFirestore.instanceFor(app: secondaryApp)
            .collection('Notification')
            .where('NotifyStatus', whereIn: ["open", "close"])
            .where('SeniorUid', isEqualTo: elderly['Uid'])
            .orderBy('CreatedAt', descending: true)
            .limit(1)
            .get()
            .then((querySnapshot) async {
              if (querySnapshot.docs.isNotEmpty) {
                // if (querySnapshot.docs.first.data()['NotifyStatus'] ==
                //         'open' ||
                //     querySnapshot.docs.first.data()['NotifyStatus'] ==
                //         'close') {
                DateTime myDateTime = DateTime.parse(querySnapshot.docs.first
                    .data()['CreatedAt']
                    .toDate()
                    .toString());
                String formattedDateTime =
                    DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);
                DateTime currentTime = DateTime.now();
                Duration difference = currentTime.difference(myDateTime);

                String formattedTime = formatDuration(difference);

                await FirebaseFirestore.instanceFor(app: secondaryApp)
                    .collection('Notification')
                    .where('NotifyStatus', whereIn: ["open"])
                    .where('SeniorUid', isEqualTo: elderly['Uid'])
                    .get()
                    .then((querySnapshot) {
                      if (querySnapshot.docs.isNotEmpty) {
                        setState(() {
                          elderlyList.add({
                            'Uid': elderly['Uid'],
                            'data': elderly['data'],
                            'emergencyCreatedAt':
                                '$formattedDateTime \n ($formattedTime)',
                            'unReadData': true
                          });
                          elderlyList.sort((a, b) => b['emergencyCreatedAt']
                              .compareTo(a['emergencyCreatedAt']));
                          isLoading = false;
                        });
                      } else {
                        setState(() {
                          elderlyList.add({
                            'Uid': elderly['Uid'],
                            'data': elderly['data'],
                            'emergencyCreatedAt':
                                '$formattedDateTime \n ($formattedTime)',
                            'unReadData': false
                          });
                          elderlyList.sort((a, b) => b['emergencyCreatedAt']
                              .compareTo(a['emergencyCreatedAt']));
                          isLoading = false;
                        });
                      }
                    });

                // }
              } else {
                setState(() {
                  elderlyList.add({
                    'Uid': elderly['Uid'],
                    'data': elderly['data'],
                    'emergencyCreatedAt': '--',
                    'unReadData': false
                  });
                  elderlyList.sort((a, b) => b['emergencyCreatedAt']
                      .compareTo(a['emergencyCreatedAt']));
                  isLoading = false;
                });
              }
            });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("ALERTS".tr()),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: isLoading
                ? LoadingAnimationWidget.horizontalRotatingDots(
                    color: Colors.blue,
                    size: 50,
                  )
                : widget.service.elderlyUnderCareList.length > 0
                    ? SizedBox(
                        width: kIsWeb ? FormFactor.desktop : double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GridView.count(
                              physics: const ScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: kIsWeb ? 0.7 : 0.7,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                ...elderlyList.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    //apply padding to all four sides
                                    child: Container(
                                      decoration: boxDecoration(Colors.blue),
                                      child: InkWell(
                                        splashColor: Colors.green,
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmergencyPage(
                                                          service:
                                                              widget.service,
                                                          senior: item)))
                                              .then((value) => retrieveData());
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              item?['unReadData']
                                                  ? badges.Badge(
                                                      badgeContent: Text('New'.tr(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 6)),
                                                      child: ProfilePicture(
                                                        name: item?['data']
                                                            ['Name'],
                                                        role: '',
                                                        radius: 45,
                                                        fontsize: 20,
                                                        tooltip: false,
                                                        count: 2,
                                                        img: item?['data']
                                                            ['ProfilePic'],
                                                      ),
                                                    )
                                                  : ProfilePicture(
                                                      name: item?['data']
                                                          ['Name'],
                                                      role: '',
                                                      radius: 45,
                                                      fontsize: 20,
                                                      tooltip: false,
                                                      count: 2,
                                                      img: item?['data']
                                                          ['ProfilePic'],
                                                    ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 6.0, 0.0, 0.0),
                                                child: Text(
                                                    item['data']['Name']
                                                        .toUpperCase(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 12.0, 0.0, 12.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                          'Last Record:'.tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 11,
                                                          )),
                                                    ),
                                                    Text(
                                                        item[
                                                            'emergencyCreatedAt'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                      )
                    : emptyContent(),
          ),
        ),
      ),
    );
  }

  Center emptyContent() {
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
                    const Icon(Icons.handshake, size: 50, color: Colors.blue),
                    Text("No Senior(s) Was Paired".tr(),
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          "Relevant content will appear in this space".tr(),
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

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:moment_dart/moment_dart.dart';
import 'package:senzepact/src/screens/Home/Games/volGames.dart';
// import 'package:senzepact/src/screens/Home/LuckyDraw/LuckyDraw.dart';
import 'package:senzepact/src/screens/Home/TotalPointEarned/PointEarned.dart';
import 'package:senzepact/src/screens/Home/Merchant/Merchant.dart';
import 'package:senzepact/src/screens/Home/Recycling.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'Pedometer/Pedometer.dart';
import 'Quiz/MainQuizPage.dart';
import '../Responsive/FormFactor.dart';
//
// import 'package:barcode_scan2/barcode_scan2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var userUid = "";
  var userName = "";
  var healthCheckList = [];

  // Group Value for Radio Button.
  int id = 1;
  int selectedDate = 0;
  int selectedTime = 0;

  var _scanBarcode = "";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    // await getLocation();
    await getHealthEventsData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  Future<void> getHealthEventsData() async {
    FirebaseFirestore.instance
        .collection('HealthCheckEvents')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((healthCheckSnapshot) => {
              healthCheckList = [],
              if (healthCheckSnapshot.docs.isNotEmpty)
                {
                  healthCheckSnapshot.docs.forEach((hcEvents) {
                    if (hcEvents.data()["Display"] == "yes") {
                      setState(() {
                        healthCheckList.add({
                          'docID': hcEvents.id,
                          'data': hcEvents.data(),
                        });
                      });

                      for (var i = 0; i < healthCheckList.length; i++) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(userUid)
                            .collection("HealthEventsBooking")
                            .where('HealthEventsID',
                                isEqualTo: healthCheckList[i]["docID"])
                            .get()
                            .then((querySnapshot) {
                          if (querySnapshot.docs.isNotEmpty) {
                            for (var result in querySnapshot.docs) {
                              setState(() {
                                healthCheckList[i]['bookedInfo'] =
                                    result.data();
                              });
                            }
                          }
                        });
                      }
                    }
                  })
                }
            });
  }

  Future<void> getLocation() async {
    // LocationPermission permission = await Geolocator.checkPermission();
    // print(permission);

    // LocationPermission permission2 = await Geolocator.requestPermission();
    // // print(permission2);
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // // print(position);
    //
    // await FirebaseFirestore.instance.collection('Users').doc(userUid).update({
    //   'GeoLocation': {
    //     'coordinates': GeoPoint(position.latitude, position.longitude)
    //   }
    // }).then((value) => print("User Updated Geo"));
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  List<DropdownMenuItem<String>> dropdownItemsDate(dates) {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var date in dates) {
      menuItems.add(DropdownMenuItem(value: date, child: Text(date)));
    }
    return menuItems;
  }

  List<DropdownMenuItem<String>> dropdownItemsTime(times) {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var time in times) {
      menuItems.add(DropdownMenuItem(value: time, child: Text(time)));
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('${"HELLO".tr()} $userName,'),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            // ShowScore(context)
            // ShowQR(context)
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                    physics: const ScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: kIsWeb ? 0.8 : 0.8,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      BefriendingVolunteer(),
                      Quizzes(),
                      Merchants(),
                      // MadeForFamiliesPartners(),
                      // Community(),
                      // Medical_Activity(),
                      // SilverSurfers(),
                      Games(),
                      Recycling(),
                      Pedometer(),
                      // CCEvent(),
                      // LuckyDraw(),
                      // ...healthCheckList.map((item) {
                      //   ShowHealthCheckEvent(item);
                      // }).toList(),
                    ]),
              ),
            ),
          ),
        ),
        // Positioned(
        //   bottom: 60,
        //   right: 0,
        //   child: Align(
        //     alignment: FractionalOffset.bottomRight,
        //     child: Padding(
        //       padding: const EdgeInsets.all(15),
        //       child: Image.asset('assets/images/senzepact_by_senzehub.png',
        //           width: 120, fit: BoxFit.contain),
        //     ),
        //   ),
        // )
      ),
    );
  }

  Padding ShowScore(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PointEarnedPage()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.catching_pokemon, size: 35),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PointEarnedPage()));
              },
              color: Colors.white,
            ),
            Text("Score".tr()),
          ],
        ),
      ),
    );
  }

  IconButton ShowQR(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () {
        // scanQR();
        // showModalBottomSheet<void>(
        //   context: context,
        //   isScrollControlled: true,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(20.0),
        //   ),
        //   builder: (BuildContext context) {
        //     return Padding(
        //       padding: const EdgeInsets.all(12.0),
        //       child: SizedBox(
        //         height: MediaQuery.of(context).size.height * 0.2,
        //         width: double.infinity,
        //         child: Column(
        //           children: [
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.end,
        //               children: [
        //                 IconButton(
        //                   icon: const Icon(
        //                     Icons.close,
        //                     size: 35,
        //                   ),
        //                   color: Colors.grey.shade700,
        //                   onPressed: () {
        //                     Navigator.pop(context);
        //                   },
        //                 ),
        //               ],
        //             ),
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: <Widget>[
        //                 Flex(
        //                     direction: Axis.vertical,
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: <Widget>[
        //                       ElevatedButton(
        //                           onPressed: () => scanQR(),
        //                           child: Text('Start QR scan')),
        //                       // Text('Scan result : $_scanBarcode\n',
        //                       //     style: TextStyle(fontSize: 20))
        //                     ]),
        //                 Padding(
        //                   padding: EdgeInsets.all(10.0),
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // );
      },
      color: Colors.white,
    );
  }

  // Future<void> scanQR() async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _scanBarcode = barcodeScanRes;
  //   });
  //
  //   FirebaseFirestore.instance
  //       .collection('DiscountCode')
  //       .orderBy('CreatedAt', descending: true)
  //       .get()
  //       .then((snapshot) {
  //     DateTime current = DateTime.now();
  //     snapshot.docs.forEach((dataSnapshot) {
  //       print(dataSnapshot.data().toString() + " HSGDFDGDFGF");
  //       if (dataSnapshot.data()['Code'].toString() == _scanBarcode.toString()) {
  //         DateTime startDateTime = DateTime.parse(
  //             dataSnapshot.data()['StartDateTime'].toDate().toString());
  //         String formattedStartDateTime =
  //             DateFormat('yyyy-MM-dd hh:mma').format(startDateTime);
  //
  //         DateTime endDateTime = DateTime.parse(
  //             dataSnapshot.data()['EndDateTime'].toDate().toString());
  //         String formattedEndDateTime =
  //             DateFormat('yyyy-MM-dd hh:mma').format(endDateTime);
  //
  //         if (dataSnapshot.data()['StartDateTime'].millisecondsSinceEpoch <
  //                 current.millisecondsSinceEpoch &&
  //             current.millisecondsSinceEpoch <
  //                 dataSnapshot.data()['EndDateTime'].millisecondsSinceEpoch) {
  //           FirebaseFirestore.instance
  //               .collection('Users')
  //               .doc(userUid)
  //               .collection('RewardsHistory')
  //               .where("Code", isEqualTo: _scanBarcode)
  //               .get()
  //               .then((snapshotRH) {
  //             if (snapshotRH.docs.isEmpty) {
  //               FirebaseFirestore.instance
  //                   .collection('Users')
  //                   .doc(userUid)
  //                   .collection("RewardsHistory")
  //                   .add({
  //                 'CreatedAt': DateTime.now(),
  //                 'MerchantID ': dataSnapshot.id,
  //                 'Code': _scanBarcode,
  //                 'Value': dataSnapshot.data()['Value'],
  //                 'Remark': dataSnapshot.data()['Remark'],
  //               });
  //
  //               AwesomeDialog(
  //                 context: context,
  //                 animType: AnimType.leftSlide,
  //                 headerAnimationLoop: false,
  //                 dialogType: DialogType.success,
  //                 showCloseIcon: true,
  //                 title: 'Scan Successfully'.tr(),
  //                 desc: _scanBarcode,
  //                 btnOkOnPress: () {},
  //                 btnOkIcon: Icons.check_circle,
  //               ).show();
  //             }
  //             if (snapshotRH.docs.isNotEmpty) {
  //               AwesomeDialog(
  //                 context: context,
  //                 animType: AnimType.leftSlide,
  //                 headerAnimationLoop: false,
  //                 dialogType: DialogType.warning,
  //                 showCloseIcon: true,
  //                 title: 'Code Used'.tr(),
  //                 desc: _scanBarcode,
  //                 btnOkOnPress: () {},
  //                 btnOkIcon: Icons.check_circle,
  //               ).show();
  //             }
  //           });
  //         }
  //         if (dataSnapshot.data()['StartDateTime'].millisecondsSinceEpoch <
  //                 current.millisecondsSinceEpoch &&
  //             current.millisecondsSinceEpoch >
  //                 dataSnapshot.data()['EndDateTime'].millisecondsSinceEpoch) {
  //           AwesomeDialog(
  //             context: context,
  //             animType: AnimType.leftSlide,
  //             headerAnimationLoop: false,
  //             dialogType: DialogType.warning,
  //             showCloseIcon: true,
  //             title: 'Promo Ends'.tr() + ' at ' + formattedEndDateTime,
  //             // desc: _scanBarcode,
  //             btnOkOnPress: () {},
  //             btnOkIcon: Icons.check_circle,
  //           ).show();
  //         }
  //         if (dataSnapshot.data()['StartDateTime'].millisecondsSinceEpoch >
  //                 current.millisecondsSinceEpoch &&
  //             current.millisecondsSinceEpoch <
  //                 dataSnapshot.data()['EndDateTime'].millisecondsSinceEpoch) {
  //           AwesomeDialog(
  //             context: context,
  //             animType: AnimType.leftSlide,
  //             headerAnimationLoop: false,
  //             dialogType: DialogType.warning,
  //             showCloseIcon: true,
  //             title: 'Promo starts at '.tr() + formattedStartDateTime,
  //             // desc: _scanBarcode,
  //             btnOkOnPress: () {},
  //             btnOkIcon: Icons.check_circle,
  //           ).show();
  //         }
  //       } else {
  //         if (_scanBarcode != "-1") {
  //           AwesomeDialog(
  //             context: context,
  //             animType: AnimType.leftSlide,
  //             headerAnimationLoop: false,
  //             dialogType: DialogType.warning,
  //             showCloseIcon: true,
  //             title: 'Invalid code'.tr(),
  //             desc: _scanBarcode,
  //             btnOkOnPress: () {},
  //             btnOkIcon: Icons.check_circle,
  //           ).show();
  //         }
  //       }
  //     });
  //   });
  // }

  Padding CCEvent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 80.0),
                    child: Image.asset('assets/images/brochure.jpeg'),
                  );
                });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.groups,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    children: [
                      Text("National Family Weekend".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text("10 - 11 June\nPunggol Comm Club".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding SilverSurfers() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        //apply padding to all four sides
        child: Container(
          decoration: boxDecoration(Colors.blue),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () {
              launchInBrowser(
                  Uri(scheme: 'https', host: 'www.empower.org.sg', path: '/'));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Icon(Icons.connect_without_contact,
                    color: Colors.blueAccent, size: 50.0),
                // <-- Icon
                Text("Silver Surfers".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                // <-- Text
              ],
            ),
          ),
        ));
  }

  Padding Medical_Activity() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        //apply padding to all four sides
        child: Container(
          decoration: boxDecoration(Colors.blue),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () {
              launchInBrowser(Uri(
                  scheme: 'https',
                  host: 'www.senzepact.com',
                  path: '/wellness'));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Icon(Icons.accessibility,
                    color: Colors.blueAccent, size: 50.0),
                // <-- Icon
                Text("Medical / Activities".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                // <-- Text
              ],
            ),
          ),
        ));
  }

  Padding MadeForFamiliesPartners() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            launchInBrowser(Uri(
                scheme: 'https',
                host: 'www.senzepact.com',
                path: '/community'));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Icon(Icons.groups, color: Colors.blueAccent, size: 50.0),
              // <-- Icon
              Text("Made For Families Partners".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Community() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            launchInBrowser(Uri(
                scheme: 'https',
                host: 'www.senzepact.com',
                path: '/community'));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Icon(Icons.groups, color: Colors.blueAccent, size: 50.0),
              // <-- Icon
              Text("COMMUNITY".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Quizzes() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MainQuizPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.quiz,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Quizzes".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Merchants() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MerchantPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.business,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Local Community Merchants".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding LuckyDraw() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => LuckyDraw()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.event,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Lucky Draw".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Games() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const GamesPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.videogame_asset,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Games".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Recycling() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            // launchInBrowser(Uri(
            //     scheme: 'https',
            //     host: 'www.senzehealth.com',
            //     path: '/community/#contact'));
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RecyclingPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.recycling,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("RECYCLING".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding Pedometer() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            // launchInBrowser(Uri(
            //     scheme: 'https',
            //     host: 'www.senzehealth.com',
            //     path: '/community/#contact'));
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PedometerPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.directions_run,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Pedometer".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding ShowHealthCheckEvent(item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      //apply padding to all four sides
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (item['bookedInfo'] != null) {
                    selectedDate = item['bookedInfo']['DateIndex'];
                    selectedTime = item['bookedInfo']['TimeIndex'];
                  } else {
                    selectedDate = 0;
                    selectedTime = 0;
                  }
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(item['data']['EventTitle'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                decoration: TextDecoration.underline)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            child: Text('CANCEL'.tr()),
                          ),
                          TextButton(
                            onPressed: () {
                              submitHealthCheckEvent(
                                  item,
                                  selectedDate,
                                  item['data']['Date'][selectedDate],
                                  selectedTime,
                                  item['data']['Time'][selectedTime]);
                              Navigator.pop(context);
                            },
                            child: Text('OK'.tr()),
                          ),
                        ],
                        content: SizedBox(
                          width: double.minPositive,
                          height: double.maxFinite,
                          child: Column(
                            children: [
                              Container(
                                decoration: boxDecoration(Colors.orange),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.orange),
                                          const SizedBox(width: 5),
                                          Text('ADDRESS'.tr(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(item['data']['Address'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.orange,
                                                fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (item['bookedInfo'] != null)
                                Container(
                                  decoration: boxDecoration(Colors.green),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.bookmark_added_outlined,
                                              color: Colors.green),
                                          const SizedBox(width: 5),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text('Remark'.tr(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                            "You have booked Health Check"
                                                    .tr() +
                                                "\n " +
                                                item['bookedInfo']['Date'] +
                                                "\n" +
                                                item['bookedInfo']['Time'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: boxDecoration(Colors.blue),
                                child: Column(
                                  children: [
                                    if (item['bookedInfo'] == null)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'Select Date and Time below and click \"Ok\" to book a slot:'
                                                .tr(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14)),
                                      ),
                                    if (item['bookedInfo'] != null)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                            'Select Date and Time below and click \"Ok\" to modify:'
                                                .tr(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14)),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text('Select Date'.tr(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline)),
                                            DropdownButton<String>(
                                              value: item['data']['Date']
                                                  [selectedDate],
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              // underline: Container(
                                              //   height: 1,
                                              //   color: Colors.blue,
                                              // ),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  selectedDate = item['data']
                                                          ['Date']
                                                      .indexWhere(((date) =>
                                                          date == value));
                                                });
                                              },
                                              items: dropdownItemsTime(
                                                  item['data']['Date']),
                                            ),

                                            // SizedBox(
                                            //   height:200,
                                            //   child: Padding(
                                            //     padding: const EdgeInsets.only(
                                            //         bottom: 15.0),
                                            //     child: ListView.builder(
                                            //       shrinkWrap: true,
                                            //       itemCount:
                                            //           item['data']['Date'].length,
                                            //       itemBuilder:
                                            //           (BuildContext context,
                                            //               int index2) {
                                            //         return RadioListTile<int>(
                                            //           visualDensity:
                                            //               const VisualDensity(
                                            //                   horizontal: -4,
                                            //                   vertical: -4),
                                            //           contentPadding:
                                            //               EdgeInsets.zero,
                                            //           value: index2,
                                            //           groupValue: selectedDate,
                                            //           title: Text(item['data']
                                            //               ['Date'][index2]),
                                            //           onChanged: (value) {
                                            //             if (value is int) {
                                            //               setState(() {
                                            //                 selectedDate = value;
                                            //               });
                                            //             }
                                            //           },
                                            //         );
                                            //       },
                                            //     ),
                                            //   ),
                                            // ),
                                            const SizedBox(height: 10),
                                            Text('Select Time'.tr(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline)),
                                            DropdownButton<String>(
                                              value: item['data']['Time']
                                                  [selectedTime],
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              // underline: Container(
                                              //   height: 1,
                                              //   color: Colors.blue,
                                              // ),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  selectedTime = item['data']
                                                          ['Time']
                                                      .indexWhere(((time) =>
                                                          time == value));
                                                });
                                              },
                                              items: dropdownItemsTime(
                                                  item['data']['Time']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   height: 400,
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(
                              //         bottom: 15.0),
                              //     child: ListView.builder(
                              //       shrinkWrap: true,
                              //       itemCount:
                              //           item['data']['Time'].length,
                              //       itemBuilder:
                              //           (BuildContext context,
                              //               int index2) {
                              //         return RadioListTile(
                              //           visualDensity:
                              //               const VisualDensity(
                              //                   horizontal: -4,
                              //                   vertical: -4),
                              //           contentPadding:
                              //               EdgeInsets.zero,
                              //           value: index2,
                              //           groupValue: selectedTime,
                              //           title: Text(item['data']
                              //               ['Time'][index2]),
                              //           onChanged: (newValue) =>
                              //               setState(() {
                              //             selectedTime =
                              //                 newValue as int;
                              //           }),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Icon(Icons.assignment_rounded,
                    color: Colors.blueAccent, size: 40.0),
                Text(item['data']['Month'].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                Text(item['data']['EventTitle'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding BefriendingVolunteer() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            launchInBrowser(Uri(
                scheme: 'https',
                host: 'www.senzepact.com',
                path: '/befriending-seniors'));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.volunteer_activism,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("BEFRIENDING VOLUNTEER".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              // <-- Text
            ],
          ),
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

  void submitHealthCheckEvent(
      hcItem, selectedDate, hcDate, selectedTime, hcTime) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("HealthEventsBooking")
        .where('HealthEventsID', isEqualTo: hcItem["docID"])
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var result in querySnapshot.docs) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .collection("HealthEventsBooking")
              .doc(result.id)
              .update({
            'UpdatedAt': DateTime.now(),
            'DateIndex': selectedDate,
            'Date': hcDate,
            'TimeIndex': selectedTime,
            'Time': hcTime,
          });
        }
      } else {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(userUid)
            .collection("HealthEventsBooking")
            .add({
          'CreatedAt': DateTime.now(),
          'HealthEventsID': hcItem["docID"],
          'DateIndex': selectedDate,
          'Date': hcDate,
          'TimeIndex': selectedTime,
          'Time': hcTime,
          'Month': hcItem["data"]["Month"],
          'AttendedStatus': false,
        });
      }
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.success,
        showCloseIcon: true,
        title: 'Submitted Successfully'.tr(),
        desc: 'You have booked Health Check'.tr(),
        btnOkOnPress: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        },
        // btnOkIcon: Icons.check_circle,
      ).show();
    });
  }
}

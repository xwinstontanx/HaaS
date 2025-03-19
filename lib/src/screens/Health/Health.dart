import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Health/HealthHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:flutter/foundation.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({Key? key}) : super(key: key);

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  var userUid = "";
  var userName = "";
  var HeartRateValue = "-- ";
  var Spo2Value = "-- ";
  var TemperatureValue = "-- ";
  DateTime? createdDateHR;
  var SystolicValue = "-- ";
  var DiastolicValue = "-- ";
  DateTime? createdDateBP;
  var BloodGlucoseValue = "-- ";
  DateTime? createdDateBG;
  var WeightValue = "-- ";
  DateTime? createdDateWeight;
  var HeightValue = "-- ";
  DateTime? createdDateHeight;
  var BMIValue = "-- ";

  var months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    getUser().then((value) => getHealthData());
  }

  Future<void> getHealthData() async {
    // let startTime = moment().utcOffset(0);
    // startTime.set({ hour: 0, minute: 0, second: 0, millisecond: 0 })
    //
    // let endTime = moment().utcOffset(0).add(1, 'd');
    // endTime.set({ hour: 0, minute: 0, second: 0, millisecond: 0 })

    DateTime now = DateTime.now().toUtc();

    DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0, 0, 0, 0);

    Duration oneDay = const Duration(days: 1);
    DateTime endTime = startTime.add(oneDay);

    // Get today's latest Health data (DeviceType: 5 (BG), 4 (Weight), 3 (BP), 2 (Desktop), 1 (Wearable))
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 1)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((wearSnapshot) {
      if (wearSnapshot.docs.isNotEmpty) {
        final wearDetailSnapshot = wearSnapshot.docs.first;
        setState(() {
          HeartRateValue = wearDetailSnapshot.data()['HeartRate'].toString();
          Spo2Value = wearDetailSnapshot.data()['Spo2'].toString();
          TemperatureValue =
              wearDetailSnapshot.data()['Temperature'].toString();
          createdDateHR = wearDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 2)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((deskSnapshot) {
      if (deskSnapshot.docs.isNotEmpty) {
        final deskDetailSnapshot = deskSnapshot.docs.first;
        setState(() {
          HeartRateValue = deskDetailSnapshot.data()['HeartRate'].toString();
          Spo2Value = deskDetailSnapshot.data()['Spo2'].toString();
          TemperatureValue =
              deskDetailSnapshot.data()['Temperature'].toString();
          createdDateHR = deskDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 3)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((bpSnapshot) {
      if (bpSnapshot.docs.isNotEmpty) {
        final bpDetailSnapshot = bpSnapshot.docs.first;
        setState(() {
          SystolicValue = bpDetailSnapshot.data()['Systolic'].toString();
          DiastolicValue = bpDetailSnapshot.data()['Diastolic'].toString();
          createdDateBP = bpDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 5)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((bgSnapshot) {
      if (bgSnapshot.docs.isNotEmpty) {
        final bgDetailSnapshot = bgSnapshot.docs.first;
        setState(() {
          BloodGlucoseValue =
              bgDetailSnapshot.data()["BloodGlucose"].toString();
          createdDateBG = bgDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 4)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((weightSnapshot) {
      if (weightSnapshot.docs.isNotEmpty) {
        final weightDetailSnapshot = weightSnapshot.docs.first;

        setState(() {
          WeightValue = weightDetailSnapshot.data()["Weight"].toString();
          createdDateWeight = weightDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 6)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .listen((heightSnapshot) {
      if (heightSnapshot.docs.isNotEmpty) {
        final heightDetailSnapshot = heightSnapshot.docs.first;
        setState(() {
          HeightValue = heightDetailSnapshot.data()["Height"].toString();
          createdDateHeight = heightDetailSnapshot.data()['CreatedAt'].toDate();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 7)
        // .where("CreatedAt",
        //     isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        // .where("CreatedAt", isLessThan: Timestamp.fromDate(endTime))
        .orderBy('CreatedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((bmiSnapshot) {
      if (bmiSnapshot.docs.isNotEmpty) {
        final bmiDetailSnapshot = bmiSnapshot.docs.first;
        setState(() {
          BMIValue = bmiDetailSnapshot.data()["BMI"].toString();
        });
      }
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
        title: Text('Health'.tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HealthHistoryPage()));
            },
            color: Colors.white,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getHealthData();
        },
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Hello " +
                    //       userName +
                    //       ", your latest health vitals on ${createdDate.day} ${months[createdDate.month - 1]} ${createdDate.year}",
                    //   style: TextStyle(color: Colors.black, fontSize: 14),
                    // ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            createdDateHR == null
                                ? const SizedBox(height: 0)
                                : Timestamp(
                                    timeStamp: createdDateHR as DateTime),
                            HealthData(
                                icon:
                                    'assets/images/healthcheckicons/heartRate.png',
                                title: "HEART RATE".tr(),
                                value: HeartRateValue,
                                unit: "BPM"),
                            HealthData(
                                icon: 'assets/images/healthcheckicons/spo.png',
                                title: "SPO2".tr(),
                                value: Spo2Value,
                                unit: "%"),
                            HealthData(
                                icon: 'assets/images/healthcheckicons/temp.png',
                                title: "TEMPERATURE".tr(),
                                value: TemperatureValue,
                                unit: "°C"),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            createdDateBP == null
                                ? const SizedBox(height: 0)
                                : Timestamp(
                                    timeStamp: createdDateBP as DateTime),
                            HealthData(
                                icon: 'assets/images/healthcheckicons/bp.png',
                                title: "BLOOD PRESSURE".tr() +
                                    "\n(" +
                                    "SYSTOLIC".tr() +
                                    ")",
                                value: SystolicValue,
                                unit: "mmHg"),
                            HealthData(
                                icon: 'assets/images/healthcheckicons/bp.png',
                                title: "BLOOD PRESSURE".tr() +
                                    "\n(" +
                                    "DIASTOLIC".tr() +
                                    ")",
                                value: DiastolicValue,
                                unit: "mmHg"),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            createdDateBG == null
                                ? const SizedBox(height: 0)
                                : Timestamp(
                                    timeStamp: createdDateBG as DateTime),
                            HealthData(
                                icon:
                                    'assets/images/healthcheckicons/bloodGlucose.png',
                                title: "BLOOD GLUCOSE".tr(),
                                value: BloodGlucoseValue,
                                unit: "mmol/L"),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            createdDateWeight == null
                                ? const SizedBox(height: 0)
                                : Timestamp(
                                    timeStamp: createdDateWeight as DateTime),
                            HealthData(
                                icon:
                                    'assets/images/healthcheckicons/weight.jpeg',
                                title: "WEIGHT".tr(),
                                value: WeightValue,
                                unit: "kg"),
                            HealthData(
                                icon:
                                    'assets/images/healthcheckicons/height.png',
                                title: "HEIGHT".tr(),
                                value: HeightValue,
                                unit: "cm"),
                            HealthData(
                                icon: 'assets/images/healthcheckicons/bmi.png',
                                title: "BMI".tr(),
                                value: BMIValue,
                                unit: "kg/m2"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Timestamp extends StatelessWidget {
  const Timestamp({
    super.key,
    required this.timeStamp,
  });

  final DateTime timeStamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "UPDATED ON".tr() +
            " " +
            DateFormat('dd-MM-yyyy kk:mma').format(timeStamp),
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.indigo,
            fontSize: 14,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HealthData extends StatelessWidget {
  const HealthData({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  final String icon;
  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(icon, width: 40),
                const SizedBox(width: 5),
                Text(title, style: const TextStyle(fontSize: 13)),
              ]),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " " + unit,
                style: const TextStyle(color: Colors.black, fontSize: 11),
              ),
            ],
          ),
        )
      ],
    );
  }
}

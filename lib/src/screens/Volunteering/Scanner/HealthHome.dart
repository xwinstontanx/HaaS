import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Health/HealthHistory.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthBloodGlucose.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthBloodPressure.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthVitals.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthWeight.dart';
import 'package:senzepact/src/screens/Volunteering/Volunteering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:flutter/foundation.dart';

import 'HealthHeight.dart';

class HealthHomePage extends StatefulWidget {
  final String elderlyUid;

  const HealthHomePage(this.elderlyUid, {super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> {
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

  @override
  void initState() {
    super.initState();
    getHealthData();
  }

  Future<void> getHealthData() async {
    DateTime now = DateTime.now().toUtc();

    // For startTime
    DateTime startTime = DateTime.utc(now.year, now.month, now.day, 0, 0, 0, 0);

    // For endTime (adding 1 day to startTime)
    DateTime endTime = startTime.add(Duration(days: 1));

    // Get today's latest Health data (DeviceType: 5 (BG), 4 (Weight), 3 (BP), 2 (Desktop), 1 (Wearable))
    QuerySnapshot wearSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 1)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (wearSnapshot.docs.isNotEmpty) {
      var wearDetailSnapshot = wearSnapshot.docs.first;
      var data = wearDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        HeartRateValue = data['HeartRate']?.toString() ?? '--';
        Spo2Value = data['Spo2']?.toString() ?? '--';
        TemperatureValue = data['Temperature']?.toString() ?? '--';
        createdDateHR = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot deskSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 2)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (deskSnapshot.docs.isNotEmpty) {
      var deskDetailSnapshot = deskSnapshot.docs.first;
      var data = deskDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        HeartRateValue = data['HeartRate']?.toString() ?? '--';
        Spo2Value = data['Spo2']?.toString() ?? '--';
        TemperatureValue = data['Temperature']?.toString() ?? '--';
        createdDateHR = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot bpSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 3)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (bpSnapshot.docs.isNotEmpty) {
      var bpDetailSnapshot = bpSnapshot.docs.first;
      var data = bpDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        SystolicValue = data['Systolic']?.toString() ?? '--';
        DiastolicValue = data['Diastolic']?.toString() ?? '--';
        createdDateBP = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot weightSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 4)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (weightSnapshot.docs.isNotEmpty) {
      var weightDetailSnapshot = weightSnapshot.docs.first;
      var data = weightDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        WeightValue = data['Weight']?.toString() ?? '--';
        createdDateWeight = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot bgSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 5)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (bgSnapshot.docs.isNotEmpty) {
      var bgDetailSnapshot = bgSnapshot.docs.first;
      var data = bgDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        BloodGlucoseValue = data['BloodGlucose']?.toString() ?? '--';
        createdDateBG = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot heightSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 6)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (heightSnapshot.docs.isNotEmpty) {
      var heightDetailSnapshot = heightSnapshot.docs.first;
      var data = heightDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        HeightValue = data['Height']?.toString() ?? '--';
        createdDateHeight = data['CreatedAt']?.toDate() ?? DateTime.now();
      });
    }

    QuerySnapshot bmiSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 7)
        .where("CreatedAt", isGreaterThanOrEqualTo: startTime)
        .where("CreatedAt", isLessThan: endTime)
        .orderBy("CreatedAt", descending: false)
        .limit(1)
        .get();

    if (bmiSnapshot.docs.isNotEmpty) {
      var bmiDetailSnapshot = bmiSnapshot.docs.first;
      var data = bmiDetailSnapshot.data() as Map<String, dynamic>;

      setState(() {
        BMIValue = data['BMI']?.toString() ?? '--';
      });
    }
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => VolunteeringPage()))),
        title: Text('Health'.tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: kIsWeb ? FormFactor.desktop : double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                              : Timestamp(timeStamp: createdDateHR as DateTime),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HealthVitalsPage(widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon:
                                    'assets/images/healthcheckicons/heartRate.png',
                                title: "HEART RATE".tr(),
                                value: HeartRateValue,
                                unit: "BPM"),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HealthVitalsPage(widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon: 'assets/images/healthcheckicons/spo.png',
                                title: "SPO2".tr(),
                                value: Spo2Value,
                                unit: "%"),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HealthVitalsPage(widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon: 'assets/images/healthcheckicons/temp.png',
                                title: "TEMPERATURE".tr(),
                                value: TemperatureValue,
                                unit: "°C"),
                          ),
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
                              : Timestamp(timeStamp: createdDateBP as DateTime),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HealthBloodPressurePage(
                                          widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon: 'assets/images/healthcheckicons/bp.png',
                                title: "BLOOD PRESSURE".tr() +
                                    "\n(" +
                                    "SYSTOLIC".tr() +
                                    ")",
                                value: SystolicValue,
                                unit: "mmHg"),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HealthBloodPressurePage(
                                          widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon: 'assets/images/healthcheckicons/bp.png',
                                title: "BLOOD PRESSURE".tr() +
                                    "\n(" +
                                    "DIASTOLIC".tr() +
                                    ")",
                                value: DiastolicValue,
                                unit: "mmHg"),
                          ),
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
                              : Timestamp(timeStamp: createdDateBG as DateTime),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HealthBloodGlucosePage(
                                          widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon:
                                    'assets/images/healthcheckicons/bloodGlucose.png',
                                title: "BLOOD GLUCOSE".tr(),
                                value: BloodGlucoseValue,
                                unit: "mmol/L"),
                          ),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HealthWeightPage(widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon:
                                    'assets/images/healthcheckicons/weight.jpeg',
                                title: "WEIGHT".tr(),
                                value: WeightValue,
                                unit: "kg"),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HealthHeightPage(widget.elderlyUid)));
                            },
                            child: HealthData(
                                icon:
                                    'assets/images/healthcheckicons/height.png',
                                title: "HEIGHT".tr(),
                                value: HeightValue,
                                unit: "cm"),
                          ),
                          GestureDetector(
                            onTap: () {
                              print('bmi tapped!');
                            },
                            child: HealthData(
                                icon: 'assets/images/healthcheckicons/bmi.png',
                                title: "BMI".tr(),
                                value: BMIValue,
                                unit: "kg/m2"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      getHealthData();
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Refresh Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => VolunteeringPage()));
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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

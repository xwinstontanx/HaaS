import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Health/HealthHistory.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthHome.dart';
import 'package:senzepact/src/screens/Volunteering/Volunteering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:flutter/foundation.dart';

class HealthWeightPage extends StatefulWidget {
  final String elderlyUid;

  const HealthWeightPage(this.elderlyUid, {super.key});

  @override
  State<HealthWeightPage> createState() => _HealthWeightPageState();
}

class _HealthWeightPageState extends State<HealthWeightPage> {
  var userUid = "";
  var userName = "";

  bool manualInput = false;
  bool showFields = false;
  bool autoInput = false;
  String bleStatus = '';

  String weight = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  void handleManualInput() {
    setState(() {
      manualInput = true;
      showFields = true;
      autoInput = false;
      weight = '';
    });
  }

  void handleAutoInput() {
    setState(() {
      manualInput = false;
      showFields = true;
      autoInput = true;
      weight = '--';
    });
  }

  //TODO reference from https://gitlab.com/senzehubiot/senzepact_health_scanner/-/blob/master/src/screens/HealthCheckScreen/HealthCheckWeight.js?ref_type=heads

  Future<void> submit() async {
    if (weight != '') {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.elderlyUid)
            .collection('HealthData')
            .add({
          'DeviceType': 4,
          'Weight': weight,
          // 'DeviceID': deviceId,
          'CreatedAt': DateTime.now(),
        });
        DateTime now = DateTime.now().toUtc();
        // For startTime
        DateTime startTime =
            DateTime.utc(now.year, now.month, now.day, 0, 0, 0, 0);

        // For endTime (adding 1 day to startTime)
        DateTime endTime = startTime.add(Duration(days: 1));
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

          var heightData = data['Height'];
          var bmi = double.parse(weight) /
              ((double.parse(heightData) / 100) *
                  (double.parse(heightData) / 100));

          // Push the BMI value
          FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.elderlyUid)
              .collection('HealthData')
              .add({
            'DeviceType': 7,
            'BMI': double.parse(bmi.toStringAsFixed(1)),
            'CreatedAt': DateTime.now(),
          });
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: ''.tr(),
          desc: 'Health data added successfully!'.tr(),
          btnOkOnPress: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HealthHomePage(widget.elderlyUid)));
          },
        ).show();
      } catch (e) {
        print('Error adding health data: $e');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Error adding health data'.tr(),
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error'.tr(),
        desc: 'Kindly fill up all the fields'.tr(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 40),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Weight Readings',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (!manualInput && !showFields)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: handleManualInput,
                      child: Text('Input weight manually'),
                    ),
                    Text(
                        '------------------------- or -------------------------'),
                    ElevatedButton(
                      onPressed: handleAutoInput,
                      child: Text('Retrieve weight from device'),
                    ),
                  ],
                ),
              if (manualInput && showFields)
                Column(
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          weight = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'WEIGHT (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (weight != '--' && weight.isNotEmpty)
                      ElevatedButton(
                        onPressed: submit,
                        child: Text('Submit'),
                      ),
                  ],
                ),
              if (autoInput)
                Column(
                  children: [
                    //TODO: autoinput field
                    if (weight != '--' && weight.isNotEmpty)
                      ElevatedButton(
                        onPressed: submit,
                        child: Text('Submit'),
                      ),
                  ],
                ),
            ],
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

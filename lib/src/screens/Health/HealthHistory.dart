import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryBMI.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryBloodGlucose.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryBloodPressure.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryHeartRate.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryHeight.dart';
import 'package:senzepact/src/screens/Health/HealthHistorySpo2.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryTemperature.dart';
import 'package:senzepact/src/screens/Health/HealthHistoryWeight.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';

class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({Key? key}) : super(key: key);

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("HEALTH HISTORY".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: kIsWeb ? FormFactor.desktop : double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 60.0),
              child: GridView.count(
                  physics: const ScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: kIsWeb ? 0.8 : 0.8,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    HeartRate(),
                    Spo2(),
                    Temperature(),
                    BloodPressure(),
                    BloodGlucose(),
                    Weight(),
                    Height(),
                    BMI(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Padding HeartRate() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryHeartRatePage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/heartRate.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("HEART RATE".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding Spo2() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistorySpo2Page()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/spo.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("SPO2".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding Temperature() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryTemperaturePage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/temp.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("TEMPERATURE".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding BloodPressure() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryBloodPressurePage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/bp.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("BLOOD PRESSURE".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding BloodGlucose() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryBloodGlucosePage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/bloodGlucose.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("BLOOD GLUCOSE".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding Weight() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryWeightPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/weight.jpeg',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("WEIGHT".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding Height() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryHeightPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/height.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("HEIGHT".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding BMI() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthHistoryBMIPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                'assets/images/healthcheckicons/bmi.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Text("BMI".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
}

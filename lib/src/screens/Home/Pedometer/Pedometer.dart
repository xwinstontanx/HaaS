import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Responsive/FormFactor.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/*
Known issues
- For android it only starts counting when the user install the app
- The latest step counts will be captured if the user move
- Need to launch the app
 */

class _StepData {
  _StepData(this.createdAt, this.value);

  final String createdAt;
  final int value;
}

class PedometerPage extends StatefulWidget {
  const PedometerPage({Key? key}) : super(key: key);

  @override
  State<PedometerPage> createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  final int maxStepCounts = 9999999;
  var userUid = "";
  var userName = "";
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  // String _status = '?';
  int _stepsCummulative = 0;
  int _stepsCummulativeYtd = 0;
  int _stepsDaily = 0;
  String _stepsTimestamp = '';
  late SharedPreferences prefs;
  late DateTime stepTimestampCloud;
  late DateTime stepTimestampLocal;
  final int targetStepCounts = 10000;
  var stepData = [];
  List<_StepData> stepValues = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
    initPlatformState();
  }

  retrieveData() async {
    await getUser();
    await getPermission();
    await getSteps();
    await getStepsHistory();
  }

  Future<void> getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  Future<void> getPermission() async {
    if (await Permission.activityRecognition.isGranted == false) {
      await Permission.activityRecognition.request();
    }
  }

  Future<void> getSteps() async {
    setState(() {
      _stepsCummulative = prefs.getInt('_stepsCumulative') ?? maxStepCounts;
      _stepsCummulativeYtd =
          prefs.getInt('_stepsCumulativeYtd') ?? maxStepCounts;
      _stepsTimestamp = prefs.getString('steps_timestamp') ?? '';
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .get()
        .then((profile) async => {
              if (profile.exists)
                {
                  if (profile.data()!.containsKey("StepsDaily") &&
                      profile.data()!.containsKey("StepsCumulativeYtd"))
                    {
                      prefs.setInt('_stepsCumulativeYtd',
                          profile.data()!['StepsCumulativeYtd']),
                      setState(() {
                        _stepsDaily = profile.data()!['StepsDaily'];
                        _stepsCummulativeYtd =
                            profile.data()!['StepsCumulativeYtd'];
                      })
                    }
                  else
                    {
                      setState(() {
                        _stepsDaily = 0;
                      })
                    }
                }
            });
  }

  Future<void> getStepsHistory() async {
    var collection = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('DailyStepCounts')
        .orderBy('CreatedAt', descending: true);
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();

      DateTime myDateTime =
          DateTime.parse(data['CreatedAt'].toDate().toString());
      DateTime timmyDateTime2 = new DateTime(myDateTime.year, myDateTime.month, myDateTime.day-1, myDateTime.hour, myDateTime.minute, myDateTime.second, myDateTime.millisecond, myDateTime.microsecond);

      String formattedDateTime = DateFormat('yyyy-MM-dd').format(timmyDateTime2);

      stepData.add({'createdAt': formattedDateTime, 'value': data['Steps']});

      stepValues.add(_StepData(formattedDateTime, data['Steps']));
    }

    setState(() {
      stepValues = stepValues;
      stepValues = stepValues;
    });
  }

  Future<void> onStepCount(StepCount event) async {
    if (_stepsCummulativeYtd >= maxStepCounts) {
      setState(() {
        _stepsCummulative = event.steps;
        _stepsDaily = event.steps;
      });
    } else {
      setState(() {
        _stepsDaily = event.steps - _stepsCummulativeYtd;
      });
    }
    prefs.setInt('_stepsCumulative', event.steps);
    prefs.setString('steps_timestamp', event.timeStamp.toString());

    FirebaseFirestore.instance.collection('Users').doc(userUid).update({
      'StepsCumulative': event.steps,
      'StepsDaily': _stepsDaily,
      'StepsTimestamp': event.timeStamp
    });
  }

// void onPedestrianStatusChanged(PedestrianStatus event) {
//   print(event);
//   setState(() {
//     _status = event.status;
//   });
// }
//
// void onPedestrianStatusError(error) {
//   print('onPedestrianStatusError: $error');
//   setState(() {
//     _status = 'Pedestrian Status not available';
//   });
//   print(_status);
// }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    // setState(() {
    //   _steps = 'Step Count not available';
    // });
  }

  void initPlatformState() {
    // _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    // _pedestrianStatusStream
    //     .listen(onPedestrianStatusChanged)
    //     .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Pedometer".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: kIsWeb ? FormFactor.desktop : double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,100.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: boxDecoration(Colors.blue),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.directions_run,
                                color: Colors.blueAccent, size: 40),
                            Text(
                              'Steps Taken Today:'.tr(),
                              style: TextStyle(
                                  fontSize: 20, color: Colors.blueAccent),
                            ),
                            SizedBox(height: 15),
                            record(_stepsDaily.toString(),
                                targetStepCounts.toString()),
                            SizedBox(height: 15),
                            // Text(
                            //   'Pedestrian Status',
                            //   style: TextStyle(fontSize: 30),
                            // ),
                            // Icon(
                            //   _status == 'walking'
                            //       ? Icons.directions_walk
                            //       : _status == 'stopped'
                            //           ? Icons.accessibility_new
                            //           : Icons.error,
                            //   size: 100,
                            // ),
                            // Center(
                            //   child: Text(
                            //     _status,
                            //     style: _status == 'walking' || _status == 'stopped'
                            //         ? TextStyle(fontSize: 30)
                            //         : TextStyle(fontSize: 20, color: Colors.red),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                        decoration: boxDecoration(Colors.blue),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 15),
                              Text(
                                'HISTORY'.tr(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 15),
                              // if (stepData.isNotEmpty)
                              //   SingleChildScrollView(
                              //     scrollDirection: Axis.vertical,
                              //     child: DataTable(
                              //         // Datatable widget that have the property columns and rows.
                              //         border: TableBorder.all(width: 1),
                              //         columns: [
                              //           // Set the name of the column
                              //           DataColumn(
                              //               label: Flexible(
                              //             fit: FlexFit.tight,
                              //             child: Center(
                              //               child: Text("RECORDED AT".tr(),
                              //                   textAlign: TextAlign.center,
                              //                   style: const TextStyle(
                              //                       color: Colors.blue,
                              //                       fontWeight:
                              //                           FontWeight.bold)),
                              //             ),
                              //           )),
                              //           DataColumn(
                              //               label: Flexible(
                              //             fit: FlexFit.tight,
                              //             child: Center(
                              //               child: Text('${'Steps'.tr()}',
                              //                   textAlign: TextAlign.center,
                              //                   style: const TextStyle(
                              //                       color: Colors.blue,
                              //                       fontWeight:
                              //                           FontWeight.bold)),
                              //             ),
                              //           )),
                              //         ],
                              //         rows: stepData
                              //             .map(
                              //               (e) => DataRow(
                              //                 cells: [
                              //                   DataCell(Center(
                              //                     child: Text(
                              //                       e['createdAt'],
                              //                       style: const TextStyle(
                              //                         fontStyle:
                              //                             FontStyle.normal,
                              //                       ),
                              //                     ),
                              //                   )),
                              //                   DataCell(Center(
                              //                     child: Text(
                              //                       e['value'].toString(),
                              //                       style: const TextStyle(
                              //                         fontStyle:
                              //                             FontStyle.normal,
                              //                       ),
                              //                     ),
                              //                   )),
                              //                 ],
                              //               ),
                              //             )
                              //             .toList()),
                              //   ),
                              if (stepValues.isNotEmpty)
                                SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    // Chart title
                                    title: ChartTitle(text: 'Steps'.tr()),
                                    // Enable legend
                                    legend: Legend(isVisible: false),
                                    // Enable tooltip
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    series: <ChartSeries<_StepData, String>>[
                                      LineSeries<_StepData, String>(
                                          dataSource: stepValues,
                                          xValueMapper: (_StepData step, _) =>
                                              step.createdAt,
                                          yValueMapper: (_StepData step, _) =>
                                              step.value,
                                          markerSettings: const MarkerSettings(
                                              isVisible: true,
                                              height: 3,
                                              width: 3,
                                              shape: DataMarkerType.circle,
                                              borderWidth: 2,
                                              borderColor: Colors.blue),
                                          name: 'Steps'.tr(),
                                          // Enable data label
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                                  isVisible: false))
                                    ]),
                              if (stepValues.isEmpty)
                                Center(child: Text("NO DATA AVAILABLE".tr())),
                              SizedBox(height: 15),
                            ]))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget record(String current, String target) {
    double progress = 0.0;

    int _current = int.tryParse(current) ?? 0;
    int _target = int.tryParse(target) ?? 0;

    if (_current > 0 && _target > 0) {
      progress = _current / _target;
      if (progress > 1.0) {
        progress = 1.0;
      }
    } else {
      progress = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Column(
        //   children: [
        //     // Image.asset(
        //     //   icon,
        //     //   height: 80,
        //     //   width: 80,
        //     // ),
        //     Icon(Icons.directions_run,
        //         color: Colors.blueAccent,
        //         size: 30),
        //     Text(
        //       "Steps".tr(),
        //       textAlign: TextAlign.right,
        //       style: TextStyle(
        //           fontFamily: 'ProductSans',
        //           color: Colors.black38,
        //           fontSize: 20),
        //     ),
        //   ],
        // ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  current,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontSize: 40),
                ),
                Text(
                  ' / ' + target,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black26, fontSize: 15),
                ),
              ],
            ),
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width * 0.8,
              animation: true,
              lineHeight: 20.0,
              animationDuration: 2000,
              percent: progress,
              center: Text((progress * 100).toStringAsFixed(1) + "%"),
              // linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.amber,
            ),
          ],
        ),
      ],
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

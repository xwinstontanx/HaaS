import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _HealthData {
  _HealthData(this.createdAt, this.value);

  final String createdAt;
  final double value;
}

class HealthHistoryBloodGlucosePage extends StatefulWidget {
  const HealthHistoryBloodGlucosePage({Key? key}) : super(key: key);

  @override
  State<HealthHistoryBloodGlucosePage> createState() =>
      _HealthHistoryBloodGlucosePageState();
}

class _HealthHistoryBloodGlucosePageState
    extends State<HealthHistoryBloodGlucosePage> {
  var userUid = "";
  var userName = "";
  var healthData = [];

  List<_HealthData> healthValues = [];
  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    // Get today's latest Health data (DeviceType: 5 (BG), 4 (Weight), 3 (BP), 2 (Desktop), 1 (Wearable))
    var collection = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('HealthData')
        .where("DeviceType", isEqualTo: 5)
        .orderBy('CreatedAt', descending: true);
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();

      DateTime myDateTime =
          DateTime.parse(data['CreatedAt'].toDate().toString());
      String formattedDateTime =
          DateFormat('yyyy-MM-dd hh:mma').format(myDateTime);

      healthData.add({
        'createdAt': formattedDateTime,
        'value': data['BloodGlucose'].toString()
      });

      healthValues.add(_HealthData(
          formattedDateTime, double.parse(data['BloodGlucose'].toString())));
    }

    setState(() {
      healthData = healthData;
      healthValues = healthValues;
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
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop()),
            bottom: TabBar(
              tabs: [
                Tab(child: Text("NUMERIAL".tr())),
                Tab(child: Text("GRAPH".tr())),
              ],
            ),
            title: Text("BLOOD GLUCOSE".tr()),
            automaticallyImplyLeading: false,
            actions: const <Widget>[],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (healthData.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                        // Datatable widget that have the property columns and rows.
                        border: TableBorder.all(width: 1),
                        columns: [
                          // Set the name of the column
                          DataColumn(
                              label: Flexible(
                                fit: FlexFit.tight,
                                child: Center(
                                  child: Text("RECORDED AT".tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )),
                          DataColumn(
                              label: Flexible(
                                fit: FlexFit.tight,
                                child: Center(
                                  child: Text(
                                      '${'BLOOD GLUCOSE'.tr()} \n (mmol/L)',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )),
                        ],
                        rows: healthData
                            .map(
                              (e) => DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Text(
                                      e['createdAt'],
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Text(
                                      e['value'],
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            )
                            .toList()),
                  ),
                if (healthValues.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        // Chart title
                        title: ChartTitle(text: 'BLOOD GLUCOSE'.tr()),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<_HealthData, String>>[
                          LineSeries<_HealthData, String>(
                              dataSource: healthValues,
                              xValueMapper: (_HealthData health, _) =>
                                  health.createdAt,
                              yValueMapper: (_HealthData health, _) =>
                                  health.value,
                              markerSettings: const MarkerSettings(
                                  isVisible: true,
                                  height: 3,
                                  width: 3,
                                  shape: DataMarkerType.circle,
                                  borderWidth: 2,
                                  borderColor: Colors.blue),
                              name: 'BLOOD GLUCOSE'.tr(),
                              // Enable data label
                              dataLabelSettings:
                                  const DataLabelSettings(isVisible: false))
                        ]),
                  ),
                if (healthData.isEmpty)
                  Center(child: Text("NO DATA AVAILABLE".tr())),
                if (healthValues.isEmpty)
                  Center(child: Text("NO DATA AVAILABLE".tr())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

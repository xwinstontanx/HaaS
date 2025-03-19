import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeDevice {
  String? deviceEui;
  String? address;
  String? mainUser;
  String? movement;
  Color? movementColor;
  String? lastRecordedAt;
  String? fsCreatedAt;

  HomeDevice(
      {this.deviceEui,
      this.address,
      this.mainUser,
      this.movement,
      this.movementColor,
      this.lastRecordedAt,
      this.fsCreatedAt});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = [
    'https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
    'https://images.unsplash.com/photo-1586901533048-0e856dff2c0d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586902279476-3244d8d18285?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586943101559-4cdcf86a6f87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1556&q=80',
    'https://images.unsplash.com/photo-1586951144438-26d4e072b891?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586953983027-d7508a64f4bb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
  ];

  var userUid = "";

  int _selectedIndex = 0;
  List<HomeDevice> devicesList = [];
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      images.forEach((imageUrl) {
        precacheImage(NetworkImage(imageUrl), context);
      });
    });
    super.initState();
    FirebaseFirestore.instance
        .collection("Devices")
        .snapshots()
        .listen((querySnapshot) {
      if (devicesList.length != 0) {
        getDevices();
      }
    });

    getUser();
    getDevices();
  }

  @override
  void dispose() {
    devicesList.clear();
    super.dispose();
  }

  Future<void> getDevices() async {
    devicesList = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("DeviceUnderCare")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection("Devices")
            .where('DeviceEui', isEqualTo: result.data()['DeviceEui'])
            // .where('Movement', isEqualTo: 'Detected')
            .orderBy('CreatedAt', descending: true)
            .limit(1)
            .get()
            .then((querySnapshot2) {
          querySnapshot2.docs.forEach((result2) {
            var date = result2.data()['CreatedAt'].toDate().toString();
            var time = Moment.parse(date).format('DD MMM YYYY') +
                ' ' +
                Moment.parse(date).format('h:mm a');

            if (result2.data()['Movement'] == "Detected") {
              devicesList.add(HomeDevice(
                  deviceEui: result.data()['DeviceEui'],
                  address: result.data()['Address'],
                  mainUser: result.data()['MainUser'],
                  movement: result2.data()['Movement'],
                  movementColor: Colors.green,
                  lastRecordedAt: time,
                  fsCreatedAt:
                      result2.data()['CreatedAt'].toDate().toString()));
            } else {
              devicesList.add(HomeDevice(
                  deviceEui: result.data()['DeviceEui'],
                  address: result.data()['Address'],
                  mainUser: result.data()['MainUser'],
                  movement: result2.data()['Movement'],
                  movementColor: Colors.red,
                  lastRecordedAt: time,
                  fsCreatedAt:
                      result2.data()['CreatedAt'].toDate().toString()));
            }

            setState(() {
              devicesList:
              devicesList.sort((b, a) => a.lastRecordedAt
                  .toString()
                  .compareTo(b.lastRecordedAt.toString()));
            });
          });
        });
      });
    });
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
    });
  }

  Future<void> onPressedHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceEui', devicesList[index].deviceEui.toString());
    print(devicesList[index].deviceEui);
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => DeviceHistoryPage()));
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()));
    }
    if (index == 1) {
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }

  Future<void> onPressedDelete(int index) async {
    var tempDeviceEui;
    tempDeviceEui = devicesList[index].deviceEui;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Confirmation"),
            content: Text("Are you sure that you want to delete '" +
                devicesList[index].deviceEui.toString() +
                "' ?"),
            actions: [
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("Users")
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                      FirebaseFirestore.instance
                          .collection("Users")
                          .doc(result.data()['Uid'])
                          .collection("DeviceUnderCare")
                          .get()
                          .then((querySnapshot2) {
                        querySnapshot2.docs.forEach((result2) {
                          if (result2.data()['DeviceEui'] == tempDeviceEui) {
                            FirebaseFirestore.instance
                                .collection("Users")
                                .doc(result.data()['Uid'])
                                .collection("DeviceUnderCare")
                                .doc(result2.id)
                                .delete();
                          }
                        });
                      });
                    });
                    setState(() {
                      devicesList.removeAt(index);
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, '),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
          child: Center(
        child: SizedBox(
          width: kIsWeb ? 600.0 : double.infinity,
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Container(
                    //     child: CarouselSlider.builder(
                    //   itemCount: images.length,
                    //   options: CarouselOptions(
                    //     autoPlay: true,
                    //     aspectRatio: 2.0,
                    //     enlargeCenterPage: true,
                    //   ),
                    //   itemBuilder: (context, index, realIdx) {
                    //     return Container(
                    //       child: Center(
                    //           child: Image.network(images[index],
                    //               fit: BoxFit.cover, width: 1000)),
                    //     );
                    //   },
                    // )
                    ),
              ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.gamepad, color: Colors.grey),
                          Text("Game")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.emoji_food_beverage, color: Colors.grey),
                          Text("Food")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.health_and_safety, color: Colors.grey),
                          Text("Health")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.grey),
                          Text("Shopping")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.business_center, color: Colors.grey),
                          Text("Business")
                        ],
                      ),
                    ),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.group, color: Colors.grey),
                          Text("Groups")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.recycling, color: Colors.grey),
                          Text("Recycle")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.grey),
                          Text("Volunteering")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.message, color: Colors.grey),
                          Text("Message")
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.event, color: Colors.grey),
                          Text("Events")
                        ],
                      ),
                    ),
                  ])
            ],
          ),
        ),
      )),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 50.0,
        items: <Widget>[
          Container(
            height: 50,
            child: const Column(
              children: [Icon(Icons.home, color: Colors.blue), Text("Home")],
            ),
          ),
          Container(
            height: 50,
            child: const Column(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey),
                Text("Events")
              ],
            ),
          ),
          Container(
            height: 50,
            child: const Column(
              children: [
                Icon(Icons.doorbell, color: Colors.grey),
                Text("Alerts")
              ],
            ),
          ),
          Container(
            height: 50,
            child: const Column(
              children: [
                Icon(Icons.settings, color: Colors.grey),
                Text("Settings")
              ],
            ),
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
           Timer(const Duration(milliseconds: 400), () {
            _onItemTapped(index);
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

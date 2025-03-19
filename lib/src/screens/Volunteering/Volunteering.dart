import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senzepact/src/screens/Volunteering/CaseNotes/MainCaseNotes.dart';
import 'package:senzepact/src/screens/Volunteering/CentresDirectory/MainCentresDirectory.dart';
import 'package:senzepact/src/screens/Volunteering/CheckInStatus/MainCheckInStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Responsive/FormFactor.dart';
import 'Chat/MainChat.dart';
import 'Emergency/MainEmergency.dart';
import 'Scanner/HealthHome.dart';
import 'Scanner/MainScanner.dart';
import 'Schedule/MainSchedule.dart';
import 'VolunteeringService.dart';
import 'package:badges/badges.dart' as badges;

class VolunteeringPage extends StatefulWidget {
  const VolunteeringPage({Key? key}) : super(key: key);

  @override
  State<VolunteeringPage> createState() => VolunteeringPageState();
}

class VolunteeringPageState extends State<VolunteeringPage> {
  VolunteeringService service = new VolunteeringService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await service.getUser();
    await service.getElderlyList();
    await service.getElderlyListLastEmergency();
    await service.getElderlyListLastMsg();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("Volunteering".tr()),
          automaticallyImplyLeading: false,
          actions: <Widget>[ShowBadge(context)],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? LoadingAnimationWidget.horizontalRotatingDots(
                    color: Colors.blue,
                    size: 50,
                  )
                : SizedBox(
                    width: kIsWeb ? FormFactor.desktop : double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.count(
                          physics: const ScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: kIsWeb ? 1.0 : 1.0,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            Schedule(),
                            CaseNotes(),
                            Emergency(),
                            CheckInStatus(),
                            Chat(),
                            CentresDirectory(),
                            // Scanner(),
                          ]),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Padding Schedule() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        //apply padding to all four sides
        child: Container(
          decoration: boxDecoration(Colors.blue),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainSchedulePage()))
                  .then((value) => retrieveData());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(builder: (context, constraint) {
                    return Center(
                      child: Icon(Icons.calendar_month,
                          color: Colors.blueAccent,
                          size: constraint.biggest.height / 1.5),
                    );
                  }),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text("Schedules".tr(),
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
        ));
  }

  Padding CaseNotes() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        //apply padding to all four sides
        child: Container(
          decoration: boxDecoration(Colors.blue),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MainCaseNotesPage(
                            service: service,
                          ))).then((value) => retrieveData());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(builder: (context, constraint) {
                    return Center(
                      child: Icon(Icons.book,
                          color: Colors.blueAccent,
                          size: constraint.biggest.height / 1.5),
                    );
                  }),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text("Case Notes".tr(),
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
        ));
  }

  Padding Emergency() {
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
                    builder: (_) => MainEmergencyPage(
                          service: service,
                        ))).then((value) => retrieveData());
          },
          child: service.elderlyUnderCareListNewEmergency.contains(true)
              ? badges.Badge(
                  badgeContent: Text('New'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 6)),
                  child: EmergencyContent(),
                )
              : EmergencyContent(),
        ),
      ),
    );
  }

  Padding CheckInStatus() {
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
                    builder: (_) => MainCheckInPage(
                          service: service,
                        ))).then((value) => retrieveData());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.thumb_up,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Check In Status".tr(),
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

  Padding Chat() {
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
                        builder: (_) => MainChatPage(service: service)))
                .then((value) => retrieveData());
          },
          child: service.elderlyUnderCareListNewMsg.contains(true)
              ? badges.Badge(
                  badgeContent: Text('New'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 6)),
                  child: ChatContent(),
                )
              : ChatContent(),
        ),
      ),
    );
  }

  Padding CentresDirectory() {
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
                    builder: (_) => MainCentresDirectoryPage(
                          service: service,
                        ))).then((value) => retrieveData());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.store_mall_directory,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Centres Directory".tr(),
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

  Column EmergencyContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: LayoutBuilder(builder: (context, constraint) {
            return Center(
              child: Icon(Icons.campaign,
                  color: Colors.blueAccent,
                  size: constraint.biggest.height / 1.5),
            );
          }),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("ALERTS".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        // <-- Text
      ],
    );
  }

  Column ChatContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: LayoutBuilder(builder: (context, constraint) {
            return Center(
              child: Icon(Icons.chat,
                  color: Colors.blueAccent,
                  size: constraint.biggest.height / 1.5),
            );
          }),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text("Chat".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        // <-- Text
      ],
    );
  }

  Padding Scanner() {
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
                    builder: (_) => MainScannerPage(
                          service: service,
                        )));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.qr_code_scanner,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("QR Scanner".tr(),
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

  Padding ShowBadge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: service.userOrgId != ""
          ? InkWell(
              onTap: () {
                showProfileBadge(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.badge, size: 35),
                    onPressed: () {
                      showProfileBadge(context);
                    },
                    color: Colors.white,
                  ),
                  // Text("Profile Badge".tr()),
                ],
              ),
            )
          : SizedBox(
              height: 0,
            ),
    );
  }

  Future<void> showProfileBadge(BuildContext context) async {
    var getOrgName =
        await FirebaseFirestore.instance
            .collection('RoleList')
            .doc(service.userRole)
            .get();
    if (getOrgName.exists) {
      Map<String, dynamic>? data = getOrgName.data();
      Map<String, dynamic>? userProfileV;

      var userProfile = await FirebaseFirestore.instance
          .collection('Users')
          .doc(service.userUid)
          .get();

      if (userProfile.exists) {
        userProfileV = userProfile.data();
      }

      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 35,
                        ),
                        color: Colors.grey.shade700,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProfilePicture(
                        name: service.userName,
                        role: 'Volunteer',
                        radius: 81,
                        fontsize: 51,
                        tooltip: false,
                        count: 2,
                        img: userProfileV?['ProfilePic'],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Text(
                        service.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Text(
                        data?['RoleName'],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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

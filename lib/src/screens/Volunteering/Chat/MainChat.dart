import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import '../VolunteeringService.dart';
import 'Chat.dart';
import 'package:badges/badges.dart' as badges;

class MainChatPage extends StatefulWidget {
  final VolunteeringService service;

  const MainChatPage({Key? key, required this.service}) : super(key: key);

  @override
  State<MainChatPage> createState() => MainChatPageState();
}

class MainChatPageState extends State<MainChatPage> {
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
    if (widget.service.elderlyUnderCareList.length > 0) {
      for (var elderly in widget.service.elderlyUnderCareList) {
        setState(() {
          elderlyList.add({'Uid': elderly['Uid'], 'data': elderly['data']});
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
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
          title: Text("Chat".tr()),
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
                              childAspectRatio: kIsWeb ? 0.8 : 0.8,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                ...elderlyList.map((item) {
                                  return ChatContent(item);
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
                    const Icon(Icons.handshake,
                        size: 50, color: Colors.blue),
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

  Padding ChatContent(item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      //apply padding to all four sides
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) =>
                    ChatPage(service: widget.service, senior: item)));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                widget.service.elderlyUnderCareListNewMsg[
                            elderlyList.indexOf(item)] ==
                        true
                    ? badges.Badge(
                        badgeContent: Text('New'.tr(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 6)),
                        child: ProfilePicture(
                          name: item?['data']['Name'],
                          role: '',
                          radius: 45,
                          fontsize: 20,
                          tooltip: false,
                          count: 2,
                          img: item?['data']['ProfilePic'],
                        ),
                      )
                    : ProfilePicture(
                        name: item?['data']['Name'],
                        role: '',
                        radius: 45,
                        fontsize: 20,
                        tooltip: false,
                        count: 2,
                        img: item?['data']['ProfilePic'],
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
                  child: Text(item['data']['Name'].toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
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

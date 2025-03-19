import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import '../../../../firebase_options_senzehub.dart';
import '../VolunteeringService.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final VolunteeringService service;
  var senior;

  ChatPage({Key? key, required this.service, required this.senior})
      : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool isLoading = true;
  var msgController = TextEditingController();
  List<ChatMessage> messages = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getChatList();
  }

  Future<void> getChatList() async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );

    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('VolunteerChats')
        .doc(widget.senior?['Uid'])
        .collection('Chats')
        .orderBy('CreatedAt', descending: false)
        .snapshots()
        .listen((querySnapshot) {
      messages = [];
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> dataChat = queryDocumentSnapshot.data();
        setState(() {
          messages.add(ChatMessage(
              Content: dataChat['Content'],
              CreatedAt: dataChat['CreatedAt'].toDate(),
              IsSystem: dataChat['IsSystem'],
              Name: dataChat['Name'],
              Uid: dataChat['Uid']));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Chat".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            child: ListView.builder(
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 70),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                      alignment: (messages[index].IsSystem
                          ? Alignment.center
                          : messages[index].Uid == widget.service.userUid
                              ? Alignment.topRight
                              : Alignment.topLeft),
                      child: Column(
                        mainAxisAlignment: messages[index].IsSystem
                            ? MainAxisAlignment.center
                            : messages[index].Uid == widget.service.userUid
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        crossAxisAlignment: messages[index].IsSystem
                            ? CrossAxisAlignment.center
                            : messages[index].Uid == widget.service.userUid
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          messages[index].IsSystem
                              ? Column(
                                  children: [
                                    Text(
                                      messages[index].Content,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: messages[index].Content.contains(
                                                      "Emergency Triggered") ||
                                                  messages[index].Content.contains(
                                                      "No check in for 3 days")
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      dateFormat
                                          .format(messages[index].CreatedAt),
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: messages[index].Content.contains(
                                                      "Emergency Triggered") ||
                                                  messages[index].Content.contains(
                                                      "No check in for 3 days")
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                  ],
                                )
                              : messages[index].Uid == widget.service.userUid
                                  ? Text(
                                      dateFormat
                                          .format(messages[index].CreatedAt),
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                    )
                                  : Text(
                                      messages[index].Name +
                                          ", " +
                                          dateFormat.format(
                                              messages[index].CreatedAt),
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                    ),
                          messages[index].IsSystem
                              ? SizedBox(
                                  height: 0,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: (messages[index].Uid ==
                                            widget.service.userUid
                                        ? Colors.blue[200]
                                        : Colors.grey.shade200),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    messages[index].Content,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                        ],
                      )),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(left: 10, top: 10),
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (msgController.text.toString().isNotEmpty) {
                        FirebaseFirestore.instanceFor(
                                app: Firebase.app("secondary"))
                            .collection('VolunteerChats')
                            .doc(widget.senior['Uid'])
                            .collection('Chats')
                            .add({
                          'Content': msgController.text.toString(),
                          'CreatedAt': DateTime.now(),
                          'IsSystem': false,
                          'Name': widget.service.userName,
                          'Uid': widget.service.userUid
                        }).then((value) => {msgController.text = ""});
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.blue,
                      size: 25,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
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

class ChatMessage {
  String Content = "";
  DateTime CreatedAt;
  bool IsSystem = false;
  String Name = "";
  String Uid = "";

  ChatMessage(
      {required String this.Content,
      required DateTime this.CreatedAt,
      required bool this.IsSystem,
      required String this.Name,
      required String this.Uid});
}

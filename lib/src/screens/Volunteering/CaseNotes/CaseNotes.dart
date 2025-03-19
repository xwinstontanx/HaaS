import 'dart:io' show File, Platform;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:senzepact/src/screens/Volunteering/CaseNotes/MainCaseNotes.dart';
import 'package:senzepact/src/screens/volunteering/Events.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:core';

import 'CaseNotesList.dart';

class CaseNotesPage extends StatefulWidget {
  final String elderlyUid;
  final String caseNoteId;

  const CaseNotesPage(this.elderlyUid, this.caseNoteId, {super.key});

  @override
  State<CaseNotesPage> createState() => CaseNotesPageState();
}

List<String> activityList = <String>[
  'Art'.tr(),
  'Fitness'.tr(),
  'Drawing'.tr(),
  'Tidying'.tr(),
  'Chatting'.tr(),
  'Other'.tr()
];

enum RadioButton { Yes, No }

class CaseNotesPageState extends State<CaseNotesPage> {
  final remarkController = TextEditingController();
  var userUid = "";

  String? startTime = "";
  late DateTime startTimeV;
  String? endTime = "";
  late DateTime endTimeV;
  String? durationV = "";
  String? dropdownValue;
  RadioButton? _FollowUpselection = RadioButton.No;
  String? fileName = "";

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList;

  Map<String, dynamic>? caseNoteItem;

  dynamic? activityValueDynamic;
  List<String> activityValue = [];

  @override
  void initState() {
    super.initState();
    retrieveData();

    //Get userUid and fetch events details
    getUser().then((value) => {});
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
    });
  }

  Future<void> retrieveData() async {
    await FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
        .collection('Users')
        .doc(widget.elderlyUid)
        .collection('CaseNotesHistory')
        .doc(widget.caseNoteId)
        .get()
        .then((caseNoteSnapshot) async {
      if (caseNoteSnapshot.exists) {
        print(caseNoteSnapshot.data());
        caseNoteItem = caseNoteSnapshot.data();
        if (caseNoteItem!['Activities'] != null) {
          activityValueDynamic = caseNoteItem!['Activities'];
          // activityValue = activityValueDynamic as List<String>;
          print("object");
          print(activityValueDynamic);
          // print(activityValue);
        }
        if (caseNoteSnapshot.data()!['TimeIn'] != null) {
          startTime = caseNoteSnapshot.data()!['TimeIn'];
        }
        if (caseNoteSnapshot.data()!['TimeOut'] != null) {
          endTime = caseNoteSnapshot.data()!['TimeOut'];
        }
        if (caseNoteSnapshot.data()!['Duration'] != null) {
          durationV = caseNoteSnapshot.data()!['Duration'];
        }
        if (caseNoteSnapshot.data()!['Attachment'] != null) {
          fileName = "Image.jpeg";
        }
        if (caseNoteSnapshot.data()!['FollowUp'] != null) {
          _FollowUpselection = caseNoteSnapshot.data()!['Followup'] == "true"
              ? RadioButton.Yes
              : RadioButton.No;
        }
        if (caseNoteSnapshot.data()!['Remark'] != null) {
          remarkController.text = caseNoteSnapshot.data()!['Remark'];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Case Note".tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                activity(),
                timeIn(),
                timeOut(),
                duration(),
                attachment(),
                followUp(),
                remark(),
                submit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding activity() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ACTIVITY".tr(),
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          DropDownMultiSelect(
            options: activityList,
            selectedValues: activityValue,
            onChanged: (value) {
              setState(() {
                activityValue = value as List<String>;
              });
            },
            whenEmpty: "Select Activity".tr(),
          ),
          // DropdownButton<String>(
          //   isExpanded: true,
          //   items: activityList.map<DropdownMenuItem<String>>((String value) {
          //     return DropdownMenuItem<String>(
          //       value: value,
          //       child: Text(value),
          //     );
          //   }).toList(),
          //   icon: const Icon(Icons.edit),
          //   elevation: 16,
          //   style: const TextStyle(color: Colors.black),
          //   underline: Container(
          //     height: 2,
          //     color: Colors.blue,
          //   ),
          //   hint: Text("Select Activity".tr()),
          //   value: dropdownValue,
          //   onChanged: (String? value) {
          //     // This is called when the user selects an item.
          //     setState(() {
          //       dropdownValue = value ?? "";
          //     });
          //   },
          // ),
          Text(
            activityValue.toString(),
            style: const TextStyle(color: Colors.blue, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Padding timeIn() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TIME IN".tr(),
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(startTime!,
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
              ),
              // Icon(Icons.punch_clock, color: Colors.grey.shade700,),
              IconButton(
                icon: const Icon(Icons.punch_clock),
                color: Colors.grey.shade700,
                tooltip: "TIME IN".tr(),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      currentTime: DateTime.now(), onConfirm: (date) {
                    setState(() {
                      startTime =
                          DateFormat('dd/MM/yyyy, h:mm:ss a').format(date);
                      startTimeV = date;
                      durationV = endTime != ""
                          ? "${endTimeV.difference(startTimeV).toString().substring(0, 1)} hour ${endTimeV.difference(startTimeV).toString().substring(2, 4)} minutes"
                          : "";
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding timeOut() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TIME OUT".tr(),
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(endTime!,
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
              ),
              // Icon(Icons.punch_clock, color: Colors.grey.shade700,),
              IconButton(
                icon: const Icon(Icons.punch_clock),
                color: Colors.grey.shade700,
                tooltip: "TIME OUT".tr(),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      currentTime: DateTime.now(), onConfirm: (date) {
                    setState(() {
                      endTime =
                          DateFormat('dd/MM/yyyy, h:mm:ss a').format(date);
                      endTimeV = date;
                      durationV = startTime != ""
                          ? "${endTimeV.difference(startTimeV).toString().substring(0, 1)} hour ${endTimeV.difference(startTimeV).toString().substring(2, 4)} minutes"
                          : "";
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding duration() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DURATION".tr(),
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(durationV!,
                style: const TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Padding attachment() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${"Attachment".tr().replaceAll(RegExp(':'), '')} (${"Optional".tr()}):",
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("",
                        style: TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                  // Icon(Icons.punch_clock, color: Colors.grey.shade700,),
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    color: Colors.grey.shade700,
                    tooltip:
                        "${"Attachment".tr().replaceAll(RegExp(':'), '')} (${"Optional".tr()}):",
                    onPressed: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        _setImageFileListFromFile(image);
                      });
                    },
                  ),
                ],
              ),
              // (fileName == "" && event!['event']['Attachment'] == null)
              //     ? const SizedBox(
              //         height: 0,
              //       )
              //     : Image.network(event!['event']['Attachment'] ?? "",
              //         height: 150,
              //         fit: BoxFit.fill, loadingBuilder: (BuildContext context,
              //             Widget child, ImageChunkEvent? loadingProgress) {
              //         if (loadingProgress == null) return child;
              //         return Center(
              //           child: CircularProgressIndicator(
              //             value: loadingProgress.expectedTotalBytes != null
              //                 ? loadingProgress.cumulativeBytesLoaded /
              //                     loadingProgress.expectedTotalBytes!
              //                 : null,
              //           ),
              //         );
              //       }, errorBuilder: (BuildContext context, Object exception,
              //             StackTrace? stackTrace) {
              //         return const Text('');
              //       })
            ],
          ),
        ],
      ),
    );
  }

  Padding followUp() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "REQUIRES FOLLOW-UP".tr(),
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text('Yes'.tr()),
                dense: true,
                leading: Radio<RadioButton>(
                  value: RadioButton.Yes,
                  groupValue: _FollowUpselection,
                  onChanged: (RadioButton? value) {
                    setState(() {
                      _FollowUpselection = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('No'.tr()),
                dense: true,
                leading: Radio<RadioButton>(
                  value: RadioButton.No,
                  groupValue: _FollowUpselection,
                  onChanged: (RadioButton? value) {
                    setState(() {
                      _FollowUpselection = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding remark() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${"REMARK".tr().replaceAll(RegExp(':'), '')} (${"Optional".tr()}):",
            style: const TextStyle(color: Colors.blue, fontSize: 17),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: remarkController,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: 5, // when user presses enter it will adapt to it
            ),
          ),
        ],
      ),
    );
  }

  Center submit() {
    return Center(
      child: ElevatedButton(
        onPressed: () => {submitCaseNote()},
        child: Text(
          'SUBMIT'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  void submitCaseNote() {
    // Check inputs
    // if (dropdownValue == null) {
    //   showDialog("ACTIVITY".tr().replaceAll(RegExp(':'), ''));
    // } else
    if (startTime == "") {
      showDialog("TIME IN".tr().replaceAll(RegExp(':'), ''));
    } else if (endTime == "") {
      showDialog("TIME OUT".tr().replaceAll(RegExp(':'), ''));
    } else {
      // Push to case note collection
      FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
          // .collection('BefriendBuddyDetails')
          // .doc(event!['event']['CasenoteID'])
          // .doc(widget.caseNoteId)
          .collection('Users')
          .doc(widget.elderlyUid)
          .collection('CaseNotesHistory')
          .doc(widget.caseNoteId)
          .update({
        'Activities': activityValue,
        'TimeIn': startTime,
        'TimeOut': endTime,
        'Duration': durationV,
        'FollowUp': _FollowUpselection == RadioButton.Yes ? "Yes" : "No",
        'Remark': remarkController.text,
        'Status': 2
      }).then((value) => {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  title: 'Case Note'.tr(),
                  desc: "Submitted Successfully".tr(),
                  btnOkOnPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CaseNotesList(widget.elderlyUid)));
                  },
                ).show()
              });
    }
  }

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
    _imageFileList?.forEach((element) {
      uploadFile(element);
      setState(() {
        fileName = "Image.jpeg";
      });
    });
  }

  Future<String> uploadFile(XFile _image) async {
    // String seniorUID = event!['event']['Elderly'];
    String seniorUID = widget.elderlyUid;
    Reference storageReference = FirebaseStorage.instance.ref().child(
        '$seniorUID/CaseNote/cn_${DateTime.now().millisecondsSinceEpoch}');

    UploadTask uploadTask = storageReference.putFile(File(_image.path));

    await uploadTask;
    String returnURL = "";

    await storageReference.getDownloadURL().then((fileURL) async {
      returnURL = fileURL;

      // Save to firestore
      FirebaseFirestore.instanceFor(app: Firebase.app("secondary"))
          // .collection('BefriendBuddyDetails')
          // .doc(event!['event']['CasenoteID'])
          // .doc(widget.caseNoteId)
          .collection('Users')
          .doc(widget.elderlyUid)
          .collection('CaseNotesHistory')
          .doc(widget.caseNoteId)
          .update({'Attachment': fileURL}).then((value) => {
                setState(() {
                  fileName = "Image.jpeg";
                  caseNoteItem!['Attachment'] = fileURL;
                })
              });
    });
    return returnURL;
  }

  void showDialog(String msg) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error'.tr(),
      desc: "${"Kindly Enter Following Information".tr()}: \n$msg",
      btnOkOnPress: () {},
    ).show();
  }
}

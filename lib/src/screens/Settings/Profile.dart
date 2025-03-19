import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senzepact/src/screens/Settings/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:custom_switch/custom_switch.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<ProfilePage> {
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var postalcodeController = TextEditingController();
  var genderController = TextEditingController();
  var dobController = TextEditingController();

  bool statusCommonPool = false;
  var userUid = "";
  var userName = "";
  Map<String, dynamic>? userProfileV;

  final List<String> itemsGender = ['Male', 'Female'];
  String? selectedValueGender;
  final List<String> itemsCountry = ['Singapore'];
  String? selectedValueCountry;
  final List<String> itemsRace = ['Chinese', 'Malay', 'Indian', 'Others'];
  String? selectedValueRace;

  var finaldate;
  var currentYear;

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList;

  bool checkedValue = false;

  String? selectedValueRoleList;

  void callDatePicker() async {
    var order = await getDate();
    if (order != null) {
      setState(() {
        finaldate = order;
      });
    }
  }

  Future<List<DropdownMenuItem<String>>> fetchDropdownItemsRoleList() async {
    List<DropdownMenuItem<String>> menuItemsRoleList = [];
    var querySnapshot =
        await FirebaseFirestore.instance.collection('RoleList').get();

    for (var queryDocumentSnapshot in querySnapshot.docs) {
      menuItemsRoleList.add(DropdownMenuItem(
        value: queryDocumentSnapshot.data()['RoleNumber'].toString(),
        child: Text(queryDocumentSnapshot.data()['RoleName'].toString().tr()),
      ));
    }

    return menuItemsRoleList;
  }

  Future<DateTime?> getDate() {
    // Imagine that this function is
    // more complex and slow.
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy');
    final String formatted = formatter.format(now);
    setState(() {
      currentYear = formatted;
    });
    // print(formatted); // something like 2013-04-20 yyyy-MM-dd
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
      // builder: (BuildContext context, Widget child) {
      //   return Theme(
      //     data: ThemeData.light(),
      //     child: child,
      //   );
      // },
    );
  }

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        // print(user.uid);
        print('User is signed in!');
        getUser();
        setState(() {
          emailController.text =
              user.email.toString() == 'null' ? "" : user.email.toString();
        });
      }
    });
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
      nameController.text = userName;
    });

    var userProfile =
        await FirebaseFirestore.instance.collection('Users').doc(userUid).get();
    setState(() {
      userProfileV = userProfile.exists ? userProfile.data() : null;
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .get()
        .then((data) {
      setState(() {
        // statusCommonPool = data['CommonPool'];
        // nameController.text = data['Name'];
        phoneController.text = data['PhoneNumber'];
        postalcodeController.text = data['PostalCode'];
        addressController.text = data['Address'];
        genderController.text = data['Gender'];
        dobController.text = data['DateOfBirth'];
        selectedValueRoleList = data['Role'];
        checkedValue = data['IsVolunteer'] ?? false;

        // selectedValueCountry = data['Country'];
        // selectedValueRace = data['Race'];
        // finaldate = data['DateOfBirth'];
      });
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
        title: Text("Profile".tr()),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.delete_rounded),
                color: Colors.red,
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.bottomSlide,
                    title: "Delete Profile".tr(),
                    desc: "Are you sure you want to delete profile".tr(),
                    btnOkOnPress: () async {
                      // Add to DisabledAccount collection
                      FirebaseFirestore.instance
                          .collection('DisabledAccount')
                          .add({
                        'Uid': userUid,
                        'CreatedAt': DateTime.now(),
                      }).then((value) => {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userUid)
                                    .update({'FcmToken': ''}),
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userUid)
                                    .collection('LogHistory')
                                    .add({
                                  'CreatedAt': DateTime.now(),
                                  'From': 'Mobile',
                                  'Action': 'DeleteAccount'
                                })
                              });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove("userUid");
                      FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const LoginScreen();
                          },
                        ),
                        (_) => false,
                      );
                    },
                    btnCancelOnPress: () {},
                  ).show();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 25);
                  setState(() {
                    _setImageFileListFromFile(image);
                  });
                },
                child: Column(
                  children: [
                    ProfilePicture(
                      name: userName,
                      role: '',
                      radius: 60,
                      fontsize: 40,
                      tooltip: false,
                      count: 2,
                      img: userProfileV?['ProfilePic'],
                    ),
                    Text("Upload Profile Picture".tr(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  // readOnly: true,
                  controller: nameController,
                  decoration: InputDecoration(
                      // border: InputBorder.none,
                      labelText: 'NAME'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  // readOnly: true,
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // title: const Text(""),
                            // content: const Text(""),
                            actions: [
                              Center(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        Icon(
                                          Icons.list,
                                          size: 16,
                                          color: Colors.blueAccent,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Select Gender',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blueAccent,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: itemsGender
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedValueGender,
                                    onChanged: (value) {
                                      setState(() {
                                        genderController.text = value as String;
                                        // selectedValueGender = value as String;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  controller: genderController,
                  decoration: InputDecoration(
                      // border: InputBorder.none,
                      labelText: 'Gender'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  // readOnly: true,
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2030),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        dobController.text =
                            DateFormat('dd-MM-yyyy').format(selectedDate);
                      }
                    });
                  },
                  controller: dobController,
                  decoration: InputDecoration(
                      // border: InputBorder.none,
                      suffixIcon: const Icon(Icons.calendar_month),
                      labelText: 'Date of Birth'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  readOnly: true,
                  controller: emailController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Email'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  readOnly: true,
                  controller: phoneController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'PHONE NUMBER'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 15.0, right: 15.0, top: 15, bottom: 0),
              //   child: TextField(
              //     controller: addressController,
              //     decoration: InputDecoration(labelText: 'Address'),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  // readOnly: true,
                  controller: addressController,
                  decoration: InputDecoration(
                      // border: InputBorder.none,
                      labelText: 'Home Address'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextField(
                  // readOnly: true,
                  controller: postalcodeController,
                  decoration: InputDecoration(
                      // border: InputBorder.none,
                      labelText: 'POSTAL CODE'.tr(),
                      labelStyle:
                          const TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: FutureBuilder<List<DropdownMenuItem<String>>>(
                  future: fetchDropdownItemsRoleList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Or any other loading indicator
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<DropdownMenuItem<String>> menuItemsRoleList =
                          snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        hint: Text('Role'.tr()),
                        value: selectedValueRoleList,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValueRoleList = newValue!;
                          });
                        },
                        items: menuItemsRoleList,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          // labelText: 'Gender'.tr(),
                          prefixIcon: Icon(Icons.person_pin, size: 32),
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: CheckboxListTile(
                    title: Text(
                        "I wish to receive volunteering event details".tr(),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                    value: checkedValue,
                    onChanged: (newValue) {
                      setState(() {
                        checkedValue = newValue!;
                      });
                    },
                    visualDensity:
                        const VisualDensity(horizontal: -4.0, vertical: -4.0),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                  )),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 15.0, right: 15.0, top: 15, bottom: 0),
              //   child: new Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Container(
              //         decoration: BoxDecoration(color: Colors.white),
              //         padding: EdgeInsets.symmetric(horizontal: 30.0),
              //         child: finaldate == null
              //             ? Text(
              //                 "Click below to set Date Of Birth",
              //                 textScaleFactor: 1.0,
              //               )
              //             : Text(
              //                 DateFormat('dd-MM-yyyy')
              //                     .format(DateTime.parse("$finaldate")),
              //                 textScaleFactor: 1.5,
              //               ),
              //       ),
              //       ElevatedButton(
              //         onPressed: callDatePicker,
              //         // color: Colors.blueAccent,
              //         child: new Text('SET DATE OF BIRTH',
              //             style: TextStyle(color: Colors.white)),
              //       ),
              //     ],
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 15.0, right: 15.0, top: 15, bottom: 0),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton2(
              //       isExpanded: true,
              //       hint: Row(
              //         children: const [
              //           Icon(
              //             Icons.list,
              //             size: 16,
              //             color: Colors.black,
              //           ),
              //           Expanded(
              //             child: Text(
              //               'Select Gender',
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.black,
              //               ),
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //           ),
              //         ],
              //       ),
              //       items: itemsGender
              //           .map((item) => DropdownMenuItem<String>(
              //                 value: item,
              //                 child: Text(
              //                   item,
              //                   style: const TextStyle(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.black,
              //                   ),
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ))
              //           .toList(),
              //       value: selectedValueGender,
              //       onChanged: (value) {
              //         setState(() {
              //           selectedValueGender = value as String;
              //         });
              //       },
              //       icon: const Icon(
              //         Icons.arrow_drop_down,
              //       ),
              //       iconSize: 30,
              //       iconEnabledColor: Colors.black,
              //       iconDisabledColor: Colors.grey,
              //       buttonHeight: 50,
              //       // buttonWidth: 160,
              //       buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              //       buttonDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         border: Border.all(
              //           color: Colors.black26,
              //         ),
              //         color: Colors.white,
              //       ),
              //       buttonElevation: 2,
              //       itemHeight: 40,
              //       itemPadding: const EdgeInsets.only(left: 14, right: 14),
              //       dropdownMaxHeight: 200,
              //       dropdownWidth: 200,
              //       dropdownPadding: null,
              //       dropdownDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         color: Colors.white,
              //       ),
              //       dropdownElevation: 8,
              //       scrollbarRadius: const Radius.circular(40),
              //       scrollbarThickness: 6,
              //       scrollbarAlwaysShow: true,
              //       offset: const Offset(-20, 0),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 15.0, right: 15.0, top: 15, bottom: 0),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton2(
              //       isExpanded: true,
              //       hint: Row(
              //         children: const [
              //           Icon(
              //             Icons.list,
              //             size: 16,
              //             color: Colors.black,
              //           ),
              //           Expanded(
              //             child: Text(
              //               'Select Country',
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.black,
              //               ),
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //           ),
              //         ],
              //       ),
              //       items: itemsCountry
              //           .map((item) => DropdownMenuItem<String>(
              //                 value: item,
              //                 child: Text(
              //                   item,
              //                   style: const TextStyle(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.black,
              //                   ),
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ))
              //           .toList(),
              //       value: selectedValueCountry,
              //       onChanged: (value) {
              //         setState(() {
              //           selectedValueCountry = value as String;
              //         });
              //       },
              //       icon: const Icon(
              //         Icons.arrow_drop_down,
              //       ),
              //       iconSize: 30,
              //       iconEnabledColor: Colors.black,
              //       iconDisabledColor: Colors.grey,
              //       buttonHeight: 50,
              //       // buttonWidth: 160,
              //       buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              //       buttonDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         border: Border.all(
              //           color: Colors.black26,
              //         ),
              //         color: Colors.white,
              //       ),
              //       buttonElevation: 2,
              //       itemHeight: 40,
              //       itemPadding: const EdgeInsets.only(left: 14, right: 14),
              //       dropdownMaxHeight: 200,
              //       dropdownWidth: 200,
              //       dropdownPadding: null,
              //       dropdownDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         color: Colors.white,
              //       ),
              //       dropdownElevation: 8,
              //       scrollbarRadius: const Radius.circular(40),
              //       scrollbarThickness: 6,
              //       scrollbarAlwaysShow: true,
              //       offset: const Offset(-20, 0),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 15.0, right: 15.0, top: 15, bottom: 0),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton2(
              //       isExpanded: true,
              //       hint: Row(
              //         children: const [
              //           Icon(
              //             Icons.list,
              //             size: 16,
              //             color: Colors.black,
              //           ),
              //           Expanded(
              //             child: Text(
              //               'Select Race',
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.black,
              //               ),
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //           ),
              //         ],
              //       ),
              //       items: itemsRace
              //           .map((item) => DropdownMenuItem<String>(
              //                 value: item,
              //                 child: Text(
              //                   item,
              //                   style: const TextStyle(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.black,
              //                   ),
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ))
              //           .toList(),
              //       value: selectedValueRace,
              //       onChanged: (value) {
              //         setState(() {
              //           selectedValueRace = value as String;
              //         });
              //       },
              //       icon: const Icon(
              //         Icons.arrow_drop_down,
              //       ),
              //       iconSize: 30,
              //       iconEnabledColor: Colors.black,
              //       iconDisabledColor: Colors.grey,
              //       buttonHeight: 50,
              //       // buttonWidth: 160,
              //       buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              //       buttonDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         border: Border.all(
              //           color: Colors.black26,
              //         ),
              //         color: Colors.white,
              //       ),
              //       buttonElevation: 2,
              //       itemHeight: 40,
              //       itemPadding: const EdgeInsets.only(left: 14, right: 14),
              //       dropdownMaxHeight: 200,
              //       dropdownWidth: 200,
              //       dropdownPadding: null,
              //       dropdownDecoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(14),
              //         color: Colors.white,
              //       ),
              //       dropdownElevation: 8,
              //       scrollbarRadius: const Radius.circular(40),
              //       scrollbarThickness: 6,
              //       scrollbarAlwaysShow: true,
              //       offset: const Offset(-20, 0),
              //     ),
              //   ),
              // ),

              // Padding(
              //     padding: const EdgeInsets.only(
              //         left: 15.0, right: 15.0, top: 15, bottom: 0),
              //     child: Row(
              //       children: <Widget>[
              //         Expanded(
              //           child: Text('I AM IN THE COMMON POOL OF VOLUNTEERS',
              //               textAlign: TextAlign.left),
              //         ),
              //         Container(
              //           child: CustomSwitch(
              //             activeColor: Colors.blue,
              //             value: statusCommonPool,
              //             onChanged: (value) async {
              //               print("VALUE : $value");
              //               if (value) {
              //                 await FirebaseFirestore.instance
              //                     .collection('Users')
              //                     .doc(userUid)
              //                     .update({'CommonPool': true}).then(
              //                         (value) => showDialog(
              //                             context: context,
              //                             builder: (BuildContext context) {
              //                               return AlertDialog(
              //                                 title: Text(""),
              //                                 content: Text(
              //                                     "I am in the common pool of volunteers"),
              //                                 actions: [
              //                                   TextButton(
              //                                     child: Text("Ok"),
              //                                     onPressed: () {
              //                                       Navigator.of(context).pop();
              //                                     },
              //                                   )
              //                                 ],
              //                               );
              //                             }));
              //               } else {
              //                 await FirebaseFirestore.instance
              //                     .collection('Users')
              //                     .doc(userUid)
              //                     .update({'CommonPool': false}).then(
              //                         (value) => showDialog(
              //                             context: context,
              //                             builder: (BuildContext context) {
              //                               return AlertDialog(
              //                                 title: Text(""),
              //                                 content: Text(
              //                                     "I am not in the common pool of volunteers"),
              //                                 actions: [
              //                                   TextButton(
              //                                     child: Text("Ok"),
              //                                     onPressed: () {
              //                                       Navigator.of(context).pop();
              //                                     },
              //                                   )
              //                                 ],
              //                               );
              //                             }));
              //               }
              //               setState(() {
              //                 statusCommonPool = value;
              //               });
              //             },
              //           ),
              //         ),
              //       ],
              //     )
              //
              //     // CustomSwitch(
              //     //   activeColor: Colors.blue,
              //     //   value: statusCommonPool,
              //     //   onChanged: (value) {
              //     //     print("VALUE : $value");
              //     //     setState(() {
              //     //       statusCommonPool = value;
              //     //     });
              //     //   },
              //     // ),
              //     ),
              Container(
                height: 50,
                width: 250,
                margin: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () => UpdateProfile(),
                  child: Text(
                    'Update Profile'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
    _imageFileList?.forEach((element) {
      uploadFile(element);
    });
  }

  Future<String> uploadFile(XFile _image) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        '$userUid/profilePic/profilePic_${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(File(_image.path));
    await uploadTask;
    String returnURL = "";
    await storageReference.getDownloadURL().then((fileURL) async {
      returnURL = fileURL;
      // Save to firestore
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .update({'ProfilePic': fileURL});

      // Update profile pic
      var userProfile = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .get();
      setState(() {
        userProfileV = userProfile.exists ? userProfile.data() : null;
      });
    });
    return returnURL;
  }

  Future<void> UpdateProfile() async {
    // int age = int.parse(currentYear) -
    //     int.parse(DateFormat('yyyy')
    //         .format(DateTime.parse("$dobController.text"))
    //         .toString());
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      // title: 'Profile'.tr(),
      desc: 'Proceed to submit your updated profile?'.tr(),
      btnOkOnPress: () {
        FirebaseFirestore.instance.collection('Users').doc(userUid).update({
          'UpdatedAt': DateTime.now(),
          'Name': nameController.text,
          'PhoneNumber': phoneController.text,
          'Address': addressController.text,
          'PostalCode': postalcodeController.text,
          'Gender': genderController.text,
          // 'Country': selectedValueCountry,
          // 'Race': selectedValueRace,
          'DateOfBirth': dobController.text,
          // 'Age': age.toString(),
          'IsVolunteer': checkedValue,
          'Role': selectedValueRoleList
        }).then(
          (value) => AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            // title: 'Profile'.tr(),
            desc: "Submitted Successfully".tr(),
            btnOkOnPress: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('userName', nameController.text);

              if (selectedValueRoleList != null) {
                prefs.setString('userRole', selectedValueRoleList!);
                FirebaseFirestore.instance
                    .collection('RoleList')
                    .doc(selectedValueRoleList)
                    .get()
                    .then((roleDetails) async => {
                          prefs.setString(
                              'userOrgId',
                              roleDetails.data()!['OrganizationId'] != null
                                  ? roleDetails.data()!['OrganizationId']
                                  : ""),
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userUid)
                              .update({
                            'OrganizationId':
                                roleDetails.data()!['OrganizationId'] != null
                                    ? roleDetails.data()!['OrganizationId']
                                    : "",
                          })
                        });
              }
              ;

              getUser();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            btnCancelOnPress: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('userName', nameController.text);
              getUser();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ).show(),
        );
      },
      btnCancelOnPress: () {},
    ).show();
  }
}

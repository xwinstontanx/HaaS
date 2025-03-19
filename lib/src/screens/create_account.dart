import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateAccountScreen extends StatefulWidget {
  final String method;

  const CreateAccountScreen(this.method, {super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final nameController = TextEditingController();
  final phonenumberController = TextEditingController();

  final addressController = TextEditingController();
  final postalController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late DateTime _selectedDate;
  String selectedDOB = "";
  String? selectedValue;
  String? selectedValueRoleList;
  bool disclaimer = false;
  String orgID = "";

  final codeController = TextEditingController();
  String verificationReceived = '';
  bool sendCode = false;
  bool checkedValue = false;

  late ConfirmationResult confirmationResult;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "Male", child: Text("Male".tr())),
      DropdownMenuItem(value: "Female", child: Text("Female".tr())),
    ];
    return menuItems;
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

  // Initially password is obscure
  bool _obscureText = true;
  String version = "";

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CREATE ACCOUNT".tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? 600.0 : double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black26, width: 1),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                elevation: 7,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Kindly Enter Following Information'.tr(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'NAME'.tr(),
                          hintText: '',
                          prefixIcon: const Icon(Icons.people, size: 24),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 15),
                      child: TextField(
                          controller: phonenumberController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            // labelText:
                            //     'PHONE NUMBER'.tr() + ' (' + 'Optional'.tr() + ')',
                            labelText: 'PHONE NUMBER'.tr(),
                            hintText: '',
                            prefixIcon: const Icon(Icons.phone, size: 24),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0, bottom: 15),
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // labelText: 'Gender'.tr(),
                            prefixIcon: Icon(Icons.person_pin, size: 32),
                          ),
                          hint: Text('Gender'.tr()),
                          value: selectedValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                          items: dropdownItems),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 0, bottom: 15),
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade500,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.calendar_month,
                                        size: 24, color: Colors.grey.shade500),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Date of Birth'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                Text(
                                  selectedDOB,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0, bottom: 15),
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Home Address'.tr(),
                          hintText: '',
                          prefixIcon: const Icon(Icons.location_on, size: 24),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0, bottom: 15),
                      child: TextField(
                          controller: postalController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'POSTAL CODE'.tr(),
                            hintText: '',
                            prefixIcon: const Icon(Icons.home, size: 24),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                          ]),
                    ),
                    widget.method == "email"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 0, bottom: 15),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Email'.tr(),
                                  hintText: '',
                                  prefixIcon:
                                      const Icon(Icons.email, size: 24)),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(),
                          ),
                    widget.method == "email"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 0, bottom: 15),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Password'.tr(),
                                hintText: '',
                                prefixIcon:
                                    const Icon(Icons.lock_rounded, size: 24),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: _toggle,
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(),
                          ),
                    widget.method == "email"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 0, bottom: 15),
                            child: TextField(
                              controller: confirmPasswordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Confirm Password'.tr(),
                                hintText: '',
                                prefixIcon:
                                    const Icon(Icons.lock_rounded, size: 24),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: _toggle,
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0, bottom: 15),
                      child: FutureBuilder<List<DropdownMenuItem<String>>>(
                        future: fetchDropdownItemsRoleList(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                            left: 15.0, right: 15.0, top: 5, bottom: 15),
                        child: CheckboxListTile(
                          title: Text(
                              "I wish to receive volunteering event details"
                                  .tr(),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                          value: checkedValue,
                          onChanged: (newValue) {
                            setState(() {
                              checkedValue = newValue!;
                            });
                          },
                          visualDensity: const VisualDensity(
                              horizontal: -4.0, vertical: -4.0),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        )),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0, bottom: 10.0),
                      child: Center(
                          child: Text.rich(TextSpan(
                              text:
                                  'By creating an account, you have read and acknowledge the '
                                      .tr(),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                              children: <TextSpan>[
                            TextSpan(
                                text: 'Privacy Policy'.tr(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(Uri.parse(
                                        'https://www.senzepact.com/2023/privacy-policy-3/'));
                                  })
                          ]))),
                    ),
                    sendCode == true
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15, bottom: 0),
                            child: TextField(
                              controller: codeController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Verification Code'.tr(),
                                hintText: '',
                                prefixIcon:
                                    const Icon(Icons.lock_rounded, size: 24),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: _toggle,
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(),
                          ),
                    sendCode == false && widget.method == "phone"
                        ? Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => verifyPhoneNumber(),
                              child: Text(
                                'Get Verification Code'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          )
                        : Container(),
                    sendCode == true && widget.method == "phone"
                        ? Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => createAccountWithPhoneNumber(
                                  codeController.text),
                              child: Text(
                                'SUBMIT'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          )
                        : Container(),
                    widget.method == "email"
                        ? Container(
                            height: 50,
                            width: 250,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () => signUp(
                                  nameController.text,
                                  phonenumberController.text,
                                  selectedValue,
                                  selectedDOB,
                                  addressController.text,
                                  postalController.text,
                                  emailController.text,
                                  passwordController.text,
                                  confirmPasswordController.text,
                                  selectedValueRoleList),
                              child: Text(
                                'SUBMIT'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          )
                        : Container(),
                    // Container(
                    //   height: 50,
                    //   width: 250,
                    //   margin: const EdgeInsets.symmetric(vertical: 30),
                    //   decoration: BoxDecoration(
                    //       color: Colors.blue,
                    //       borderRadius: BorderRadius.circular(20)),
                    //   child: TextButton(
                    //     onPressed: () => {
                    //       if (widget.method == "email")
                    //         {
                    //           signUp(
                    //               nameController.text,
                    //               phonenumberController.text,
                    //               selectedValue,
                    //               selectedDOB,
                    //               addressController.text,
                    //               postalController.text,
                    //               emailController.text,
                    //               passwordController.text,
                    //               confirmPasswordController.text)
                    //         },
                    //       if (widget.method == "phone")
                    //         {
                    //           signUp(
                    //               nameController.text,
                    //               phonenumberController.text,
                    //               selectedValue,
                    //               selectedDOB,
                    //               addressController.text,
                    //               postalController.text,
                    //               "",
                    //               "",
                    //               "")
                    //         }
                    //     },
                    //     child: Text(
                    //       'SUBMIT'.tr(),
                    //       style: const TextStyle(
                    //           color: Colors.white, fontSize: 15),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp(name, phonenumber, gender, dob, address, postal, email,
      password, confirmPassword, roleNumber) async {
    EasyLoading.show(status: 'Creating...'.tr());

    if (widget.method == "email") {
      if (password != confirmPassword) {
        EasyLoading.dismiss();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: '',
          desc: 'Password is not identical.'.tr(),
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            Navigator.of(context).pop();
          },
        ).show();
      } else if (name != "" &&
          phonenumber != "" &&
          gender != "" &&
          dob != "" &&
          address != "" &&
          postal != "" &&
          roleNumber != "" &&
          email != "" &&
          password != "" &&
          password.length > 5) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          final user = userCredential.user;
          user?.sendEmailVerification();

          // To get the division
          FirebaseFirestore.instance
              .collection('PostalCodeList')
              .where('PostalCode', isEqualTo: postal)
              .get()
              .then((divisions) => {
                    for (var division in divisions.docs)
                      {
                        if (division.data()['Division'] ==
                            "BEDOK RESERVOIR-PUNGGOL")
                          {orgID = "4C2ppIky98e5iEH7TdAJ"}
                      }
                  })
              .then((value) => {
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user?.uid)
                        .set({
                          'CreatedAt': DateTime.now(),
                          'Name': name,
                          'PhoneNumber': phonenumber,
                          'Gender': gender,
                          'DateOfBirth': dob,
                          'Address': address,
                          'PostalCode': postal,
                          'Uid': user?.uid,
                          'Country': 'Singapore',
                          'CountryCode': '+65',
                          'OrganizationId': orgID,
                          'IsVolunteer': checkedValue,
                          'SignUpWithEmail': true,
                          'Email': email.toString().toLowerCase(),
                          'Role': roleNumber,
                        })
                        .then((value) => {
                              EasyLoading.dismiss(),
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.bottomSlide,
                                title: 'Account Created'.tr(),
                                desc:
                                    'Please check your inbox/junk to verfiy your email'
                                        .tr(),
                                btnOkOnPress: () {
                                  Navigator.of(context).pop();
                                },
                              ).show()
                            })
                        .catchError(
                            (error) => print("Failed to add user: $error"))
                  });
        } on FirebaseAuthException catch (e) {
          EasyLoading.dismiss();
          if (e.code == 'weak-password') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error'.tr(),
              desc: 'The provided password is too weak'.tr(),
              btnOkOnPress: () {},
            ).show();
          } else if (e.code == 'email-already-in-use') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error'.tr(),
              desc: 'The credential has been used'.tr(),
              btnOkOnPress: () {},
            ).show();
          }
        } catch (e) {
          print(e);
        }
      } else {
        EasyLoading.dismiss();
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
  }

  Future<void> signUpWithPhoneNumber(name, phonenumber, gender, dob, address,
      postal, roleNumber, User user) async {
    EasyLoading.show(status: 'Creating...'.tr());

    if (widget.method == "phone") {
      if (name != "" &&
          phonenumber != "" &&
          gender != "" &&
          dob != "" &&
          address != "" &&
          postal != "" &&
          roleNumber != "") {
        try {
          // To get the division
          FirebaseFirestore.instance
              .collection('PostalCodeList')
              .where('PostalCode', isEqualTo: postal)
              .get()
              .then((divisions) => {
                    for (var division in divisions.docs)
                      {
                        if (division.data()['Division'] ==
                            "BEDOK RESERVOIR-PUNGGOL")
                          {orgID = "4C2ppIky98e5iEH7TdAJ"}
                      }
                  })
              .then((value) => {
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user?.uid)
                        .set({
                          'CreatedAt': DateTime.now(),
                          'Name': name,
                          'PhoneNumber': phonenumber,
                          'Gender': gender,
                          'DateOfBirth': dob,
                          'Address': address,
                          'PostalCode': postal,
                          'Uid': user?.uid,
                          'Country': 'Singapore',
                          'CountryCode': '+65',
                          'OrganizationId': orgID,
                          'IsVolunteer': checkedValue,
                          'SignUpWithEmail': false,
                          'Role': roleNumber,
                        })
                        .then((value) => {
                              EasyLoading.dismiss(),
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.bottomSlide,
                                title: 'Account Created'.tr(),
                                desc:
                                    'Kindly proceed to Login With Phone Number'
                                        .tr(),
                                btnOkOnPress: () {
                                  Navigator.of(context).pop();
                                },
                              ).show()
                            })
                        .catchError(
                            (error) => print("Failed to add user: $error"))
                  });
        } on FirebaseAuthException catch (e) {
          EasyLoading.dismiss();
          if (e.code == 'weak-password') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error'.tr(),
              desc: 'The provided password is too weak'.tr(),
              btnOkOnPress: () {},
            ).show();
          } else if (e.code == 'email-already-in-use') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error'.tr(),
              desc: 'The credential has been used'.tr(),
              btnOkOnPress: () {},
            ).show();
          }
        } catch (e) {
          print(e);
        }
      } else {
        EasyLoading.dismiss();
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
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    final DateTime? selectedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate == null || selectedDate == _selectedDate) {
      return;
    }
    setState(() {
      _selectedDate = selectedDate;
      selectedDOB = formatter.format(_selectedDate);
    });
  }

  Future<void> verifyPhoneNumber() async {
    EasyLoading.show(status: 'Getting Verification Code...'.tr());
    try {
      if (phonenumberController.text.length == 8) {
        if (nameController.text != "" &&
            selectedValue != "" &&
            selectedDOB != "" &&
            addressController.text != "" &&
            postalController.text != "") {
          FirebaseFirestore.instance
              .collection('Users')
              .where('PhoneNumber', isEqualTo: phonenumberController.text)
              .get()
              .then((userSnapshot) async => {
                    if (userSnapshot.size == 0)
                      {
                        if (kIsWeb)
                          {
                            await FirebaseAuth.instance
                                .signInWithPhoneNumber(
                                    "+65${phonenumberController.text}")
                                .then((result) => {
                                      EasyLoading.dismiss(),
                                      confirmationResult = result,
                                      setState(() {
                                        sendCode = true;
                                        confirmationResult = result;
                                      }),
                                    }),
                          }
                        else
                          {
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: "+65${phonenumberController.text}",
                              verificationCompleted:
                                  (PhoneAuthCredential credential) async {},
                              verificationFailed: (FirebaseAuthException e) {
                                EasyLoading.dismiss();
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.bottomSlide,
                                  title: 'Error'.tr(),
                                  desc: e.code,
                                  btnOkOnPress: () {
                                    Navigator.of(context).pop();
                                  },
                                ).show();
                                if (e.code == 'invalid-phone-number') {
                                  print(
                                      'The provided phone number is not valid.');
                                }

                                // Handle other errors
                              },
                              codeSent:
                                  (String verificationId, int? resendToken) {
                                EasyLoading.dismiss();
                                setState(() {
                                  sendCode = true;
                                });
                                verificationReceived = verificationId;
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {
                                print('Code auto retrieval timeout');
                              },
                            )
                          }
                      }
                    else
                      {
                        EasyLoading.dismiss(),
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.bottomSlide,
                          title: 'Error'.tr(),
                          desc:
                              'Phone number exists in our records, kindly proceed to login with previous credential'
                                  .tr(),
                          btnOkOnPress: () {
                            Navigator.of(context).pop();
                          },
                        ).show()
                      }
                  });
        } else {
          EasyLoading.dismiss();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error'.tr(),
            desc: 'Kindly fill up all the fields'.tr(),
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        EasyLoading.dismiss();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Phone Number'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      print('Error sending SMS verification code: $e');
      // setState(() {
      //   sendCode = false;
      // });
      if (e.code == "invalid-verification-id") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      if (e.code == "code-expired") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'The verification code has expired. Please try again.'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      if (e.code == "invalid-verification-code") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> createAccountWithPhoneNumber(String codeEntered) async {
    EasyLoading.show(status: 'Creating...'.tr());

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await confirmationResult.confirm(codeEntered);
      } else {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationReceived,
          smsCode: codeEntered,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (widget.method == "phone") {
        signUpWithPhoneNumber(
            nameController.text,
            phonenumberController.text,
            selectedValue,
            selectedDOB,
            addressController.text,
            postalController.text,
            selectedValueRoleList,
            user!);
      }
      setState(() {
        sendCode = false;
      });
      EasyLoading.dismiss();
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      if (e.code == "invalid-verification-id") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      if (e.code == "code-expired") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'The verification code has expired. Please try again.'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      if (e.code == "invalid-verification-code") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Error'.tr(),
          desc: 'Invalid Code'.tr(),
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
        ).show();
      }
      print('Error signing in with SMS code: $e');
    }
  }
}

import 'dart:async';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as Flutter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senzepact/src/screens/Volunteering/Scanner/HealthHome.dart';
import '../../../../firebase_options_senzehub.dart';
import '../Volunteering.dart';
import '../VolunteeringService.dart';

// import 'package:flutter_barcode_scanner_fork/flutter_barcode_scanner.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class MainScannerPage extends StatefulWidget {
  final VolunteeringService service;

  const MainScannerPage({Flutter.Key? key, required this.service})
      : super(key: key);

  @override
  State<MainScannerPage> createState() => MainScannerPageState();
}

class MainScannerPageState extends State<MainScannerPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    scanQR();
  }

  String encryptAESCryptoJS(String plainText, String passphrase) {
    try {
      final salt = genRandomWithNonZero(8);
      var keyndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyndIV.item1);
      final iv = encrypt.IV(keyndIV.item2);

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      Uint8List encryptedBytesWithSalt = Uint8List.fromList(
          createUint8ListFromString("Salted__") + salt + encrypted.bytes);
      return base64.encode(encryptedBytesWithSalt);
    } catch (error) {
      rethrow;
    }
  }

  String decryptAESCryptoJS(String encrypted, String passphrase) {
    try {
      Uint8List encryptedBytesWithSalt = base64.decode(encrypted);

      Uint8List encryptedBytes =
          encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
      final salt = encryptedBytesWithSalt.sublist(8, 16);
      var keyndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyndIV.item1);
      final iv = encrypt.IV(keyndIV.item2);

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
      final decrypted =
          encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
      return decrypted;
    } catch (error) {
      rethrow;
    }
  }

  Tuple2<Uint8List, Uint8List> deriveKeyAndIV(
      String passphrase, Uint8List salt) {
    var password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash = Uint8List(0);

    while (!enoughBytesForKey) {
      int preHashLength = currentHash.length + password.length + salt.length;
      if (currentHash.length > 0) {
        preHash = Uint8List.fromList(currentHash + password + salt);
      } else {
        preHash = Uint8List.fromList(password + salt);
      }

      // currentHash = md5.convert(preHash).bytes;
      currentHash = Uint8List.fromList(md5.convert(preHash).bytes);
      concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
      if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
    }

    var keyBtyes = concatenatedHashes.sublist(0, 32);
    var ivBtyes = concatenatedHashes.sublist(32, 48);
    return Tuple2(keyBtyes, ivBtyes);
  }

  Uint8List createUint8ListFromString(String s) {
    var ret = Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  Uint8List genRandomWithNonZero(int seedLength) {
    final random = Random.secure();
    const int randomMax = 245;
    final Uint8List uint8list = Uint8List(seedLength);
    for (int i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax) + 1;
    }
    return uint8list;
  }

  Future<void> startBarcodeScanStream() async {
    // FlutterBarcodeScanner.getBarcodeStreamReceiver(
    //         '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
    //     .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    //       '#ff6666', 'Cancel', true, ScanMode.QR, DefaultCamera.BACK);
    //   print(barcodeScanRes);
    // } on PlatformException {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }
    //
    // try {
    //   // Decrypt
    //   String decryptedText =
    //       decryptAESCryptoJS(barcodeScanRes, 'SenzeHub is the best');
    //   print(
    //       'Decrypted data: $decryptedText'); // SenzePact-AHapkZ08juNY87if72k0DcCVKWm2-2023-07-20 13:55:29.976
    //
    //   if (decryptedText.contains("-")) {
    //     final firstDashIndex = decryptedText.indexOf("-");
    //     final projectName = decryptedText.substring(0, firstDashIndex);
    //     final elderlyUidDateTime = decryptedText.substring(firstDashIndex + 1);
    //
    //     final elderlyUidDate = elderlyUidDateTime.split(" ")[0];
    //     final elderlyUidDateDashIndex = elderlyUidDateTime.indexOf("-");
    //     final elderlyUid =
    //         elderlyUidDateTime.substring(0, elderlyUidDateDashIndex);
    //     final date = elderlyUidDateTime
    //         .substring(elderlyUidDate.length - 10)
    //         .substring(0, 10);
    //     final timePart = elderlyUidDateTime.split(" ")[1];
    //
    //     // print(projectName);
    //     // print(elderlyUidDateTime);
    //     // print(elderlyUidDate);
    //     // print(elderlyUidDateDashIndex);
    //     // print(elderlyUid);
    //     // print(date);
    //     // print(timePart);
    //     final decryptedDateTime = DateTime.parse(date + "T" + timePart);
    //     final currentDateTime = DateTime.now();
    //
    //     final duration = currentDateTime.difference(decryptedDateTime);
    //
    //     print('duration data: $duration');
    //     if (duration.inMinutes < 1) {
    //       print('duration data: $duration');
    //       FirebaseFirestore.instance
    //           .collection('Users')
    //           .doc(elderlyUid)
    //           .get()
    //           .then((data) {
    //         if (data.exists) {
    //           Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (_) => HealthHomePage(elderlyUid)));
    //         } else {
    //           AwesomeDialog(
    //             context: context,
    //             dialogType: DialogType.error,
    //             animType: AnimType.bottomSlide,
    //             title: 'Error'.tr(),
    //             desc: 'Senior not found'.tr(),
    //             btnOkOnPress: () {
    //               Navigator.push(context,
    //                   MaterialPageRoute(builder: (_) => VolunteeringPage()));
    //             },
    //           ).show();
    //         }
    //       });
    //     } else {
    //       AwesomeDialog(
    //         context: context,
    //         dialogType: DialogType.error,
    //         animType: AnimType.bottomSlide,
    //         title: 'Error'.tr(),
    //         desc: 'Kindly use the latest QR code'.tr(),
    //         btnOkOnPress: () {
    //           Navigator.push(context,
    //               MaterialPageRoute(builder: (_) => VolunteeringPage()));
    //         },
    //       ).show();
    //     }
    //   } else {
    //     AwesomeDialog(
    //       context: context,
    //       dialogType: DialogType.error,
    //       animType: AnimType.bottomSlide,
    //       title: 'Error'.tr(),
    //       desc: 'Invalid QR code'.tr(),
    //       btnOkOnPress: () {
    //         Navigator.push(
    //             context, MaterialPageRoute(builder: (_) => VolunteeringPage()));
    //       },
    //     ).show();
    //   }
    // } catch (error) {
    //   AwesomeDialog(
    //     context: context,
    //     dialogType: DialogType.error,
    //     animType: AnimType.bottomSlide,
    //     title: 'Error'.tr(),
    //     desc: 'Invalid QR code.'.tr(),
    //     btnOkOnPress: () {
    //       Navigator.push(
    //           context, MaterialPageRoute(builder: (_) => VolunteeringPage()));
    //     },
    //   ).show();
    // }
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
          title: Text("QR Scanner".tr()),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
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

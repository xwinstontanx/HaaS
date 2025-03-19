import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:easy_localization/easy_localization.dart';

class ShowQrCodePage extends StatefulWidget {
  const ShowQrCodePage({Key? key}) : super(key: key);

  @override
  createState() => ShowQrCodePageState();
}

class ShowQrCodePageState extends State<ShowQrCodePage> {
  bool statusCommonPool = false;
  var userUid = "";
  var name = "";
  var encryptedUidTimestamp = '';
  Timer? timer;

  @override
  void initState() {
    // For initial first QR
    setState(() {
      encryptedUidTimestamp = generateQR();
    });

    getUser().then((value) => {
          //code to run on every 10 seconds
          timer = Timer.periodic(const Duration(seconds: 10), (timer) {
            setState(() {
              encryptedUidTimestamp = generateQR();
            });
            // print(decryptAESCryptoJS(
            //     encryptedUidTimestamp, 'SenzeHub is the best'));
            // print(encryptedUidTimestamp);
          })
        });

    super.initState();
  }

  String generateQR() {
    var currentTimeStamp = DateTime.now().toString();

    return encryptAESCryptoJS(
        "SenzePact-$userUid-$currentTimeStamp", 'SenzeHub is the best');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
    });
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .get()
        .then((data) {
      setState(() {
        name = data['Name'];
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
            onPressed: () => {timer?.cancel(), Navigator.of(context).pop()}),
        title: Text("QR Code".tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: QrImageView(
                          data: encryptedUidTimestamp,
                          version: QrVersions.auto,
                          size: 250.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(
                          name,
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

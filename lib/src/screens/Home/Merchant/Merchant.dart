import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/Merchant/MerchantDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Responsive/FormFactor.dart';

class MerchantPage extends StatefulWidget {
  const MerchantPage({Key? key}) : super(key: key);

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  var userUid = "";
  var userName = "";
  var merchantList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
    await getMerchantData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  Future<void> getMerchantData() async {
    FirebaseFirestore.instance
        .collection('Merchant')
        .orderBy('CreatedAt', descending: false)
        .get()
        .then((merchantSnapshot) => {
              merchantList = [],
              if (merchantSnapshot.docs.isNotEmpty)
                {
                  for (var merchant in merchantSnapshot.docs)
                    {
                      setState(() {
                        merchantList.add({
                          'docID': merchant.id,
                          'data': merchant.data(),
                          'showPromo': false,
                          'FromFlashScreen':false,
                        });
                      })
                    }
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
        title: Text("Merchants".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: kIsWeb ? FormFactor.desktop : double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                  physics: const ScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: kIsWeb? 0.8: 0.8,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    ...merchantList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        //apply padding to all four sides
                        child: Container(
                          decoration: boxDecoration(Colors.blue),
                          child: InkWell(
                            splashColor: Colors.green,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MerchantDetailPage(item)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  (item!['data']['MerchantIcon'] == null)
                                      ? const SizedBox(
                                    height: 0,
                                  )
                                      : Image.network(item!['data']['MerchantIcon'] ?? "",
                                      height: 50, fit: BoxFit.fill,
                                      loadingBuilder: (BuildContext context, Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace)
                                      {
                                        return const Text('');
                                      }
                                  ),
                                  Text(item['data']['Name'].toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ]),
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

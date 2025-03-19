import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantDetailPage extends StatefulWidget {
  var item;

  MerchantDetailPage(this.item, {Key? key}) : super(key: key);

  @override
  State<MerchantDetailPage> createState() {
    return _MerchantDetailPageState();
  }
}

class _MerchantDetailPageState
    extends State<MerchantDetailPage> {
  var userUid = "";
  var userName = "";
  var merchantList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
    if (kDebugMode) {
      // print(widget.item);
    }
  }

  retrieveData() async {
    // await getUser();
    // await getMerchantData();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  // Future<void> getMerchantData() async {
  //   FirebaseFirestore.instance
  //       .collection('Merchant')
  //       .orderBy('CreatedAt', descending: false)
  //       .get()
  //       .then((merchantSnapshot) => {
  //             merchantList = [],
  //             if (merchantSnapshot.docs.isNotEmpty)
  //               {
  //                 for (var merchant in merchantSnapshot.docs)
  //                   {
  //                     setState(() {
  //                       merchantList.add({
  //                         'docID': merchant.id,
  //                         'data': merchant.data(),
  //                       });
  //                     })
  //                   }
  //               }
  //           });
  // }

  @override
  Widget build(BuildContext context) {
    // var merchant = Map<String, dynamic>.from(widget.item);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text(widget.item['data']['Name']),
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 100.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (widget.item['data']['MerchantIcon'] == null)
                    ? const SizedBox(
                        height: 0,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                            widget.item['data']['MerchantIcon'] ?? "",
                            height: 50,
                            fit: BoxFit.fill, loadingBuilder:
                                (BuildContext context, Widget child,
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
                        }, errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                          return const Text('');
                        }),
                      ),
                (widget.item['data']['MerchantImage'] == null)
                    ? const SizedBox(
                        height: 0,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                            widget.item['data']['MerchantImage'] ?? "",
                            fit: BoxFit.fill, loadingBuilder:
                                (BuildContext context, Widget child,
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
                        }, errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                          return const Text('');
                        }),
                      ),
                Content(
                    merchant: widget.item['data']['Slogan'].toString(),
                    value: 'Slogan',
                    showTitle: false),
                Content(
                    merchant: widget.item['data']['Description'].toString(),
                    value: 'Description',
                    showTitle: false),
                Content(
                    merchant: widget.item['data']['Website'].toString(),
                    value: 'Website',
                    showTitle: true),
                Content(
                    merchant: widget.item['data']['PIC'].toString(),
                    value: 'PIC',
                    showTitle: true),
                Content(
                    merchant: widget.item['data']['PhoneNumber'].toString(),
                    value: 'PhoneNumber',
                    showTitle: true),
                Content(
                    merchant: widget.item['data']['Address'].toString(),
                    value: 'Address',
                    showTitle: true),
              ],
            ),
          ),
        ));
  }
}

Future<void> launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

class Content extends StatelessWidget {
  const Content(
      {super.key,
      required this.merchant,
      required this.value,
      required this.showTitle});

  final showTitle;
  final value;
  final String merchant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: Column(
        children: [
          showTitle
              ? Row(
                  children: [
                    Flexible(
                      child: (merchant == "null")
                          ? const SizedBox(
                              height: 0,
                            )
                          : Text(value + ":",
                              textAlign: value == 'Description'
                                  ? TextAlign.start
                                  : TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: value == 'Description'
                                      ? FontWeight.normal
                                      : FontWeight.bold)),
                    ),
                  ],
                )
              : const SizedBox(
                  height: 0,
                ),
          Row(
            children: [
              Flexible(
                child: (merchant == "null")
                    ? const SizedBox(
                        height: 0,
                      )
                    : GestureDetector(
                        onTap: () {
                          if (value == 'Website') {
                            launchInBrowser(Uri.parse(merchant));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(merchant,
                              textAlign: value == 'Description'
                                  ? TextAlign.justify
                                  : TextAlign.start,
                              style: TextStyle(
                                  color: value == 'Description'
                                      ? Colors.black
                                      : value == 'Slogan'
                                          ? Colors.grey
                                          : Colors.blue,
                                  fontStyle: value == 'Slogan'
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  fontWeight: value == 'Description' ||
                                          value == 'Slogan'
                                      ? FontWeight.normal
                                      : FontWeight.bold)),
                        ),
                      ),
              ),
            ],
          ),
          value == 'Description'
              ? const SizedBox(
                  height: 14,
                )
              : const SizedBox(
                  height: 0,
                )
        ],
      ),
    );
  }
}

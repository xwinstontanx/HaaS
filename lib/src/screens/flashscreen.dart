import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/login.dart';
import 'package:senzepact/src/screens/Responsive/FormFactor.dart';
import 'package:senzepact/src/screens/Home/Merchant/MerchantDetails.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({Key? key}) : super(key: key);

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  var merchantList = [];

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getMerchantData();
  }

  void dialog(type, title, desc) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage("assets/images/background.jpg"),
          //     fit: BoxFit.fill,
          //   ),
          // ),
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: kIsWeb ? FormFactor.desktop : double.infinity,
                child: Center(
                  child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
                      child: Column(
                        children: [
                          // GestureDetector(
                          //   onTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       builder: (BuildContext context1) {
                          //         return Column(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: <Widget>[
                          //             ListTile(
                          //               title: Text('ENGLISH'.tr()),
                          //               onTap: () {
                          //                 context.setLocale(
                          //                     const Locale('en'));
                          //                 Navigator.pop(context);
                          //               },
                          //             ),
                          //             ListTile(
                          //               title: Text('CHINESE'.tr()),
                          //               onTap: () {
                          //                 context.setLocale(
                          //                     const Locale('zh'));
                          //                 Navigator.pop(context);
                          //               },
                          //             ),
                          //             ListTile(
                          //               title: Text('MALAY'.tr()),
                          //               onTap: () {
                          //                 Navigator.pop(context);
                          //                 context.setLocale(
                          //                     const Locale('ms'));
                          //               },
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //   },
                          //   child: Column(
                          //     children: [
                          //       const Icon(Icons.language,
                          //           size: 25, color: Colors.blue),
                          //       Text("Change Language2".tr(),
                          //           textAlign: TextAlign.center,
                          //           style: const TextStyle(
                          //               color: Colors.blue, fontSize: 10))
                          //     ],
                          //   ),
                          // ),
                          const Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  "Bedok Reservoir-Punggol imPact Day\n(10 - 11 June, 11am to 5pm)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(
                          //       "Community, Family, Games, Jobs and Health"
                          //           .tr(),
                          //       textAlign: TextAlign.center,
                          //       style: const TextStyle(
                          //         color: Colors.black,
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 13,
                          //       )),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/images/brochure.jpeg'),
                          ),
                          GridView.count(
                              physics: const ScrollPhysics(),
                              crossAxisCount: 2,
                              // childAspectRatio: kIsWeb? 7.0: 0.8,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                // createAccount(),
                                signIn(),
                                changeLanguage(),

                                // registerForTalks(),
                                // upcomingCCEvents(),
                                // games(),
                                // quiz()
                              ]),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 0.0),
                            child: Text("Merchants and Partners".tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline)),
                          ),

                          GridView.count(
                              physics: const ScrollPhysics(),
                              crossAxisCount: 2,
                              // childAspectRatio: kIsWeb? 2.5: 0.8,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                merchants(
                                    "Polarise Education",
                                    'assets/images/polarise.png',
                                    'http',
                                    "www.polariseeducation.org",
                                    "/Home.html"),
                                merchants(
                                    "Singapore Cancer Society",
                                    'assets/images/singaporecancersociety.png',
                                    'https',
                                    "singaporecancersociety.org.sg",
                                    "/"),
                                // merchants(
                                //     "Yamaha Music",
                                //     'assets/images/yamaha.png',
                                //     'https',
                                //     "sg.yamaha.com",
                                //     "/en/education/index.html"),
                                merchants(
                                    "Yamaha Music",
                                    'assets/images/yamahatrial.png',
                                    'https',
                                    "forms.gle",
                                    "/nVBpZ7awhs3yxhDU7"),
                                merchants(
                                    "Centre for Fathering",
                                    'assets/images/centreforfathering.jpeg',
                                    'https',
                                    "fathers.com.sg",
                                    "/"),
                                merchants(
                                    "HUR Solutions",
                                    'assets/images/hursolution.png',
                                    'https',
                                    "hursolutions.com",
                                    "/"),
                                merchants(
                                    "Silver Travel Horizon",
                                    'assets/images/silverhorizontravel.png',
                                    'https',
                                    "silverhorizontravel.com",
                                    "/"),
                                merchants(
                                    "Grateful World",
                                    'assets/images/gratefulworld.png',
                                    'https',
                                    "grateful-world.com",
                                    "/"),
                                merchants("Kimui", 'assets/images/kimui.png',
                                    'https', "kimui.com", "/"),
                              ]),
                          // Container(
                          //   color: Colors.blue[50],
                          //   child: GridView.count(
                          //       crossAxisCount: 2,
                          //       childAspectRatio: (itemWidth / itemHeight),
                          //       shrinkWrap: true,
                          //       scrollDirection: Axis.vertical,
                          //       children: [
                          //         ...merchantList.map((item) {
                          //           return Padding(
                          //             padding: const EdgeInsets.all(12),
                          //             //apply padding to all four sides
                          //             child: Container(
                          //               decoration: boxDecoration(Colors.blue),
                          //               child: InkWell(
                          //                 splashColor: Colors.green,
                          //                 onTap: () {
                          //                   Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                           builder: (_) =>
                          //                               VolunteeringMerchantDetailPage(
                          //                                   item)));
                          //                 },
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.all(8.0),
                          //                   child: Column(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.spaceEvenly,
                          //                     children: <Widget>[
                          //                       (item!['data']['MerchantIcon'] == null)
                          //                           ? const SizedBox(
                          //                               height: 0,
                          //                             )
                          //                           : Image.network(
                          //                               item!['data']['MerchantIcon'] ??
                          //                                   "",
                          //                               height: 50,
                          //                               fit: BoxFit.fill,
                          //                               loadingBuilder:
                          //                                   (BuildContext context,
                          //                                       Widget child,
                          //                                       ImageChunkEvent?
                          //                                           loadingProgress) {
                          //                               if (loadingProgress == null)
                          //                                 return child;
                          //                               return Center(
                          //                                 child:
                          //                                     CircularProgressIndicator(
                          //                                   value: loadingProgress
                          //                                               .expectedTotalBytes !=
                          //                                           null
                          //                                       ? loadingProgress
                          //                                               .cumulativeBytesLoaded /
                          //                                           loadingProgress
                          //                                               .expectedTotalBytes!
                          //                                       : null,
                          //                                 ),
                          //                               );
                          //                             }, errorBuilder: (BuildContext
                          //                                       context,
                          //                                   Object exception,
                          //                                   StackTrace? stackTrace) {
                          //                               return const Text('');
                          //                             }),
                          //                       Text(item['data']['Name'].toUpperCase(),
                          //                           textAlign: TextAlign.center,
                          //                           style: const TextStyle(
                          //                               color: Colors.blue,
                          //                               fontSize: 15,
                          //                               fontWeight: FontWeight.bold)),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           );
                          //         }).toList(),
                          //       ]),
                          // ),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ));
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

  Padding createAccount() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.create,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              // <-- Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("CREATE ACCOUNT".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding changeLanguage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('ENGLISH'.tr()),
                      onTap: () {
                        context.setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('CHINESE'.tr()),
                      onTap: () {
                        context.setLocale(const Locale('zh'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('MALAY'.tr()),
                      onTap: () {
                        Navigator.pop(context);
                        context.setLocale(const Locale('ms'));
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.language,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Change Language".tr(),
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

  Padding signIn() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.login,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Join the event".tr(),
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

  Padding registerForTalks() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Icon(Icons.mic,
                            color: Colors.blueAccent,
                            size: constraint.biggest.height / 1.5),
                      ),
                      const Text("/",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 16)),
                      Center(
                        child: Icon(Icons.wallet_giftcard,
                            color: Colors.blueAccent,
                            size: constraint.biggest.height / 1.5),
                      )
                    ],
                  );
                }),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Register For Talks and Lucky Draws".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding upcomingCCEvents() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.event,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              // <-- Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Upcoming CC Events".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding games() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.videogame_asset,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              // <-- Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Games".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  Padding quiz() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Center(
                    child: Icon(Icons.quiz,
                        color: Colors.blueAccent,
                        size: constraint.biggest.height / 1.5),
                  );
                }),
              ),
              // <-- Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("Quizzes".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              // <-- Text
            ],
          ),
        ),
      ),
    );
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
                          'FromFlashScreen': true,
                        });
                      })
                    }
                }
            });
  }

  Padding merchants(
      String name, String icon, String scheme, String host, String path) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: boxDecoration(Colors.blue),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () {
              launchInBrowser(Uri(scheme: scheme, host: host, path: path));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // const Icon(Icons.groups, color: Colors.blueAccent, size: 50.0),
                // Image.network(icon, height: 50, fit: BoxFit.fill),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraint) {
                    return Center(
                        child: SizedBox(
                            height: constraint.biggest.height / 1.5,
                            child: Image.asset(icon, fit: BoxFit.contain)));
                  }),
                ),

                // Text(name,
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(
                //         color: Colors.blue, fontWeight: FontWeight.bold)),
                // <-- Text
              ],
            ),
          ),
        ),
      ),
    );
  }
}

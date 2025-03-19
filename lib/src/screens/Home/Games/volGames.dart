import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/Games/CardMatching/CardMatching.dart';
import 'package:senzepact/src/screens/Home/Games/Snake/SnakeGame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Responsive/FormFactor.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  var userUid = "";
  var userName = "";

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  retrieveData() async {
    await getUser();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUid = prefs.getString('userUid')!;
      userName = prefs.getString('userName')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Games".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
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
                      CardMatching(),
                      // PacMan(),
                      Snake(),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding CardMatching() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CardMatchingPage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black26, width: 2),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    color: Colors.white,
                    child:
                        // Icon(Icons.question_mark,
                        //     color: Colors.white, size: 50.0)
                        Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/memorygame.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  )),
              Text("CARD MATCHING".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              // <-- Text
            ],
          ),
        ),
      ),
    );
  }

  // Padding PacMan() {
  //   return Padding(
  //     padding: const EdgeInsets.all(12.0),
  //     child: Container(
  //       decoration: boxDecoration(Colors.blue),
  //       child: InkWell(
  //         splashColor: Colors.green,
  //         onTap: () {
  //           // Navigator.of(context, rootNavigator: true)
  //           //     .push(MaterialPageRoute(builder: (context) => ()));
  //         },
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: <Widget>[
  //             Image.asset(
  //               'assets/images/games/pacman.png',
  //               height: 50,
  //               width: 50,
  //               fit: BoxFit.fitWidth,
  //             ),
  //             // <-- Icon
  //             Text("PAC-MAN".tr(),
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                     color: Colors.blue, fontWeight: FontWeight.bold)),
  //             // <-- Text
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Padding Snake() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: boxDecoration(Colors.blue),
        child: InkWell(
          splashColor: Colors.green,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => const SnakeGamePage()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black26, width: 1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    color: Colors.white,
                    child:
                        // Icon(Icons.question_mark,
                        //     color: Colors.white, size: 50.0)
                        Image.asset(
                      'assets/images/snakegame.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.fitWidth,
                    ),
                  )),

              // <-- Icon
              Text("SNAKE".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              // <-- Text
            ],
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

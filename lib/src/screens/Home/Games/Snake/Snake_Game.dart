import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Responsive/FormFactor.dart';
import 'Control_Panel.dart';
import 'Direction.dart';
import 'Piece.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _SnakeGamePageState createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<GamePage> {
  List<Offset> positions = [const Offset(160.0, 460.0)];
  int length = 1;
  int step = 20;
  Direction direction = Direction.right;

  late Piece food;

  late Offset foodPosition = const Offset(160.0, 460.0);
  late double screenWidth;
  late double screenHeight;
  late int lowerBoundX, upperBoundX, lowerBoundY, upperBoundY;

  late Timer timer = Timer(const Duration(milliseconds: 1), () {});
  double speed = 1;

  int score = 0;

  var userUid = "";
  var userName = "";

  void draw() async {
    if (positions.isEmpty) {
      positions.add(getRandomPositionWithinRange());
    }

    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }

    for (int i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }

    positions[0] = await getNextPosition(positions[0]);
  }

  Direction getRandomDirection([String? type]) {
    if (type == "horizontal") {
      bool random = Random().nextBool();
      if (random) {
        return Direction.right;
      } else {
        return Direction.left;
      }
    } else if (type == "vertical") {
      bool random = Random().nextBool();
      if (random) {
        return Direction.up;
      } else {
        return Direction.down;
      }
    } else {
      int random = Random().nextInt(4);
      return Direction.values[random];
    }
  }

  Offset getRandomPositionWithinRange() {
    int posX = Random().nextInt(upperBoundX) + lowerBoundX;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;
    return Offset(roundToNearestTens(posX).toDouble(),
        roundToNearestTens(posY).toDouble());
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundY && direction == Direction.up) {
      return true;
    }

    return false;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Game Over".tr(),
            style: const TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your scored ".tr() + score.toString(),
            style: const TextStyle(color: Colors.blueAccent),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (score != 0) {
                  int count = 0;
                  // FirebaseFirestore.instance
                  //     .collection('Users')
                  //     .doc(userUid)
                  //     .collection("GamesHistory")
                  //     .add({
                  //   'CreatedAt': DateTime.now(),
                  //   'GameName': 'Snake',
                  //   'Score': score.toString(),
                  // })
                  //
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userUid)
                      .collection('GamesHistory')
                      .where('GameName', isEqualTo: 'Snake')
                      .orderBy('CreatedAt', descending: true)
                      .limit(1)
                      .get()
                      .then((querySnapshot) {
                    //found
                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentSnapshot latestDoc = querySnapshot.docs.first;
                      Object? latestData = latestDoc.data();
                      Map<String, dynamic> myMap =
                          Map<String, dynamic>.from(latestData as Map);

                      DateTime dateTime = myMap['CreatedAt'].toDate();

                      DateTime currentDate = DateTime.now();

                      bool isToday = dateTime.year == currentDate.year &&
                          dateTime.month == currentDate.month &&
                          dateTime.day == currentDate.day;
                      //Compare date today then no add to total
                      if (isToday) {
                        // today
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userUid)
                            .collection("GamesHistory")
                            .add({
                          'CreatedAt': DateTime.now(),
                          'GameName': 'Snake',
                          'Score': score.toString(),
                          'PointEarned': "0"
                        });
                      } else {
                        //not today then add to total
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userUid)
                            .get()
                            .then((profile) async => {
                                  if (profile.exists)
                                    {
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(userUid)
                                          .update({
                                        'TotalPointEarned': profile
                                                .data()!['TotalPointEarned'] +
                                            1
                                      }),
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(userUid)
                                          .collection("GamesHistory")
                                          .add({
                                        'CreatedAt': DateTime.now(),
                                        'GameName': 'Snake',
                                        'Score': score.toString(),
                                        'PointEarned': "1"
                                      })
                                    },
                                });
                      }
                    } else {
                      //not found means new
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userUid)
                          .get()
                          .then((profile) async => {
                                if (profile.exists)
                                  {
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(userUid)
                                        .update({
                                      'TotalPointEarned':
                                          profile.data()!['TotalPointEarned'] +
                                              1
                                    }),
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(userUid)
                                        .collection("GamesHistory")
                                        .add({
                                      'CreatedAt': DateTime.now(),
                                      'GameName': 'Snake',
                                      'Score': score.toString(),
                                      'PointEarned': "1"
                                    })
                                  }
                              });
                    }
                  }).then((value) => {
                            count = 0,
                            Navigator.popUntil(context, (route) {
                              return count++ == 3;
                            })

                          });
                } else {
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 3;
                  });
                }
              },
              child: Text(
                // "Restart",
                "Ok".tr(),
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Offset> getNextPosition(Offset position) async {
    late Offset nextPosition;

    if (detectCollision(position) == true) {
      if (timer.isActive) timer.cancel();
      await Future.delayed(
          const Duration(milliseconds: 500), () => showGameOverDialog());
      return position;
    }

    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    return nextPosition;
  }

  void drawFood() {
    foodPosition ??= getRandomPositionWithinRange();

    if (foodPosition == positions[0]) {
      length++;
      speed = speed + 0.25;
      score = score + 5;
      changeSpeed();

      foodPosition = getRandomPositionWithinRange();
    }

    food = Piece(
      posX: foodPosition.dx.toInt(),
      posY: foodPosition.dy.toInt(),
      size: step,
      color: const Color(0XFF8EA604),
      isAnimated: true,
    );
  }

  List<Piece> getPieces() {
    List<Piece> pieces = [];
    draw();
    drawFood();

    for (var i = 0; i < positions.length; ++i) {
      Piece p = Piece(
        posX: positions[i].dx.toInt(),
        posY: positions[i].dy.toInt(),
        size: step,
        color: Colors.red,
      );

      pieces.add(p);
    }

    return pieces;
  }

  Widget getControls() {
    return ControlPanel(
      onTapped: (Direction newDirection) {
        direction = newDirection;
      },
    );
  }

  int roundToNearestTens(int num) {
    int divisor = step;
    int output = (num ~/ divisor) * divisor;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  void changeSpeed() {
    if (timer.isActive) timer.cancel();

    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  Widget getScore() {
    return Positioned.fill(
      child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "${"Score".tr()}: $score",
            style: const TextStyle(fontSize: 24.0),
          )),
    );
  }

  void restart() {
    length = 5;
    positions = [];
    direction = getRandomDirection();
    speed = 1;
    score = 0;
    changeSpeed();
  }

  Widget getPlayAreaBorder() {
    return Positioned(
      top: 30.0,
      left: 0.0,
      child: Container(
        width: (upperBoundX - lowerBoundX + step).toDouble(),
        height: (upperBoundY - lowerBoundY + step).toDouble(),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.7),
            style: BorderStyle.solid,
            width: 5.0,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    retrieveData();
    restart();
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
    screenWidth = kIsWeb
        ? FormFactor.desktop * 0.98
        : MediaQuery.of(context).size.width * 0.95;
    screenHeight = MediaQuery.of(context).size.height * 0.68;

    lowerBoundX = 1;
    lowerBoundY = step;
    upperBoundX = roundToNearestTens(screenWidth.toInt() - step);
    upperBoundY = roundToNearestTens(screenHeight.toInt() - step);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("SNAKE".tr()),
        automaticallyImplyLeading: false,
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: kIsWeb ? FormFactor.desktop : double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    getPlayAreaBorder(),
                    ...getPieces(),
                    getControls(),
                    food,
                    getScore(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/Games/CardMatching/CardMatchingHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Responsive/FormFactor.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CardMatchingPage extends StatefulWidget {
  const CardMatchingPage({Key? key}) : super(key: key);

  @override
  State<CardMatchingPage> createState() =>
      _CardMatchingPageState();
}

class _CardMatchingPageState extends State<CardMatchingPage> {
  final List<String> _difficulties = <String>[
        'Easy'.tr(),
        'Medium'.tr(),
        'Hard'.tr()
      ],
      _bestTime = <String>['-', '-', '-'];

  late double _responsiveCoefficient;

  final List<Color> _color2 = <Color>[
    const Color(0xFF448AFF),
    const Color(0xFFFFD700),
    const Color(0xFFFF4500)
  ];

  final List<ValueNotifier<double>> _scale = <ValueNotifier<double>>[
    ValueNotifier<double>(1.0),
    ValueNotifier<double>(1.0),
    ValueNotifier<double>(1.0)
  ];

  void _getTimes() async {
    SharedPreferences _sp = await SharedPreferences.getInstance();
    if (_sp.getString('easyBestTime') != null) {
      _bestTime[0] = '${_sp.getString('easyBestTime')!} seconds.';
    }
    if (_sp.getString('casualBestTime') != null) {
      _bestTime[1] = '${_sp.getString('casualBestTime')!} seconds.';
    }
    if (_sp.getString('veteranBestTime') != null) {
      _bestTime[2] = '${_sp.getString('veteranBestTime')!} seconds.';
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getTimes();
  }

  @override
  Widget build(BuildContext context) {
    _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) *
        sqrt(MediaQuery.of(context).size.height);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("CARD MATCHING".tr()),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const VolunteeringCardMatchingHistoryPage()));
            },
            color: Colors.white,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
              child: Text(
                'SELECT DIFFICULTY'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: kIsWeb ? FormFactor.desktop : double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <ValueListenableBuilder<double>>[
                    for (int index = 0; index < _difficulties.length; index++)
                      ValueListenableBuilder<double>(
                        valueListenable: _scale[index],
                        builder: (BuildContext context, double scale,
                            Widget? child) {
                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => Game(
                                                (index + 4),
                                                ((index == 2) ? 5 : 4),
                                                _color2[index],
                                                _difficulties[index],
                                                index)));
                                  },
                                  onHover: (bool value) {
                                    if (value == true) {
                                      _scale[index].value = 1.2;
                                    } else {
                                      _scale[index].value = 1.0;
                                    }
                                  },
                                  child: AnimatedContainer(
                                    padding: EdgeInsets.symmetric(
                                        vertical: _responsiveCoefficient /
                                            pow(6.5, 2),
                                        horizontal: _responsiveCoefficient /
                                            pow(5.5, 2)),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.elasticOut,
                                    transform: Matrix4.identity()..scale(scale),
                                    transformAlignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: (scale == 1.0)
                                          ? Colors.blueAccent
                                          : _color2[index],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              (scale == 1.0) ? 36.0 : 36.0)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _difficulties[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Game extends StatefulWidget {
  final int sizeX, sizeY;
  final Color _color1;
  final String _difficulty;
  final int _difficultyIndex;

  const Game(this.sizeX, this.sizeY, this._color1, this._difficulty,
      this._difficultyIndex,
      {Key? key})
      : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  late Color _complementColor;
  final List<IconData> _iconLibrary = <IconData>[
        Icons.anchor,
        Icons.android,
        Icons.favorite,
        Icons.light,
        Icons.airplanemode_on,
        Icons.umbrella,
        Icons.alarm,
        Icons.directions_subway_rounded,
        Icons.person,
        Icons.light_mode_outlined,
        Icons.all_inclusive,
        Icons.wine_bar,
        Icons.star,
        Icons.headset_rounded,
        Icons.whatshot_outlined,
        Icons.delete,
        Icons.audiotrack_rounded,
        Icons.visibility,
        Icons.traffic_rounded,
        Icons.beach_access_rounded,
        Icons.downhill_skiing_rounded,
        Icons.directions_bike_rounded,
        Icons.directions_boat_rounded,
        Icons.lunch_dining_rounded,
        Icons.restaurant,
        Icons.shopping_cart_rounded,
        Icons.smoking_rooms_rounded,
        Icons.sports_esports_rounded,
      ],
      _icons = <IconData>[];

  final List<double> maxDuration = <double>[80.0, 100.0, 150.0];

  final List<AnimationController> _startAnimations = <AnimationController>[],
      _controllers = <AnimationController>[];
  final List<Animation<double>> _animations = <Animation<double>>[];
  final List<ValueNotifier<Color>> _colors = <ValueNotifier<Color>>[];
  final List<ValueNotifier<double>> _scale = <ValueNotifier<double>>[];
  final List<bool> _isMatched = <bool>[];
  late int _first = -1, _second = -1, _matchedCnt = 0, _dimension;
  late AnimationController _timerAnimation;
  final List<Color> _randomColors = <Color>[],
      _bckgrndColors = <Color>[],
      _frgrndColors = <Color>[];
  late double _iconSize, _responsiveCoefficient;
  late String _completeMessage = '';

  var userUid = "";
  var userName = "";

  Timer? timer;
  double consumedTime = 0.0;

  @override
  void initState() {
    super.initState();
    retrieveData();
    _dimension = widget.sizeX * widget.sizeY;
    List<int> _indices = Iterable<int>.generate(_dimension).toList();
    for (int j = 0; j < _dimension / 2; j++) {
      Color _tmp;
      while (true) {
        _tmp = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        int cnt = 0;
        for (int i = 0; i < _randomColors.length; i++) {
          if (_randomColors[i] == _tmp) {
            cnt++;
            break;
          }
        }
        if (cnt == 0) {
          break;
        }
      }
      _randomColors.add(_tmp);
      IconData _tmp2;
      while (true) {
        _tmp2 = _iconLibrary[Random().nextInt(_iconLibrary.length)];
        int cnt = 0;
        for (int i = 0; i < _icons.length; i++) {
          if (_icons[i] == _tmp2) {
            cnt++;
            break;
          }
        }
        if (cnt == 0) {
          break;
        }
      }
      _icons.add(_tmp2);
    }
    _randomColors.addAll(_randomColors.getRange(0, _randomColors.length));
    _icons.addAll(_icons.getRange(0, _icons.length));
    _indices.shuffle();
    List<Color> tmpColors = <Color>[];
    List<IconData> tmpIcons = <IconData>[];
    for (int i = 0; i < _dimension; i++) {
      tmpColors.add(_randomColors[i]);
      tmpIcons.add(_icons[i]);
    }
    _randomColors.clear();
    _icons.clear();
    for (int j = 0; j < _dimension; j++) {
      _randomColors.add(tmpColors[(_indices[j])]);
      _icons.add(tmpIcons[(_indices[j])]);
      _controllers.add(AnimationController(
          vsync: this, duration: const Duration(seconds: 1), value: 1.0));
      _animations.add(Tween<double>(begin: 0.0, end: pi).animate(
          CurvedAnimation(
              parent: _controllers[j],
              reverseCurve: Curves.linearToEaseOut.flipped,
              curve: Curves.linearToEaseOut)));
      _startAnimations.add(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 700),
          value: 1.0));
      _colors.add(ValueNotifier<Color>(Colors.transparent));
      _scale.add(ValueNotifier<double>(1.0));
      _isMatched.add(false);
      _frgrndColors.add(HSLColor.fromColor(_randomColors[j])
          .withLightness(HSLColor.fromColor(_randomColors[j]).lightness / 2)
          .toColor());
      _bckgrndColors.add(HSLColor.fromColor(_randomColors[j])
          .withLightness(HSLColor.fromColor(_randomColors[j]).lightness * 1.5)
          .toColor());
    }
    _timerAnimation = AnimationController(
        vsync: this, duration: Duration(seconds: (_dimension * 5).toInt()));
    _timerAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        //RAN OUT OF TIME
        _first = -2;
        _second = -2;
        for (int i = 0; i < _dimension; i++) {
          _startAnimations[i].forward();
        }
        Timer(const Duration(milliseconds: 700), () {
          setState(() {});
        });
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      Timer(const Duration(milliseconds: 500), () {
        for (int i = 0; i < _dimension; i++) {
          _startAnimations[i].reverse();
        }
        _timerAnimation.forward();
      });
    });

    timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      consumedTime = (_dimension * 5 * _timerAnimation.value);
      setState(() {
        consumedTime:
        consumedTime;
      });
    });
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
  void dispose() {
    for (int i = 0; i < _icons.length; i++) {
      _controllers[i].dispose();
      _startAnimations[i].dispose();
      _colors[i].dispose();
      _scale[i].dispose();
    }
    _timerAnimation.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _check() async {
    if (_icons[_first] == _icons[_second]) {
      //CORRECT MATCH
      _matchedCnt += 2;
      _startAnimations[_first].forward();
      _startAnimations[_second].forward();
      _isMatched[_first] = true;
      _isMatched[_second] = true;
      if (_matchedCnt == _dimension) {
        _completeMessage =
            'You completed in ${consumedTime.toStringAsFixed(3)} seconds.';
        //
        FirebaseFirestore.instance
            .collection('Users')
            .doc(userUid)
            .collection('GamesHistory')
            .where('GameName', isEqualTo: 'CardMatching')
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
                'GameName': 'CardMatching',
                'TimeCompleted': consumedTime,
                'Mode': widget._difficulty,
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
                              'TotalPointEarned':
                                  profile.data()!['TotalPointEarned'] + 1
                            }),
                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(userUid)
                                .collection("GamesHistory")
                                .add({
                              'CreatedAt': DateTime.now(),
                              'GameName': 'CardMatching',
                              'TimeCompleted': consumedTime,
                              'Mode': widget._difficulty,
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
                                profile.data()!['TotalPointEarned'] + 1
                          }),
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userUid)
                              .collection("GamesHistory")
                              .add({
                            'CreatedAt': DateTime.now(),
                            'GameName': 'CardMatching',
                            'TimeCompleted': consumedTime,
                            'Mode': widget._difficulty,
                            'PointEarned': "1"
                          })
                        }
                    });
          }
        });
        //
        SharedPreferences _sp = await SharedPreferences.getInstance();
        if (_sp.getString('${widget._difficulty.toLowerCase()}BestTime') ==
                null ||
            double.parse(_sp.getString(
                    '${widget._difficulty.toLowerCase()}BestTime')!) >
                consumedTime) {
          if (_sp.getString('${widget._difficulty.toLowerCase()}BestTime') !=
              null) {
            // FirebaseFirestore.instance
            //     .collection('Users')
            //     .doc(userUid)
            //     .collection("GamesHistory")
            //     .add({
            //   'CreatedAt': DateTime.now(),
            //   'GameName': 'CardMatching',
            //   'Mode': widget._difficulty,
            // });
            //
            FirebaseFirestore.instance
                .collection('Users')
                .doc(userUid)
                .collection('GamesHistory')
                .where('GameName', isEqualTo: 'CardMatching')
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
                    'GameName': 'CardMatching',
                    'TimeCompleted': consumedTime,
                    'Mode': widget._difficulty,
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
                                  'TotalPointEarned':
                                      profile.data()!['TotalPointEarned'] + 1
                                }),
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userUid)
                                    .collection("GamesHistory")
                                    .add({
                                  'CreatedAt': DateTime.now(),
                                  'GameName': 'CardMatching',
                                  'TimeCompleted': consumedTime,
                                  'Mode': widget._difficulty,
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
                                    profile.data()!['TotalPointEarned'] + 1
                              }),
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(userUid)
                                  .collection("GamesHistory")
                                  .add({
                                'CreatedAt': DateTime.now(),
                                'GameName': 'CardMatching',
                                'TimeCompleted': consumedTime,
                                'Mode': widget._difficulty,
                                'PointEarned': "1"
                              })
                            }
                        });
              }
            });
            //
            _completeMessage =
                'CONGRATULATIONS! NEW BEST!\n\nCompleted in $consumedTime seconds.';
          }
          _sp.setString('${widget._difficulty.toLowerCase()}BestTime',
              consumedTime.toStringAsFixed(3));
        }
        _timerAnimation.reset();
        timer?.cancel();
      }
      Timer(const Duration(milliseconds: 100), () {
        _first = -1;
        _second = -1;
        Timer(const Duration(milliseconds: 600), () {
          setState(() {});
        });
      });
    } else {
      //FALSE MATCH
      _controllers[_first].reset();
      _controllers[_first].forward();
      _controllers[_second].reset();
      _controllers[_second].forward();
      Timer(const Duration(milliseconds: 210), () {
        _colors[_first].value = Colors.transparent;
        _colors[_second].value = Colors.transparent;
        _first = -1;
        _second = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) *
        sqrt(MediaQuery.of(context).size.height);
    _iconSize = _responsiveCoefficient / _dimension * 1;

    _complementColor = const Color(0xFFE0E0E0);

    int count = 0;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("CARD MATCHING".tr()),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            if (_timerAnimation.status != AnimationStatus.completed &&
                _matchedCnt < _dimension)
              IconButton(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: const Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  _timerAnimation.stop();
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.scale,
                    headerAnimationLoop: false,
                    dialogType: DialogType.noHeader,
                    showCloseIcon: true,
                    title: 'Game Paused'.tr(),
                    btnOkText: "Continue",
                    btnOkOnPress: () {
                      Timer(const Duration(milliseconds: 400), () {
                        _timerAnimation.forward(from: _timerAnimation.value);
                      });
                    },
                    btnOkColor: Colors.green,
                    btnCancelText: "Quit",
                    btnCancelOnPress: () {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                    },
                    btnCancelColor: Colors.red,
                  ).show();
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Stack(
                children: <Widget>[
                  (_timerAnimation.status != AnimationStatus.completed)
                      ? Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LinearPercentIndicator(
                                width: kIsWeb
                                    ? MediaQuery.of(context).size.width / 4
                                    : MediaQuery.of(context).size.width * 0.8,
                                lineHeight: 30.0,
                                barRadius: const Radius.circular(10.0),
                                percent: (consumedTime /
                                        maxDuration[widget._difficultyIndex])
                                    .toDouble(),
                                center: Stack(
                                  children: <Widget>[
                                    Text(
                                      "Time Left: ".tr() +
                                          (maxDuration[
                                                      widget._difficultyIndex] -
                                                  consumedTime)
                                              .toStringAsFixed(0) +
                                          " second(s)".tr(),
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2.0
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    Text(
                                        "Time Left: ".tr() +
                                            (maxDuration[widget
                                                        ._difficultyIndex] -
                                                    consumedTime)
                                                .toStringAsFixed(0) +
                                            " second(s)".tr(),
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white)),
                                  ],
                                ),
                                trailing: (consumedTime /
                                                maxDuration[
                                                    widget._difficultyIndex])
                                            .toDouble() >
                                        0.8
                                    ? const Icon(Icons.mood_bad,
                                        color: Colors.red)
                                    : const Icon(Icons.mood,
                                        color: Colors.green),
                                // barRadius: barRadius.roundAll,
                                backgroundColor: (consumedTime /
                                                maxDuration[
                                                    widget._difficultyIndex])
                                            .toDouble() >
                                        0.8
                                    ? Colors.red[100]
                                    : Colors.blue[100],
                                progressColor: (consumedTime /
                                                maxDuration[
                                                    widget._difficultyIndex])
                                            .toDouble() >
                                        0.8
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  (_matchedCnt == _dimension)
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Congratulation, you did it!!'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.blue,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 36.0, 0.0, 36.0),
                                child: Text(
                                  _completeMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 250,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20)),
                                child: TextButton(
                                  onPressed: () => {
                                    Navigator.popUntil(context, (route) {
                                      return count++ == 2;
                                    }),
                                  },
                                  child: Text(
                                    'Ok'.tr(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : (_timerAnimation.status == AnimationStatus.completed)
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Time is up!!'.tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: 250,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextButton(
                                      onPressed: () => {
                                        Navigator.popUntil(context, (route) {
                                          return count++ == 2;
                                        }),
                                      },
                                      child: Text(
                                        'Ok'.tr(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 50.0, 8.0, 50.0),
                              child: GridView.count(
                                physics: const ScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 16.0, 8.0, 8.0),
                                crossAxisCount: widget.sizeX,
                                childAspectRatio:
                                    MediaQuery.of(context).size.aspectRatio *
                                        1.25,
                                mainAxisSpacing: _responsiveCoefficient / 80,
                                crossAxisSpacing: _responsiveCoefficient / 80,
                                children: <ScaleTransition>[
                                  for (int index = 0;
                                      index < _icons.length;
                                      index++)
                                    ScaleTransition(
                                      scale: CurvedAnimation(
                                              parent: _startAnimations[index],
                                              curve: Curves.easeInOutQuart)
                                          .drive(Tween<double>(
                                              begin: 1.0, end: 0.85)),
                                      child: FadeTransition(
                                        opacity: CurvedAnimation(
                                                parent: _startAnimations[index],
                                                curve: Curves.easeInCubic)
                                            .drive(Tween<double>(
                                                begin: 1.0, end: 0.0)),
                                        child: Visibility(
                                          visible: !_isMatched[index],
                                          child: InkWell(
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onTap: () {
                                              if ((_first == -1 ||
                                                      _second == -1) &&
                                                  (_controllers[index]
                                                          .isAnimating ==
                                                      false)) {
                                                if (_controllers[index]
                                                        .isCompleted ==
                                                    true) {
                                                  _controllers[index].reverse();
                                                  if (_first == -1) {
                                                    _first = index;
                                                  } else {
                                                    _second = index;
                                                    Timer(
                                                        const Duration(
                                                            seconds: 1), () {
                                                      _check();
                                                    });
                                                  }
                                                } else {
                                                  _first = -1;
                                                  _controllers[index].forward();
                                                }
                                                Timer(
                                                    const Duration(
                                                        milliseconds: 210), () {
                                                  _colors[index]
                                                      .value = (_colors[index]
                                                              .value ==
                                                          Colors.transparent)
                                                      ? _bckgrndColors[index]
                                                      : Colors.transparent;
                                                });
                                              }
                                            },
                                            onHover: (bool value) {
                                              if (value == true) {
                                                _scale[index].value = 1.05;
                                              } else {
                                                _scale[index].value = 1.0;
                                              }
                                            },
                                            child: AnimatedBuilder(
                                              animation: _controllers[index],
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Transform(
                                                  alignment: Alignment.center,
                                                  transform: Matrix4.identity()
                                                    ..setEntry(3, 2, 0.001)
                                                    ..rotateY(_animations[index]
                                                        .value),
                                                  child: ValueListenableBuilder<
                                                      Color>(
                                                    valueListenable:
                                                        _colors[index],
                                                    builder:
                                                        (BuildContext context,
                                                            Color color,
                                                            Widget? child) {
                                                      return ValueListenableBuilder<
                                                          double>(
                                                        valueListenable:
                                                            _scale[index],
                                                        builder: (BuildContext
                                                                context,
                                                            double scale,
                                                            Widget? child) {
                                                          return AnimatedScale(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            curve: Curves
                                                                .easeInOut,
                                                            scale: scale,
                                                            child:
                                                                AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              curve: Curves
                                                                  .easeInOut,
                                                              transformAlignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: (scale ==
                                                                        1.0)
                                                                    ? widget
                                                                        ._color1
                                                                    : _complementColor,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            8.0)),
                                                              ),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: color,
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          8.0)),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    _icons[
                                                                        index],
                                                                    size:
                                                                        _iconSize,
                                                                    color: (color ==
                                                                            Colors
                                                                                .transparent)
                                                                        ? color
                                                                        : _frgrndColors[
                                                                            index],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                ],
              ),
            ),
          ),
        ));
  }
}

import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senzepact/src/screens/Home/Games/Snake/Snake_Game.dart';
import 'package:senzepact/src/screens/Home/Games/Snake/SnakeGameHistory.dart';

import '../../../Responsive/FormFactor.dart';

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({Key? key}) : super(key: key);

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  @override
  Widget build(BuildContext context) {
    var _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) *
        sqrt(MediaQuery.of(context).size.height);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("SNAKE".tr()),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SnakeGameHistoryPage()));
            },
            color: Colors.white,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? FormFactor.desktop : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        '** Instruction **'.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Snake Game Instruction'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 250,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const GamePage()))
                        },
                        child: Text(
                          'Start'.tr(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
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

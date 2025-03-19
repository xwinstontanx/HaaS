import 'package:flutter/material.dart';

import 'Control_Button.dart';
import 'Direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction) onTapped;

  const ControlPanel({Key? key, required this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 10.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ControlButton(
              icon: const Icon(Icons.arrow_left, size: 55),
              onPressed: () {
                onTapped(Direction.left);
              },
            ),
          ),
          Column(
            children: [
              ControlButton(
                icon: const Icon(Icons.arrow_drop_up_sharp, size: 55),
                onPressed: () {
                  onTapped(Direction.up);
                },
              ),
              const SizedBox(
                height: 40.0,
              ),
              ControlButton(
                icon: const Icon(Icons.arrow_drop_down_sharp, size: 55),
                onPressed: () {
                  onTapped(Direction.down);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ControlButton(
              icon: const Icon(Icons.arrow_right, size: 55),
              onPressed: () {
                onTapped(Direction.right);
              },
            ),
          ),
        ],
      ),
    );
  }
}

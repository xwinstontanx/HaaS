import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final void Function() onPressed;
  final Icon icon;

  const ControlButton({Key? key, required this.onPressed, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: SizedBox(
        width: 60.0,
        height: 60.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            elevation: 8.0,
            onPressed: onPressed,
            child: icon,
          ),
        ),
      ),
    );
  }
}

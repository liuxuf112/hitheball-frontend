import 'package:flutter/material.dart';

class TeamColor extends StatefulWidget {
  const TeamColor(this.tColor, {Key? key}) : super(key: key);

  final int tColor;

  @override
  _TeamColorState createState() => _TeamColorState(tColor);
}

class _TeamColorState extends State<TeamColor> {
  _TeamColorState(this.tColor);

  final int tColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 1, 7, 0),
        child: Column(children: [
          if (tColor == 1) ...[
            Text(
              "RED",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ] else ...[
            const Text(
              "BLUE",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ]
        ]));
  }
}

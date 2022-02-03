import 'package:flutter/material.dart';

class TimerTimeCard extends StatelessWidget {
  const TimerTimeCard(final this.time, {Key? key}) : super(key: key);
  final String time;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // padding: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );
  }
}

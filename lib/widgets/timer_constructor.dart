import 'package:flutter/material.dart';
import './timer_text_card.dart';
import './timer_time_card.dart';

String twoDigits(int n) => n.toString().padLeft(2, '0');

class TimerConstructor extends StatelessWidget {
  const TimerConstructor(
      {required this.hours,
      required this.minutes,
      required this.seconds,
      Key? key})
      : super(key: key);
  final int hours;
  final int minutes;
  final int seconds;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimerTimeCard(twoDigits(hours)),
        const SizedBox(width: 4),
        const TimerTextCard(),
        const SizedBox(width: 4),
        TimerTimeCard(twoDigits(minutes.remainder(60))),
        const SizedBox(width: 4),
        const TimerTextCard(),
        const SizedBox(width: 4),
        TimerTimeCard(twoDigits(seconds.remainder(60))),
      ],
    );
  }
}

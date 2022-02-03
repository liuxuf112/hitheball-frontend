import 'package:enhanced_ctf/widgets/text_with_outline.dart';
import 'package:flutter/material.dart';

class HowLongGameTookDisplay extends StatefulWidget {
  const HowLongGameTookDisplay(
      {required this.dayLength,
      required this.hourLength,
      required this.minuteLength,
      required this.secondLength,
      Key? key})
      : super(key: key);
  final int dayLength;
  final int hourLength;
  final int minuteLength;
  final int secondLength;
  @override
  _HowLongGameTookDisplayState createState() => _HowLongGameTookDisplayState();
}

class _HowLongGameTookDisplayState extends State<HowLongGameTookDisplay> {
  String _text = "";

  void setText() {
    _text = "";
    if (widget.dayLength == 0 &&
        widget.hourLength == 0 &&
        widget.minuteLength == 0 &&
        widget.secondLength == 0) {
      return;
    }
    //if bot hdays and hours are 0, we just say minutes and seconds.
    _text = "The game took ";
    if (widget.dayLength == 0 && widget.hourLength == 0) {
      if (widget.minuteLength != 0) {
        _text += widget.minuteLength.toString() + " minutes and ";
      }
      _text += widget.secondLength.toString() + " seconds.";
    } else {
      //otherwise we put some commas.
      if (widget.dayLength == 0) {
        _text += widget.dayLength.toString() + " days, ";
      }

      _text += widget.hourLength.toString() + " hours, ";
      _text += widget.minuteLength.toString() + " minutes, and ";
      _text += widget.secondLength.toString() + " seconds.";
    }
    setState(() {
      _text = _text;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setText();
    return Center(
      child: TextWithOutline(
          fontSize: 28,
          strokeColor: Colors.black,
          strokeWidth: 1.5,
          text: _text,
          textColor: Colors.white,
          rightPadding: 0),
    );
  }
}

import 'package:flutter/material.dart';

class TextWithOutline extends StatelessWidget {
  final double fontSize;
  final double strokeWidth;
  final Color strokeColor;
  final Color textColor;
  final String text;
  final double rightPadding;
  const TextWithOutline(
      {required this.fontSize,
      required this.strokeWidth,
      required this.strokeColor,
      required this.textColor,
      required this.text,
      this.rightPadding = 10.0,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: Stack(
        children: <Widget>[
          // Stroked text as border.
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
          // Solid text as fill.
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

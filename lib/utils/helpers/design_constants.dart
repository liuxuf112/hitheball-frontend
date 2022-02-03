import 'package:flutter/material.dart';

//constant colors for things
class AppConstants {
  static const bannerColor = Color(0xFFCA4A4A);
  static const bgColor = Color(0xFFB8B8B8);
  static const buttonColor = Color(0xFFFFFFFF);
  static const buttonSelectedBackgroundColor = Color(0xFFFFFFFF);
  static const buttonDeselectedTextColor = Colors.black;
  static const buttonTextColor = Colors.black;
  static const buttonDeselectedBackgroundColor =
      Color(0xFFA2A2A2); //ARGB for some reason
  static const redTeamMapArea = Color(0x7FFF2012);
  static const blueTeamMapArea = Color(0x7F007CFF);
  static const topOfAppBarText = Text("ECTF", textAlign: TextAlign.center);
  static const titleTextStyle =
      TextStyle(fontSize: 30, overflow: TextOverflow.fade);
  static const bodyTextStyle = TextStyle(fontSize: 20);
}

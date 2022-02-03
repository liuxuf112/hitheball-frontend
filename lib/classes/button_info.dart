import 'package:flutter/cupertino.dart';

class ButtonInfo {
  VoidCallback clickFunction;
  Icon buttonIcon;

  ButtonInfo({required this.buttonIcon, required this.clickFunction});
}

import 'package:flutter/material.dart';
import '../classes/button_info.dart';

class RowOfButtons extends StatelessWidget {
  final List<ButtonInfo> buttons;
  const RowOfButtons(this.buttons, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons
          .map(
            (buttonInfo) => ElevatedButton(
              onPressed: buttonInfo.clickFunction,
              child: buttonInfo.buttonIcon,
            ),
          )
          .toList(),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}

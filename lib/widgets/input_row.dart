import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/text_with_outline.dart';

class InputRow extends StatelessWidget {
  final double fontSize;
  final double strokeWidth;
  final Color strokeColor;
  final Color textColor;
  final String text;
  final double textRightPadding;
  final TextInputType keyboardType;
  final double inputBoxWidth;
  final double inputBoxHeight;
  final RegExp allowedInput;
  final TextEditingController formController;
  const InputRow(
      {required this.fontSize,
      required this.strokeWidth,
      required this.strokeColor,
      required this.textColor,
      required this.text,
      this.textRightPadding = 12.0,
      required this.keyboardType,
      required this.inputBoxWidth,
      required this.inputBoxHeight,
      required this.allowedInput,
      required this.formController,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextWithOutline(
            fontSize: fontSize,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            textColor: textColor,
            text: text,
            rightPadding: textRightPadding),
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(
              width: inputBoxWidth, height: inputBoxHeight),
          child: TextFormField(
            controller: formController,
            autofocus: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(allowedInput),
            ],
            keyboardType: keyboardType,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
          ),
        ),
      ],
    );
  }
}

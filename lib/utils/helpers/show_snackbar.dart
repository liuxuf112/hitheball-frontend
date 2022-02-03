import 'package:flutter/material.dart';

void showSnackBarMessage(String string, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(string)),
  );
}

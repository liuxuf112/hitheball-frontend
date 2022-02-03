import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:flutter/material.dart';

import 'class_constants.dart';

Future<void> showClassInfoDialogue(context) async {
  final GameState _gameState = GameState();
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Class: ${_gameState.className}",
          style: const TextStyle(fontSize: 30),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  "You are a ${_gameState.className}. ${ClassConstants.classDescriptions[_gameState.className]}"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

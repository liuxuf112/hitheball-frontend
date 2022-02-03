import 'package:enhanced_ctf/pages/home_screen.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:flutter/material.dart';

Future<void> showRemovedFromGameDialogue(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.yellow,
        title: const Text(
          "Uh oh!",
          style: TextStyle(fontSize: 30),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text("You were removed from the game you were in!"),
              Text(
                  "This might be because the creator deleted the game, or because you were removed from the game.")
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Home'),
            onPressed: () {
              newPageClearAllPrevious(context, const HomeScreen());
            },
          ),
        ],
      );
    },
  );
}

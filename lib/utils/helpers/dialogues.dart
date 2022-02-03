import 'package:flutter/material.dart';

Future<void> showDeathDialogue(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(224, 137, 29, 1),
        title: const Text('You are eliminated!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('You were just eliminated.'),
              Text("Return to your team's zone to revive."),
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

Future<void> showStoleFlagDialogue(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(29, 224, 66, 1),
        title: const Text('You just stole an enemy flag!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Get it back to your team region without being hit!'),
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

Future<void> showTaggedPlayerDialogue(context, username) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(29, 224, 66, 1),
        title: Text('You just eliminated $username!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Nice job!'),
              Text("Go tag some more enemies."),
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

Future<void> showCapturedFlagDialogue(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user doesn't need to tap button
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(29, 224, 66, 1),
        title: const Text('You just captured an enemy flag!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Nice job!'),
              Text("Now go get some more."),
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

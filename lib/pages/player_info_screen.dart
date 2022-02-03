import 'package:enhanced_ctf/utils/helpers/class_dialogues.dart';
import 'package:enhanced_ctf/utils/helpers/team_enums.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import '../utils/helpers/design_constants.dart';

class PlayerInfoScreen extends StatefulWidget {
  const PlayerInfoScreen({Key? key}) : super(key: key);

  @override
  _PlayerInfoScreenState createState() => _PlayerInfoScreenState();
}

class _PlayerInfoScreenState extends State<PlayerInfoScreen> {
  final GameState _gameState = GameState();

  void _displayClassInfo() {
    showClassInfoDialogue(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
        backgroundColor: AppConstants.bannerColor,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: calculateMaxPageHeight(context),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Wrap(
                // this used to be a Column, keeping this code just in case
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.start,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 150, // to apply margin in the main axis of the wrap
                // spacing might be buggy for some devices currently
                runSpacing: 20, // to apply margin in the cross axis of the wrap
                children: [
                  Text(
                    "Player Name: " + _gameState.username.toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // I'll make this display the team properly in the future
                  Text(
                    "Team: " +
                        teamNames[_gameState.whichTeamAmI][0].toUpperCase() +
                        teamNames[_gameState.whichTeamAmI].substring(
                            teamNames[_gameState.whichTeamAmI].length - 2),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View Radius: " +
                        _gameState.viewRadius.toString() +
                        " meters",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tag Radius: " +
                        _gameState.tagRadius.toString() +
                        " meters",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Game ID: " + _gameState.gameID.toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _gameState.classId == 0
                      ? const Center()
                      : Row(
                          children: [
                            Text(
                              "Class: " + _gameState.className.toString(),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _gameState.classId == 0
                                ? const Center()
                                : CupertinoButton(
                                    borderRadius: BorderRadius.zero,
                                    child: const Icon(
                                        CupertinoIcons.question_circle),
                                    onPressed: _displayClassInfo)
                          ],
                        ),
                ]),
          ),
        ),
      ),
    );
  }
}

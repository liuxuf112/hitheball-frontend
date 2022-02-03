import 'package:enhanced_ctf/utils/helpers/team_enums.dart';
import 'package:enhanced_ctf/widgets/text_with_outline.dart';
import 'package:flutter/material.dart';

class TeamScoreEndGameDisplay extends StatefulWidget {
  const TeamScoreEndGameDisplay(
      {required this.flagsRemaining, required this.teamNumber, Key? key})
      : super(key: key);
  final int flagsRemaining;
  final int teamNumber;
  @override
  _TeamScoreEndGameDisplayState createState() =>
      _TeamScoreEndGameDisplayState();
}

class _TeamScoreEndGameDisplayState extends State<TeamScoreEndGameDisplay> {
  String _teamNameText = "";
  String _scoreText = "";
  Color _teamColor = Colors.red;

  void _setText() {
    if (widget.teamNumber < 1 ||
        widget.teamNumber > Team.maxTeams.index ||
        widget.flagsRemaining < 0) {
      return;
    }
    String teamName = teamNames[widget.teamNumber];

    //now we set the score text.
    String scoreText =
        " team has " + widget.flagsRemaining.toString() + " flags remaining.";

    setState(() {
      _teamColor = teamColors[widget.teamNumber]!;
      _teamNameText = teamName.toUpperCase();
      _scoreText = scoreText;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setText();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWithOutline(
              fontSize: 28,
              strokeColor: Colors.black,
              strokeWidth: 1.5,
              text: _teamNameText,
              textColor: _teamColor,
              rightPadding: 0),
          Expanded(
            child: TextWithOutline(
                fontSize: 28,
                strokeColor: Colors.black,
                strokeWidth: 1.5,
                text: _scoreText,
                textColor: Colors.white,
                rightPadding: 0),
          ),
        ],
      ),
    );
  }
}

import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:enhanced_ctf/widgets/text_with_outline.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BigEndGameText extends StatefulWidget {
  const BigEndGameText({Key? key, required this.gameResult}) : super(key: key);
  final int
      gameResult; //who won the game? 0 = tie, all other numbers  are which team won
  @override
  _BigEndGameTextState createState() => _BigEndGameTextState();
}

class _BigEndGameTextState extends State<BigEndGameText> {
  String _text = "";
  final GameState _gameState = GameState();
  Color _color = Colors.black;
  static AudioCache player = AudioCache(prefix: 'assets/sounds/');

  @override
  void initState() {
    super.initState();
    setText();
  }

  void setText() {
    if (widget.gameResult == 0) {
      setState(() {
        _text = "It was a tie.";
        _color = Colors.amber;
      });
      player.play('tie.mp3');
    } else if (widget.gameResult == -1) {
      //no result set yet
      setState(() {
        _text = "";
      });
    } else if (widget.gameResult == _gameState.whichTeamAmI) {
      setState(() {
        _text = "You win!!!!!";
        _color = Colors.green[600]!;
      });
      player.play('win.mp3');
    } else {
      setState(() {
        _text = "Defeat... Better luck next time.";
        _color = Colors.red[300]!;
      });
      player.play('lose.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    setText();
    return Center(
      child: TextWithOutline(
          fontSize: 28,
          strokeColor: Colors.black,
          strokeWidth: 1.5,
          text: _text,
          textColor: _color,
          rightPadding: 0),
    );
  }
}

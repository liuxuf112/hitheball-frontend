import 'dart:convert';

import 'package:enhanced_ctf/pages/home_screen.dart';
import 'package:enhanced_ctf/utils/helpers/design_constants.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/helpers/team_enums.dart';
import 'package:enhanced_ctf/utils/services/get_device_id.dart';
import 'package:enhanced_ctf/utils/services/http_requests.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:enhanced_ctf/widgets/big_endgame_text.dart';
import 'package:enhanced_ctf/widgets/how_long_game_took.dart';
import 'package:enhanced_ctf/widgets/team_score_endgame.dart';

// confetti animation
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';

// rain animation
import 'package:parallax_rain/parallax_rain.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: EndGameScreen());
  }
}

class EndGameScreen extends StatefulWidget {
  const EndGameScreen({Key? key}) : super(key: key);

  @override
  _EndGameScreenState createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  final GameState _gameState = GameState();

  int _winner = -1;
  int _gameDayLength = 0;
  int _gameHourLength = 0;
  int _gameMinuteLength = 0;
  int _gameSecondLength = 0;
  int _teamOneFlagsLeft = -1;
  int _teamTwoFlagsLeft = -1;

  // confetti animation
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;
  bool _visible = false;

  void _getEndGameInfo() async {
    String? deviceID = await DeviceId.getDeviceID();
    if (deviceID == null) {
      debugPrint("deviceID = null, this shouldn't happen");
      showSnackBarMessage(
          "Get End Game Info failed, deviceID is null", context);
      return;
    }

    String? gameId = _gameState.gameID;
    try {
      var response = await makeGetRequest(
          GET_END_INFO, {"gameId": gameId, "deviceId": deviceID});
      if (response == null) {
        throw "getEndGame Info Failed";
      }
      if (response.statusCode != 200) {
        debugPrint(response.body);
        showSnackBarMessage(
            "Could not get end game info: ${response.body}", context);
        return;
      }
      var responseDecoded = jsonDecode(response.body);
      setState(() {
        _winner = responseDecoded["winner"];
        _gameDayLength = responseDecoded["gameDayLength"];
        _gameHourLength = responseDecoded["gameHourLength"];
        _gameMinuteLength = responseDecoded["gameMinuteLength"];
        _gameSecondLength = responseDecoded["gameSecondLength"];
        _teamOneFlagsLeft = int.parse(responseDecoded["teamOneFlagsLeft"]);
        _teamTwoFlagsLeft = int.parse(responseDecoded["teamTwoFlagsLeft"]);
      });
      debugPrint(_winner.toString());
    } on Exception {
      debugPrint("Get End Game Info Failed");
    }
  }

  @override
  void initState() {
    super.initState();
    _getEndGameInfo();

    // confetti animation
    _confettiControllerLeft =
        ConfettiController(duration: const Duration(seconds: 10));
    _confettiControllerRight =
        ConfettiController(duration: const Duration(seconds: 10));
    showBanner();
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    super.dispose();
  }

  showBanner() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _visible = true;
        _confettiControllerLeft.play();
        _confettiControllerRight.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.bannerColor,
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newPageClearAllPrevious(context, const HomeScreen());
        },
        tooltip: "Go Home",
        child: const Icon(CupertinoIcons.home),
      ),
      body: Stack(
        children: [
          if (_winner == 1) ...[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      //   "https://images.unsplash.com/photo-1530323588099-931c746ab7f7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=627&q=80"),
                      "http://images.unsplash.com/photo-1513151233558-d860c5398176?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _visible ? 1 : 0,
                    duration: const Duration(seconds: 1),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 250),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BigEndGameText(gameResult: _winner),
                          HowLongGameTookDisplay(
                            dayLength: _gameDayLength,
                            hourLength: _gameHourLength,
                            minuteLength: _gameMinuteLength,
                            secondLength: _gameSecondLength,
                          ),
                          TeamScoreEndGameDisplay(
                              flagsRemaining: _teamOneFlagsLeft,
                              teamNumber: Team.red.index),
                          TeamScoreEndGameDisplay(
                              flagsRemaining: _teamTwoFlagsLeft,
                              teamNumber: Team.blue.index),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConfettiWidget(
                      confettiController: _confettiControllerLeft,
                      blastDirection: -3.14 / 3,
                      emissionFrequency: 0.01,
                      numberOfParticles: 10,
                      maximumSize: const Size(20, 10),
                      maxBlastForce: 40,
                      minBlastForce: 30,
                      gravity: 0.1,
                      shouldLoop: true,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConfettiWidget(
                      confettiController: _confettiControllerRight,
                      blastDirection: -3 * 3.14 / 4,
                      emissionFrequency: 0.01,
                      numberOfParticles: 10,
                      maximumSize: const Size(20, 10),
                      maxBlastForce: 40,
                      minBlastForce: 30,
                      gravity: 0.1,
                      shouldLoop: true,
                    ),
                  ),
                ])
          ] else if (_winner == 2) ...[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://images.unsplash.com/photo-1617440168937-c6497eaa8db5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMjA3fDB8MXxzZWFyY2h8MXx8YmFkJTIwbW9vZHx8MHx8fHwxNjMxMjIzMzY3&ixlib=rb-1.2.1&q=80&w=1080"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        Expanded(
                          child: ParallaxRain(
                            dropColors: const [Colors.blueGrey],
                            trail: true,
                            dropFallSpeed: 5,
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                  AnimatedScale(
                                    scale: _visible ? 1 : 0,
                                    duration: const Duration(seconds: 1),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 250),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          BigEndGameText(gameResult: _winner),
                                          HowLongGameTookDisplay(
                                            dayLength: _gameDayLength,
                                            hourLength: _gameHourLength,
                                            minuteLength: _gameMinuteLength,
                                            secondLength: _gameSecondLength,
                                          ),
                                          TeamScoreEndGameDisplay(
                                              flagsRemaining: _teamOneFlagsLeft,
                                              teamNumber: Team.red.index),
                                          TeamScoreEndGameDisplay(
                                              flagsRemaining: _teamTwoFlagsLeft,
                                              teamNumber: Team.blue.index),
                                        ],
                                      ),
                                    ),
                                  ),
                                ])),
                          ),
                        )
                      ]))
                ]),
          ] else if (_winner == 0) ...[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://i.imgflip.com/32xr47.jpg"),
                  //  "https://sportzcraazy.com/wp-content/uploads/2018/10/Tug-of-war.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _visible ? 1 : 0,
                    duration: const Duration(seconds: 1),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 250),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BigEndGameText(gameResult: _winner),
                          HowLongGameTookDisplay(
                            dayLength: _gameDayLength,
                            hourLength: _gameHourLength,
                            minuteLength: _gameMinuteLength,
                            secondLength: _gameSecondLength,
                          ),
                          TeamScoreEndGameDisplay(
                              flagsRemaining: _teamOneFlagsLeft,
                              teamNumber: Team.red.index),
                          TeamScoreEndGameDisplay(
                              flagsRemaining: _teamTwoFlagsLeft,
                              teamNumber: Team.blue.index),
                        ],
                      ),
                    ),
                  ),
                ])
          ] else ...[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(width: 3, color: Colors.black)),
              child: const Text(
                "Waiting for Game Stats...",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

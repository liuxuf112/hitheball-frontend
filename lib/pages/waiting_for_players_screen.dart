import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/helpers/timing_constants.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/in_game_screen.dart';
import 'package:flutter/services.dart';
import '../utils/services/http_requests.dart';
import '../utils/helpers/design_constants.dart';
import '../utils/services/get_device_id.dart';
import '../utils/helpers/show_snackbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppConstants.bgColor,
        ),
        home: const WaitingForPlayersScreen());
  }
}

class WaitingForPlayersScreen extends StatefulWidget {
  const WaitingForPlayersScreen({Key? key}) : super(key: key);

  @override
  _WaitingForPlayersScreenState createState() =>
      _WaitingForPlayersScreenState();
}

class _WaitingForPlayersScreenState extends State<WaitingForPlayersScreen> {
  List players1 = [];
  List players2 = [];
  final GameState _gameState = GameState();

  bool _isTimerStopped = false;
  bool showCreateGameButton = false;
  bool _isStartingGame = false;

  String _waitingForPlayersText = "Waiting for Players";
  int _maxPlayers = 0;
  int _currentPlayers = 0;

  void _generateWaitingText() {
    setState(() {
      _waitingForPlayersText = "Waiting For Players (" +
          _currentPlayers.toString() +
          "/" +
          _maxPlayers.toString() +
          ")";
    });
  }

  void _calculateShouldShowButton() {
    if (_gameState.createdGame) {
      setState(() {
        showCreateGameButton = true;
      });
    } else {
      setState(() {
        showCreateGameButton = false;
      });
    }
  }

  void showPlayers() async {
    String? deviceId = await DeviceId.getDeviceID();
    String? gameId = _gameState.gameID;

    if (deviceId == null || gameId == null) {
      debugPrint("error in show players");
      showSnackBarMessage("Couldn't get player info for game...", context);
    }

    try {
      var queryParameters = {"gameId": gameId, "deviceId": deviceId};
      var response =
          await makeGetRequest(GET_PLAYERS_IN_GAME_PATH, queryParameters);
      if (response == null) {
        throw "Get Request Failed";
      }
      var json = response.body;
      var data = jsonDecode(json);
      players1.clear();
      players2.clear();
      for (Map info in data['players']) {
        if (info["team_number"] == 1) {
          players1.add(info["username"]);
        }
        if (info["team_number"] == 2) {
          players2.add(info["username"]);
        }
      }

      setState(() {
        players1 = players1;
        players2 = players2;
        _currentPlayers = players1.length + players2.length;
        _maxPlayers = data['maxPlayers'];
      });
      _generateWaitingText();
    } catch (e) {
      String _text = "request failed：$e";
      debugPrint(_text);
    }
  }

  void startShowPlayersTimer() async {
    var timeout = const Duration(seconds: TimingConstants.showPlayersTime);
    showPlayers();
    Timer.periodic(timeout, (timer) async {
      //callback function
      if (_isTimerStopped) {
        timer.cancel();
      } else {
        showPlayers();
      }
    });
  }

  void getGameStarted() async {
    String? deviceId = await DeviceId.getDeviceID();
    String? gameId = _gameState.gameID;

    if (deviceId == null || gameId == null) {
      debugPrint("error in ifStartGame");
      showSnackBarMessage(
          "No idea whether the game is started yet. Info in my_game_state is wrong",
          context);
    }
    var queryParameters = {
      "gameId": gameId.toString(),
      "deviceId": deviceId.toString()
    };
    var response = await makeGetRequest('getGameStarted', queryParameters);
    bool result;
    try {
      if (response == null) {
        throw "Failed To Get Response";
      }
      if (response.statusCode == HttpStatus.ok) {
        var json = response.body;
        var data = jsonDecode(json);
        result = data['gameStarted'];
        if (result == true && _isTimerStopped == false) {
          _isTimerStopped = true;
          newPageClearAllPrevious(context, const InGameScreen());
        }
      } else {
        debugPrint(
            'Error getting IP address:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      debugPrint('getting gameStarted info failed');
    }
  }

  void startGetStartGameTimer() async {
    getGameStarted();
    Timer.periodic(const Duration(seconds: TimingConstants.checkStartGameTime),
        (timer) async {
      if (_isTimerStopped) {
        timer.cancel();
      } else {
        getGameStarted();
      }
    });
  }

  startGame() async {
    try {
      String? deviceId = await DeviceId.getDeviceID();
      String? gameId = _gameState.gameID;

      if (deviceId == null || gameId == null) {
        debugPrint("error in start game");
        showSnackBarMessage("Couldn't get player info for game.", context);
        _isStartingGame = false;
        return;
      }
      Map<String, dynamic> jsonMap = {"gameId": gameId, "deviceId": deviceId};
      var response =
          await makePostRequest(json.encode(jsonMap), START_GAME_PATH);
      if (response == null) {
        throw "Post Request Failed";
      }

      if (response.statusCode == HttpStatus.ok) {
        _isTimerStopped = true;
        setState(() {
          _isStartingGame = false;
        });
        newPageClearAllPrevious(context, const InGameScreen());
      } else {
        debugPrint("Start Game: statusCode----${response.statusCode}");

        showSnackBarMessage("Error getting response from server", context);
        setState(() {
          _isStartingGame = false;
        });
      }
    } catch (exception) {
      setState(() {
        _isStartingGame = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateShouldShowButton();
    startShowPlayersTimer();
    if (_gameState.createdGame == false) {
      startGetStartGameTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isTimerStopped = true;
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
            maxHeight: calculateMaxPageHeight(context),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _waitingForPlayersText,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Game ID: " + _gameState.gameID.toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                            tooltip: "Copy",
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _gameState.gameID));
                              showSnackBarMessage(
                                  "Copied ${_gameState.gameID} to clipboard",
                                  context);
                            },
                            icon: const Icon(
                              Icons.content_copy,
                              size: 26,
                              semanticLabel: "Copy Button",
                            ))
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "RED ",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const Text(
                            "Team",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              width: 3,
                              color: Colors.black,
                            )),
                        child: ListView(
                          children: <Widget>[
                            Column(
                                children: players1.map((value) {
                              return ListTile(
                                title: Text(value),
                              );
                            }).toList()),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 10.0),
                              child: const Text(
                                "BLUE ",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )),
                          const Text("Team",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              width: 3,
                              color: Colors.black,
                            )),
                        child: ListView(
                          children: <Widget>[
                            Column(
                                children: players2.map((value) {
                              return ListTile(
                                title: Text(value),
                              );
                            }).toList()),
                          ],
                        ),
                      ),
                    ),

                    _isStartingGame
                        ? const CircularProgressIndicator()
                        : showCreateGameButton
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  child: const Text('Start Game'),
                                  onPressed: _isStartingGame
                                      ? null
                                      : () {
                                          setState(() {
                                            _isStartingGame = true;
                                          });
                                          startGame();
                                        },
                                ),
                              )
                            : const Center(), //return nothing.. better way to do this maybe but this works.
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

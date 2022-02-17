import 'dart:async';
import 'dart:convert';
import 'package:enhanced_ctf/pages/end_game_screen.dart';
import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/class_dialogues.dart';
import 'package:enhanced_ctf/utils/helpers/dialogues.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/helpers/uh_oh_dialogues.dart';
import 'package:enhanced_ctf/utils/helpers/vibration.dart';
import 'package:enhanced_ctf/utils/services/get_device_id.dart';
import 'package:enhanced_ctf/utils/services/get_location.dart';
import 'package:enhanced_ctf/widgets/game_timer.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/chat_screen.dart';
import 'package:enhanced_ctf/pages/map_screen.dart';
import 'package:enhanced_ctf/pages/home_screen.dart';
import 'package:enhanced_ctf/pages/player_info_screen.dart';
import 'package:enhanced_ctf/pages/team_color.dart';
import 'package:enhanced_ctf/pages/get_team_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:location/location.dart';

import '../utils/helpers/design_constants.dart';
import '../utils/helpers/timing_constants.dart';
import '../utils/services/my_game_state.dart';
import '../utils/services/http_requests.dart';

class InGameScreen extends StatefulWidget {
  const InGameScreen({Key? key}) : super(key: key);

  @override
  _InGameScreenState createState() => _InGameScreenState();
}

class _InGameScreenState extends State<InGameScreen> {
  int _selectedIndex = 0;
  bool _isTimerStopped = false;
  bool _loading = true;
  int tColor = 0;
  static AudioCache player = AudioCache(prefix: 'assets/sounds/');

  final GameState _gameState = GameState();

  bool _showedClassDialogue = false;
  //sends the user location to the server\
  void _exitGame() {
    if (_isTimerStopped == true) {
      return;
    }
    _isTimerStopped = true;
    showRemovedFromGameDialogue(context);
  }

  void _sendLocation() async {
    LocationData? myLocation;
    try {
      myLocation = await getCurrentLocation();
    } on TimeoutException catch (e) {
      debugPrint("Exception: $e");
      showSnackBarMessage(
          "Error getting your location. Location not updated.", context);
      return;
      // TODO
    } on Exception catch (e) {
      showSnackBarMessage("Error: $e", context);
      return;
    }

    _gameState.currentPosition = myLocation;
    var currDeviceId = await DeviceId.getDeviceID();
    LocationData currLocation;
    if (currDeviceId == null) {
      showSnackBarMessage("couldn't get your device ID", context);
      return;
    }
    if (_gameState.currentPosition == null) {
      showSnackBarMessage("Your current position is null!", context);
      return;
    } else {
      currLocation = _gameState.currentPosition!;
    }

    var postBody = {
      "deviceId": currDeviceId,
      "latitude": currLocation.latitude,
      "longitude": currLocation.longitude,
    };
    try {
      var postResponse =
          await makePostRequest(jsonEncode(postBody), UPDATE_MY_LOCATION_PATH);
      if (postResponse == null) {
        throw "post request failed";
      }
      if (_isTimerStopped) {
        return;
      }

      //post request status code 506 means the player isn't in a game anymore.
      debugPrint(postResponse.statusCode.toString());
      if (postResponse.statusCode == 506) {
        _exitGame();
        return;
      }
      if (postResponse.statusCode != 200) {
        debugPrint(
            'Status: ${postResponse.statusCode} Body: ${postResponse.body}');

        return;
      }
    } on Exception {
      debugPrint("Post Location Failed");
    }
    //otherwise, all good, we updated our location!
  }

  void dealWithGetBody(decodedBody) {
    print(decodedBody);
    bool newHasFlag = decodedBody["hasFlag"];
    int newFlagNumber = -1;
    if (newHasFlag) {
      newFlagNumber = decodedBody["flagNumber"];
    }
    bool newEliminated = decodedBody["eliminated"];
    int newViewRadius = decodedBody["viewRadius"];
    int newTagRadius = decodedBody["tagRadius"];
    String username = decodedBody["username"];
    bool isGameOver = decodedBody["gameOver"];

    if (isGameOver == true && _gameState.gameEnded == false) {
      _gameState.gameEnded = true;
      _isTimerStopped = true;

      newPageClearAllPrevious(context, const EndGameScreen());
    }

    //if we don't have a flag and we just got a flag
    if (_gameState.currentFlagHolding == null && newHasFlag == true) {
      _gameState.currentFlagHolding = newFlagNumber;
      showStoleFlagDialogue(context);
      player.play('flag_pickup.mp3');
    } else if (_gameState.currentFlagHolding !=
            null && //if you're not holding a flag and you used to be, but you're not eliminated
        newHasFlag == false &&
        newEliminated == false) {
      _gameState.currentFlagHolding = null;
      normalVibrate();
      showCapturedFlagDialogue(context);
      player.play('flag_capture.mp3');
    }

    if (newEliminated != _gameState.amIEliminated) {
      if (newEliminated == true) {
        //if you are eliminated now and you weren't before
        _gameState.currentFlagHolding = null;
        normalVibrate();
        showDeathDialogue(context);
        player.play('eliminated.mp3');
      } else {
        showSnackBarMessage("You are no longer eliminated!", context);
        player.play('revive.mp3');
      }
      _gameState.amIEliminated = newEliminated;
    }

    //if our current view radius is null

    _gameState.viewRadius = newViewRadius;
    _gameState.tagRadius = newTagRadius;
    _gameState.username = username;

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    return;
  }

  void _inGameLoop() async {
    var queryParameters = {
      "deviceId": _gameState.thisDeviceID.toString(),
      "gameId": _gameState.gameID.toString()
    }; //TODO:  check to make sure they're set here.

    //first we request our data.

    try {
      var myInfoResponse =
          await makeGetRequest(GET_MY_INFO_PATH, queryParameters);
      if (myInfoResponse == null) {
        throw "myInfo Failed";
      }
      //506 is game is ended

      if (myInfoResponse.statusCode == 506) {
        _exitGame();
        return;
      }
      if (myInfoResponse.statusCode != 200) {
        debugPrint("Status Code: ${myInfoResponse.statusCode}");
        debugPrint(myInfoResponse.body);
        showSnackBarMessage(
            "Getting information from server failed...", context);
      } else {
        var jsonDecoded = jsonDecode(myInfoResponse.body);
        dealWithGetBody(jsonDecoded);
      }
    } on Exception {
      debugPrint("MyInfoPath Failed");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        {
          newPageReversible(context, const ChatScreen());
        }
        break;

      case 1:
        {
          newPageReversible(context, const MapScreen());
        }
        break;

      case 2:
        {
          newPageClearAllPrevious(context, const HomeScreen());
        }
        break;

      case 3:
        {
          newPageReversible(context, const PlayerInfoScreen());
        }
    }
  }

  void startInGameTimer() {
    _inGameLoop(); //do it once to load in the information to start with
    Timer.periodic(const Duration(seconds: TimingConstants.inGameLoopTime),
        (timer) {
      if (_isTimerStopped) {
        timer.cancel();
      } else {
        _inGameLoop();
      }
    });
  }

  void startSendLocationTimer() {
    //sending the location
    _sendLocation(); //starts it with no delay
    Timer.periodic(const Duration(seconds: TimingConstants.sendLocationTime),
        (timer) {
      if (_isTimerStopped) {
        timer.cancel();
      } else {
        _sendLocation();
      }
    });
  }

  @override
  void initState() {
    tColor = _gameState.whichTeamAmI;
    super.initState(); //sets the in game loop
    //fetching the info
    startInGameTimer();
    startSendLocationTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _isTimerStopped = true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              child: Container(
                color: Colors.black,
                height: 3.0,
              ),
              preferredSize: const Size.fromHeight(4.0)),
          centerTitle: true,
          title: const GameTimer(),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: AppConstants.bgColor,
                body: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: calculateMaxPageHeight(context),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            width: 330,
                            child: Card(
                              elevation: 0,
                              color: AppConstants.bgColor,
                              child: Row(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          5.0, 7.0, 0.0, 0.0),
                                      child: TeamColor(tColor)),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: const Text(
                                        "Team",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 250,
                            width: 330,
                            decoration: const BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 3,
                                  offset: Offset(4.0, 6.0),
                                  spreadRadius: -5.0,
                                )
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: const BorderSide(
                                      width: 3, color: Colors.black)),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 15, 20, 20),
                                  child: Column(
                                    children: const <Widget>[
                                      MyTeamMember(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: Center(
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Game ID: " +
                                              _gameState.gameID.toString(),
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ))),

                            //child: const Card(
                            //  elevation: 0,
                            //  color: AppConstants.bgColor,
                            // child: team(),
                            //)
                          )
                        ]),
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.message, color: Colors.black),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined, color: Colors.black),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.black),
              label: 'Player',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[900],
          onTap: _onItemTapped,
        ),
      );

  Widget team() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildFlagCard(header: 'Steal Flag'),
        const SizedBox(width: 16),
        buildTagCard(header: 'Tag Enemy'),
        const SizedBox(width: 16),
        buildButtonCard(header: 'Button'),
      ],
    );
  }

  Widget buildFlagCard({required String header}) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: Text(header,
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
      ]);

  Widget buildTagCard({required String header}) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: Text(header,
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
      ]);

  Widget buildButtonCard({required String header}) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: Text(header,
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
      ]);
}

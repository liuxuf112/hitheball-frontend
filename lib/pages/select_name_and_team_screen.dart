import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/helpers/regex.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/waiting_for_players_screen.dart';
import '../utils/services/my_game_state.dart';
import '../utils/services/get_device_id.dart';
import '../utils/helpers/design_constants.dart';
import 'dart:convert';
import '../utils/services/http_requests.dart';
import '../widgets/text_with_outline.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SelectNameAndTeamScreen());
  }
}

class SelectNameAndTeamScreen extends StatefulWidget {
  const SelectNameAndTeamScreen({Key? key}) : super(key: key);

  @override
  _SelectNameAndTeamScreenState createState() =>
      _SelectNameAndTeamScreenState();
}

class _SelectNameAndTeamScreenState extends State<SelectNameAndTeamScreen> {
  final GameState _gameState = GameState();
  final _usernameController = TextEditingController();
  bool _redTeamSelected = false;
  bool _blueTeamSelected = false;
  bool _attemptingJoin = false;
  final _formKey = GlobalKey<FormState>();
  void _sendJoinPost(gameId, deviceId, username, team) async {
    Map<String, dynamic> postInfo = {
      "deviceId": deviceId,
      "gameId": gameId,
      "username": username,
      "team": team
    };
    String postJson = jsonEncode(postInfo);
    try {
      var response = await makePostRequest(postJson, JOIN_GAME_PATH);
      if (response == null) {
        throw "Post Failed";
      }
      if (response.statusCode != 200) {
        debugPrint("Error in post request!");
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        showSnackBarMessage(
            'Joining game failed. Game might not exist.', context);
      } else {
        //now that we've successfully joined a game, update GameState
        _gameState.gameID = gameId;
        _gameState.whichTeamAmI = team;
        _gameState.username = username;
        _gameState.gameEnded = false;
        _gameState.queenFlag = -1;
        newPageClearAllPrevious(context, const WaitingForPlayersScreen());
      }
      setState(() {
        _attemptingJoin = false;
      });
    } catch (e) {
      debugPrint("Post failed");
      showSnackBarMessage("Sending information to server failed", context);
      setState(() {
        _attemptingJoin = false;
      });
    }
  }

  void _attemptJoinGame() {
    //first we check if the conditions are met, otherwise some error message should be displayed
    //which is not the case right now.
    if (_canUserAttemptJoin()) {
      String joinGameId = _gameState.attemptGameID.toString();
      String deviceID = _gameState.thisDeviceID.toString();
      String userName = isValidUserName(_usernameController.text).toString();
      int team = _redTeamSelected ? 1 : 2; //team is 1 if red, 2 if blue.
      _sendJoinPost(joinGameId, deviceID, userName, team);
    } else {
      debugPrint("invalid game state in select_name_and_team_screen");
      setState(() {
        _attemptingJoin = false;
      });
    }
  }

  //returns true if the user can attempt to join the game, false otherwise.
  bool _canUserAttemptJoin() {
    if (isValidUserName(_usernameController.text) ==
            null || //username check should be regex.
        _gameState.attemptGameID == null ||
        _gameState.thisDeviceID == null ||
        (_blueTeamSelected == false && _redTeamSelected == false)) {
      return false;
    } else {
      return true;
    }
  }

  void _setDeviceId() async {
    _gameState.thisDeviceID = await DeviceId.getDeviceID();
  } //this should probably be placed somewhere else.

  @override
  void initState() {
    super.initState();
    _setDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.bannerColor,
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: calculateMaxPageHeight(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const TextWithOutline(
                              fontSize: 25,
                              strokeWidth: 4,
                              strokeColor: Colors.black,
                              text: 'Player Name:',
                              textColor: Colors.white,
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (textBoxValue) {
                                  if (textBoxValue != null &&
                                      isValidUserName(textBoxValue) != null) {
                                    return null;
                                  } else {
                                    return "Please enter a valid username, alphanumeric symbols only! (a-z, A-Z, 0-9). 1-255 characters";
                                  }
                                },
                                controller: _usernameController,
                                onChanged: (text) {
                                  setState(
                                      () {}); //when the text changes, check if the button should be updated
                                },
                                autofocus: false,
                                decoration: InputDecoration(
                                    hintText: "Enter your username",
                                    errorMaxLines: 4,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width:
                                              10, // Doesn't work for some reason
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const TextWithOutline(
                              fontSize: 25,
                              strokeColor: Colors.black,
                              strokeWidth: 4,
                              text: "Team:",
                              textColor: Colors.white),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _redTeamSelected = !_redTeamSelected;
                                    _blueTeamSelected = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _redTeamSelected
                                      ? AppConstants
                                          .buttonSelectedBackgroundColor
                                      : AppConstants
                                          .buttonDeselectedBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(width: 2)),
                                ),
                                child: Text(
                                  'RED',
                                  style: TextStyle(
                                    color: _redTeamSelected
                                        ? Colors.red
                                        : AppConstants
                                            .buttonDeselectedTextColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _redTeamSelected = false;
                                    _blueTeamSelected = !_blueTeamSelected;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _blueTeamSelected
                                      ? AppConstants
                                          .buttonSelectedBackgroundColor
                                      : AppConstants
                                          .buttonDeselectedBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(width: 2)),
                                ),
                                child: Text(
                                  'BLUE',
                                  style: TextStyle(
                                    color: _blueTeamSelected
                                        ? Colors.blue
                                        : AppConstants
                                            .buttonDeselectedTextColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Currently, the Join Game button isn't in the right position
              // due to how I'm padding things. I'll look into a fix later
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: _attemptingJoin
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _attemptingJoin ||
                                (!_redTeamSelected && !_blueTeamSelected)
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _attemptingJoin = true;
                                  });

                                  _attemptJoinGame();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(width: 2)),
                        ),
                        child: const Text(
                          'Join Game',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

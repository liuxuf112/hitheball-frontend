import 'dart:convert';

import 'package:enhanced_ctf/pages/select_map_screen.dart';
import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/services/my_desired_map.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../utils/services/my_game_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/helpers/design_constants.dart';
import 'package:numberpicker/numberpicker.dart';
import '../widgets/text_with_outline.dart';
import '../widgets/input_row.dart';

import '../utils/services/http_requests.dart';
import '../utils/services/get_device_id.dart';
import './select_name_and_team_screen.dart';
import '../utils/helpers/show_snackbar.dart';

const double inputBoxWidth = 130;
const double inputBoxHeight = 45;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CreateGameScreen());
  }
}

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({Key? key}) : super(key: key);

  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  var hour = '00';
  var minute = '00';
  var _hourValue = 0;
  var _minuteValue = 30;

  var _minimumMinuteSelector =
      5; //this updates to 0 once hours goes to higher than 1, and back to 0.
  var _createGameButtonActive = true;

  final tagRadiusController = TextEditingController(text: '10');
  final viewRadiusController = TextEditingController(text: '30');
  final playersController = TextEditingController(text: '20');
  final flagsController = TextEditingController(text: '3');
  final coinsController = TextEditingController(text: '5');

  bool isChessOn = false;
  final GameState _gameState = GameState();
  final WantedMap _wantedMap = WantedMap();
  @override
  void dispose() {
    super.dispose();
    _wantedMap.mapRegion = null; //have to clear it out.
  }

  void _sendCreateGameRequest() async {
    //first we send a getRequest.
    String? deviceID = await DeviceId.getDeviceID();
    if (deviceID == null) {
      debugPrint("deviceID = null, this shouldn't happen");
      showSnackBarMessage(
          'Creating game failed... deviceID does not exist', context);
      setState(() {
        _createGameButtonActive = true;
      });

      return;
    }

    //check if map is selected.
    if (_wantedMap.mapRegion == null) {
      showSnackBarMessage("You need to select a map first.", context);
      setState(() {
        _createGameButtonActive = true;
      });

      return;
    }

    //this should probably be deleted later.
    var deleteQueryParameters = {
      "gameId": _gameState.gameID.toString(),
      "deviceId": deviceID.toString()
    };
    var deleteResponse =
        await makeDeleteRequest(DELETE_GAMES_PATH, deleteQueryParameters);
    if (deleteResponse == null) {
      return;
    }
    if (deleteResponse.statusCode != 200) {
      if (foundation.kDebugMode) {
        debugPrint(
            "something went wrong with default deleting games, but no reason to alert user: " +
                deleteResponse.body);
      }
    }
    //end things that should be deleted later. This needs to be handled better.
    String gameId = "";
    dynamic response;
    try {
      response = await makeGetRequest(CREATE_GAME_PATH, {"deviceId": deviceID});
      if (response == null) {
        throw "get create game failed";
      }
      if (response.statusCode != 200) {
        showSnackBarMessage(
            'Creating game failed... your deviceID might already have a game associated with it. Delete that game first',
            context);
        _createGameButtonActive = true;

        return;
      }
      var jsonDecoded = jsonDecode(response.body);
      gameId = jsonDecoded["gameId"];
      _gameState.attemptGameID = gameId;
      _gameState.gameID = gameId;
    } on Exception {
      debugPrint("create game failed, get request rejected");
    }

    List<Map<String, double>> regionJSON;
    Map<String, dynamic> sendBody = {};

    regionJSON = _wantedMap.mapRegion!.toJson();

    int gameLengthInMinutes = _hourValue * 60 + _minuteValue;
    sendBody["gameId"] = gameId;
    sendBody["deviceId"] = deviceID;
    sendBody["gameLength"] = gameLengthInMinutes;
    sendBody["defaultTagRadius"] = int.parse(tagRadiusController.text);
    sendBody["defaultViewRadius"] = int.parse(viewRadiusController.text);
    sendBody["maxPlayers"] = int.parse(playersController.text);
    sendBody["currentRound"] = 0;
    sendBody["region"] = regionJSON;
    sendBody["gameType"] = isChessOn ? 1 : 0; //temporary set.
    sendBody["divideByLatitude"] = _wantedMap.divideByLatitude;
    sendBody["amountOfFlags"] = int.parse(flagsController.text);
    response = await makePostRequest(jsonEncode(sendBody), SET_GAME_INFO_PATH);
    if (response.statusCode != 200) {
      //if the response isn't 200, we haven't successfuly made a game, so we should delete it then try again
      var response =
          await makeDeleteRequest(DELETE_GAMES_PATH, deleteQueryParameters);
      if (response == null) {
        return;
      }
      if (response.statusCode != 200) {
        if (foundation.kDebugMode) {
          debugPrint(
              "something went wrong with default deleting games, but no reason to alert user: " +
                  response.body);
        }
      }

      showSnackBarMessage('Creating game failed', context);

      setState(() {
        _createGameButtonActive = true;
      });

      return;
    } else {
      _wantedMap.mapRegion = null;

      _gameState.createdGame = true;
      Map<String, dynamic> sendCoinBody = {};
      sendCoinBody["gameId"] = gameId;
      sendCoinBody["amount"] = int.parse(coinsController.text);

      response = await makePostRequest(
          jsonEncode(sendCoinBody), GENERATE_COIN_FOR_GAME);
      if (response.statusCode != 200) {
        showSnackBarMessage('Generate coins failed', context);
      } else {
        showSnackBarMessage(
            "Creating game succeeded! gameID: $gameId", context);

        _gameState.createdGame = true;
        _wantedMap.mapRegion = null;
        //tring to replace the page
        //because you create the game yoou shouldn't be able to go back to editing it.
        //maybe add another navigation button somewhere?
        newPageReplaceCurrent(context, const SelectNameAndTeamScreen());
      }
    }

    return;
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
          constraints: BoxConstraints(
            minHeight: calculateMaxPageHeight(context),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 50.0, left: 20.0), //THIS IS BAD TOO
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Form(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 40), //THIS HARD CODING IS VERY BAD

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InputRow(
                            formController: playersController,
                            allowedInput: RegExp("[0-9]"),
                            fontSize: 20,
                            strokeWidth: 4,
                            strokeColor: Colors.black,
                            textColor: Colors.white,
                            text: 'Max Players:',
                            textRightPadding: 12.0,
                            inputBoxHeight: inputBoxHeight,
                            inputBoxWidth: inputBoxWidth,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InputRow(
                            formController: flagsController,
                            allowedInput: RegExp("[0-9]"),
                            fontSize: 20,
                            strokeWidth: 4,
                            strokeColor: Colors.black,
                            textColor: Colors.white,
                            text: 'Number of Flags:',
                            textRightPadding: 12.0,
                            inputBoxHeight: inputBoxHeight,
                            inputBoxWidth: inputBoxWidth,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InputRow(
                            formController: coinsController,
                            allowedInput: RegExp("[0-9]"),
                            fontSize: 20,
                            strokeWidth: 4,
                            strokeColor: Colors.black,
                            textColor: Colors.white,
                            text: 'Number of Coins:',
                            textRightPadding: 12.0,
                            inputBoxHeight: inputBoxHeight,
                            inputBoxWidth: inputBoxWidth,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const TextWithOutline(
                                  fontSize: 20,
                                  strokeColor: Colors.black,
                                  strokeWidth: 4,
                                  textColor: Colors.white,
                                  text: "Time Limit:",
                                  rightPadding: 12.0),
                              NumberPicker(
                                  value: _hourValue,
                                  minValue: 0,
                                  maxValue: 24,
                                  itemHeight: 30,
                                  itemWidth: 30,
                                  itemCount: 3,
                                  onChanged: (value) => setState(() {
                                        _hourValue = value;
                                        if (_hourValue == 0) {
                                          //if we set hour value to 0 or less...
                                          _minimumMinuteSelector =
                                              5; //the minimum minute is now 5.
                                        } else {
                                          _minimumMinuteSelector = 0;
                                        }
                                        if (_minuteValue == 0) {
                                          _minuteValue = 5;
                                        }
                                      })),
                              const Text('hours'),
                              NumberPicker(
                                value: _minuteValue,
                                minValue: _minimumMinuteSelector,
                                maxValue: 55,
                                step: 5,
                                itemHeight: 30,
                                itemWidth: 30,
                                itemCount: 3,
                                onChanged: (value) =>
                                    setState(() => _minuteValue = value),
                              ),
                              const Text('minutes'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const TextWithOutline(
                                fontSize: 20,
                                strokeColor: Colors.black,
                                strokeWidth: 4,
                                text: "Playable Area:",
                                textColor: Colors.white,
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints.tightFor(
                                    width: inputBoxWidth,
                                    height: inputBoxHeight),
                                child: ElevatedButton(
                                  onPressed: () {
                                    newPageReversible(
                                        context, const SelectMapScreen());
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        AppConstants.buttonColor),
                                  ),
                                  child: Text(
                                    _wantedMap.mapRegion == null
                                        ? 'Select Map'
                                        : 'Change Map',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InputRow(
                              allowedInput: RegExp("[0-9]"),
                              fontSize: 20,
                              formController: viewRadiusController,
                              inputBoxHeight: inputBoxHeight,
                              inputBoxWidth: inputBoxWidth,
                              keyboardType: TextInputType.number,
                              strokeColor: Colors.black,
                              textColor: Colors.white,
                              strokeWidth: 4,
                              text: 'View Radius (m):',
                              textRightPadding: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InputRow(
                              allowedInput: RegExp("[0-9]"),
                              fontSize: 20,
                              formController: tagRadiusController,
                              inputBoxHeight: inputBoxHeight,
                              inputBoxWidth: inputBoxWidth,
                              keyboardType: TextInputType.number,
                              strokeColor: Colors.black,
                              textColor: Colors.white,
                              strokeWidth: 4,
                              text: 'Tag Radius (m):',
                              textRightPadding: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const TextWithOutline(
                                  fontSize: 20,
                                  strokeWidth: 4,
                                  strokeColor: Colors.black,
                                  textColor: Colors.white,
                                  text: "Chess:"),
                              Switch(
                                value: isChessOn,
                                onChanged: (value) {
                                  setState(() {
                                    isChessOn = value;
                                  });
                                },
                                activeTrackColor: Colors.green,
                                activeColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _createGameButtonActive
                    ? ElevatedButton(
                        onPressed: _createGameButtonActive
                            ? () {
                                setState(() {
                                  _createGameButtonActive = false;
                                });
                                _sendCreateGameRequest();
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor: _createGameButtonActive
                                ? MaterialStateProperty.all(
                                    AppConstants.buttonColor)
                                : MaterialStateProperty.all(AppConstants
                                    .buttonDeselectedBackgroundColor)),
                        child: const Text(
                          'Create Game',
                          style: TextStyle(
                            color: AppConstants.buttonTextColor,
                            fontSize: 30,
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

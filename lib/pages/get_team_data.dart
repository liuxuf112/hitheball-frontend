import 'package:enhanced_ctf/classes/teammate_info.dart';
import 'package:enhanced_ctf/utils/helpers/class_constants.dart';
import 'package:enhanced_ctf/utils/helpers/timing_constants.dart';
import 'package:flutter/material.dart';
import '../utils/services/my_game_state.dart';
import 'package:enhanced_ctf/utils/services/get_device_id.dart';
import '../utils/services/http_requests.dart';
import 'dart:convert';
import 'dart:async';

class MyTeamMember extends StatefulWidget {
  const MyTeamMember({Key? key}) : super(key: key);

  @override
  _MyTeamMemberState createState() => _MyTeamMemberState();
}

class _MyTeamMemberState extends State<MyTeamMember> {
  List<TeammateInfo> teammates = [];

  final GameState _gameState = GameState();
  dynamic data;
  bool _isTimerStopped = false;

  @override
  void dispose() {
    super.dispose();
    _isTimerStopped = true;
  }

  void startGetTeamTimer() {
    grabTeamData();
    Timer.periodic(const Duration(seconds: TimingConstants.getTeamTime),
        (timer) async {
      //callback function
      if (_isTimerStopped || _gameState.gameEnded == true) {
        timer.cancel();
      } else {
        grabTeamData();
      }
    });
  }

  //note that the color of the icons doesn't matter here because it makes it all one color
  ImageIcon bishopIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/blueBishop.png'),
  );
  ImageIcon knightIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/blueKnight.png'),
  );
  ImageIcon queenIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/blueQueen.png'),
  );
  ImageIcon pawnIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/bluePawn.png'),
  );
  ImageIcon rookIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/blueRook.png'),
  );
  ImageIcon kingIcon = const ImageIcon(
    AssetImage('assets/images/chess_images/blueKing.png'),
  );

  //returns appropriate icon given classId
  ImageIcon getIcon(classId) {
    String classString = ClassConstants.classNames[classId]!;
    switch (classString) {
      case "Pawn":
        return pawnIcon;
      case "Knight":
        return knightIcon;
      case "Bishop":
        return bishopIcon;
      case "Rook":
        return rookIcon;
      case "Queen":
        return queenIcon;
      case "King":
        return kingIcon;
      case "None":
      default:
        return const ImageIcon(null);
    }
  }

  void grabTeamData() async {
    String? deviceId = await DeviceId.getDeviceID();
    String? gameId = _gameState.gameID;

    if (deviceId == null || gameId == null) {
      debugPrint("error in team players data");
    }

    try {
      var queryParameters = {"gameId": gameId, "deviceId": deviceId};

      var response =
          await makeGetRequest(getTeammatesLocations, queryParameters);

      if (response == null) {
        throw "get teammates locations failed";
      }
      var json = response.body;
      data = jsonDecode(json);
      teammates.clear();

      for (Map info in data) {
        TeammateInfo newTeammate = TeammateInfo(
            info["username"], info["eliminated"], info["class"],
            flagNumber: info["flagNumber"] ?? -1, hasFlag: (info["hasFlag"]));
        teammates.add(newTeammate);
      }
      teammates.sort(
          (a, b) => a.username.compareTo(b.username)); //sorts list by username

      if (!mounted) {
        return;
      } //adding before every set state because causes error if not.
      if (_isTimerStopped == false) {
        setState(() {});
      }
    } catch (e) {
      String _text = "request failed：$e";
      debugPrint(_text);
    }
  }

  @override
  void initState() {
    super.initState();
    startGetTeamTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (int i = 0; i < teammates.length; i++)
        Card(
          margin: const EdgeInsets.only(bottom: 15.0),
          color: Colors.white,
          elevation: 0,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: teammates[i].username + " ",
                        style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    WidgetSpan(
                      child: Tooltip(
                        message: teammates[i].hasFlag
                            ? "Flag #${teammates[i].flagNumber}"
                            : "No Flag",
                        child: Icon(Icons.flag,
                            size: 20.0,
                            color: teammates[i].hasFlag
                                ? Colors.green
                                : Colors.black54),
                      ),
                    ),
                    WidgetSpan(
                      // other possible icons: local_hospital_rounded, health_and_safety_rounded
                      child: Tooltip(
                        message:
                            teammates[i].eliminated ? "Eliminated" : "Alive",
                        child: Icon(Icons.favorite_rounded,
                            size: 20.0,
                            color: teammates[i].eliminated
                                ? Colors.black54
                                : Colors.red),
                      ),
                    ),
                    teammates[i].classID == 0
                        ? const WidgetSpan(child: Center())
                        : WidgetSpan(
                            child: Tooltip(
                                message: teammates[i].classString,
                                child: getIcon(teammates[i].classID))),
                  ])),
                ],
              )),
        ),
    ]);
  }
}

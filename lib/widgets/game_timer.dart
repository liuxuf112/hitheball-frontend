import 'dart:async';
import 'dart:convert';

import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/services/get_device_id.dart';
import 'package:enhanced_ctf/utils/services/http_requests.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';
import 'package:enhanced_ctf/widgets/timer_constructor.dart';
import 'package:flutter/material.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({Key? key}) : super(key: key);

  @override
  _GameTimerState createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  Duration duration = const Duration();
  final GameState _gameState = GameState();
  bool timerStarted = false;
  Timer? gameTimer;
  int gameLength = 0;
  @override
  void initState() {
    super.initState();
    fetchTime();
  }

  @override
  void dispose() {
    super.dispose();
    gameTimer!.cancel();
  }

  //void setInitialDuration(totalLengthInMinutes) {
  void setInitialDuration(hrs, min, sec, totalLengthInMinutes) {
    int finalHrs = 0;
    int finalMin = 0;
    int finalSec = 0;

    int hrs1 = hrs;
    int min1 = min;
    int sec1 = sec;

    while (totalLengthInMinutes != 0) {
      if ((totalLengthInMinutes - 60) >= 0) {
        finalHrs += 1;
        totalLengthInMinutes -= 60;
      } else {
        finalMin = totalLengthInMinutes;
        totalLengthInMinutes = 0;
      }
    }

    finalSec -= sec1;
    if (finalSec < 0) {
      finalSec += 60;
      finalMin -= 1;
    }

    finalMin -= min1;
    if (finalMin < 0) {
      finalMin += 60;
      finalHrs -= 1;
    }

    finalHrs -= hrs1;

    setState(() {
      duration =
          Duration(hours: finalHrs, minutes: finalMin, seconds: finalSec);
      timerStarted = true;
    });
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      subTime();
    });
  }

  void subTime() {
    var subSeconds = 1;
    if (!mounted) return;

    setState(() {
      final seconds = duration.inSeconds - subSeconds;
      if (seconds < 0) {
        gameTimer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  fetchTime() async {
    String? deviceId = await DeviceId.getDeviceID();
    String? gameId = _gameState.gameID;

    if (deviceId == null || gameId == null) {
      debugPrint("error in team players data");
      showSnackBarMessage("Couldn't get player info for game...", context);
    }

    try {
      var queryParameters = {"gameId": gameId, "deviceId": deviceId};
      var response = await makeGetRequest(getClockInfo, queryParameters);
      var json = response!.body;
      var data = await jsonDecode(json);
//////////////////////////////////////////////

      var startTime = data["startTimeStamp"];
      startTime = startTime.split("T");
      startTime = startTime[1].split(".");
      startTime = startTime[0];
      startTime = startTime.split(":");

      int gameHours = int.parse(startTime[0]);

      int pstHours = gameHours - 8;
      if (pstHours < 0) {
        pstHours += 24;
      }
      int gameMinutes = int.parse(startTime[1]);
      int gameSeconds = int.parse(startTime[2]);

      var tdata = DateTime.now().toString();
      var currentTime1 = tdata.split(" ");
      currentTime1 = currentTime1[1].split(".");
      var currentTime = currentTime1[0];
      var currentTime2 = currentTime.split(":");

      int phoneHours = int.parse(currentTime2[0]);

      int phoneMinutes = int.parse(currentTime2[1]);
      int phoneSeconds = int.parse(currentTime2[2]);

      int finalHrs = 0;
      int finalMin = 0;
      int finalSec = 0;

      int hoursDiff = phoneHours - pstHours; //game started at 1:30:40
      int minsDiff = phoneMinutes - gameMinutes; //2:30:39
      if (minsDiff < 0) {
        minsDiff += 60;
        hoursDiff -= 1;
      }

      int secsDiff = phoneSeconds - gameSeconds; //2:30:40

      if (secsDiff < 0) {
        secsDiff += 60;
        minsDiff -= 1;
        if (minsDiff < 0) {
          minsDiff += 60;
          hoursDiff -= 1;
        }
      }
      finalHrs = hoursDiff;
      finalMin = minsDiff;
      finalSec = secsDiff;

      //setInitialDuration();

//////////////////////////////////////////////////////////
      setInitialDuration(finalHrs, finalMin, finalSec, data["gameLength"]);
      //SHOULD ACTUALLY BE gamelength - (Currenttime - gameStartTime)
    } catch (e) {
      String _text = "request failed：$e";
      debugPrint(_text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: timerStarted
          ? [
              const Expanded(
                child: Text('Time Left', textAlign: TextAlign.center),
              ),
              TimerConstructor(
                  hours: duration.inHours,
                  minutes: duration.inMinutes,
                  seconds: duration.inSeconds),
            ]
          : [],
    );
  }
}

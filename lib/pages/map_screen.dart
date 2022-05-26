import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'dart:math';
import 'package:enhanced_ctf/classes/coin_location_data.dart';
import 'package:enhanced_ctf/classes/map_data_point.dart';
import 'package:enhanced_ctf/classes/location_data.dart';
import 'package:enhanced_ctf/utils/helpers/class_constants.dart';
import 'package:enhanced_ctf/utils/helpers/design_constants.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/helpers/team_enums.dart';
import 'package:enhanced_ctf/utils/helpers/timing_constants.dart';
import 'package:enhanced_ctf/utils/services/get_device_id.dart';
import 'package:enhanced_ctf/utils/services/get_location.dart';
import 'package:enhanced_ctf/utils/services/http_requests.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/services/get_device_id.dart';
import '../utils/services/my_game_state.dart';
import 'package:enhanced_ctf/utils/services/my_game_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;

const chessPieceWidth = 100;
const flagWidthAndHeight = 100;
const userWidthAndHeight = 100;
const coinWidthAndHeight = 80;

const ballWidthAndHeight = 100;
var tempx = 37.42227873061003;
var tempy = -122.0839528893912;
var temphit = false;
var hit_top = 1;

var top_boundary;
var bot_boundary;
var left_boundary;
var right_boundary;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GameState _gameState = GameState();
  late GoogleMapController mapController;
  LatLng? _center;
  List<Marker> listMarkers = [];
  List<LatLngData> listLocation = [];
  List<MapDataPoint> teamMatesListLocation = [];

  List<MapDataPoint> enemysList = [];
  List<MapDataPoint> enemysFlagsList = [];
  List<MapDataPoint> teamMatesFlagsList = [];
  List<CoinLocationData> gameCoins = [];
  final double _defaultZoom = 17;
  final double _GET_COIN_DISTANCE = 10;

  List<LatLng> polygonCoords = [];
  List<LatLng> teamOneList = [];
  List<LatLng> polygonCoordsBlue = [];
  List<LatLng> polygonCoordsYellowTop = [];
  List<LatLng> polygonCoordsYellowBottom = [];
  Set<Marker> listCustomMarkers = {};
  Set<Polygon> listMainPolygon = {};
  final Set<Polygon> listPolygon = {};

  BitmapDescriptor? pinLocationIconRed;
  BitmapDescriptor? pinLocationIconBlue;
  BitmapDescriptor? pinLocationFlagRed;
  BitmapDescriptor? pinLocationFlagRedBluePoint;
  BitmapDescriptor? pinLocationFlagBlueRedPoint;
  BitmapDescriptor? pinLocationFlagBlue;
  BitmapDescriptor? pinLocationIconCoin;

  BitmapDescriptor? pinLocationBall;

  BitmapDescriptor? redKnight;
  BitmapDescriptor? blueKnight;
  BitmapDescriptor? redBishop;
  BitmapDescriptor? blueBishop;
  BitmapDescriptor? redKing;
  BitmapDescriptor? blueKing;
  BitmapDescriptor? redRook;
  BitmapDescriptor? blueRook;
  BitmapDescriptor? redPawn;
  BitmapDescriptor? bluePawn;
  BitmapDescriptor? redQueen;
  BitmapDescriptor? blueQueen;

  List<dynamic> teamOneRegion = [];
  List<dynamic> teamTwoRegion = [];
  List<dynamic> teamMates = [];
  List<dynamic> enemys = [];
  List<dynamic> teamFlags = [];
  List<dynamic> enemyFlags = [];

  bool _isTimerStopped = false;
  bool _loading = true;

  static AudioCache player = AudioCache(prefix: 'assets/sounds/');
  void _updateCurrentLatLong() async {
    //if null set it
    try {
      _gameState.currentPosition ??= await getCurrentLocation();
    } on TimeoutException catch (e) {
      debugPrint("Exception: $e");
      showSnackBarMessage("Error getting your location.", context);
      return;
    } on Exception catch (e) {
      showSnackBarMessage("Error: $e", context);
      return;
    }
    if (!mounted) return;
    setState(() {
      _center = LatLng(_gameState.currentPosition!.latitude!,
          _gameState.currentPosition!.longitude!);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentLatLong();
    setCustomMapPin();
    loadChessImages();
    getRegionData();
    startGetDataTimer();
  }

  void startGetDataTimer() {
    Duration timeout = const Duration(seconds: TimingConstants.getMapInfoTime);
    getTeamLocationDataResult();
    Timer.periodic(timeout, (timer) {
      if (_isTimerStopped) {
        timer.cancel();
      } else {
        getTeamLocationDataResult();
      }
    });
  }

  Map<String, double> _findMinAndMaxLatAndLong(teamRegion) {
    double minLat, minLong, maxLat, maxLong;
    minLat = maxLat = teamRegion[0]['latitude'];
    minLong = maxLong = teamRegion[0]['longitude'];
    for (int i = 0; i < teamRegion.length; i++) {
      if (teamRegion[i]['latitude'] > maxLat) {
        maxLat = teamRegion[i]['latitude'];
      }
      if (teamRegion[i]['latitude'] < minLat) {
        minLat = teamRegion[i]['latitude'];
      }
      if (teamRegion[i]['longitude'] > maxLong) {
        maxLong = teamRegion[i]['longitude'];
      }
      if (teamRegion[i]['longitude'] < minLong) {
        minLong = teamRegion[i]['longitude'];
      }
    }
    return {
      'maxLat': maxLat,
      'maxLong': maxLong,
      'minLat': minLat,
      'minLong': minLong
    };
  }

  void _setTeamRegionPolygonData() {
    polygonCoords.clear();
    polygonCoordsBlue.clear();
    Map<String, double> minsAndMaxesTeamOne =
        _findMinAndMaxLatAndLong(teamOneRegion);
    Map<String, double> minsAndMaxesTeamTwo =
        _findMinAndMaxLatAndLong(teamTwoRegion);

    var minLat1 = minsAndMaxesTeamOne['minLat'];
    var maxlat1 = minsAndMaxesTeamOne['maxLat'];

    var minLat2 = minsAndMaxesTeamTwo['minLat'];
    var maxlat2 = minsAndMaxesTeamTwo['maxLat'];

    if (maxlat2! > maxlat1!) {
      top_boundary = maxlat2;
    } else {
      top_boundary = maxlat1;
    }

    if (minLat2! < minLat1!) {
      bot_boundary = minLat2;
    } else {
      bot_boundary = minLat1;
    }

    var minLong1 = minsAndMaxesTeamOne['minLong'];
    var maxLong1 = minsAndMaxesTeamOne['maxLong'];

    left_boundary = minLong1;
    right_boundary = maxLong1;

    //hard coded for 4 points teanm one.
    polygonCoords.add(LatLng(
        minsAndMaxesTeamOne['maxLat']!, minsAndMaxesTeamOne['maxLong']!));
    polygonCoords.add(LatLng(
        minsAndMaxesTeamOne['maxLat']!, minsAndMaxesTeamOne['minLong']!));
    polygonCoords.add(LatLng(
        minsAndMaxesTeamOne['minLat']!, minsAndMaxesTeamOne['minLong']!));
    polygonCoords.add(LatLng(
        minsAndMaxesTeamOne['minLat']!, minsAndMaxesTeamOne['maxLong']!));

    polygonCoordsBlue.add(LatLng(
        minsAndMaxesTeamTwo['maxLat']!, minsAndMaxesTeamTwo['maxLong']!));
    polygonCoordsBlue.add(LatLng(
        minsAndMaxesTeamTwo['maxLat']!, minsAndMaxesTeamTwo['minLong']!));
    polygonCoordsBlue.add(LatLng(
        minsAndMaxesTeamTwo['minLat']!, minsAndMaxesTeamTwo['minLong']!));
    polygonCoordsBlue.add(LatLng(
        minsAndMaxesTeamTwo['minLat']!, minsAndMaxesTeamTwo['maxLong']!));
  }

  void getRegionData() async {
    String? gameId = _gameState.gameID;
    String? deviceId = await DeviceId.getDeviceID();
    if (gameId == null || deviceId == null) {
      showSnackBarMessage(
          "Error getting team data, internal state is incorrect DeviceID: $deviceId, gameID: $gameId",
          context);
      return;
    }

    var queryParameters = {"gameId": gameId, "deviceId": deviceId};
    try {
      var response =
          await makeGetRequest(GET_GAME_REGIONS_PATH, queryParameters);
      if (response == null) {
        throw "getGameRegions Failed";
      }
      if (response.statusCode != 200) {
        debugPrint(
            "error in getting data in map screen regions"); //handle this better
      } else {
        String data = response.body;
        teamOneRegion = json.decode(data)['teamOneRegion'];
        teamTwoRegion = json.decode(data)['teamTwoRegion'];

        _setTeamRegionPolygonData();

        listMainPolygon.add(Polygon(
            polygonId: const PolygonId('red'),
            points: polygonCoords,
            strokeWidth: 3,
            fillColor: AppConstants.redTeamMapArea,
            strokeColor: Colors.black));

        listMainPolygon.add(Polygon(
            polygonId: const PolygonId('blue'),
            points: polygonCoordsBlue,
            strokeWidth: 3,
            fillColor: AppConstants.blueTeamMapArea,
            strokeColor: Colors.black));

        setState(() {
          _loading = false;
        });

        debugPrint('team one and two data  :${listMainPolygon.length}');
      }
    } on Exception {
      debugPrint("getGameRegion Failed");
    }
  }

  void getTeamLocationDataResult() async {
    String? gameId = _gameState.gameID;
    String? deviceId = await DeviceId.getDeviceID();
    if (gameId == null || deviceId == null) {
      showSnackBarMessage(
          "Error getting team data, internal state is incorrect DeviceID: $deviceId, gameID: $gameId",
          context);
    }
    var queryParameters = {"gameId": gameId, "deviceId": deviceId};

    try {
      var response = await makeGetRequest(GET_MAP_SCREEN_PATH, queryParameters);
      if (response == null) {
        throw "Getting map screen failed";
      }
      if (response.statusCode != 200) {
        debugPrint("error in getting data map screen"); //handle this better
      } else {
        String data = response.body;
        var decodedData = json.decode(data);

        teamMates = decodedData['teammates'];
        enemys = decodedData['enemys'];
        teamFlags = decodedData['teamFlags'];

        debugPrint(decodedData.toString());
        //debugPrint(decodedData['teamFlags'].toString());

        enemyFlags = decodedData['enemyFlags'];

        listCustomMarkers
            .clear(); //clears out the list, because flags can be removed from the game.
        teamMatesLocationList();
        teamMatesFlag();
        enemyLocationList();
        enemyFlag();
        addball();

        if (_isTimerStopped == false) {
          setState(() {});
        }
      }
    } on Exception {
      debugPrint("Getting map screen failed");
    }
  }

  double getDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  void addball() {
    tempx = tempx + (0.0001 * hit_top);

    Random random = new Random();
    int randomNumber = random.nextInt(100);

    //moving by set global
    if (temphit == true) {
      if (randomNumber > 50) {
        tempy = tempy + 0.0001;
      } else {
        tempy = tempy - 0.0001;
      }

      temphit = false;
    }

    if (tempx > top_boundary) {
      hit_top = -1;
    }

    if (tempx < bot_boundary) {
      hit_top = 1;
    }

    if (tempy < left_boundary) {
      tempy = tempy + 0.0005;
    }

    if (tempy > right_boundary) {
      tempy = tempy - 0.0005;
    }

    //link this part to the database
    listCustomMarkers.add(
      Marker(
        anchor: const Offset(0.3, 0.3),
        markerId: MarkerId('ball'),
        position: LatLng(tempx, tempy),
        icon: pinLocationBall != null
            ? pinLocationBall!
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
      ),
    );
  }

  void addBallMarker(user) {
    if (user.username == _gameState.username &&
        _gameState.whichTeamAmI == blueTeamNumber) {
      return;
    }
    listCustomMarkers.add(
      Marker(
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId('Marker Blue ${user.username} $blueTeamNumber'),
          position: LatLng(user.latitude, user.longitude),
          onTap: () {
            debugPrint('Blue Player Pressed');
            _tagCheck(user, blueTeamNumber);
          },
          icon: getBlueIcon(user)),
    );
  }

  void teamMatesLocationList() {
    teamMatesListLocation.clear();
    for (int i = 0; i < teamMates.length; i++) {
      if (teamMates[i] != null &&
          (teamMates[i]['latitude'] != -1000 &&
              teamMates[i]['latitude'] != null)) {
        teamMatesListLocation.add(MapDataPoint.fromJSON(teamMates[i]));
      }
    }

    for (int i = 0; i < teamMatesListLocation.length; i++) {
      MapDataPoint user = teamMatesListLocation[i];
      switch (_gameState.whichTeamAmI) {
        case redTeamNumber:
          addRedCustomMarker(user);
          break;
        case blueTeamNumber:
          addBlueCustomMarker(user);
          break;
        default:
          debugPrint("unknown team number: ${_gameState.whichTeamAmI}");
      }
    }
  }

  void enemyLocationList() {
    enemysList.clear();
    for (int i = 0; i < enemys.length; i++) {
      if (enemys[i] != null) {
        enemysList.add(MapDataPoint.fromJSON(enemys[i]));
      }
    }

    for (int i = 0; i < enemysList.length; i++) {
      MapDataPoint user = enemysList[i];
      switch (_gameState.whichTeamAmI) {
        case redTeamNumber: //if on red team, enemies are blue
          addBlueCustomMarker(user);
          break;
        case blueTeamNumber: //read above comment
          addRedCustomMarker(user);
          break;
      }
    }
  }

  void enemyFlag() {
    enemysFlagsList.clear();
    for (int i = 0; i < enemyFlags.length; i++) {
      if (enemyFlags[i]['stolen'] == true) {
        //if this flag is stolen don't draw it, let the player draw it.
        continue;
      }
      if (enemyFlags[i]['latitude'] != null &&
          enemyFlags[i]['longitude'] != null) {
        enemysFlagsList.add(MapDataPoint.fromJSON(enemyFlags[i]));
      }
    }
    for (int i = 0; i < enemysFlagsList.length; i++) {
      MapDataPoint flag = enemysFlagsList[i];
      switch (_gameState.whichTeamAmI) {
        case redTeamNumber: //if on red team, enemies are blue
          addFlagMarkerBlue(flag);
          break;
        case blueTeamNumber: //read above comment
          addFlagMarkerRed(flag);

          break;
      }
    }
  }

  void teamMatesFlag() {
    teamMatesFlagsList.clear();

    for (int i = 0; i < teamFlags.length; i++) {
      if (teamFlags[i]['stolen'] == true) {
        //if the flag is stolen, we don't render it.
        continue;
      }
      if (teamFlags[i]['latitude'] != null &&
          teamFlags[i]['longitude'] != null) {
        teamMatesFlagsList.add(MapDataPoint.fromJSON(teamFlags[i]));
      }
    }
    for (int i = 0; i < teamMatesFlagsList.length; i++) {
      MapDataPoint flag = teamMatesFlagsList[i];
      switch (_gameState.whichTeamAmI) {
        case redTeamNumber: //if on red team, enemies are blue
          addFlagMarkerRed(flag);
          break;
        case blueTeamNumber: //read above comment
          addFlagMarkerBlue(flag);

          break;
      }
    }
  }

  void addRedCustomMarker(user) {
    if (user.username == _gameState.username &&
        _gameState.whichTeamAmI == redTeamNumber) {
      return;
    }
    listCustomMarkers.add(
      Marker(
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId('Marker Red ${user.username} $redTeamNumber'),
        position: LatLng(user.latitude, user.longitude),
        onTap: () {
          debugPrint('Red Player Pressed');
          _tagCheck(user, redTeamNumber);
        },
        icon: getRedIcon(user),
      ),
    );
  }

  void addFlagMarkerRed(flag) {
    listCustomMarkers.add(
      Marker(
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId('Flag ${flag.flagNumber} Team: $redTeamNumber'),
        position: LatLng(flag.latitude, flag.longitude),
        onTap: () {
          debugPrint('Red Flag Pressed');
          _stealCheck(flag, redTeamNumber);
        },
        icon: pinLocationFlagRed != null
            ? pinLocationFlagRed!
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
      ),
    );
  }

  void addFlagMarkerBlue(flag) {
    listCustomMarkers.add(Marker(
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId('Flag ${flag.flagNumber} Team: $blueTeamNumber'),
        position: LatLng(flag.latitude, flag.longitude),
        onTap: () {
          debugPrint('Blue Flag Pressed');
          _stealCheck(flag, blueTeamNumber);
        },
        icon: pinLocationFlagBlue != null
            ? pinLocationFlagBlue!
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              )));
  }

  void addBlueCustomMarker(user) {
    if (user.username == _gameState.username &&
        _gameState.whichTeamAmI == blueTeamNumber) {
      return;
    }
    listCustomMarkers.add(
      Marker(
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId('Marker Blue ${user.username} $blueTeamNumber'),
          position: LatLng(user.latitude, user.longitude),
          onTap: () {
            debugPrint('Blue Player Pressed');
            _tagCheck(user, blueTeamNumber);
          },
          icon: getBlueIcon(user)),
    );
  }

  BitmapDescriptor getBlueIcon(MapDataPoint user) {
    //TODO: add custom images for when a class is holding a flag
    String classString = ClassConstants.classNames[user.classID]!;

    switch (classString) {
      case "Pawn":
        if (bluePawn != null) {
          return bluePawn!;
        }
        break;
      case "Knight":
        if (blueKnight != null) {
          return blueKnight!;
        }
        break;
      case "Bishop":
        if (blueBishop != null) {
          return blueBishop!;
        }
        break;
      case "Rook":
        if (blueRook != null) {
          return blueRook!;
        }
        break;
      case "Queen":
        if (blueQueen != null) {
          return blueQueen!;
        }
        break;
      case "King":
        if (blueKing != null) {
          return blueKing!;
        }
        break;
      case "None":
      default:
        break;
    }
    return pinLocationIconBlue!;
  }

  BitmapDescriptor getRedIcon(MapDataPoint user) {
    String classString = ClassConstants.classNames[user.classID]!;
    switch (classString) {
      case "Pawn":
        if (redPawn != null) {
          return redPawn!;
        }
        break;
      case "Knight":
        if (redKnight != null) {
          return redKnight!;
        }
        break;
      case "Bishop":
        if (redBishop != null) {
          return redBishop!;
        }
        break;
      case "Rook":
        if (redRook != null) {
          return redRook!;
        }
        break;
      case "Queen":
        if (redQueen != null) {
          return redQueen!;
        }
        break;
      case "King":
        if (redKing != null) {
          return redKing!;
        }
        break;
      case "None":
      default:
        break;
    }
    return pinLocationIconRed!;
  }

  void loadChessImages() async {
    //TODO: these images are loaded every time you reopen the map slowing down load times.
    //these should be always loaded once a user joins a game.
    redKnight = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redKnight.png', chessPieceWidth);
    blueKnight = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/blueKnight.png', chessPieceWidth);
    redPawn = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redPawn.png', chessPieceWidth);
    bluePawn = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/bluePawn.png', chessPieceWidth);
    redBishop = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redBishop.png', chessPieceWidth);
    blueBishop = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/blueBishop.png', chessPieceWidth);
    redRook = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redRook.png', chessPieceWidth);
    blueRook = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/blueRook.png', chessPieceWidth);
    redKing = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redKing.png', chessPieceWidth);
    blueKing = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/blueKing.png', chessPieceWidth);
    redQueen = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/redQueen.png', chessPieceWidth);
    blueQueen = await getBitmapDescriptorFromAssetBytes(
        'assets/images/chess_images/blueQueen.png', chessPieceWidth);
  }

  void setCustomMapPin() async {
    pinLocationIconRed = await getBitmapDescriptorFromAssetBytes(
        'assets/images/red_circle.png', userWidthAndHeight);

    pinLocationIconBlue = await getBitmapDescriptorFromAssetBytes(
        'assets/images/blue_circle.png', userWidthAndHeight);
    pinLocationFlagBlue = await getBitmapDescriptorFromAssetBytes(
        'assets/images/flag.png', flagWidthAndHeight);

    pinLocationBall = await getBitmapDescriptorFromAssetBytes(
        'assets/images/ball.png', ballWidthAndHeight);

    pinLocationFlagRed = await getBitmapDescriptorFromAssetBytes(
        'assets/images/red_flag.png', flagWidthAndHeight);
    pinLocationFlagRedBluePoint = await getBitmapDescriptorFromAssetBytes(
        'assets/images/red_flag_blue_point.png', userWidthAndHeight);

    pinLocationFlagBlueRedPoint = await getBitmapDescriptorFromAssetBytes(
        'assets/images/blue_flag_red_point.png', userWidthAndHeight);

    pinLocationIconCoin = await getBitmapDescriptorFromAssetBytes(
        'assets/images/coin.png', coinWidthAndHeight);

    setState(() {});
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void _tagCheck(MapDataPoint user, int teamNumber) async {
    _showTagPlayerDialog(user, teamNumber);
  }

  void _stealCheck(MapDataPoint flag, int teamNumber) async {
    _showStealFlagDialog(flag, teamNumber);
  }

  void _moveflag() async {
    String? deviceID = await DeviceId.getDeviceID();
    if (deviceID == null) {
      debugPrint("deviceID = null, this shouldn't happen");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('deviceID does not exist')),
      );
      return;
    }

    String? gameID = _gameState.gameID;

    try {
      var response = await makeGetRequest(move_flag, {
        "gameId": gameID,
        "deviceId": deviceID,
      });
    } on Exception {
      showSnackBarMessage("move flag failed", context);
    }
  }

  Future<void> _showTagPlayerDialog(MapDataPoint player, int teamNumber) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: (teamNumber == _gameState.whichTeamAmI)
              ? const Text('Teammate Info')
              : const Text('Enemy Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username: ${player.username}'),
              Text('Class: ${ClassConstants.classNames[player.classID]}'),
              player.eliminated == true
                  ? const Text('Current Status: Dead')
                  : const Text('Current Status: Alive'),
              player.hasFlag == true
                  ? Text("Player currently has " +
                      ((teamNumber == _gameState.whichTeamAmI)
                          ? "enemy "
                          : "team") +
                      "flag #${player.flagNumber}")
                  : const Center(),
              (_gameState.className == "King" &&
                      teamNumber != _gameState.whichTeamAmI)
                  ? const Text('Note: As a king you cannot tag enemy players.')
                  : const Center(),
              (ClassConstants.classNames[player.classID] == "Knight" &&
                      teamNumber != _gameState.whichTeamAmI)
                  ? const Text("Note: Enemy knights cannot be tagged")
                  : const Center()
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Dismiss',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            (_gameState.amIEliminated == true ||
                    teamNumber == _gameState.whichTeamAmI ||
                    _gameState.className == "King" ||
                    ClassConstants.classNames[player.classID] ==
                        "Knight") //kings cannot tag players, and knights cannot be tagged.
                ? const Center()
                : TextButton(
                    child: const Text(
                      'Attempt Tag',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    onPressed: () {},
                  ),
          ],
        );
      },
    );
  }

  Future<void> _showStealFlagDialog(MapDataPoint flag, int teamNumber) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: teamNumber == _gameState.whichTeamAmI
              ? const Text('Team Flag')
              : const Text('Enemy Flag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flag #${flag.flagNumber}'),
                _gameState.className == "Queen" &&
                        _gameState.queenFlag == flag.flagNumber &&
                        teamNumber != _gameState.whichTeamAmI
                    ? const Text(
                        'Note: As a queen you can alway see this flag, but you can never obtain it.')
                    : const Center(),
                (_gameState.className == "Knight" &&
                        teamNumber != _gameState.whichTeamAmI)
                    ? const Text(
                        'Note: As a knight, you cannot steal any flags, but you can inform your teammates where they are!')
                    : const Center()
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Dismiss',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            (_gameState.amIEliminated == false &&
                    _gameState.className != "Knight" &&
                    flag.flagNumber != _gameState.queenFlag &&
                    teamNumber !=
                        _gameState
                            .whichTeamAmI) //if you're not eliminated, and not a knight, and it's not a queen flag and it's on an enemy team
                ? TextButton(
                    child: const Text(
                      'Attempt Steal',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    onPressed: () {},
                  )
                : const Center(),
          ],
        );
      },
    );
  }

  Set<Circle> getCircle() {
    if (_gameState.currentPosition == null) {
      return {};
    }
    Set<Circle> mCircle = {
      Circle(
        circleId: const CircleId("2"),
        center: LatLng(_gameState.currentPosition!.latitude!,
            _gameState.currentPosition!.longitude!),
        radius: (_gameState.viewRadius)!.toDouble(),
        fillColor: const Color.fromARGB(40, 0, 255, 0),
        strokeWidth: 0,
        zIndex: 1,
      ),
      Circle(
        circleId: const CircleId("1"),
        center: LatLng(_gameState.currentPosition!.latitude!,
            _gameState.currentPosition!.longitude!),
        radius: (_gameState.tagRadius)!.toDouble(),
        fillColor: const Color.fromARGB(70, 0, 150, 0),
        strokeWidth: 0,
        zIndex: 2,
      )
    };
    return mCircle;
  }

  @override
  void dispose() {
    _isTimerStopped = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: _loading || _center == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center!,
                      zoom: _defaultZoom,
                    ),
                    polygons: listMainPolygon,
                    myLocationEnabled: true,
                    markers: listCustomMarkers,
                    zoomControlsEnabled: true,
                    circles: getCircle(),
                  ),
                ),
                if (listLocation.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: listLocation.length,
                      itemBuilder: (context, index) {
                        LatLngData model = listLocation[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: LatLng(
                                          listLocation[index].latitude,
                                          listLocation[index].longitude),
                                      zoom: _defaultZoom),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(
                                model.deviceID,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text('Hit The Ball'),
                    onPressed: () {
                      _moveflag();
                      temphit = true;
                      //old moveing flag, modify relate to ball
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

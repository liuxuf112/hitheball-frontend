import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

const blueTeamNumber = 2;
const redTeamNumber = 1;

class GameState {
  //this class manages an object instance.
  static final GameState _instance = GameState._internal();

  // passes the instantiation to the _instance object - no I don't know what this means either
  factory GameState() => _instance;

  //initialize variables in here - private constructor

  GameState._internal() {
    gameID = "AAAAAA"; //don't need to initialize
  }
  String? gameID; //this is the game we are CURRENTLY IN
  String? username;
  String? attemptGameID; //this is the game that we will be attempting to join.
  String?
      thisDeviceID; //currently initialized in join_game, should probably be initialized somewhere else.
  bool createdGame = false; //did this user create the game?
  int? tagRadius;
  int? viewRadius;
  int? gameMaxPlayers;
  int? currentRound;
  bool amIEliminated = false;
  int whichTeamAmI = 0;
  bool gameEnded = false;
  int?
      currentFlagHolding; //set to null by default, set to flag number if you are holding a flag.
  int lastUpdated = 0;
  LocationData? currentPosition;
  int classId = 0;
  String className = "None";
  int queenFlag = -1;
}


//to access this in another class, or set / grab variables do this:
/*
   GameState _gameState = GameState();
   , and then in a function somewhere:

   if (_gameState.gameID != null) {
      print(_gameState.gameID);
    }

    it should be static between files, so if you set it it should change.
*/
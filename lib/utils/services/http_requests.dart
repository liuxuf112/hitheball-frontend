// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import './get_hostname.dart';
import 'dart:io';

const CREATE_GAME_PATH = 'createGame';
const DELETE_GAMES_PATH = 'deleteMyGames';
const JOIN_GAME_PATH = 'joinGame';
const GET_GAME_REGIONS_PATH = 'getGameRegions';
const GET_MAP_SCREEN_PATH = 'getMapScreenInfo';
const GET_MY_INFO_PATH = 'getMyInfo';
const UPDATE_MY_LOCATION_PATH = 'updatePlayerLocation';

const START_GAME_PATH = '/startGame';
const GET_PLAYERS_IN_GAME_PATH = '/getPlayersInGame';
const SET_GAME_INFO_PATH = '/setGameInfo';
const TAG_PLAYER_PATH = '/attemptTagPlayer';
const move_flag = '/moveflag';
const STEAL_FLAG_PATH = '/attemptStealFlag';
const getTeammatesLocations = '/getTeammatesLocations';
const getClockInfo = '/getClockInfo';
const GET_END_INFO = '/getEndGameInfo';
const GENERATE_COIN_FOR_GAME = "/generateCoinForGame";
const GET_COINS_FROM_GAME = "/getCoinsFromGame";
const PLAYER_GET_GAME_COIN = '/playerGetGameCoin';

Future<Response?> makePostRequest(String jsonBody, String path) async {
  //what happens if the server doesn't exist?... ah it creates a socket error, errno 110, address = 10.0.2.2. SocketException
  // print("makign a post request");
  final url = Uri.https(hostname, path);

  final headers = {"Content-type": "application/json"};
  final json = jsonBody;
  //print("body here is: " + json);

  //print('Status code: ${response.statusCode}');
  //print('Body: ${response.body}');
  try {
    final response = await post(url, headers: headers, body: json);
    return response;
  } catch (e) {
    if (e is SocketException) {
      debugPrint("Socket exception on get ${e.toString()}");
    } else if (e is TimeoutException) {
      //treat TimeoutException
      debugPrint("Timeout exception: ${e.toString()}");
    } else {
      ("Unhandled exception: ${e.toString()}");
    }
    return null;
  }
}

Future<Response?> makeGetRequest(
    String path, Map<String, dynamic> queryParameters) async {
  //final url = Uri.parse('$hostname/database');
  final url = Uri.https(hostname, path, queryParameters);

  try {
    Response response = await get(url);
    return response;
  } catch (e) {
    if (e is SocketException) {
      debugPrint("Socket exception on get ${e.toString()}");
    } else if (e is TimeoutException) {
      //treat TimeoutException
      debugPrint("Timeout exception: ${e.toString()}");
    } else {
      ("Unhandled exception: ${e.toString()}");
    }
    return null;
  }

  //print('Get Status code: ${response.statusCode}');
  //print('Headers: ${response.headers}');
  //print('Body: ${response.body}');
}

//eventually all request should be updated to have this kind of queryParameter creating
Future<Response?> makeDeleteRequest(
    String path, Map<String, String> queryParameters) async {
  var uri = Uri.https(hostname, path, queryParameters);

  try {
    return await delete(uri);
  } catch (e) {
    if (e is SocketException) {
      debugPrint("Socket exception on delete ${e.toString()}");
    } else if (e is TimeoutException) {
      //treat TimeoutException
      debugPrint("Timeout exception: ${e.toString()}");
    } else {
      debugPrint("Unhandled exception: ${e.toString()}");
    }
    return null;
  }
}

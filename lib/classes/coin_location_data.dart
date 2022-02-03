class CoinLocationData {
  int coinId;
  String gameId;
  String playerId;
  double latitude = -1000;
  double longitude = -1000;
  String createDate;

  CoinLocationData(
      { required this.coinId,
        required this.gameId,
        required this.playerId,
        required this.latitude,
        required this.longitude,
      required this.createDate});

  factory CoinLocationData.fromJSON(Map<String, dynamic> data) {
    return CoinLocationData(
        coinId: data['coin_id']??'',
        gameId: data['game_id']??'',
        playerId: data['player_id']??'',
        latitude: data['coin_location']['x'] ?? -1000,
        longitude: data['coin_location']['y'] ?? -1000,
        createDate: data['create_date'],  );
  }

  Map toJson() => {
    'coinId': coinId,
    'gameId': gameId,
    'player_id': playerId,
    'latitude': latitude,
    'longitude': longitude,
    'createDate': createDate
  };
}
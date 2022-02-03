class MapDataPoint {
  double latitude = -1000;
  double longitude = -1000;
  String username = "";
  int flagNumber = -1;
  bool hasFlag = false;
  int classID = 0;
  bool eliminated = false;

  MapDataPoint(
      {required this.latitude,
      required this.longitude,
      this.username = "",
      this.flagNumber = -1,
      this.hasFlag = false,
      this.classID = 0,
      this.eliminated = false});

  factory MapDataPoint.fromJSON(Map<String, dynamic> data) {
    return MapDataPoint(
        latitude: data['latitude'] ?? -1000,
        longitude: data['longitude'] ?? -1000,
        username: data['username'] ?? "",
        flagNumber: data['flagNumber'] ?? -1,
        hasFlag: data['hasFlag'] ?? false,
        classID: data['class'] ?? 0,
        eliminated: data['eliminated'] ?? false);
  }

  Map toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'username': username,
        'flagNumber': flagNumber,
        'hasFlag': hasFlag,
        'class': classID,
        'eliminated': eliminated
      };
}

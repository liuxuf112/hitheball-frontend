class LatLngData {
  double latitude;
  double longitude;
  String deviceID;
  LatLngData(
      {required this.latitude,
      required this.longitude,
      required this.deviceID});
  LatLngData.fromJSON(Map<String, dynamic> data)
      : latitude = double.parse(data['latitude']),
        longitude = double.parse(data['longitude']),
        deviceID = data['deviceid'];

  Map toJson() => {
        'deviceid': deviceID,
        'latitude': latitude,
        'longitude': longitude,
      };
}

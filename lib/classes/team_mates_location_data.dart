class TeamMatesLatLngData {
  Location location;

  TeamMatesLatLngData({
    required this.location,
  });

  factory TeamMatesLatLngData.fromJSON(Map<String, dynamic> data) {
    return TeamMatesLatLngData(location: Location.fromJSON(data));
  }

  Map toJson() => {
        'location': location,
      };
}

class Location {
  double latitude;
  double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJSON(Map<String, dynamic> data) {
    return Location(
        latitude: double.parse(data['latitude'].toString()),
        longitude: double.parse(data['longitude'].toString()));
  }

  Map toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

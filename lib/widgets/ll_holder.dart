import 'package:flutter/material.dart';
import '../classes/location_data.dart';

//this widget will take in longitude, latitude, and userID and should return a
//Row widget with the information nicely displayed in columns. Currently it returns a Text
//widget.
//Additionally, the latitude and longitude should probably be trimmed to a reasonable number of decimal points.
//Refer to https://flutter.dev/docs/development/ui/layout to learn more about rows.

class LatLongHolder extends StatelessWidget {
  final LatLngData locationData;

  const LatLongHolder(this.locationData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text("Longitude: " +
            locationData.longitude.toString() +
            " Latitude: " +
            locationData.latitude.toString() +
            " deviceID: " +
            locationData.deviceID),
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return Text("Longitude: " +
        locationData.longitude.toString() +
        " Latitude: " +
        locationData.latitude.toString() +
        " deviceID: " +
        locationData.deviceID);
  }*/
}

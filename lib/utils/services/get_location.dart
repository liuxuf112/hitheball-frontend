import 'dart:async';

import 'package:location/location.dart';

Future<LocationData?> getCurrentLocation() async {
  Location location = Location();
  var _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }
  PermissionStatus _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  LocationData currentLocation = await location.getLocation();
  return currentLocation;
  /* return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
      timeLimit: const Duration(seconds: TimingConstants.getLocationTimeout));*/
}

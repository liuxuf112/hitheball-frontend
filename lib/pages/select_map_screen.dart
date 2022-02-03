import 'dart:async';
import 'dart:math';

import 'package:enhanced_ctf/classes/region.dart';
import 'package:enhanced_ctf/utils/helpers/design_constants.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/helpers/timing_constants.dart';
import 'package:enhanced_ctf/utils/services/get_location.dart';
import 'package:enhanced_ctf/utils/services/my_desired_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const initialOffsetFromPlayer = 0.001;

class SelectMapScreen extends StatefulWidget {
  const SelectMapScreen({Key? key}) : super(key: key);

  @override
  _SelectMapScreenState createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {
  LatLng? _currentLatLong;
  final double _defaultZoom = 17;
  final Set<Marker> _polygonMarkers = {};
  final WantedMap _wantedMap = WantedMap();

  Marker marker1 = const Marker(markerId: MarkerId("1"));
  Marker marker2 = const Marker(markerId: MarkerId("2"));
  Marker marker3 = const Marker(markerId: MarkerId("3"));
  Marker marker4 = const Marker(markerId: MarkerId("4"));

  bool? _divideByLatitude;

  final Set<Polygon> _drawPolygons = {};

  double _maxRectLong = 0.0,
      _minRectLong = 0.0,
      _maxRectLat = 0.0,
      _minRectLat = 0.0; //variables that will define the markers.
  double _drawMaxRectLong = 0.0,
      _drawMinRectLong = 0.0,
      _drawMaxRectLat = 0.0,
      _drawMinRectLat = 0.0; //variables that will define the markers.

  void _updateWantedMap() {
    if (!mounted) return;
    setState(() {
      _wantedMap.divideByLatitude = _divideByLatitude;
      _wantedMap.mapRegion = Region({
        "latitude": marker1.position.latitude,
        "longitude": marker1.position.longitude
      }, {
        "latitude": marker2.position.latitude,
        "longitude": marker2.position.longitude
      }, {
        "latitude": marker3.position.latitude,
        "longitude": marker3.position.longitude
      }, {
        "latitude": marker4.position.latitude,
        "longitude": marker4.position.longitude
      });
    });
  }

  Future<void> _showInstructionsDialogue() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resizing map'),
          content: const Text('To resize the map hold and drag the markers.'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Got it',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _initializeRectDimensions() {
    if (_currentLatLong != null) {
      LatLng tempStore = _currentLatLong!;
      _maxRectLong =
          min((tempStore.longitude) + initialOffsetFromPlayer, 180.0);
      _minRectLong =
          max((tempStore.longitude) - initialOffsetFromPlayer, -180.0);
      _maxRectLat = min((tempStore.latitude) + initialOffsetFromPlayer, 90.0);
      _minRectLat = max((tempStore.latitude) - initialOffsetFromPlayer, -90.0);
    }
  }

  void _setMarkersFromWantedMap() async {
    LocationData? newLocation;
    try {
      newLocation = await getCurrentLocation();
      if (newLocation == null) {
        throw "Could Not Get Location";
      }
    } on TimeoutException catch (e) {
      debugPrint("Exception: $e");
      showSnackBarMessage(
          "Unable to get location within ${TimingConstants.getLocationTimeout} seconds. Make sure location permissions are enabled.",
          context);
      return;
    } on Exception catch (e) {
      showSnackBarMessage("Error: $e", context);
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentLatLong = LatLng(newLocation!.latitude!, newLocation!.longitude!);

      _showInstructionsDialogue();
    });
    _maxRectLong = -180.0;
    _minRectLong = 180.0;
    _maxRectLat = -90.0;
    _minRectLat = 90.0;
    List<double> longitudes = [
      _wantedMap.mapRegion!.corner1["longitude"]!,
      _wantedMap.mapRegion!.corner2["longitude"]!,
      _wantedMap.mapRegion!.corner3["longitude"]!,
      _wantedMap.mapRegion!.corner4["longitude"]!
    ];
    List<double> latitudes = [
      _wantedMap.mapRegion!.corner1["latitude"]!,
      _wantedMap.mapRegion!.corner2["latitude"]!,
      _wantedMap.mapRegion!.corner3["latitude"]!,
      _wantedMap.mapRegion!.corner4["latitude"]!
    ];
    for (var i = 0; i < longitudes.length; i++) {
      if (longitudes[i] > _maxRectLong) {
        _maxRectLong = longitudes[i];
      }
      if (longitudes[i] < _minRectLong) {
        _minRectLong = longitudes[i];
      }
      if (latitudes[i] > _maxRectLat) {
        _maxRectLat = latitudes[i];
      }
      if (latitudes[i] < _minRectLat) {
        _minRectLat = latitudes[i];
      }
    }
    setState(() {
      _divideByLatitude = _wantedMap.divideByLatitude!;
    });

    _updateMarkerList();
    _updateDrawMinsAndMaxes();
    _updateDrawPolygon();
  }

  //updates the players current latitude and longitude
  void _updateCurrentLatLong() async {
    LocationData? newLocation;
    try {
      newLocation = await getCurrentLocation();
      if (newLocation == null) {
        throw "Could Not Get Location";
      }
    } on TimeoutException catch (e) {
      debugPrint("Exception: $e");
      if (!mounted) return;
      showSnackBarMessage(
          "Unable to get location within ${TimingConstants.getLocationTimeout} seconds. Make sure location permissions are enabled.",
          context); //TODO: make this a better dialogue
      Navigator.of(context).pop();
      return;
    } on Exception catch (e) {
      showSnackBarMessage("Error: $e", context);
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentLatLong = LatLng(newLocation!.latitude!, newLocation!.longitude!);
      _showInstructionsDialogue();
    });

    _initializeRectDimensions();
    _initializeMarkers();
  }

  void _initializeMarkerList() {
    _setMarker("1");
    _setMarker("2");
    _setMarker("3");
    _setMarker("4");
    _updateDrawMinsAndMaxes();
    _updateDrawPolygon();
    _updateWantedMap();
  }

  //this function updates the marker list with the new values based on maxRectLong, minRectLong, etc.
  void _updateMarkerList() {
    _setMarker("1");
    _setMarker("2");
    _setMarker("3");
    _setMarker("4");
    _updateWantedMap();
  }

  void _updateDrawMinsAndMaxes() {
    _drawMinRectLat = 90.0;
    _drawMinRectLong = 180.0;
    _drawMaxRectLat = -90.0;
    _drawMaxRectLong = -180.0;
    List<Marker> markers = [marker1, marker2, marker3, marker4];
    for (var i = 0; i < markers.length; i++) {
      if (markers[i].position.latitude < _drawMinRectLat) {
        _drawMinRectLat = markers[i].position.latitude;
      }
      if (markers[i].position.longitude < _drawMinRectLong) {
        _drawMinRectLong = markers[i].position.longitude;
      }
      if (markers[i].position.latitude > _drawMaxRectLat) {
        _drawMaxRectLat = markers[i].position.latitude;
      }
      if (markers[i].position.longitude > _drawMaxRectLong) {
        _drawMaxRectLong = markers[i].position.longitude;
      }
    }
  }

  void _updateDrawPolygon() {
    _drawPolygons.clear();
    List<LatLng> redTeamPoints = [];
    List<LatLng> blueTeamPoints = [];

    //marker 1 holds max lat and max long
    //marker 2 holds max lat and min long
    //marker 3 holds min lat and min long
    //marker 4 holds min lat and max long
    if (_divideByLatitude == true) {
      //if we're splitting the area in half by latitude.
      LatLng middleMinLong =
          LatLng((_drawMaxRectLat + _drawMinRectLat) / 2, _drawMinRectLong);
      LatLng middleMaxLong =
          LatLng((_drawMaxRectLat + _drawMinRectLat) / 2, _drawMaxRectLong);

      redTeamPoints.add(LatLng(_drawMaxRectLat, _drawMaxRectLong));
      redTeamPoints.add(LatLng(_drawMaxRectLat, _drawMinRectLong));
      redTeamPoints.add(middleMinLong);
      redTeamPoints.add(middleMaxLong);
      redTeamPoints.add(LatLng(_drawMaxRectLat, _drawMaxRectLong));

      blueTeamPoints.add(LatLng(_drawMinRectLat, _drawMinRectLong));
      blueTeamPoints.add(LatLng(_drawMinRectLat, _drawMaxRectLong));
      blueTeamPoints.add(middleMaxLong);
      blueTeamPoints.add(middleMinLong);
      blueTeamPoints.add(LatLng(_drawMinRectLat, _drawMinRectLong));
    } else {
      //dividing by longitude
//if we're splitting the area in half by latitude.
      LatLng middleMinLat =
          LatLng(_drawMinRectLat, (_drawMaxRectLong + _drawMinRectLong) / 2);
      LatLng middleMaxLat =
          LatLng(_drawMaxRectLat, (_drawMaxRectLong + _drawMinRectLong) / 2);

      redTeamPoints.add(LatLng(_drawMaxRectLat, _drawMinRectLong));
      redTeamPoints.add(LatLng(_drawMinRectLat, _drawMinRectLong));
      redTeamPoints.add(middleMinLat);
      redTeamPoints.add(middleMaxLat);

      redTeamPoints.add(LatLng(_drawMaxRectLat, _drawMinRectLong));

      blueTeamPoints.add(LatLng(_drawMaxRectLat, _drawMaxRectLong));
      blueTeamPoints.add(LatLng(_drawMinRectLat, _drawMaxRectLong));
      blueTeamPoints.add(middleMinLat);
      blueTeamPoints.add(middleMaxLat);

      blueTeamPoints.add(LatLng(_drawMaxRectLat, _drawMaxRectLong));
    }

    Polygon redTeamPolygon = Polygon(
      polygonId: const PolygonId("redTeamArea"),
      fillColor: AppConstants.redTeamMapArea,
      visible: true,
      strokeWidth: 0,
      points: redTeamPoints,
    );
    Polygon blueTeamPolygon = Polygon(
      polygonId: const PolygonId("blueTeamArea"),
      fillColor: AppConstants.blueTeamMapArea,
      visible: true,
      strokeWidth: 0,
      points: blueTeamPoints,
    );
    setState(() {
      _drawPolygons.add(redTeamPolygon);
      _drawPolygons.add(blueTeamPolygon);
    });
  }

  void _setMarker(String markerId) {
    _polygonMarkers.clear();
    switch (markerId) {
      case "1":
        marker1 = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(_maxRectLat, _maxRectLong),
          alpha: 1.0,
          draggable: true,
          onDrag: (value) {
            _updateAllOtherMarkers(value, markerId);
          },
          onDragEnd: (value) {
            _updateAllOtherMarkers(value, markerId);
            _updateMarkerList();
            _updateDrawMinsAndMaxes();
            _updateDrawPolygon();
          },
          visible: true,
        );

        break;
      case "2":
        marker2 = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(_maxRectLat, _minRectLong),
          alpha: 1.0,
          draggable: true,
          onDrag: (value) {
            _updateAllOtherMarkers(value, markerId);
          },
          onDragEnd: (value) {
            _updateAllOtherMarkers(value, markerId);
            _updateMarkerList();
            _updateDrawMinsAndMaxes();
            _updateDrawPolygon();
          },
          visible: true,
        );
        break;
      case "3":
        marker3 = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(_minRectLat, _minRectLong),
          alpha: 1.0,
          draggable: true,
          onDrag: (value) {
            _updateAllOtherMarkers(value, markerId);
          },
          onDragEnd: (value) {
            _updateAllOtherMarkers(value, markerId);
            _updateMarkerList();
            _updateDrawMinsAndMaxes();
            _updateDrawPolygon();
          },
          visible: true,
        );
        break;
      case "4":
        marker4 = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(_minRectLat, _maxRectLong),
          alpha: 1.0,
          draggable: true,
          onDrag: (value) {
            _updateAllOtherMarkers(value, markerId);
          },
          onDragEnd: (value) {
            _updateAllOtherMarkers(value, markerId);
            _updateMarkerList();
            _updateDrawMinsAndMaxes();
            _updateDrawPolygon();
          },
          visible: true,
        );
        break;
    }
    setState(() {
      _polygonMarkers.add(marker1);
      _polygonMarkers.add(marker2);
      _polygonMarkers.add(marker3);
      _polygonMarkers.add(marker4);
    });
  }

  //updates all markers except for the one
  void _updateAllOtherMarkers(LatLng newPos, String markerId) {
    //you only have to update the two markers next to you.

    //marker 1 holds max lat and max long
    //marker 2 holds max lat and min long
    //marker 3 holds min lat and min long
    //marker 4 holds min lat and max long
    switch (markerId) {
      case "1":
        _maxRectLat = newPos.latitude;
        _maxRectLong = newPos.longitude;
        _setMarker("2");
        _setMarker("4");
        break;
      case "2":
        _maxRectLat = newPos.latitude;
        _minRectLong = newPos.longitude;
        _setMarker("3");
        _setMarker("1");
        break;
      case "3":
        _minRectLat = newPos.latitude;
        _minRectLong = newPos.longitude;
        _setMarker("2");
        _setMarker("4");
        break;
      case "4":
        _minRectLat = newPos.latitude;
        _maxRectLong = newPos.longitude;
        _setMarker("1");
        _setMarker("3");
        break;
    }
  }

  void _initializeMarkers() {
    _initializeMarkerList();
  }

  @override
  void initState() {
    if (_wantedMap.divideByLatitude == null) {
      _divideByLatitude = true;
    } else {
      _divideByLatitude = _wantedMap.divideByLatitude;
    }
    super.initState();
    if (_wantedMap.mapRegion == null) {
      _updateCurrentLatLong();
    } else {
      _setMarkersFromWantedMap();
    }
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
      body: _currentLatLong == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: _currentLatLong!, zoom: _defaultZoom),
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    markers: _polygonMarkers,
                    polygons: _drawPolygons,
                  ),
                ),
              ],
            ),
      floatingActionButton: _currentLatLong == null
          ? const Center()
          : FloatingActionButton(
              child: const Icon(CupertinoIcons.arrow_swap),
              tooltip: "Swap Split Direction",
              onPressed: () {
                _divideByLatitude = !_divideByLatitude!;
                _wantedMap.divideByLatitude = _divideByLatitude;
                _updateDrawPolygon();
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

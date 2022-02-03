import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/design_constants.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:enhanced_ctf/utils/helpers/show_snackbar.dart';
import 'package:enhanced_ctf/utils/services/get_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'home_screen.dart';

class RequestLocationPermissionScreen extends StatefulWidget {
  var nextPage;

  RequestLocationPermissionScreen(this.nextPage, {Key? key}) : super(key: key);

  @override
  _RequestLocationPermissionScreenState createState() =>
      _RequestLocationPermissionScreenState();
}

const double bottomButtonWidth = 150;
const double bottomButtonHeight = 30;
const TextStyle bottomButtonText = TextStyle(fontSize: 16);
ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.transparent,
    textStyle: bottomButtonText,
    shadowColor: Colors.transparent,
    side: BorderSide.none,
    onPrimary: Color(0xFFda0A65C2));

class _RequestLocationPermissionScreenState
    extends State<RequestLocationPermissionScreen> {
  Future<void> _showAreYouSure(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user doesn't need to tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'You will not be able to use this app if you do not enable location permissions.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No, take me back.'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes, I\'m sure'),
              onPressed: () {
                newPageClearAllPrevious(context, const HomeScreen());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSettingsRequest() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
            'This app needs location access to function correctly. Please enable this within settings.'),
        actions: <Widget>[
          TextButton(
            child: Text('Deny'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
              child: Text('Settings'),
              onPressed: () {
                newPageClearAllPrevious(context, HomeScreen());
                AppSettings.openAppSettings();
              }),
        ],
      ),
    );
  }

  void _turnOnPerms() async {
    Location location = Location();
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        showSnackBarMessage(
            "Error: Location services are not enabled on this device. Please enable location services to continue.",
            context);
        return;
      }
    }
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _showSettingsRequest();
        return;
      }
    } else if (_permissionGranted == PermissionStatus.deniedForever) {}

    newPageReplaceCurrent(context, widget.nextPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.bannerColor,
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: calculateMaxPageHeight(context),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                const Text("Use your location",
                    style: AppConstants.titleTextStyle),
                const SizedBox(height: 10),
                const Text(
                    "ECTF needs to access your location to be able to share it with other players in the game.",
                    textAlign: TextAlign.center,
                    style: AppConstants.bodyTextStyle),
                const SizedBox(height: 15),
                const Text(
                    "For best performance, allow ECTF to access your location in the background as well.",
                    textAlign: TextAlign.center,
                    style: AppConstants.bodyTextStyle),
                Image.asset('assets/images/screenshots/mapExample.png'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: bottomButtonWidth,
                    height: bottomButtonHeight,
                    child: ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        _showAreYouSure(context);
                      },
                      child: const Text("No thanks"),
                    ),
                  ),
                  SizedBox(
                    width: bottomButtonWidth,
                    height: bottomButtonHeight,
                    child: ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        _turnOnPerms();
                      },
                      child: const Text("Turn on"),
                    ),
                  )
                ]),
          ),
          elevation: 0),
    );
  }
}

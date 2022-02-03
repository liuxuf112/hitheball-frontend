import 'package:enhanced_ctf/pages/request_location_permissions_screen.dart';
import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/create_game_screen.dart';
import 'package:enhanced_ctf/pages/join_game_screen.dart';
import 'package:enhanced_ctf/pages/settings_screen.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:location/location.dart';
import '../utils/helpers/design_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppConstants.bgColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(269, 73),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black, width: 3)),
              primary: Colors.white,
              onPrimary: Colors.black,
              shadowColor: Colors.black,
              elevation: 5,
              textStyle:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static AudioCache player = AudioCache(prefix: 'assets/sounds/');

  void _attemptGotoCreateGame() async {
    Location location = Location();
    PermissionStatus locationPerms = await location.hasPermission();
    bool locationStatus = await location.serviceEnabled();

    bool locationEnabled =
        (locationPerms == PermissionStatus.granted) && locationStatus;

    if (locationEnabled) {
      newPageReversible(context, const CreateGameScreen());
    } else {
      newPageReversible(
          context, RequestLocationPermissionScreen(const CreateGameScreen()));
    }
  }

  void _attemptGotoJoinGame() async {
    Location location = Location();
    PermissionStatus locationPerms = await location.hasPermission();

    bool locationEnabled = locationPerms == PermissionStatus.granted;
    if (locationEnabled) {
      newPageReversible(context, const JoinGameScreen());
    } else {
      newPageReversible(
          context, RequestLocationPermissionScreen(const JoinGameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
        backgroundColor: AppConstants.bannerColor,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: calculateMaxPageHeight(context),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*  Padding(
                    padding: const EdgeInsets.only(
                        top: 150.0, right: 5.0, left: 5.0, bottom: 5.0),
                    child: ElevatedButton(
                      child: const Text('Resume Game'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InGameScreen(),
                          ),
                        );
                      },
                    ),
                  ),*/
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text('Create Game'),
                    onPressed: () {
                      _attemptGotoCreateGame();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text('Join Game'),
                    onPressed: () {
                      _attemptGotoJoinGame();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text('Settings'),
                    onPressed: () {
                      newPageReversible(context, const SettingsScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/help_screen.dart';
import '../utils/helpers/design_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppConstants.bgColor,
        ),
        home: const SettingsScreen());
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
        backgroundColor: AppConstants.bannerColor,
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.black,
                      size: 36.0,
                      semanticLabel: 'Help Button',
                    ),
                    tooltip: 'Help',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    '// Settings Screen',
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              )
            ],
          )),
    );
  }
}

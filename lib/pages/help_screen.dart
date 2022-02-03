import 'package:flutter/material.dart';
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
        home: const HelpScreen());
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
        backgroundColor: AppConstants.bannerColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                '// Help Screen',
                style: TextStyle(fontSize: 25),
              ),
            ]),
      ),
    );
  }
}

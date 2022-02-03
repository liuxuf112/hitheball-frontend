import 'package:vibration/vibration.dart';

void normalVibrate() async {
  bool? hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator == true) {
    Vibration.vibrate();
  }
}

import 'package:platform_device_id/platform_device_id.dart';
import './my_game_state.dart';

//returns the device id of this device
class DeviceId {
  static final GameState _gameState = GameState();
  static Future<String?> getDeviceID() async {
    if (_gameState.thisDeviceID != null) {
      return _gameState.thisDeviceID;
    } else {
      String? deviceID = await PlatformDeviceId.getDeviceId;
      _gameState.thisDeviceID = deviceID;
      return deviceID;
    }
  }
}

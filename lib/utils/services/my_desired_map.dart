//instantiated when the user wants to define their own map.
import 'package:enhanced_ctf/classes/region.dart';

class WantedMap {
  //this clas manages an object instance
  static final WantedMap _instance = WantedMap._internal();
  WantedMap._internal();
  // passes the instantiation to the _instance object - no I don't know what this means either
  factory WantedMap() => _instance;

  Region? mapRegion;
  bool? divideByLatitude;
}

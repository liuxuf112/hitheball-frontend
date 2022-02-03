import 'package:enhanced_ctf/utils/helpers/class_constants.dart';

class TeammateInfo {
  TeammateInfo(this.username, this.eliminated, this.classID,
      {this.classString = "", this.hasFlag = false, this.flagNumber = -1}) {
    classString = ClassConstants.classNames[classID]!;
  }
  String username;
  bool hasFlag;
  bool eliminated;
  int flagNumber;
  int classID;
  String classString;
}

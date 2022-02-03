//returns a string if it is a valid ID (case insensitive),
//returns null if not valid.
String? isValidGameId(String gameID) {
  RegExp gameIDReg = RegExp(
    r"^\s*([A-Za-z]{6})\s*$", //matches any 6 character sequence a-z,A-Z, whitespace on either side
  );

  var match = gameIDReg.firstMatch(gameID);
  String? matchedText = match?.group(1).toString().toUpperCase();
  return matchedText;
}

//max username length is 255
String? isValidUserName(String userName) {
  RegExp userNameReg = RegExp(
    r"^\s*([A-Za-z0-9\s]{1,255})\s*$", //a-z and alphanumeric for 1-255 characters. - can change later
  );
  var match = userNameReg.firstMatch(userName);
  String? matchedText = match?.group(1).toString();
  return matchedText;
}

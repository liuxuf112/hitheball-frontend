class TimingConstants {
  static const inGameLoopTime = 1; //3 seconds
  static const sendLocationTime = 1; //how often we send the user location
  static const getMapInfoTime = 1;

  static const checkStartGameTime =
      3; //how often we check if the game is started in waiting for players
  static const showPlayersTime =
      2; //how often we update players on the waiting for players

  static const getTeamTime = 1; //how often we get team on in game screen.

  static const getLocationTimeout =
      5; //how many seconds we will wait before timing out because we can't get user location.
}

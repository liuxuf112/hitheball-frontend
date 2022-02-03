//this file returns the hostname that we will be sending requests to via http

//comment this if you want to test locally
String get hostname {
  return 'hitheball.herokuapp.com';
}

//uncomment this if you want to test locally.
/*
String get hostname {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  } else {
    return 'http://localhost:3000';
  }
}*/

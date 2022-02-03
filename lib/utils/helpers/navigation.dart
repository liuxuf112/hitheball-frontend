import 'package:flutter/material.dart';

//navigate to a new page with the ability to go back.
void newPageReversible(context, newPage) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => newPage,
    ),
  );
}

//new page delete previous page by replacing it. Note you can still navigate two back
void newPageReplaceCurrent(context, newPage) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => newPage),
  );
}

void newPageClearAllPrevious(context, newPage) {
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => newPage), (r) => false);
}

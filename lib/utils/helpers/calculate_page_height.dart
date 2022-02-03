
import 'package:flutter/material.dart';

double calculateMaxPageHeight(context){
  double height = MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                kBottomNavigationBarHeight;//this is important to account for top bar
  if(height < 0){
    return 1;
  }
  return height;
}
import 'package:flutter/material.dart';
import '../classes/location_data.dart';
import './ll_holder.dart';

//this function should return a widget of type Column filled with all the rows of LatLongHolders
//for every item in the locationDataList that is passed to it. Currently it just returns a single
//latLongHolder for the first item in this list. Clearly this is not correct. Look into the column class https://api.flutter.dev/flutter/widgets/Column-class.html
//and also the .map functionality... this post might help: https://stackoverflow.com/questions/55039861/creating-a-list-of-widgets-from-map-with-keys-and-values

class LatLongList extends StatelessWidget {
  final List<LatLngData> locationDataList;

  const LatLongList(this.locationDataList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: Card(
          color: Colors.grey,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: locationDataList.map((i) => LatLongHolder(i)).toList(),
          ),
        ));

    //  return LatLongHolder(locationDataList[0]);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/Funt.dart';
import 'package:weather/SearchPlace.dart';
class LocationManage extends StatefulWidget {
  @override
  _LocationManageState createState() => _LocationManageState();
}

class _LocationManageState extends State<LocationManage> {
  var index = 0;
    @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quan ly vi tri'),
              Row(
                children: [
                  IconButton(onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPlace()));
                  },
                      icon: Icon(Icons.add)),
                  SizedBox(width: 10,),
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                ],
              )
            ],

          ),
        ),
        body: ListView.builder(
          itemCount: selectedPlaces.length,
            itemBuilder: (context, index) {
            final place = selectedPlaces[index];
            return ListTile(
              title: Text(place['name']),
            );
            })
      );
    }
}

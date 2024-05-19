/*

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/constant.dart';
import 'package:weather/SearchPlace.dart';
import 'package:weather/main.dart';


class LocationManage extends StatefulWidget {
  @override
  _LocationManageState createState() => _LocationManageState();
}

class _LocationManageState extends State<LocationManage> {
  bool editMode = false; // Variable to track edit mode
  List<bool> selectedToDelete = []; // List to track selected places for deletion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quản lí vị trí'),
            Row(
              children: [
                IconButton(onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPlace()));
                },
                    icon: Icon(Icons.add)),
                SizedBox(width: 10,),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Toggle edit mode
                      editMode = !editMode;
                      if (!editMode) {
                        // Clear selectedToDelete list when exiting edit mode
                        selectedToDelete = List.generate(selectedPlaces.length, (index) => false);
                      }
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
                SizedBox(width: 10,),
                // Confirm button to delete selected places
                editMode
                    ? IconButton(
                      onPressed: () {
                    // Delete selected places
                      deleteSelectedPlaces();
                      },
                      icon: Icon(Icons.delete_forever_rounded),
                )
                    : Container(),
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
            title: Row(
              children: [
                // Display checkbox only in edit mode
                editMode
                    ? Checkbox(
                  value: selectedToDelete[index],
                  onChanged: (value) {
                    setState(() {
                      selectedToDelete[index] = value!;
                    });
                  },
                )
                    : Container(),
                SizedBox(width: editMode ? 10 : 0), // Add spacing between checkbox and place name
                Text(place['name']),
              ],
            ),
            onTap: () {
              setState(() {
                LocationName = OfficialName(place['name']);
                KeyLocation = Position(
                  latitude: place['latitude'],
                  longitude: place['longitude'],
                  timestamp: DateTime.now(), // You can adjust these values as needed
                  accuracy: 0.0, // Assuming 0.0 as a placeholder
                  altitude: 0.0, // Assuming 0.0 as a placeholder
                  heading: 0.0, // Assuming 0.0 as a placeholder
                  speed: 0.0, // Assuming 0.0 as a placeholder
                  speedAccuracy: 0.0,
                  altitudeAccuracy: 0.0,
                  headingAccuracy: 0.0,
                  // Assuming 0.0 as a placeholder
                );
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  MyApp()));
              });
            },
          );
        },
      ),
    );
  }

  // Function to delete selected places
  void deleteSelectedPlaces() {
    setState(() {
      // Remove selected places from selectedPlaces list
      for (int i = selectedToDelete.length - 1; i >= 0; i--) {
        if (selectedToDelete[i]) {
          selectedPlaces.removeAt(i);
          selectedToDelete.removeAt(i);
        }
      }
      // Exit edit mode after deletion
      editMode = false;
    });
  }
}
*/
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/constant.dart';
import 'package:weather/SearchPlace.dart';
import 'package:weather/main.dart';

class LocationManage extends StatefulWidget {
  @override
  _LocationManageState createState() => _LocationManageState();
}

class _LocationManageState extends State<LocationManage> {
  bool editMode = false; // Variable to track edit mode
  List<bool> selectedToDelete = []; // List to track selected places for deletion

  @override
  void initState() {
    super.initState();
    // Initialize selectedToDelete list based on selectedPlaces length
    selectedToDelete = List.generate(selectedPlaces.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quản lí vị trí'),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPlace()));
                  },
                  icon: Icon(Icons.add),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Toggle edit mode
                      editMode = !editMode;
                      if (!editMode) {
                        // Clear selectedToDelete list when exiting edit mode
                        selectedToDelete = List.generate(selectedPlaces.length, (index) => false);
                      }
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
                SizedBox(width: 10),
                // Confirm button to delete selected places
                editMode
                    ? IconButton(
                  onPressed: deleteSelectedPlaces,
                  icon: Icon(Icons.delete_forever_rounded),
                )
                    : Container(),
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
            title: Row(
              children: [
                // Display checkbox only in edit mode
                editMode
                    ? Checkbox(
                  value: selectedToDelete[index],
                  onChanged: (value) {
                    setState(() {
                      selectedToDelete[index] = value!;
                    });
                  },
                )
                    : Container(),
                SizedBox(width: editMode ? 10 : 0), // Add spacing between checkbox and place name
                Text(place['name']),
              ],
            ),
            onTap: () {
              if (!editMode) {
                setState(() {
                  LocationName = OfficialName(place['name']);
                  KeyLocation = Position(
                    latitude: place['latitude'],
                    longitude: place['longitude'],
                    timestamp: DateTime.now(),
                    accuracy: 0.0,
                    altitude: 0.0,
                    heading: 0.0,
                    speed: 0.0,
                    speedAccuracy: 0.0,
                    altitudeAccuracy: 0.0,
                    headingAccuracy: 0.0,
                  );
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyApp()));
                });
              }
            },
          );
        },
      ),
    );
  }

  // Function to delete selected places
  void deleteSelectedPlaces() {
    setState(() {
      for (int i = selectedToDelete.length - 1; i >= 0; i--) {
        if (selectedToDelete[i]) {
          selectedPlaces.removeAt(i);
          selectedToDelete.removeAt(i);
        }
      }
      // Exit edit mode after deletion
      editMode = false;
    });
  }
}

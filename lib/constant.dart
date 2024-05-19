import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz;
Position? KeyLocation;
Map<String, dynamic> data = {};
List<Map<String, dynamic>> selectedPlaces = [];
String? LocationName;
String? InitialName;
String? type = 'metric';
void initializeTimeZones() {
  tz.initializeTimeZones();
}

String OfficialName(String name) {
  List<String> parts = name.split(',').map((e) => e.trim()).toList();
  return parts[0];
}
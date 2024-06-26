
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:weather/constant.dart';
import 'package:weather/LocationManage.dart';
import 'package:weather/SearchPlace.dart';
import 'package:weather/setting.dart';


void main() {
  runApp(WeatherApp());
}
class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp()
    );
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  Position? currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String? aqiIndex;
  int? aqi;
  @override
  void initState() {
    super.initState();

    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print('Service disable');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // Handle case where user has permanently denied location permission
      print('Location permission denied permanently');
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    currentLocation = await Geolocator.getCurrentPosition();
    if(KeyLocation == null) {
      KeyLocation = currentLocation;
    }
    fetchWeatherData(KeyLocation!.latitude, KeyLocation!.longitude);
    getAQIIndex(KeyLocation!.latitude, KeyLocation!.longitude);
    getLocationName(KeyLocation!.latitude, KeyLocation!.longitude);
    print(KeyLocation!.latitude);
    print(KeyLocation!.longitude);
  }

  Map<String, dynamic> weatherData = {};
  Map<String, dynamic> weatherName = {};
  Map<String, dynamic> weatherInfo = {};
  Future<void> fetchWeatherData(double lat, double lon) async {
    var lat = KeyLocation!.latitude;
    var lon = KeyLocation!.longitude;
    const apikey = "YOUR API KEY";
    final url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&units=$type&appid=$apikey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> getAQIIndex(double lat, double lon) async {
    const appid = 'YOUR API KEY';
    var lat = KeyLocation!.latitude;
    var lon = KeyLocation!.longitude;
    final url = 'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$appid';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200) {
      setState(() {
        weatherInfo = json.decode(response.body);
      });
      aqi = weatherInfo['list'][0]['main']['aqi'];
      switch(aqi) {
        case 1:
          aqiIndex = 'Tốt';
          break;
        case 2:
          aqiIndex = 'Vừa';
          break;
        case 3:
          aqiIndex = 'Trung bình';
          break;
        case 4:
          aqiIndex = 'Kém';
          break;
        case 5:
          aqiIndex = 'Rất kém';
          break;
        default:
          aqiIndex = 'Unknown';
          break;
      }
    } else {
      throw Exception('Failed to load AQI Index');
    }
  }

  Future<void> getLocationName(double lat, double lon) async {
    const key = 'YOUR API KEY';
    final lat = currentLocation?.latitude;
    final lon = currentLocation?.longitude;
    final url =
        'https://revgeocode.search.hereapi.com/v1/revgeocode?at=$lat,$lon&apiKey=$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherName = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Fail to load Location name');
    }
    if(LocationName == null) {
      LocationName = weatherName.isNotEmpty ? weatherName["items"][0]["address"]["city"] : "";
    }
    InitialName = weatherName.isNotEmpty ? weatherName["items"][0]["address"]["city"] : "";
  }

  String formatEpochTimeToTime(int epochTime ) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }


  String getDayName(int epochTime) {
    DateTime dateTime =
    DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    List<String> weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return weekdays[dateTime.weekday - 1];
  }
  String getWeatherIconPath(String iconCode) {
    return 'assets/svgs/$iconCode.svg';
  }


  void getDataForSelectedPlace(Map<String, dynamic> place) {
    LocationName = place['name'];
    final lat = place['latitude'];
    final lon = place['longitude'];
    fetchWeatherData(lat, lon);
    getAQIIndex(lat, lon);
    getLocationName(lat, lon);
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Weather Forecast'),
          ),
          backgroundColor: Color(0xFFEFEFEF),
          drawer: Drawer(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 70),
                child: Wrap(
                  runSpacing: 10,
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text('Vị trí hiện tại'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 52.0),
                      title: Text('$InitialName'),
                        onTap: () {
                          setState(() {
                            LocationName = InitialName;
                            KeyLocation = null;
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  MyApp()));
                          });
                        }
                    ),
                    ListTile(
                        leading: Icon(Icons.location_searching_sharp),
                        title: Text('Vị trí khác'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SearchPlace()));
                        }
                    ),
                    ...selectedPlaces.map((place) {
                      return ListTile(
                        contentPadding: EdgeInsets.only(left: 52.0),
                        title: Text(place['name']),
                        onTap: () {
                          // Thực hiện hành động khi bấm vào địa điểm, ví dụ hiển thị thông tin chi tiết
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

                        },
                      );
                    }).toList(),
                    ListTile(
                      leading: Icon(Icons.notes_outlined),
                      title: Text('Quản lí vị trí'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LocationManage()));
                      },
                    ),
                    Divider(color: Colors.black54,),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Cài đặt'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Setting()));
                      },
                    )

                  ],
                ),
              ),
            ),
          ),


          body: weatherData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                // Current Weather
                    SizedBox(height: 10,),
                  Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ListTile(
                        title: Text('Thời tiết hiện tại'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${weatherData['current']['temp']}\u00B0', style: TextStyle(fontSize: 50),),
                            Text('Cảm giác như ${weatherData['current']['feels_like']}\u00B0'),
                            Text('$LocationName', style: TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),
                      ),
                      const SizedBox(width: 0),
                      SvgPicture.asset(getWeatherIconPath(weatherData['current']['weather'][0]['icon']), height: 150, width: 150),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                // Hourly Forecast
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text('Dự báo 48 giờ'),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            weatherData['hourly'].length,
                                (index){
                              double popValue = double.parse(weatherData['hourly'][index]['pop'].toString());
                              int pop1 = (popValue*100).round();
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text('${formatEpochTimeToTime(weatherData['hourly'][index]['dt'])}'),
                                    SvgPicture.asset(getWeatherIconPath(weatherData['hourly'][index]['weather'][0]['icon']), width: 50, height: 50,),
                                    Text('${weatherData['hourly'][index]['temp']}\u00B0'),
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/svgs/pop.svg", width: 15, height: 15,),
                                        Text(' $pop1%'),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }


                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: ListTile(
                    title: Text('Dự báo hàng ngày'),
                    subtitle: Column(
                      children: List.generate(
                        weatherData['daily'].length,
                            (index) {
                          // Lấy các giá trị từ weatherData
                          final dayName = getDayName(weatherData['daily'][index]['dt']);
                          var maxTemp = double.parse(weatherData['daily'][index]['temp']['max'].toString());
                          var minTemp = double.parse(weatherData['daily'][index]['temp']['min'].toString());
                          final weatherIcon = weatherData['daily'][index]['weather'][0]['icon'];
                          var pop = double.parse(weatherData['daily'][index]['pop'].toString());

                          int max = maxTemp.round();
                          int min = minTemp.round();
                          int pop1 = (pop*100).round();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: (MediaQuery.of(context).size.width-20)/10*3,
                                    child: Text('$dayName', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Container(

                                      width: (MediaQuery.of(context).size.width-20)/10*1.5,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/svgs/pop.svg', width: 15),
                                          Text(' $pop1%'),
                                        ],
                                      )
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width-20)/10*2,
                                    child: SvgPicture.asset(getWeatherIconPath(weatherIcon), width: 35, height: 35,) ,
                                  ),
                                  Container(
                                    //width: (MediaQuery.of(context).size.width-20)*,
                                    child: Row(
                                      children: [
                                        Container(
                                          width:(MediaQuery.of(context).size.width-20)/10*1.2,
                                          child: Text('$max\u00B0', style: TextStyle(fontWeight: FontWeight.bold),),
                                        ),
                                        Container(
                                          width:(MediaQuery.of(context).size.width-20)/10*1,
                                          child: Text('$min\u00B0', style: TextStyle(fontWeight: FontWeight.bold),),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),

                  ),
                  child: Row(

                    children: [
                      Expanded(child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        width: (MediaQuery.of(context).size.width - 20)/2,
                        child: Column(
                          children: [
                            Text('Bình Minh', style: TextStyle(fontWeight: FontWeight.bold),),
                            Text('${formatEpochTimeToTime(weatherData['current']['sunrise'])}',style: TextStyle(fontWeight: FontWeight.bold)),
                            SvgPicture.asset("assets/svgs/sunrise.svg", width: 70, height: 70),

                          ],
                        ),
                      ),
                      ),
                      Expanded(child: Container(
                        width: (MediaQuery.of(context).size.width - 20)/2,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Text('Hoàng Hôn', style: TextStyle(fontWeight: FontWeight.bold),),
                            Text('${formatEpochTimeToTime(weatherData['current']['sunset'])}', style: TextStyle(fontWeight: FontWeight.bold),),
                            SvgPicture.asset("assets/svgs/sunset.svg", width: 70, height: 70,)
                          ],
                        ),
                      ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),

                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.only(left: 20),
                            child:
                            Column(
                              children: [
                                Text('Chỉ số UV', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 10,),
                                SvgPicture.asset('assets/svgs/uvindex.svg', width: 50, height: 50),
                                SizedBox(height: 8,),
                                Text('${weatherData['current']['uvi']}'),
                              ],
                            )
                        ),),
                        Expanded(child: Container(
                            child:
                            Column(
                              children: [
                                Text('Độ ẩm', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 10,),
                                SvgPicture.asset('assets/svgs/humidity.svg', width: 50, height: 50),
                                SizedBox(height: 8,),
                                Text('${weatherData['current']['humidity']}%'),
                              ],
                            )
                        ),),
                        Expanded(child:
                        Container(
                            padding: EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                const Text('Gió', style: TextStyle(fontWeight: FontWeight.bold),),
                                const SizedBox(height: 10,),
                                SvgPicture.asset('assets/svgs/wind.svg', width: 50, height: 50,),
                                const SizedBox(height: 8,),
                                Text('${weatherData['current']['wind_speed']} km/h'),
                              ],
                            )
                        ))
                      ]

                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/svgs/aqi.svg', width: 15),
                          Text(' AQI: $aqiIndex')
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/svgs/pressure.svg', width: 15,),
                          Text(' Áp lực không khí: ${weatherData['current']['pressure']}nPa'),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/svgs/cloudiness.svg', width: 15,),
                          Text(' Mây: ${weatherData['current']['clouds']}%'),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/svgs/visibility.svg', width: 15,),
                          Text(' Tầm nhìn xa: ${weatherData['current']['visibility']}m'),
                        ],
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('  '),
                        SvgPicture.asset('assets/svgs/openweather.svg', height: 15,),
                        const Text(' OpenWeatherMap', style: TextStyle(fontSize: 10, color: Colors.black54),)
                      ],
                    ),
                    Row(
                      children: [
                        Text('Cập nhật lúc ${formatEpochTimeToTime(weatherData['current']['dt'])}   ', style: TextStyle(fontSize: 10),),
                      ],
                    )

                  ],
                )
              ],

            ),
          )
      ),
    );
  }
}

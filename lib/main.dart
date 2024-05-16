/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> weatherData = {};

  Future<void> fetchWeatherData() async {
    const url = 'https://api.openweathermap.org/data/3.0/onecall?lat=21.03535252772096&lon=105.7853959007434&exclude=minutely&appid=0b5445878adb432729cff07122664073';
    */
/*final response = await http.get(
        'https://api.openweathermap.org/data/3.0/onecall?lat=21.03535252772956&lon=105.78539590075643&exclude=minutely&appid=0b5445878adb432729cff07122664073' as Uri);*//*

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: weatherData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather
              ListTile(
                title: Text('Current Weather'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Temperature: ${weatherData['current']['temp']}'),
                    Text(
                        'Feels Like: ${weatherData['current']['feels_like']}'),
                    Text('Pressure: ${weatherData['current']['pressure']}'),
                    Text('Humidity: ${weatherData['current']['humidity']}'),
                    Text('Weather: ${weatherData['current']['weather'][0]['icon']}'),
                  ],
                ),
              ),
              // Hourly Forecast
              ListTile(
                title: Text('Hourly Forecast'),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      weatherData['hourly'].length,
                          (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Time: ${weatherData['hourly'][index]['dt']}'),
                            Text('Temperature: ${weatherData['hourly'][index]['temp']}'),
                            Text('Feels Like: ${weatherData['hourly'][index]['feels_like']}'),
                            Text('Weather: ${weatherData['hourly'][index]['weather'][0]['icon']}'),
                            Text('POP: ${weatherData['hourly'][index]['pop']}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Daily Forecast
              ListTile(
                title: Text('Daily Forecast'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    weatherData['daily'].length,
                        (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${weatherData['daily'][index]['dt']}'),
                        Text('Max Temperature: ${weatherData['daily'][index]['temp']['max']}'),
                        Text('Min Temperature: ${weatherData['daily'][index]['temp']['min']}'),
                        Text('Weather: ${weatherData['daily'][index]['weather'][0]['icon']}'),
                        Text('POP: ${weatherData['daily'][index]['pop']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/


//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather/Funt.dart';
import 'package:http/http.dart' as http;
import 'package:weather/LocationManage.dart';
import 'package:weather/SearchPlace.dart';


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

  String? LocationName;
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
    x = currentLocation;
    fetchWeatherData();
    getLocationName();
    getAQIIndex();
  }

  Map<String, dynamic> weatherData = {};
  Map<String, dynamic> weatherName = {};
  Map<String, dynamic> weatherInfo = {};
  Future<void> fetchWeatherData() async {
    var lat = currentLocation!.latitude;
    var lon = currentLocation!.longitude;
    const apikey = "28c97c05a7641193a30bef73a87ff415";
    final url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&units=metric&appid=$apikey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> getAQIIndex() async {
    const appid = '0b5445878adb432729cff07122664073';
    var lat = currentLocation!.latitude;
    var lon = currentLocation!.longitude;
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


  Future<void> getLocationName() async {
    const key = 't8j30ZcKTjahgwuPbHRDWmqx1JXdaBg4Lz7a82tixWs';
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
    LocationName = weatherName.isNotEmpty ? weatherName["items"][0]["address"]["city"] : "";
  }

  String formatEpochTimeToTime(int epochTime) {
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

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Forecast'),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Wrap(
                runSpacing: 16,
                children: [
                  ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Vị trí hiện tại'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 52.0),
                    title: Text('$LocationName'),
                    onTap: () =>Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  MyApp())),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_searching_sharp),
                    title: Text('Vị trí khác'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SearchPlace()));
                    }
                  ),
                  ListTile(
                    leading: Icon(Icons.add_alarm),
                    title: Text('sample'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (contex) => LocationManage()));
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
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                  color: Colors.black12,
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
                //padding: EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  color: Colors.black12,
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
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: ListTile(
                  title: Text('Dự báo hàng ngày'),
                  subtitle: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: Colors.black12,
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
                  color: Colors.black12,
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
                  color: Colors.black12,
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

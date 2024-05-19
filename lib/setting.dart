
import 'package:flutter/material.dart';
import 'package:weather/constant.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Setting();

 }

 class _Setting extends State<Setting> {
  String title = 'Đơn vị';
  String item1 = '\u00B0C';
  String item2 = '\u00B0F';

  @override
   Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
        backgroundColor: Color(0xFFEFEFEF),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListTile(
                title: Text(title),
                trailing: PopupMenuButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  color: Colors.white,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Text(item1),
                        value: 'metric'),
                    PopupMenuItem(
                      child: Text(item2),
                      value: 'standard',)
                  ],
                  onSelected: (String newValue) {
                    setState(() {
                      type = newValue;
                    });
                  },
                )
            ),
          ),
          Spacer(),

          Divider(color: Colors.lightBlueAccent,),

          Container(

            child: Text('Tác giả: minhduonq'),
          ),
          SizedBox(height: 10,),
          Container(
            child: Text('Made in Hai Duong - Viet Nam'),
          ),
          Container(
            child: Text('University of Engineering and Technology'),
          ),
          Container(
            child: Text('Spring 2024 - Software Engineering'),
          )
        ],
      )
    );
  }
 }
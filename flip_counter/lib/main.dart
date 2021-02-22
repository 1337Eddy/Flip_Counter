import 'package:flip_counter/bottombar.dart';
import 'package:flutter/material.dart';
//import 'package:esense_flutter/esense.dart';

void main() {
  print('App startet');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BottomBar());
  }
}

import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataObject {
  int flips;
  DateTime date;
  String duration;
}

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Text text = new Text("nicht verbunden");
  Timer timer;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: 100), callback);
  }

  void callback(Timer timer) {
    setState(() {
      if (ESenseManager().connected) {
        text = new Text("Verbunden");
      } else {
        text = new Text("Nicht verbunden");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[text]);
  }
}

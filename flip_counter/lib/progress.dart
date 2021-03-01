import 'package:flip_counter/CounterStorage.dart';
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
  CounterStorage storage = new CounterStorage();
  List<Text> values = [];

  void setValues() {
    setState(() {
      storage.readTraining().then((value) => values);
    });
  }

  @override
  void initState() {
    setValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: values,
    );
  }
}

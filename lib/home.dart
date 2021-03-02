import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stopwatch time = new Stopwatch();
  bool isStarted = false;

  void startTraining() {
    setState(() {
      isStarted = !isStarted;
      if (isStarted) {
        time.reset();
        time.start();
        var receivePort = new ReceivePort();
        //Isolate.spawn(updateText(), receivePort);
        //updateText();
      } else {
        time.stop();
      }
    });
  }

  updateText() async {
    while (isStarted) {
      setState(() {});
    }
  }

  String getTextByState() {
    if (isStarted) {
      return 'Stop';
    } else {
      return 'Start';
    }
  }

  Color getColorByState() {
    if (isStarted) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: startTraining,
          child: Text(getTextByState(),
              style: TextStyle(fontSize: 40, color: Colors.black)),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(getColorByState()),
          ),
        ),
        SizedBox(height: 30.0),
        Text(
          '${time.elapsed}',
          textScaleFactor: 3,
        )
      ],
    )));
  }
}

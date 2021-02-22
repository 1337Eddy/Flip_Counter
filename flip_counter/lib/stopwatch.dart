import 'package:flutter/material.dart';
import 'timertext.dart';
import 'dart:async';

enum ButtonLabel { start, stop, reset }

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle =
      const TextStyle(fontSize: 90.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerPage extends StatefulWidget {
  TimerPage({Key key}) : super(key: key);

  TimerPageState createState() => new TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  int front = 0;
  int back = 0;
  double frequency = 0;
  Timer timer;

  final Dependencies dependencies = new Dependencies();

  void resetPressed() {
    setState(() {
      dependencies.stopwatch.stop();
      dependencies.stopwatch.reset();
      front = 0;
      back = 0;
    });
  }

  void startStopPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  Widget buildFloatingButton(ButtonLabel text, VoidCallback callback) {
    TextStyle roundTextStyle =
        const TextStyle(fontSize: 35.0, color: Colors.white);
    switch (text) {
      case ButtonLabel.start:
        return new ElevatedButton(
            child: new Text("Start", style: roundTextStyle),
            onPressed: callback,
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green)));
      case ButtonLabel.stop:
        return new ElevatedButton(
            child: new Text("Pausieren", style: roundTextStyle),
            onPressed: callback,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red)));
      case ButtonLabel.reset:
        return new ElevatedButton(
            child: new Text("Beenden", style: roundTextStyle),
            onPressed: callback,
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange)));
      default:
        throw Error();
    }
  }

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: 100), callback);
    super.initState();
  }

  void callback(Timer timer) {
    int time = dependencies.stopwatch.elapsedMilliseconds;
    double seconds = time / 1000;
    double minutes = seconds / 60;

    setState(() {
      if (minutes == 0) {
        frequency = 0;
      } else {
        frequency = double.parse(((front + back) / minutes).toStringAsFixed(2));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(fontSize: 20.0, color: Colors.black);
    return new Column(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
            child: new Column(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 10),
              child: new TimerText(dependencies: dependencies),
            ),
            new Text("Dauer", style: textStyle),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Text("Frontflips", style: textStyle),
                      new Text(front.toString(), style: textStyle),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Text("Backflips", style: textStyle),
                      new Text(back.toString(), style: textStyle),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Text("Flips pro Minute", style: textStyle),
                      new Text(frequency.toString(), style: textStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )),

        //new SizedBox(height: 10),
        new Expanded(
          flex: 0,
          child: new Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingButton(
                    dependencies.stopwatch.isRunning
                        ? ButtonLabel.stop
                        : ButtonLabel.start,
                    startStopPressed),
                buildFloatingButton(ButtonLabel.reset, resetPressed),
              ],
            ),
          ),
        ),

        new Expanded(
          flex: 0,
          child: new Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new ElevatedButton(
                  child: new Text("Front"),
                  onPressed: addfront,
                ),
                new ElevatedButton(
                  child: new Text("Back"),
                  onPressed: addback,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  addfront() {
    setState(() {
      front++;
    });
  }

  addback() {
    setState(() {
      back++;
    });
  }
}

import 'package:esense_flutter/esense.dart';
import 'package:flip_counter/esense.dart';
import 'package:flip_counter/settings.dart';
import 'package:flutter/material.dart';
import 'timertext.dart';
import 'dart:async';

enum ButtonLabel { start, stop, reset }

enum FlipPhase { phase1, frontPhase2, backPhase2, frontPhase3, backPhase3 }

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
  ESense esense;
  StreamSubscription subscription;
  List<List<int>> fifo;
  FlipPhase flipPhase = FlipPhase.phase1;

  final Dependencies dependencies = new Dependencies();

  void resetPressed() {
    setState(() {
      dependencies.stopwatch.stop();
      dependencies.stopwatch.reset();
      front = 0;
      back = 0;
    });
  }

/*
  void detectFlip() {
    if (dependencies.stopwatch.isRunning) {
      ESenseManager().setSamplingRate(20);
      subscription = ESenseManager().sensorEvents.listen((event) {
        fifo.add(event.accel);
        fifo.removeAt(0);
        analysePattern();
      });
    }
  }

  void analysePattern() {
    flipPhase = FlipPhase.phase1;
    for (int i = 0; i < fifo.length; i++) {
      switch (flipPhase) {
        case FlipPhase.phase1:
          if (fifo[i][0] > 0) {
            flipPhase = FlipPhase.frontPhase2;
          }
          break;
        case FlipPhase.frontPhase2:
          if (fifo[i][0] > 500) {
            flipPhase = FlipPhase.frontPhase3;
          }
          break;
        case FlipPhase.frontPhase3:
          if (fifo[i][0] < 0) {
            addfront();
          }
          break;
        default:
      }
      if (fifo[i][0] / 10 == 3) {}
    }
  }
*/
  void startStopPressed() {
    setState(() {
      if (!dependencies.stopwatch.isRunning &&
          esense.status == Status.CONNECTED) {
        dependencies.stopwatch.start();
      } else {
        dependencies.stopwatch.stop();
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
            child: new Text("Stop", style: roundTextStyle),
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

  void initFifo() {
    for (int i = 0; i < 30; i++) {
      List<int> zero = [0, 0, 0];
      fifo.add(zero);
    }
  }

  @override
  void initState() {
    initFifo();
    timer = new Timer.periodic(new Duration(milliseconds: 100), callback);
    esense = new ESense(DefaultSettings.eSenseName);
    esense.connectToEsense();
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

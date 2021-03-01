import 'package:esense_flutter/esense.dart';
import 'package:flip_counter/CounterStorage.dart';
import 'package:flutter/material.dart';
import 'timertext.dart';
import 'dart:async';

enum ButtonLabel { start, stop, reset }

enum States { start, f1, f2, f3, front, back }

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
  StreamSubscription subscription;
  States state = States.start;
  int countValues = 0;

  final Dependencies dependencies = new Dependencies();

  void resetPressed() {
    var connected = ESenseManager().isConnected();
    connected.then((connect) => {
          setState(() {
            if (connect) {
              subscription.cancel();
            }
          })
        });

    setState(() {
      dependencies.stopwatch.stop();
      String data = dependencies.stopwatch.toString() + "$front";
      CounterStorage storage = new CounterStorage();
      storage.writeTraining(data);
      dependencies.stopwatch.reset();
      front = 0;
      back = 0;
    });
  }

  void listenToSensorEvents() async {
    ESenseManager().setSamplingRate(20);
    var connected = ESenseManager().isConnected();
    connected.then((value) => {
          subscription = ESenseManager().sensorEvents.listen(
            (event) {
              List<int> values = event.accel;
              int x = values[0];
              int y = values[1];
              int z = values[2];
              int valueRefreshed = 25;

              // Conditions
              bool startToF1 = x < -20000;
              bool toBack = x < -15000;
              bool toFront = x < -20000;
              bool f1ToF2 = x > 15000 && y > 20000 && z < -15000;
              bool f1ToF3 = x > 25000 && y > 9000 && z < -15000;
              bool f2ToF3;
              bool f3ToF4;

              switch (state) {
                case States.start:
                  if (startToF1) {
                    state = States.f1;
                  } else {
                    state = States.start;
                    countValues = 0;
                  }
                  break;

                case States.f1:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (f1ToF2) {
                    countValues = 0;
                    state = States.f2;
                  } else if (f1ToF3) {
                    state = States.f3;
                  } else {
                    state = States.f1;
                  }
                  countValues++;
                  break;

                case States.f2:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (toBack) {
                    countValues = 0;
                    state = States.back;
                  } else {
                    state = States.f2;
                  }
                  countValues++;
                  break;

                case States.f3:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (toFront) {
                    countValues = 0;
                    state = States.front;
                  } else {
                    state = States.f3;
                  }
                  countValues++;
                  break;

                case States.front:
                  state = States.start;
                  countValues = 0;
                  setState(() {
                    front++;
                  });
                  break;

                case States.back:
                  setState(() {
                    back++;
                  });
                  state = States.start;
                  break;
              }
            },
          )
        });
  }

  void startStopPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
        subscription.cancel();
      } else {
        dependencies.stopwatch.start();
        listenToSensorEvents();
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

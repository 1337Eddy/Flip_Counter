import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

enum States { start, q1, q2, q3, front, back }

class DefaultSettings {
  static String eSenseName = 'eSense-0264';
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  bool connected = false;
  int counter = 0;
  String buttonPress = "not tabbed";
  int buttonPressCounter = 0;
  int countValues = 0;

  List<DataRow> rows = [];

  // the name of the eSense device to connect to -- change this to your own device.

  String _xAxis = "null";
  String _yAxis = "null";
  String _zAxis = "null";
  String sensorConfig = "undefined";
  int front = 0;
  int back = 0;

  States state = States.start;

  StreamSubscription subscription;

  Timer timer;

  void initState() {
    _listenToESense();
    //listenToSensorEvents();

    super.initState();
  }

  Future _listenToESense() async {
    // if you want to get the connection events when connecting,
    // set up the listener BEFORE connecting...
    ESenseManager().connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) {
        _listenToESenseEvents();
      }

      setState(() {
        connected = false;
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            connected = true;
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }
/*
  Future _connectToESense() async {
    if (!connected)
      connected = await ESenseManager().connect(DefaultSettings.eSenseName);
    setState(() {
      _deviceStatus = connected ? 'connecting' : 'connection failed';
    });
  }
*/

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
              bool startToQ1 = x < -20000;
              bool toBack = x < -15000;
              bool toFront = x < -20000;
              bool q1ToQ2 = x > 15000 && y > 20000 && z < -15000;
              bool q1ToQ3 = x > 25000 && y > 9000 && z < -15000;

              switch (state) {
                case States.start:
                  if (startToQ1) {
                    state = States.q1;
                  } else {
                    state = States.start;
                    countValues = 0;
                  }
                  break;

                case States.q1:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (q1ToQ2) {
                    countValues = 0;
                    state = States.q2;
                  } else if (q1ToQ3) {
                    state = States.q3;
                  } else {
                    state = States.q1;
                  }
                  countValues++;
                  break;

                case States.q2:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (toBack) {
                    countValues = 0;
                    state = States.back;
                  } else {
                    state = States.q2;
                  }
                  countValues++;
                  break;

                case States.q3:
                  if (countValues > valueRefreshed) {
                    state = States.start;
                  } else if (toFront) {
                    countValues = 0;
                    state = States.front;
                  } else {
                    state = States.q3;
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
              setState(() {
                _xAxis = values[0].toString();
                _yAxis = values[1].toString();
                _zAxis = values[2].toString();

                rows.add(DataRow(cells: [
                  DataCell(Text("$_xAxis")),
                  DataCell(Text("$_yAxis")),
                  DataCell(Text("$_zAxis")),
                ]));
              });
            },
          )
        });
  }

  void _listenToESenseEvents() async {
    ESenseManager().setSamplingRate(20);
    ESenseManager().eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
          case AccelerometerOffsetRead:
            break;
          case AdvertisementAndConnectionIntervalRead:
            // TODO
            break;
          case SensorConfigRead:
            sensorConfig = (event as SensorConfigRead).toString();
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(
      Duration(seconds: 10),
      (timer) async =>
          (connected) ? await ESenseManager().getBatteryVoltage() : null,
    );

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(Duration(seconds: 2),
        () async => await ESenseManager().getDeviceName());
    Timer(Duration(seconds: 3),
        () async => await ESenseManager().getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
        () async =>
            await ESenseManager().getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
        () async => await ESenseManager().getSensorConfig());
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Padding(
                padding: const EdgeInsets.symmetric(vertical: 55.0),
                child: TextFormField(
                  initialValue: DefaultSettings.eSenseName,
                  onChanged: (text) {
                    DefaultSettings.eSenseName = text;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Gerätename'),
                )),
            Center(
                child: new Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text('Geräte Status: \t$_deviceStatus'))),
            Center(
              child: new Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Batterie Status: \t$_voltage'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: new Text("Start"),
                    onPressed: listenToSensorEvents,
                  ),
                  ElevatedButton(
                    child: new Text("Stop"),
                    onPressed: () => {subscription.pause()},
                  ),
                  ElevatedButton(
                    child: new Text("Delete Table"),
                    onPressed: () => setState(() {
                      rows = [];
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('x-Achse: \t$_xAxis'),
                  Text('y-Achse: \t$_yAxis'),
                  Text('z-Achse: \t$_zAxis'),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Frontflip: \t$front'),
                  Text('Backflip: \t$back'),
                ],
              ),
            ),
            Center(
              child: DataTable(columns: [
                DataColumn(label: Text("x-Achse")),
                DataColumn(label: Text("y-Achse")),
                DataColumn(label: Text("z-Achse"))
              ], rows: rows),
            )
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

enum States { start, f1, f2, f3, f4, b1, b2, b3, b4, b5, front, back }

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
  String _event = '';
  String _button = 'not pressed';
  bool connected = false;
  int counter = 0;
  String buttonPress = "not tabbed";
  int buttonPressCounter = 0;

  // the name of the eSense device to connect to -- change this to your own device.

  String _xAxis = "undefined";
  String _yAxis = "undefined";
  String _zAxis = "undefined";
  String sensorConfig = "undefined";
  int front = 0;
  int back = 0;
  Text text = new Text("Start");

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
    //subscription.cancel();
    ESenseManager().setSamplingRate(20);
    var connected = ESenseManager().isConnected();
    connected.then((value) => {
          subscription = ESenseManager().sensorEvents.listen(
            (event) {
              List<int> values = event.accel;
              int x = values[0];
              int y = values[1];
              switch (state) {
                case States.start:
                  if (x > 20000 && y > 20000) {
                    state = States.front;
                  } else {
                    state = States.start;
                  }
                  break;

                case States.front:
                  if (x > 20000 && y > 20000) {
                    state = States.front;
                  } else {
                    state = States.start;
                  }
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
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
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
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('eSense Device Status: \t$_deviceStatus'),
        Text('eSense Battery Level: \t$_voltage'),
        Text('xAxis: \t$_xAxis'),
        Text('yAxis: \t$_yAxis'),
        Text('zAxis: \t$_zAxis'),
        Text('\t$_button'),
        TextFormField(
          initialValue: DefaultSettings.eSenseName,
          onChanged: (text) {
            DefaultSettings.eSenseName = text;
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'Gerätename'),
        ),
        ElevatedButton(
          child: text,
          onPressed: listenToSensorEvents,
        ),
        ElevatedButton(
          child: new Text("Unsubscribe"),
          onPressed: () => {subscription.cancel()},
        ),
        Text('Front: \t$front'),
        Text('Back: \t$back'),
        Text('Status: \t $buttonPress'),
      ],
    );
  }
}

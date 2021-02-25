import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

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

  // the name of the eSense device to connect to -- change this to your own device.

  String _xAxis = "undefined";
  String _yAxis = "undefined";
  String _zAxis = "undefined";
  String sensorConfig = "undefined";
  int counterA = 0;
  int counterB = 0;

  StreamSubscription subscription;

  Timer timer;

  void initState() {
    super.initState();
    _listenToESense();
  }

  Future _listenToESense() async {
    // if you want to get the connection events when connecting,
    // set up the listener BEFORE connecting...
    ESenseManager().connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

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

  Future _connectToESense() async {
    print('connecting... connected: $connected');
    if (!connected)
      connected = await ESenseManager().connect(DefaultSettings.eSenseName);
    print("Connected in Settings $connected");
    setState(() {
      _deviceStatus = connected ? 'connecting' : 'connection failed';
    });
  }

  void listenToSensorEvents() async {
    if (ESenseManager().connected) {
      subscription = ESenseManager().sensorEvents.listen((event) {
        List<int> values = event.accel;
        setState(() {
          _xAxis = (values[0] / 10).toString();
          _yAxis = (values[1] / 10).toString();
          _zAxis = (values[2] / 10).toString();
        });
      });
    }
  }

  void _listenToESenseEvents() async {
    ESenseManager().eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            counterB++;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            break;
          case AccelerometerOffsetRead:
            listenToSensorEvents();
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

  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager().sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
        _event = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager().disconnect();
    super.dispose();
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
        Text('$_event'),
        Container(
          height: 40,
          width: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: TextButton.icon(
            onPressed: _connectToESense,
            icon: Icon(Icons.login),
            label: Text(
              'connect',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      ],
    );
  }
}

/*
floatingActionButton: FloatingActionButton(
          // a floating button that starts/stops listening to sensor events.
          // is disabled until we're connected to the device.
          onPressed: (!ESenseManager().connected)
              ? null
              : (!sampling)
                  ? _startListenToSensorEvents
                  : _pauseListenToSensorEvents,
          tooltip: 'Listen to eSense sensors',
          child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
        )
*/

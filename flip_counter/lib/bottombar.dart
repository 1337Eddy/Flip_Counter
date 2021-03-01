import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flip_counter/settings.dart';
import 'package:flip_counter/stopwatch.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  Timer timer;

  IconButton bluetoothSymbol = new IconButton(
    onPressed: () => ESenseManager().connect(DefaultSettings.eSenseName),
    icon: new Icon(Icons.bluetooth_disabled),
  );

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[TimerPage(), Settings()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> setBluethoothIcon(Timer timer) async {
    var connected = ESenseManager().isConnected();
    connected.then((connect) => {
          setState(() {
            if (connect) {
              bluetoothSymbol = new IconButton(
                icon: new Icon(Icons.bluetooth_connected),
              );
            } else {
              bluetoothSymbol = new IconButton(
                onPressed: () =>
                    ESenseManager().connect(DefaultSettings.eSenseName),
                icon: new Icon(Icons.bluetooth_disabled),
              );
            }
          })
        });
  }

  @override
  void initState() {
    timer =
        new Timer.periodic(new Duration(milliseconds: 500), setBluethoothIcon);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flip Counter'), actions: <Widget>[
        bluetoothSymbol,
      ]),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

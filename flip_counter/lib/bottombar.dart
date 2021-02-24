import 'dart:async';

import 'package:flip_counter/CounterStorage.dart';
import 'package:flip_counter/esense.dart';
import 'package:flip_counter/progress.dart';
import 'package:flip_counter/settings.dart';
import 'package:flip_counter/stopwatch.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  ESense esense;
  Timer timer;

  IconButton bluetoothSymbol = new IconButton(
    icon: const Icon(Icons.bluetooth_disabled),
  );

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    TimerPage(),
    ProgressPage(),
    Settings()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setBluethoothIcon(Timer timer) {
    setState(() {
      if (esense.status == "connected") {
        bluetoothSymbol =
            new IconButton(icon: const Icon(Icons.bluetooth_audio));
      } else {
        bluetoothSymbol =
            new IconButton(icon: const Icon(Icons.bluetooth_disabled));
        esense.connectToEsense();
      }
    });
  }

  @override
  void initState() {
    esense = new ESense(DefaultSettings.eSenseName);
    esense.connectToEsense();

    timer =
        new Timer.periodic(new Duration(milliseconds: 100), setBluethoothIcon);
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
            icon: Icon(Icons.insights),
            label: 'Fortschritt',
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

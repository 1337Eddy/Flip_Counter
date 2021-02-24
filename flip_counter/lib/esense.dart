import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

class ESense {
  bool connected = false;
  String eSenseName;
  int samplingRate = 10;
  String status;

  ESense(String eSenseName) {
    this.eSenseName = eSenseName;
  }

  Future connectToEsense() async {
    if (!connected) {
      connected = await ESenseManager().connect(eSenseName);
    }

    ESenseManager().connectionEvents.listen((event) {
      connected = false;
      switch (event.type) {
        case ConnectionType.connected:
          status = 'connected';
          connected = true;
          break;
        case ConnectionType.unknown:
          status = 'unknown';
          break;
        case ConnectionType.disconnected:
          status = 'disconnected';
          break;
        case ConnectionType.device_found:
          status = 'device_found';
          break;
        case ConnectionType.device_not_found:
          status = 'device_not_found';
          break;
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

enum Status { CONNECTED, DISCONNECTED, DEVICE_FOUND, DEVICE_NOT_FOUND, UNKNOWN }

class ESense {
  bool connected = false;
  String eSenseName;
  int samplingRate = 10;
  Status status;

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
          status = Status.CONNECTED;
          connected = true;
          break;
        case ConnectionType.unknown:
          status = Status.UNKNOWN;
          break;
        case ConnectionType.disconnected:
          status = Status.DISCONNECTED;
          break;
        case ConnectionType.device_found:
          status = Status.DEVICE_FOUND;
          break;
        case ConnectionType.device_not_found:
          status = Status.DEVICE_NOT_FOUND;
          break;
      }
    });
  }
}

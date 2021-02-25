import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flip_counter/esense.dart';

class FlipDetection {
  ESense esense;
  StreamSubscription subscription;

  FlipDetection(ESense esense) {
    this.esense = esense;
  }

  void listenToSensorEvents() async {
    if (esense.status == Status.CONNECTED) {
      subscription = ESenseManager().sensorEvents.listen((event) {
        List<int> values = event.accel;
      });
    }
  }
}

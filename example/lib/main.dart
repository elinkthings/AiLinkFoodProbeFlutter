import 'package:ailink_food_probe_example/pages/page_probe_box_device.dart';
import 'package:ailink_food_probe_example/pages/page_probe_device.dart';
import 'package:ailink_food_probe_example/utils/constants.dart';
import 'package:ailink_food_probe_example/pages/page_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(MaterialApp(
    initialRoute: page_home,
    routes: {
      page_home: (context) => const HomePage(),
      page_probe_box_device: (context) => const ProbeBoxDevicePage(),
      page_probe_devce: (context) => const ProbeDevicePage(),
    },
  ));
}

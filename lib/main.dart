import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_bootstrap.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const AppBootstrap());
}

import 'dart:async';

import 'package:alpha/firebase_options.dart';
import 'package:alpha/sign_in_demo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Initialize other stuff here...
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // or here
      runApp(const MyApp());
    },
    (e, st) => print('ERROR'),
    zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      //save to a file or do whatever you want
    }),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: ((settings) {
        // This is also invoked for incoming deep links

        // ignore: avoid_print
        print('onGenerateRoute: $settings');

        return null;
      }),
      home: const SignInDemo(),
    );
  }
}

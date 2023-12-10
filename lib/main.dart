import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:motion_alert/motion_camera.dart';
import 'package:motion_alert/UI/home_page.dart';
import 'package:motion_alert/motion_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  build(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MotionCamera.instance),
        ChangeNotifierProvider.value(value: MotionNotifier.instance),
      ],
      child: MaterialApp(
        title: 'Motion Alert',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:motion_alert/app_commander.dart';
import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/motion_camera.dart';
import 'package:motion_alert/UI/home_page.dart';
import 'package:motion_alert/motion_notifier.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          visualDensity: VisualDensity.compact,
        ),
        home: const HomePage(),
      ),
    );
  }
}

Future<void> appStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.init();
  await MotionNotifier.instance.init();
  await MotionCamera.instance.init();
  await AppCommander.instance.init();
  await WakelockPlus.toggle(enable: true);
}

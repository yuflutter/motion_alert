import 'package:flutter/widgets.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/motion_camera.dart';
import 'package:motion_alert/motion_notifier.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> appStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.init();
  await MotionNotifier.instance.init();
  await MotionCamera.instance.init();
  await WakelockPlus.toggle(enable: true);
}

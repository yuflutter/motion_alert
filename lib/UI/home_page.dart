import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import 'package:motion_alert/app_start.dart';
import 'package:motion_alert/motion_camera.dart';
import 'package:motion_alert/motion_notifier.dart';
import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/core/simple_future_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late final Future _initFuture;

  @override
  initState() {
    _initFuture = appStart();
    super.initState();
  }

  @override
  build(context) {
    return Scaffold(
      body: SafeArea(
        child: SimpleFutureBuilder<void>(
            future: _initFuture,
            builder: (context, _) {
              final camera = context.watch<MotionCamera>();
              final notifier = context.watch<MotionNotifier>();
              return Column(
                children: [
                  _input(
                    controller: AppSettings.instance.pixelChangeThresholdCtrl,
                    label: 'Pixel change threshold',
                    onSubmitted: (_) => AppSettings.instance.setPixelChangeThreshold(),
                  ),
                  _input(
                    controller: AppSettings.instance.changedPixelsPercentCtrl,
                    label: 'Changed pixels percent',
                    onSubmitted: (_) => AppSettings.instance.setChangedPixelsPercent(),
                  ),
                  _input(
                    controller: AppSettings.instance.framesPerSecondCtrl,
                    label: 'Frames per second',
                    onSubmitted: (_) => AppSettings.instance.setFramesPerSecond(),
                  ),
                  _input(
                    controller: AppSettings.instance.passwordCtrl,
                    label: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    onSubmitted: (_) => AppSettings.instance.setPassword(),
                  ),
                  Expanded(
                    child: CameraPreview(camera.cameraController),
                  ),
                  SizedBox(height: 15),
                  (camera.motionDetected)
                      ? Text(
                          'MOTION DETECTED',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : Text('DETECTING...'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(notifier.lastLog),
                        ),
                        Text('${notifier.framesCount} / ${notifier.attachmentsCount}'),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required void Function(String?) onSubmitted,
    TextInputType keyboardType = TextInputType.number,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('$label:'),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    MotionCamera.instance.dispose();
    super.dispose();
  }
}

import 'dart:async';
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
  var _isScreenVisible = true;

  @override
  initState() {
    _initFuture = appStart();
    _showScreen();
    super.initState();
  }

  @override
  build(context) {
    return Scaffold(
      body: SimpleFutureBuilder<void>(
          future: _initFuture,
          builder: (context, _) {
            context.watch<MotionCamera>();
            final notifier = context.watch<MotionNotifier>();
            return (_isScreenVisible)
                ? SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                              Row(
                                children: [
                                  Expanded(child: Text('Camera resolution:')),
                                  Expanded(
                                    child: DropdownButtonFormField<ResolutionPreset>(
                                      value: AppSettings.instance.cameraResolutionPreset,
                                      items: ResolutionPreset.values
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e.toString().split('.').last),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) => AppSettings.instance.setCameraResolutionPreset(v),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: CameraPreview(MotionCamera.instance.cameraController),
                        ),
                        SizedBox(height: 15),
                        (MotionCamera.instance.motionDetected)
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
                    ),
                  )
                : InkWell(
                    onTap: _showScreen,
                    child: Container(
                      color: Colors.black,
                    ),
                  );
          }),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required void Function(String?) onSubmitted,
    TextInputType keyboardType = TextInputType.number,
    bool obscureText = false,
  }) {
    return Row(
      children: [
        Expanded(child: Text('$label:')),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }

  void _showScreen() {
    setState(() => _isScreenVisible = true);
    Future.delayed(
      Duration(seconds: 60),
      () => setState(() => _isScreenVisible = false),
    );
  }

  @override
  dispose() {
    MotionCamera.instance.dispose();
    super.dispose();
  }
}

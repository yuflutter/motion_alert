import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/motion_detector.dart';
import 'package:motion_alert/motion_notifier.dart';

class MotionCamera with ChangeNotifier {
  late final CameraController cameraController;
  bool _motionDetected = false;

  DateTime _previousFrameTime = DateTime.now();
  CameraImage? _previousFrame;

  static final instance = MotionCamera._();
  MotionCamera._();

  bool get motionDetected => _motionDetected;

  Future<void> init() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      imageFormatGroup: ImageFormatGroup.yuv420,
      ResolutionPreset.low, //max,
      enableAudio: false,
    );
    await cameraController.initialize();
    await cameraController.startImageStream(_processFrame);
  }

  void _processFrame(CameraImage frame) {
    try {
      final now = DateTime.now();
      if (now.difference(_previousFrameTime) > AppSettings.instance.frameDuration) {
        _previousFrameTime = now;
        if (_previousFrame != null) {
          final detected = MotionDetector.detect(_previousFrame!, frame);
          if (detected != _motionDetected) {
            FlutterBeep.beep();
            MotionNotifier.instance.addFrames([frame]);
            // MotionNotifier.instance.addFrames([_previousFrame!, frame]);
            _motionDetected = detected;
            notifyListeners();
          }
        }
        _previousFrame = frame;
        MotionNotifier.instance.setCurrentFrame(frame);
      }
    } catch (e, s) {
      log('$runtimeType', error: e, stackTrace: s);
    }
  }

  @override
  dispose() async {
    await cameraController.stopImageStream();
    await cameraController.dispose();
    super.dispose();
  }
}

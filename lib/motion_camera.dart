import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/motion_detector.dart';
import 'package:motion_alert/motion_notifier.dart';

class MotionCamera with ChangeNotifier {
  late CameraController cameraController;

  bool _motionDetection = true;
  bool _motionDetected = false;
  DateTime _previousFrameTime = DateTime.now();
  CameraImage? _previousFrame;

  static final instance = MotionCamera._();
  MotionCamera._();

  bool get motionDetection => _motionDetection;
  bool get motionDetected => _motionDetected;

  Future<void> init() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      AppSettings.instance.cameraResolutionPreset,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );
    await cameraController.initialize();
    await cameraController.startImageStream(_processFrame);

    AppSettings.instance.addListener(_onChangeSettings);
  }

  void startDetectMotion() {
    _motionDetection = true;
    notifyListeners();
  }

  void stopDetectMotion() {
    _motionDetection = false;
    notifyListeners();
  }

  void _onChangeSettings() async {
    AppSettings.instance.removeListener(_onChangeSettings);
    await cameraController.stopImageStream();
    _previousFrame = null;
    _motionDetected = false;
    init();
  }

  void _processFrame(CameraImage frame) {
    try {
      final now = DateTime.now();
      if (now.difference(_previousFrameTime) > AppSettings.instance.frameDuration) {
        _previousFrameTime = now;
        if (_motionDetection && _previousFrame != null && _previousFrame?.width == frame.width) {
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
  dispose() {
    cameraController
      ..stopImageStream()
      ..dispose();
    super.dispose();
  }
}

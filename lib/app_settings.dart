import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cameraResolutionPreset0 = ResolutionPreset.medium;
const _pixelChangeThreshold0 = 10;
const _changedPixelsPercent0 = 5.0;
const _framesPerSecond0 = 5.0;

class AppSettings with ChangeNotifier {
  late ResolutionPreset _cameraResolutionPreset;

  late int _pixelChangeThreshold;
  final pixelChangeThresholdCtrl = TextEditingController();

  late double _changedPixelsPercent;
  final changedPixelsPercentCtrl = TextEditingController();

  late double _framesPerSecond;
  final framesPerSecondCtrl = TextEditingController();
  late Duration _frameDuration;

  late String _password;
  final passwordCtrl = TextEditingController();

  late SharedPreferences _prefs;

  static final instance = AppSettings._();
  AppSettings._();

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      _cameraResolutionPreset = ResolutionPreset.values.firstWhere(
        (e) => e.index == _prefs.getInt('_cameraResolutionPreset'),
        orElse: () => _cameraResolutionPreset0,
      );

      _pixelChangeThreshold = _prefs.getInt('_pixelChangeThreshold') ?? _pixelChangeThreshold0;
      pixelChangeThresholdCtrl.text = _pixelChangeThreshold.toString();

      _changedPixelsPercent = _prefs.getDouble('_changedPixelsPercent') ?? _changedPixelsPercent0;
      changedPixelsPercentCtrl.text = _changedPixelsPercent.toString();

      _framesPerSecond = _prefs.getDouble('_framesPerSecond') ?? _framesPerSecond0;
      framesPerSecondCtrl.text = _framesPerSecond.toString();
      _framePerSecondToDuration();

      _password = _prefs.getString('_password') ?? 'loyhylejdvhxghhe';
      passwordCtrl.text = _password.toString();

      _save();
    } catch (e, s) {
      log('$runtimeType', error: e, stackTrace: s);
    }
  }

  void _save() async {
    try {
      await Future.wait([
        _prefs.setInt('_cameraResolutionPreset', _cameraResolutionPreset.index),
        _prefs.setInt('_pixelChangeThreshold', _pixelChangeThreshold),
        _prefs.setDouble('_changedPixelsPercent', _changedPixelsPercent),
        _prefs.setDouble('_framesPerSecond', _framesPerSecond),
        _prefs.setString('_password', _password),
      ]);
    } catch (e, s) {
      log('$runtimeType', error: e, stackTrace: s);
    }
  }

  ResolutionPreset get cameraResolutionPreset => _cameraResolutionPreset;
  void setCameraResolutionPreset(ResolutionPreset? v) {
    if (v != null) {
      _cameraResolutionPreset = v;
      notifyListeners();
    }
  }

  int get pixelChangeThreshold => _pixelChangeThreshold;
  void setPixelChangeThreshold() {
    _pixelChangeThreshold = double.parse(pixelChangeThresholdCtrl.text).round();
    _save();
    notifyListeners();
  }

  double get changedPixelsPercent => _changedPixelsPercent;
  void setChangedPixelsPercent() {
    _changedPixelsPercent = double.parse(changedPixelsPercentCtrl.text);
    _save();
    notifyListeners();
  }

  Duration get frameDuration => _frameDuration;
  void setFramesPerSecond() {
    _framesPerSecond = double.parse(framesPerSecondCtrl.text);
    _framePerSecondToDuration();
    _save();
    notifyListeners();
  }

  String get password => _password;
  void setPassword() {
    _password = passwordCtrl.text;
    _save();
    notifyListeners();
  }

  void _framePerSecondToDuration() {
    _frameDuration = Duration(milliseconds: (1000 / _framesPerSecond).round());
  }
}

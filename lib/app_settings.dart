import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pixelChangeThresholdDefault = 10;
const _changedPixelsPercentDefault = 5.0;
const _framesPerSecondDefault = 5.0;

class AppSettings {
  late int _pixelChangeThreshold;
  final pixelChangeThresholdCtrl = TextEditingController();

  late double _changedPixelsPercent;
  final changedPixelsPercentCtrl = TextEditingController();

  late double _framesPerSecond;
  final framesPerSecondCtrl = TextEditingController();
  late Duration _frameDuration;

  late String _password;
  final passwordCtrl = TextEditingController();

  SharedPreferences? _prefs;

  static final instance = AppSettings._();
  AppSettings._();

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      _pixelChangeThreshold = _prefs!.getInt('_pixelChangeThreshold') ?? _pixelChangeThresholdDefault;
      pixelChangeThresholdCtrl.text = _pixelChangeThreshold.toString();

      _changedPixelsPercent = _prefs!.getDouble('_changedPixelsPercent') ?? _changedPixelsPercentDefault;
      changedPixelsPercentCtrl.text = _changedPixelsPercent.toString();

      _framesPerSecond = _prefs!.getDouble('_framesPerSecond') ?? _framesPerSecondDefault;
      framesPerSecondCtrl.text = _framesPerSecond.toString();
      _framePerSecondToDuration();

      _password = _prefs!.getString('_password') ?? 'loyhylejdvhxgahe';
      passwordCtrl.text = _password.toString();

      _save();
    } catch (e, s) {
      log('$runtimeType', error: e, stackTrace: s);
    }
  }

  void _save() async {
    try {
      await _prefs!.setInt('_pixelChangeThreshold', _pixelChangeThreshold);
      await _prefs!.setDouble('_changedPixelsPercent', _changedPixelsPercent);
      await _prefs!.setDouble('_framesPerSecond', _framesPerSecond);
      await _prefs!.setString('_password', _password);
    } catch (e, s) {
      log('$runtimeType', error: e, stackTrace: s);
    }
  }

  int get pixelChangeThreshold => _pixelChangeThreshold;
  void setPixelChangeThreshold() {
    _pixelChangeThreshold = double.parse(pixelChangeThresholdCtrl.text).round();
    _save();
  }

  double get changedPixelsPercent => _changedPixelsPercent;
  void setChangedPixelsPercent() {
    _changedPixelsPercent = double.parse(changedPixelsPercentCtrl.text);
    _save();
  }

  Duration get frameDuration => _frameDuration;
  void setFramesPerSecond() {
    _framesPerSecond = double.parse(framesPerSecondCtrl.text);
    _framePerSecondToDuration();
    _save();
  }

  String get password => _password;
  void setPassword() {
    _password = passwordCtrl.text;
    _save();
  }

  void _framePerSecondToDuration() {
    _frameDuration = Duration(milliseconds: (1000 / _framesPerSecond).round());
  }
}

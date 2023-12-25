import 'dart:async';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/image_converter.dart';

const _maxAttachmentCount = 18;

class MotionNotifier with ChangeNotifier {
  final List<CameraImage> _framesBuffer = [];
  final List<Attachment> _attachmentsBuffer = [];
  CameraImage? _currentFrame;
  late final SmtpServer _smtp;
  bool _executing = false;
  String _lastLog = '';

  static final instance = MotionNotifier._();
  MotionNotifier._();

  int get framesCount => _framesBuffer.length;
  int get attachmentsCount => _attachmentsBuffer.length;
  bool get executing => _executing;
  String get lastLog => _lastLog;

  Future<void> init() async {
    _smtp = SmtpServer(
      'smtp.yandex.ru',
      ssl: true,
      port: 465,
      username: AppSettings.instance.user,
      password: AppSettings.instance.password,
    );

    Timer.periodic(Duration(seconds: 20), (_) => _sendBuffer());
  }

  void setCurrentFrame(CameraImage frame) {
    _currentFrame = frame;
  }

  void addFrames(List<CameraImage> frames) async {
    _framesBuffer.addAll(frames);
    notifyListeners();
  }

  Future<void> sendCurrentFrame() async {
    if (_currentFrame != null) {
      _sendEmail(
        '${AppSettings.instance.camName} on demand',
        [await ImageConverter.frameToAttachment(_currentFrame!)],
      );
      _log('current frame sent on demand');
    }
  }

  Future<void> _sendEmail(String subject, List<Attachment> attachments) {
    final msg = Message()
      ..from = Address(AppSettings.instance.senderEmail, AppSettings.instance.senderName)
      ..recipients.add(AppSettings.instance.senderEmail)
      ..subject = subject
      ..attachments = attachments;
    return send(msg, _smtp);
  }

  void _sendBuffer() async {
    if (_framesBuffer.isEmpty || _executing) {
      return;
    }
    _executing = true;
    _log('compressing frames...');
    try {
      while (_framesBuffer.isNotEmpty && _attachmentsBuffer.length < _maxAttachmentCount) {
        final frame = _framesBuffer.removeAt(0);
        notifyListeners();
        _attachmentsBuffer.add(
          await ImageConverter.frameToAttachment(frame),
        );
      }
      _log('$attachmentsCount frames sending...');
      await _sendEmail(
        '${AppSettings.instance.camName} motion detected',
        _attachmentsBuffer,
      );
      // log(res.mail.text ?? 'null');
      // if (AppSettings.instance.phoneNumber.isNotEmpty) {
      //   Telephony.instance
      //       .sendSms(
      //         to: AppSettings.instance.phoneNumber,
      //         message: "MOTION DETECTED",
      //       )
      //       .onError(_onError);
      // }
      _log('$attachmentsCount frames sent');
    } catch (e, s) {
      _log('Error sending frames', e, s);
    }
    _executing = false;
    _attachmentsBuffer.clear();
    notifyListeners();
    if (_framesBuffer.isNotEmpty) {
      _sendBuffer();
    }
  }

  void _log(String msg, [Object? error, StackTrace? stack]) {
    if (error == null) {
      dev.log(msg);
      _lastLog = msg;
    } else {
      dev.log('$msg: ', error: error, stackTrace: stack);
      _lastLog = '$msg: $error';
    }
    notifyListeners();
  }
}

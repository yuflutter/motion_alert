import 'dart:async';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:telephony/telephony.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/image_converter.dart';

const _maxAttachmentCount = 18;

class MotionNotifier with ChangeNotifier {
  final List<CameraImage> _framesBuffer = [];
  final List<Attachment> _attachmentsBuffer = [];
  CameraImage? _currentFrame;
  late final SmtpServer _smtp;
  bool _executing = false;
  String _log = '';

  static final instance = MotionNotifier._();
  MotionNotifier._();

  int get framesCount => _framesBuffer.length;
  int get attachmentsCount => _attachmentsBuffer.length;
  bool get executing => _executing;
  String get lastLog => _log;

  Future<void> init() async {
    _smtp = SmtpServer(
      'smtp.yandex.ru',
      ssl: true,
      port: 465,
      username: 'yuflutter',
      password: AppSettings.instance.password,
    );

    Timer.periodic(Duration(seconds: 20), (_) => _sendBuffer());

    if ((await Telephony.instance.requestSmsPermissions) == true) {
      Telephony.instance.listenIncomingSms(
        onNewMessage: _receiveCommand,
        listenInBackground: false,
      );
    }
  }

  Future<void> _sendEmail(String subject, List<Attachment> attachments) {
    final msg = Message()
      ..from = Address('yuflutter@yandex.ru')
      ..recipients.add('yuflutter@yandex.ru')
      ..subject = subject
      ..attachments = attachments;
    return send(msg, _smtp);
  }

  void setCurrentFrame(CameraImage frame) {
    _currentFrame = frame;
  }

  void addFrames(List<CameraImage> frames) async {
    _framesBuffer.addAll(frames);
    notifyListeners();
  }

  void _sendBuffer() async {
    if (_framesBuffer.isEmpty || _executing) {
      return;
    }
    _executing = true;
    log('${_framesBuffer.length} frames to send');
    try {
      while (_framesBuffer.isNotEmpty && _attachmentsBuffer.length < _maxAttachmentCount) {
        final frame = _framesBuffer.removeAt(0);
        notifyListeners();
        _attachmentsBuffer.add(
          await ImageConverter.frameToAttachment(frame),
        );
      }
      log('$attachmentsCount sending...');
      await _sendEmail('MOTION DETECTED', _attachmentsBuffer);
      // log(res.mail.text ?? 'null');
      // if (AppSettings.instance.phoneNumber.isNotEmpty) {
      //   Telephony.instance
      //       .sendSms(
      //         to: AppSettings.instance.phoneNumber,
      //         message: "MOTION DETECTED",
      //       )
      //       .onError(_onError);
      // }
      log('$attachmentsCount sent');
    } catch (e, s) {
      log('', e, s);
    }
    _executing = false;
    _attachmentsBuffer.clear();
    notifyListeners();
    if (_framesBuffer.isNotEmpty) {
      _sendBuffer();
    }
  }

  void _receiveCommand(SmsMessage msg) async {
    log('SMS RECEIVED: ${msg.address}\n${msg.body}}');
    if (_currentFrame != null) {
      _sendEmail(
        'ON DEMAND',
        [await ImageConverter.frameToAttachment(_currentFrame!)],
      );
    }
    // if (msg.address == AppSettings.instance.phoneNumber) {
    //   if (msg.body?.toLowerCase() == 'get') {
    //     Telephony.instance
    //         .sendSms(
    //           to: AppSettings.instance.phoneNumber,
    //           message: "current frame:",
    //         )
    //         .onError(_onError);
    //   }
    // }
  }

  void log(String msg, [Object? error, StackTrace? stack]) {
    if (error == null) {
      dev.log(msg);
      _log = msg;
    } else {
      dev.log('$MotionNotifier ERROR: $msg', error: error, stackTrace: stack);
      _log = msg + error.toString();
    }
    notifyListeners();
  }
}

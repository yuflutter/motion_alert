import 'dart:async';
import 'dart:developer';
import 'package:enough_mail/enough_mail.dart';

import 'package:motion_alert/app_settings.dart';
import 'package:motion_alert/motion_camera.dart';
import 'package:motion_alert/motion_notifier.dart';

class AppCommander {
  late MailClient _mailClient;

  static final instance = AppCommander._();
  AppCommander._();

  Future<void> init() async {
    final email = AppSettings.instance.senderEmail;
    _mailClient = MailClient(
      MailAccount.fromDiscoveredSettings(
        name: 'Me',
        email: email,
        userName: AppSettings.instance.user,
        password: AppSettings.instance.password,
        config: (await Discover.discover(email, isLogEnabled: true))!,
      ),
      isLogEnabled: true,
    );
    await _mailClient.connect();
    await _mailClient.selectInbox();
    _mailClient.eventBus.on<MailLoadEvent>().listen((ev) {
      if (ev.message.from?[0].personalName != AppSettings.instance.senderName) {
        log('new message at ${ev.message.from}');
        MotionNotifier.instance.sendCurrentFrame();
        if (ev.message.envelope?.subject?.contains(' ${AppSettings.instance.camName} ') == true) {
          final command = ev.message.envelope!.subject!.trim().split(':').first.toLowerCase();
          log('command: $command');
          final _ = switch (command) {
            'start' => MotionCamera.instance.startDetectMotion(),
            'stop' => MotionCamera.instance.stopDetectMotion(),
            _ => null,
          };
        }
      }
    });
    await _mailClient.startPolling(Duration(seconds: 20));
    Timer.periodic(Duration(minutes: 1), (_) {
      if (!_mailClient.isPolling()) {
        init();
      }
    });

    // if ((await Telephony.instance.requestSmsPermissions) == true) {
    //   Telephony.instance.listenIncomingSms(
    //     onNewMessage: _receiveCommand,
    //     listenInBackground: false,
    //   );
    // }
  }

  // void _receiveCommand(SmsMessage msg) async {
  //   log('SMS RECEIVED: ${msg.address}\n${msg.body}}');
  //   MotionNotifier.instance.sendCurrentFrame();
  //   // if (msg.address == AppSettings.instance.phoneNumber) {
  //   //   if (msg.body?.toLowerCase() == 'get') {
  //   //     Telephony.instance
  //   //         .sendSms(
  //   //           to: AppSettings.instance.phoneNumber,
  //   //           message: "current frame:",
  //   //         )
  //   //         .onError(_onError);
  //   //   }
  //   // }
  // }
}

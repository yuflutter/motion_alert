import 'package:camera/camera.dart';
import 'package:motion_alert/app_settings.dart';

class MotionDetector {
  static bool detect(CameraImage frame1, CameraImage frame2) {
    assert(frame1.format.group == ImageFormatGroup.yuv420 && frame2.format.group == ImageFormatGroup.yuv420);
    final yy1 = frame1.planes[0].bytes;
    final yy2 = frame2.planes[0].bytes;
    bool res = false;
    double dy12 = 0; // поправочный коэффициент средней яркости
    for (var i = 0; i < yy1.length; i++) {
      dy12 += yy1[i] - yy2[i];
    }
    dy12 = dy12 / yy1.length;
    final pixelChangeThreshold = AppSettings.instance.pixelChangeThreshold;
    final changedPixelsThreshold = yy1.length * AppSettings.instance.changedPixelsPercent / 100;
    int diffsCount = 0;
    for (var i = 0; i < yy1.length; i++) {
      if ((yy1[i] - yy2[i] - dy12).abs() >= pixelChangeThreshold) {
        diffsCount++;
        if (diffsCount > changedPixelsThreshold) {
          res = true;
          break;
        }
      }
    }
    // debugPrint('$dy12 - $res');
    return res;
  }
}

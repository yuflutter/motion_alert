import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:camera/camera.dart';
import 'package:mailer/mailer.dart';

class ImageConverter {
  static Future<Attachment> frameToAttachment(CameraImage frame) async {
    final pngBytes = await compute<CameraImage, Uint8List>(
      ImageConverter._frameToPngBytes,
      frame,
    );
    final stream = StreamController<List<int>>()
      ..add(pngBytes.toList())
      ..close();
    return StreamAttachment(stream.stream, 'image/png');
  }

  static Uint8List _frameToPngBytes(CameraImage frame) {
    assert(frame.format.group == ImageFormatGroup.yuv420);
    final bytes = frame.planes[0].bytes;
    final bgra = Uint8List(frame.width * frame.height * 3);
    for (int y = 0; y < frame.height * frame.width; y += frame.width) {
      for (int x = 0; x < frame.width; x++) {
        final pixel = bytes[y + x];
        final xy = (y + x) * 3;
        bgra
          ..[xy] = pixel
          ..[xy + 1] = pixel
          ..[xy + 2] = pixel;
        // ..[xy + 3] = 0xFF;
      }
    }
    return encodePng(
      Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: bgra.buffer,
        format: Format.uint8,
        order: ChannelOrder.bgr,
      ),
    );
    // final img = Image(width: frame.width, height: frame.height);
    // // final img = Image(width: frame.height, height: frame.width);
    // final bytes = frame.planes[0].bytes;
    // for (int y = 0; y < frame.height * frame.width; y += frame.width) {
    //   for (int x = 0; x < frame.width; x++) {
    //     img.setPixelR(x, y, bytes[y + x]);
    //   }
    // }
    // return encodePng(img);
    // return encodePng(
    //   Image.fromBytes(
    //     width: frame.width,
    //     height: frame.height,
    //     bytes: frame.planes[0].bytes.buffer,
    //     format: Format.uint8,
    //     order: ChannelOrder.red,
    //   ),
    // );
  }
}

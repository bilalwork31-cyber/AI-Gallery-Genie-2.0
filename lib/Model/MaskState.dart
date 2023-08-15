import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MaskState with ChangeNotifier {
  List<Offset?> _points = [];
  ui.Image? _maskImage;

  List<Offset?> get points => _points;
  ui.Image? get maskImage => _maskImage;

  void addPoint(Offset? point) {
    _points.add(point);
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    _maskImage = null;
    notifyListeners();
  }

  Future<void> createMask(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );

    // Fill the background with black
    canvas.drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Paint()..color = Colors.black,
    );

    final int smallerDimension = image.width < image.height ? image.width : image.height;
    final double scaledStrokeWidth = smallerDimension / 25;

    Paint maskPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = scaledStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, maskPaint);
      }
    }

    final picture = recorder.endRecording();
    _maskImage = await picture.toImage(image.width, image.height);
    notifyListeners();
  }
}

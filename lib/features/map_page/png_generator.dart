import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> generatePngForNumber(int number,
    {bool active = false}) async {
  var diameter = 25 * window.devicePixelRatio;
  var strokeWidth = 1 * window.devicePixelRatio;
  var textYOffset = 4.5 * window.devicePixelRatio;

  var recorder = PictureRecorder();
  var c = Canvas(recorder);

  var circlePaint = Paint();
  circlePaint.color = number == 0
      ? (active ? Colors.grey[700] : Colors.grey)
      : (active ? Colors.blue[900] : Colors.blue);
  c.drawCircle(Offset(diameter / 2, diameter / 2), diameter / 2, circlePaint);
  var strokePaint = Paint();
  strokePaint.color = number == 0
      ? (active ? Colors.black : Colors.grey[900])
      : (active ? Colors.deepPurple[900] : Colors.blue[900]);
  strokePaint.style = PaintingStyle.stroke;
  strokePaint.strokeWidth = strokeWidth;
  c.drawCircle(
    Offset(diameter / 2, diameter / 2),
    diameter / 2 - strokeWidth / 2,
    strokePaint,
  );

  var span = TextSpan(text: '$number', style: TextStyle(fontSize: 48));
  var textPainter = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(minWidth: diameter);
  textPainter.paint(c, Offset(0, textYOffset));

  var picture = recorder.endRecording();
  var image = await picture.toImage(diameter.toInt(), diameter.toInt());
  var pngBytes = await image.toByteData(format: ImageByteFormat.png);
  return pngBytes.buffer.asUint8List();
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloorPlanPainter extends CustomPainter {
  final double roomWidth, roomHeight, scale;
  final bool showGrid, showDimensions;

  FloorPlanPainter({
    required this.roomWidth,
    required this.roomHeight,
    required this.scale,
    required this.showGrid,
    required this.showDimensions,
  });

  void _drawDashed(Canvas c, Offset s, Offset e, Paint p) {
    const dw = 10.0, ds = 5.0;
    final d = (e - s).distance;
    for (var i = 0; i < d / (dw + ds); i++) {
      final f = i * (dw + ds) / d;
      final f2 = (i * (dw + ds) + dw) / d;
      c.drawLine(s + (e - s) * f, s + (e - s) * f2, p);
    }
  }

  void _drawDimLine(Canvas c, Offset s, Offset e, String t, Paint p, bool v) {
    c.drawLine(s, e, p);
    c.drawLine(
      s + (v ? const Offset(-3, 0) : const Offset(0, -3)),
      s + (v ? const Offset(3, 0) : const Offset(0, 3)),
      p,
    );
    c.drawLine(
      e + (v ? const Offset(-3, 0) : const Offset(0, -3)),
      e + (v ? const Offset(3, 0) : const Offset(0, 3)),
      p,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = Offset((s.dx + e.dx) / 2, (s.dy + e.dy) / 2);
    if (v) {
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(-math.pi / 2);
      tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
      c.restore();
    } else {
      tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    if (showGrid) {
      final gp =
          Paint()
            ..color = const Color(0xFFE8E8E8)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;
      for (var x = 0.0; x <= size.width; x += scale) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
      }
      for (var y = 0.0; y <= size.height; y += scale) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
      }
    }
    final wp =
        Paint()
          ..color = const Color(0xFF2C2C2C)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wp);
    if (roomWidth >= 12) {
      final dp =
          Paint()
            ..color = const Color(0xFF666666)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke;
      final lw = size.width / 3;
      _drawDashed(canvas, Offset(lw, 0), Offset(lw, size.height), dp);
      _drawDashed(canvas, Offset(lw * 2, 0), Offset(lw * 2, size.height), dp);
      if (showDimensions) {
        final tp = TextPainter(
          text: const TextSpan(
            text: '4 FT LOFT',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(lw / 2 - tp.width / 2, 30));
        tp.paint(canvas, Offset(lw * 1.5 - tp.width / 2, 30));
        tp.paint(canvas, Offset(lw * 2.5 - tp.width / 2, 30));
      }
    }
    if (showDimensions) {
      final dp =
          Paint()
            ..color = const Color(0xFF9E9E9E)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
      _drawDimLine(
        canvas,
        Offset(0, -20),
        Offset(size.width, -20),
        '${roomWidth.toInt()} ft',
        dp,
        false,
      );
      _drawDimLine(
        canvas,
        Offset(-20, 0),
        Offset(-20, size.height),
        '${roomHeight.toInt()} ft',
        dp,
        true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class ComponentPainter extends CustomPainter {
  final String? imageName;
  final bool isSelected;
  final String? text;
  final double? fontSize;
  final Color? color;

  ComponentPainter({
    this.imageName,
    required this.isSelected,
    this.text,
    this.fontSize,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size s) {
    if (text != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: text ?? 'Text',
          style: TextStyle(
            color: color ?? Colors.black,
            fontSize: fontSize ?? 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final offset = Offset(
        (s.width - tp.width) / 2,
        (s.height - tp.height) / 2,
      );
      tp.paint(canvas, offset);
      if (isSelected) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, s.width, s.height),
          Paint()
            ..color = const Color(0xFFD3D3D3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }
    } else if (imageName != null) {
      final imageProvider = AssetImage('assets/images/$imageName');
      final paint = Paint()..filterQuality = FilterQuality.high;
      final picture = imageProvider.resolve(ImageConfiguration());
      picture.addListener(
        ImageStreamListener((info, synchronousCall) {
          final img = info.image;
          final srcSize = Size(img.width.toDouble(), img.height.toDouble());
          final dstSize = Size(s.width, s.height);
          final srcRect = Rect.fromLTWH(0, 0, srcSize.width, srcSize.height);
          final dstRect = Rect.fromLTWH(0, 0, dstSize.width, dstSize.height);
          canvas.drawImageRect(img, srcRect, dstRect, paint);
          if (isSelected) {
            canvas.drawRect(
              Rect.fromLTWH(0, 0, s.width, s.height),
              Paint()
                ..color = const Color(0xFFD3D3D3)
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke,
            );
          }
        }),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

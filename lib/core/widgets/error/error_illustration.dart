import 'package:flutter/material.dart';
import '../../errors/app_error_kind.dart';

class ErrorIllustration extends StatelessWidget {
  final AppErrorKind kind;
  final double size;

  const ErrorIllustration({
    super.key,
    required this.kind,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ErrorIllustrationPainter(kind: kind),
      ),
    );
  }
}

class _ErrorIllustrationPainter extends CustomPainter {
  final AppErrorKind kind;

  _ErrorIllustrationPainter({required this.kind});

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case AppErrorKind.offline:
        _paintBrokenTower(canvas, size);
        break;
      case AppErrorKind.serverUnreachable:
        _paintDisconnectedCables(canvas, size);
        break;
      case AppErrorKind.notFound:
        _paintNotFound(canvas, size);
        break;
      case AppErrorKind.unauthorized:
        _paintLocked(canvas, size);
        break;
      case AppErrorKind.server:
        _paintServerGlitch(canvas, size);
        break;
      case AppErrorKind.timeout:
        _paintTimeout(canvas, size);
        break;
      case AppErrorKind.unknown:
        _paintUnknown(canvas, size);
        break;
    }
  }

  void _paintBrokenTower(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final base_y = size.height * 0.82;
    final pole_paint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final accent = const Color(0xFF1DB954);

    canvas.drawLine(Offset(cx, base_y), Offset(cx, size.height * 0.22), pole_paint);

    final bar_paint = Paint()
      ..color = accent.withOpacity(0.8)
      ..strokeWidth = 3;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.32 + i * 0.12);
      canvas.drawLine(Offset(cx - 28, y), Offset(cx + 28, y), bar_paint);
    }

    final break_paint = Paint()
      ..color = const Color(0xFFFF375F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final mid_y = size.height * 0.48;
    canvas.drawLine(Offset(cx - 18, mid_y - 8), Offset(cx + 4, mid_y + 6), break_paint);
    canvas.drawLine(Offset(cx + 4, mid_y + 6), Offset(cx + 22, mid_y - 10), break_paint);

    final zap = Path()
      ..moveTo(cx + 34, size.height * 0.2)
      ..lineTo(cx + 48, size.height * 0.28)
      ..lineTo(cx + 38, size.height * 0.28)
      ..lineTo(cx + 52, size.height * 0.42);
    canvas.drawPath(
      zap,
      Paint()
        ..color = const Color(0xFFFF9500)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      Offset(cx, size.height * 0.18),
      6,
      Paint()..color = accent.withOpacity(0.25),
    );
  }

  void _paintDisconnectedCables(Canvas canvas, Size size) {
    final left_x = size.width * 0.22;
    final right_x = size.width * 0.78;
    final mid_y = size.height * 0.5;

    final device = RRect.fromRectAndRadius(
      Rect.fromLTWH(left_x - 22, mid_y - 30, 44, 60),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      device,
      Paint()..color = const Color(0xFF1A1A1A),
    );
    canvas.drawRRect(
      device,
      Paint()
        ..color = const Color(0xFF1DB954)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final cloud = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(right_x, mid_y - 10),
        width: 56,
        height: 36,
      ));
    canvas.drawPath(cloud, Paint()..color = const Color(0xFF2A2A2A));
    canvas.drawPath(
      cloud,
      Paint()
        ..color = const Color(0xFF1DB954).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final cable_paint = Paint()
      ..color = const Color(0xFF666666)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(left_x + 22, mid_y),
      Offset(size.width * 0.42, mid_y - 18),
      cable_paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, mid_y + 16),
      Offset(right_x - 28, mid_y),
      cable_paint,
    );

    final gap_paint = Paint()
      ..color = const Color(0xFFFF375F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final gx = size.width * 0.5;
    canvas.drawLine(Offset(gx - 10, mid_y - 4), Offset(gx + 2, mid_y + 8), gap_paint);
    canvas.drawLine(Offset(gx + 2, mid_y + 8), Offset(gx + 14, mid_y - 6), gap_paint);

    final plug_paint = Paint()..color = const Color(0xFFFF9500);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(gx - 6, mid_y + 2), width: 8, height: 14),
      plug_paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(gx + 8, mid_y + 2), width: 8, height: 14),
      plug_paint,
    );
  }

  void _paintNotFound(Canvas canvas, Size size) {
    final text = TextPainter(
      text: const TextSpan(
        text: '404',
        style: TextStyle(
          color: Color(0xFF1DB954),
          fontSize: 56,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, size.height * 0.28),
    );

    final leaf = Path()
      ..moveTo(size.width * 0.55, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.45,
        size.width * 0.58,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.32,
        size.width * 0.48,
        size.height * 0.55,
      )
      ..close();
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF1DB954).withOpacity(0.35));
    canvas.drawPath(
      leaf,
      Paint()
        ..color = const Color(0xFF1DB954)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final question = TextPainter(
      text: const TextSpan(text: '?', style: TextStyle(fontSize: 28)),
      textDirection: TextDirection.ltr,
    )..layout();
    question.paint(canvas, Offset(size.width * 0.62, size.height * 0.42));
  }

  void _paintLocked(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.58),
        width: 52,
        height: 44,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF1DB954));
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.42),
        width: 36,
        height: 36,
      ),
      3.14,
      3.14,
      false,
      Paint()
        ..color = const Color(0xFF888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  void _paintServerGlitch(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.52),
        width: size.width * 0.55,
        height: size.height * 0.38,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(box, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawRRect(
      box,
      Paint()
        ..color = const Color(0xFFFF375F).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final dot_paint = Paint()..color = const Color(0xFF1DB954);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.35 + i * 0.15), size.height * 0.44),
        4,
        dot_paint,
      );
    }

    final glitch = Paint()
      ..color = const Color(0xFFFF9500)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.58),
      Offset(size.width * 0.72, size.height * 0.62),
      glitch,
    );
    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.66),
      Offset(size.width * 0.68, size.height * 0.6),
      glitch,
    );
  }

  void _paintTimeout(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.48;
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.28,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    final hand = Paint()
      ..color = const Color(0xFF1DB954)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 28), hand);
    canvas.drawLine(Offset(cx, cy), Offset(cx + 22, cy + 8), hand);

    final z_paint = TextPainter(
      text: const TextSpan(
        text: 'z z',
        style: TextStyle(
          color: Color(0xFF888888),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    z_paint.paint(canvas, Offset(cx + 36, cy - 40));
  }

  void _paintUnknown(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawCircle(
      Offset(cx, size.height * 0.48),
      size.width * 0.22,
      Paint()..color = const Color(0xFF1A1A1A),
    );
    canvas.drawCircle(
      Offset(cx, size.height * 0.48),
      size.width * 0.22,
      Paint()
        ..color = const Color(0xFF1DB954).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final face = TextPainter(
      text: const TextSpan(text: ':|', style: TextStyle(fontSize: 36)),
      textDirection: TextDirection.ltr,
    )..layout();
    face.paint(
      canvas,
      Offset(cx - face.width / 2, size.height * 0.48 - face.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ErrorIllustrationPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

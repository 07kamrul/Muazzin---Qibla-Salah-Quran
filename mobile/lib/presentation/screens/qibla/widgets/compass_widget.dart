import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CompassWidget extends StatelessWidget {
  const CompassWidget({
    required this.compassHeading,
    required this.qiblaBearing,
    required this.isAligned,
    super.key,
  });

  final double compassHeading;
  final double qiblaBearing;
  final bool   isAligned;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring (green when aligned)
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width:  size + 24,
          height: size + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isAligned
                ? [BoxShadow(color: AppColors.domeGlow, blurRadius: 24, spreadRadius: 4)]
                : [],
            border: Border.all(
              color: isAligned ? AppColors.domePale : AppColors.goldBd,
              width: 3,
            ),
          ),
        ),

        // Rotating compass rose
        Transform.rotate(
          angle: -compassHeading * math.pi / 180,
          child: CustomPaint(
            size: Size(size, size),
            painter: _CompassPainter(),
          ),
        ),

        // Qibla pointer (fixed, points toward Kaaba)
        Transform.rotate(
          angle: (qiblaBearing - compassHeading) * math.pi / 180,
          child: SizedBox(
            width: size,
            height: size,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 8,
                height: size * 0.3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.gold, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // Kaaba icon at tip of Qibla pointer
        Transform.rotate(
          angle: (qiblaBearing - compassHeading) * math.pi / 180,
          child: SizedBox(
            width: size,
            height: size,
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -size * 0.1),
                child: const Text('🕋', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),

        // Center dot
        Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(
            color: AppColors.goldWarm,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final radius  = size.width / 2;
    final paint   = Paint()
      ..color     = AppColors.sky3
      ..style     = PaintingStyle.fill;
    final border  = Paint()
      ..color     = AppColors.domeBd
      ..style     = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background circle
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, border);

    // Cardinal marks
    final textStyle = TextStyle(
      color: AppColors.marble,
      fontSize: radius * 0.13,
      fontWeight: FontWeight.w700,
    );
    const cardinals = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final angle    = i * math.pi / 2 - math.pi / 2;
      final markR    = radius * 0.82;
      final pos      = Offset(
        center.dx + markR * math.cos(angle),
        center.dy + markR * math.sin(angle),
      );
      final textPainter = TextPainter(
        text:            TextSpan(text: cardinals[i], style: textStyle),
        textDirection:   TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Tick marks
    final tickPaint = Paint()
      ..color = AppColors.sandMid
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 72; i++) {
      final angle    = i * math.pi / 36;
      final isCard   = i % 18 == 0;
      final isMajor  = i % 6 == 0;
      final innerR   = isCard ? radius * 0.65 : (isMajor ? radius * 0.72 : radius * 0.78);
      final outerR   = radius * 0.88;

      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle)),
        Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

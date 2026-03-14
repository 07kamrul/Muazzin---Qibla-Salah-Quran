import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

// ── StarfieldWidget ───────────────────────────────────────────────────────────

/// Static randomly-placed stars, repainted only on first build.
class StarfieldWidget extends StatelessWidget {
  const StarfieldWidget({super.key, this.count = 30, this.seed = 42});
  final int count;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _StarfieldPainter(count: count, seed: seed),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.count, required this.seed});
  final int count;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final x       = rng.nextDouble() * size.width;
      final y       = rng.nextDouble() * size.height * 0.7;
      final r       = 0.5 + rng.nextDouble() * 1.2;
      final opacity = 0.25 + rng.nextDouble() * 0.75;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = AppColors.marble.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.count != count || old.seed != seed;
}

// ── MosqueSilhouette ──────────────────────────────────────────────────────────

/// Decorative mosque skyline silhouette.
class MosqueSilhouette extends StatelessWidget {
  const MosqueSilhouette({
    super.key,
    required this.width,
    this.opacity = 0.08,
    this.color = AppColors.goldPale,
  });
  final double width;
  final double opacity;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: 80,
        child: CustomPaint(painter: _SilhouettePainter(color: color)),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w     = size.width;
    final h     = size.height;
    final paint = Paint()..color = color;
    final path  = Path();

    path.moveTo(0, h);
    path.lineTo(0, h * 0.42);
    // Left minaret
    path.lineTo(w * 0.045, h * 0.42);
    path.lineTo(w * 0.045, h * 0.16);
    path.lineTo(w * 0.03,  0);
    path.lineTo(w * 0.015, h * 0.16);
    path.lineTo(w * 0.015, h * 0.42);
    path.lineTo(0, h * 0.42);
    path.moveTo(0, h);
    path.lineTo(w * 0.08, h);
    path.lineTo(w * 0.08, h * 0.57);
    // Left shoulder dome
    path.arcToPoint(
      Offset(w * 0.2, h * 0.57),
      radius: Radius.circular(w * 0.08),
      clockwise: false,
    );
    // Main dome
    path.lineTo(w * 0.35, h * 0.57);
    path.arcToPoint(
      Offset(w * 0.65, h * 0.57),
      radius: Radius.circular(w * 0.22),
      clockwise: false,
    );
    // Right shoulder dome
    path.lineTo(w * 0.8, h * 0.57);
    path.arcToPoint(
      Offset(w * 0.92, h * 0.57),
      radius: Radius.circular(w * 0.08),
      clockwise: false,
    );
    path.lineTo(w * 0.92, h);
    path.close();

    // Right minaret
    final mPath = Path();
    mPath.moveTo(w * 0.955, h * 0.42);
    mPath.lineTo(w * 0.985, h * 0.42);
    mPath.lineTo(w * 0.985, h * 0.16);
    mPath.lineTo(w,         0);
    mPath.lineTo(w * 0.955, h * 0.16);
    mPath.lineTo(w * 0.955, h * 0.42);
    mPath.close();

    canvas.drawPath(path,  paint);
    canvas.drawPath(mPath, paint);
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.color != color;
}

// ── ArabesqueBorder ───────────────────────────────────────────────────────────

/// Gold scalloped wave divider between sections.
class ArabesqueBorder extends StatelessWidget {
  const ArabesqueBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      color: AppColors.sky1,
      child: CustomPaint(
        painter: _ArabesquePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ArabesquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color      = AppColors.goldBd.withOpacity(0.3)
      ..strokeWidth = 0.6
      ..style      = PaintingStyle.stroke;
    final wavePaint = Paint()
      ..color      = AppColors.goldBd
      ..strokeWidth = 0.8
      ..style      = PaintingStyle.stroke;

    // Centre line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // Scalloped wave
    const step = 18.0;
    final path = Path();
    for (double x = 0; x < size.width; x += step) {
      path.moveTo(x, size.height / 2);
      path.relativeCubicTo(step / 4, -5, step * 3 / 4, -5, step, 0);
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_ArabesquePainter old) => false;
}

// ── KaabaIcon ─────────────────────────────────────────────────────────────────

/// Simple stylised Kaaba silhouette.
class KaabaIcon extends StatelessWidget {
  const KaabaIcon({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _KaabaPainter()),
    );
  }
}

class _KaabaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = AppColors.sandDeep;
    final goldPaint = Paint()
      ..color      = AppColors.goldBd
      ..strokeWidth = 1.2
      ..style      = PaintingStyle.stroke;

    // Body
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.25, w * 0.8, h * 0.70), bodyPaint);

    // Kiswah band
    canvas.drawLine(Offset(w * 0.1, h * 0.55), Offset(w * 0.9, h * 0.55), goldPaint);

    // Arch door
    final door = Path()
      ..moveTo(w * 0.35, h * 0.95)
      ..lineTo(w * 0.35, h * 0.60)
      ..arcToPoint(
        Offset(w * 0.65, h * 0.60),
        radius: Radius.circular(w * 0.15),
        clockwise: false,
      )
      ..lineTo(w * 0.65, h * 0.95);
    canvas.drawPath(door, bodyPaint..color = AppColors.sky3);
    canvas.drawPath(door, goldPaint);

    // Roof ledge
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.20, w * 0.90, h * 0.08),
      Paint()..color = AppColors.sandMid,
    );
  }

  @override
  bool shouldRepaint(_KaabaPainter old) => false;
}

// ── OctaStar ──────────────────────────────────────────────────────────────────

/// 8-pointed Islamic star.
class OctaStar extends StatelessWidget {
  const OctaStar({super.key, this.size = 16, this.color = AppColors.goldWarm});
  final double size;
  final Color  color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _OctaStarPainter(color: color)),
      );
}

class _OctaStarPainter extends CustomPainter {
  _OctaStarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx    = size.width / 2;
    final cy    = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.42;
    const pts   = 8;
    final path  = Path();

    for (var i = 0; i < pts * 2; i++) {
      final angle  = (math.pi / pts) * i - math.pi / 2;
      final radius = i.isEven ? outer : inner;
      final x      = cx + radius * math.cos(angle);
      final y      = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OctaStarPainter old) => old.color != color;
}

// ── HolyDivider ───────────────────────────────────────────────────────────────

/// Gold gradient rule with OctaStar centre.
class HolyDivider extends StatelessWidget {
  const HolyDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.goldBd],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: OctaStar(size: 14),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.goldBd, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ScreenHeader ──────────────────────────────────────────────────────────────

/// Haramain Night screen title bar with optional Arabic subtitle.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.arabic});
  final String  title;
  final String? arabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sky1, AppColors.sky3],
        ),
        border: Border(bottom: BorderSide(color: AppColors.goldBd)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.marble,
            ),
          ),
          if (arabic != null)
            Text(
              arabic!,
              style: const TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 18,
                color: AppColors.goldWarm,
              ),
              textDirection: TextDirection.rtl,
            ),
        ],
      ),
    );
  }
}

// ── VBadge ────────────────────────────────────────────────────────────────────

enum VBadgeType { official, community, unverified }

/// Verification status badge pill.
class VBadge extends StatelessWidget {
  const VBadge({super.key, required this.type, required this.isBn});
  final VBadgeType type;
  final bool       isBn;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (type) {
      VBadgeType.official    => (AppColors.domePale,  isBn ? 'যাচাইকৃত' : 'Verified'),
      VBadgeType.community   => (AppColors.goldWarm,  isBn ? 'কমিউনিটি' : 'Community'),
      VBadgeType.unverified  => (AppColors.sandMid,   isBn ? 'অযাচাইকৃত' : 'Unverified'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

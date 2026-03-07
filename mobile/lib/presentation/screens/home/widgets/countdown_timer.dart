import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatting.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({
    required this.remaining,
    required this.lang,
    this.large = false,
    super.key,
  });

  final Duration remaining;
  final String   lang;
  final bool     large;

  @override
  Widget build(BuildContext context) {
    final hms = Formatting.formatCountdownHMS(remaining, lang);
    final color = _countdownColor(remaining);

    if (large) {
      return Text(
        hms,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 2,
        ),
      );
    }

    return Text(
      hms,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Color _countdownColor(Duration d) {
    if (d.inMinutes > 60) return AppColors.success;
    if (d.inMinutes > 30) return AppColors.warning;
    return AppColors.error;
  }
}

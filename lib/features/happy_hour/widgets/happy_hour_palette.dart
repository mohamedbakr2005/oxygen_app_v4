import 'package:flutter/material.dart';

class HappyHourPalette {
  const HappyHourPalette._();

  static const Color accent = Color(0xFF23A26D);
  static const Color accentDark = Color(0xFF157347);
  static const Color timer = Color(0xFF1E293B);
  static const Color badgeTimer = Color(0xFFE53935);
  static const Color subtitle = Color(0xFF157347);

  static Color card(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Color.alphaBlend(const Color(0xFF23A26D).withValues(alpha: 0.16), Theme.of(context).cardColor)
        : const Color(0xFFF0FAF4);
  }

  static Color border(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF23A26D).withValues(alpha: 0.35)
        : const Color(0xFF23A26D).withValues(alpha: 0.22);
  }

  static const Color milestoneAccent = Color(0xFF23A26D);

  static Color milestoneCard(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Color.alphaBlend(const Color(0xFF23A26D).withValues(alpha: 0.16), Theme.of(context).cardColor)
        : const Color(0xFFF0FAF4);
  }

  static Color milestoneTrack(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFD1F2E0);
  }

  static Color track(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFD1F2E0);
  }
}

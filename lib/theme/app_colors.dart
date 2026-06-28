import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Purple
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D6);
  static const Color primaryLight = Color(0xFF9B94FF);
  static const Color primarySurface = Color(0xFFF0EEFF);

  // Accent - Red/Pink
  static const Color accent = Color(0xFFE53935);
  static const Color accentDark = Color(0xFFB71C1C);
  static const Color accentLight = Color(0xFFEF9A9A);
  static const Color accentSurface = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6), Color(0xFFE53935)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A42D6), Color(0xFF6C63FF), Color(0xFF8E55C8)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D1B69), Color(0xFF5C35A5), Color(0xFF9B2335)],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient instapayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF0288D1)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00695C), Color(0xFF00897B)],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
  );

  // Neutral Colors
  static const Color background = Color(0xFFF8F7FF);
  static const Color backgroundDark = Color(0xFF0F0E1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFADB5BD);

  // Status Colors
  static const Color success = Color(0xFF00897B);
  static const Color successLight = Color(0xFFE0F2F1);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Shadow Colors
  static Color shadowPrimary = primary.withOpacity(0.3);
  static Color shadowDark = Colors.black.withOpacity(0.15);
  static Color shadowLight = Colors.black.withOpacity(0.08);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.25);

  // Transaction type colors
  static const Color transferColor = Color(0xFF6C63FF);
  static const Color withdrawColor = Color(0xFFE53935);
  static const Color depositColor = Color(0xFF00897B);
}

import 'package:flutter/material.dart';

class AppConstants {
  // Default admin credentials (seeded on first run)
  static const String defaultAdminEmail = 'admin@reviewer.com';
  static const String defaultAdminPassword = 'Admin123';

  // App info
  static const String appName = 'Reviewer';
  static const String appTagline = 'Ace your academic terms';

  // Colors
  static const Color primaryColor = Color(0xFF1A237E);      // Deep Indigo
  static const Color primaryLight = Color(0xFF3949AB);      // Indigo 600
  static const Color accentColor = Color(0xFF00BCD4);       // Cyan
  static const Color successColor = Color(0xFF43A047);      // Green
  static const Color errorColor = Color(0xFFE53935);        // Red
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  // Font sizes
  static const double fontSmall = 12.0;
  static const double fontBody = 14.0;
  static const double fontTitle = 18.0;
  static const double fontLarge = 22.0;
  static const double fontXLarge = 28.0;

  // Elevation
  static const double cardElevation = 3.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration splashDuration = Duration(seconds: 2);
}

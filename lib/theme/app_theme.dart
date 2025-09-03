import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the social media management application.
/// Implements a Dark Professional theme optimized for mobile productivity and extended use.
class AppTheme {
  AppTheme._();

  // Core brand colors based on Dark Professional theme
  static const Color primary = Color(0xFF6B46C1); // Core brand purple
  static const Color secondary = Color(0xFF10B981); // Success green
  static const Color background = Color(0xFF1A1A1A); // Deep neutral background
  static const Color surface = Color(0xFF2D2D2D); // Elevated surface color
  static const Color onPrimary = Color(0xFFFFFFFF); // High contrast on purple
  static const Color onSecondary =
      Color(0xFF000000); // Maximum contrast on green
  static const Color onBackground = Color(0xFFE5E5E5); // Primary text on dark
  static const Color onSurface = Color(0xFFB3B3B3); // Secondary text color
  static const Color error = Color(0xFFEF4444); // Alert red for errors
  static const Color warning = Color(0xFFF59E0B); // Attention orange

  // Extended color palette for professional UI
  static const Color cardColor = Color(0xFF2D2D2D);
  static const Color dialogColor = Color(0xFF2D2D2D);
  static const Color dividerColor = Color(0xFF404040);
  static const Color shadowColor = Color(0x1A000000);

  // Text emphasis levels for information hierarchy
  static const Color textHighEmphasis = Color(0xFFE5E5E5); // 90% opacity
  static const Color textMediumEmphasis = Color(0xFFB3B3B3); // 70% opacity
  static const Color textDisabled = Color(0xFF666666); // 40% opacity

  /// Dark theme optimized for social media management workflows
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withValues(alpha: 0.2),
      onPrimaryContainer: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondary.withValues(alpha: 0.2),
      onSecondaryContainer: onSecondary,
      tertiary: warning,
      onTertiary: Color(0xFF000000),
      tertiaryContainer: warning.withValues(alpha: 0.2),
      onTertiaryContainer: Color(0xFF000000),
      error: error,
      onError: onPrimary,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: textMediumEmphasis,
      outline: dividerColor,
      outlineVariant: dividerColor.withValues(alpha: 0.5),
      shadow: shadowColor,
      scrim: Color(0x80000000),
      inverseSurface: Color(0xFFE5E5E5),
      onInverseSurface: Color(0xFF1A1A1A),
      inversePrimary: primary,
    ),
    scaffoldBackgroundColor: background,
    cardColor: cardColor,
    dividerColor: dividerColor,

    // AppBar theme for professional mobile interface
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textHighEmphasis,
      elevation: 2.0,
      shadowColor: shadowColor,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: textHighEmphasis,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: textHighEmphasis,
        size: 24,
      ),
    ),

    // Card theme with subtle elevation for content hierarchy
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2.0,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation optimized for gesture-first navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Contextual floating action button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 4.0,
      focusElevation: 6.0,
      hoverElevation: 6.0,
      highlightElevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),

    // Button themes for professional interactions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimary,
        backgroundColor: primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography system using Inter for optimal mobile readability
    textTheme: _buildTextTheme(),

    // Input decoration for form elements
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surface,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumEmphasis,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabled,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: error,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Interactive element themes
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return textMediumEmphasis;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.5);
        }
        return dividerColor;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimary),
      side: BorderSide(color: dividerColor, width: 2),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return dividerColor;
      }),
    ),

    // Progress and loading indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: dividerColor,
      circularTrackColor: dividerColor,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.2),
      inactiveTrackColor: dividerColor,
      valueIndicatorColor: primary,
      valueIndicatorTextStyle: GoogleFonts.inter(
        color: onPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Tab bar theme for content organization
    tabBarTheme: TabBarTheme(
      labelColor: primary,
      unselectedLabelColor: textMediumEmphasis,
      indicatorColor: primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    // Tooltip theme for contextual help
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Color(0xFF404040),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        color: textHighEmphasis,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Snackbar theme for user feedback
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF404040),
      contentTextStyle: GoogleFonts.inter(
        color: textHighEmphasis,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4.0,
    ),

    // Dialog theme for modal interactions
    dialogTheme: DialogTheme(
      backgroundColor: dialogColor,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: textHighEmphasis,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: textMediumEmphasis,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // List tile theme for content lists
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: primary.withValues(alpha: 0.1),
      iconColor: textMediumEmphasis,
      textColor: textHighEmphasis,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Chip theme for tags and filters
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary.withValues(alpha: 0.2),
      disabledColor: dividerColor,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
  );

  /// Light theme (minimal implementation for system compatibility)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withValues(alpha: 0.1),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondary.withValues(alpha: 0.1),
      onSecondaryContainer: secondary,
      tertiary: warning,
      onTertiary: Color(0xFF000000),
      tertiaryContainer: warning.withValues(alpha: 0.1),
      onTertiaryContainer: warning,
      error: error,
      onError: onPrimary,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      onSurfaceVariant: Color(0xFF666666),
      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFF0F0F0),
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: surface,
      onInverseSurface: onSurface,
      inversePrimary: primary,
    ),
    textTheme: _buildTextTheme(isLight: true),
  );

  /// Build typography system optimized for mobile social media management
  static TextTheme _buildTextTheme({bool isLight = false}) {
    final Color textColor = isLight ? Color(0xFF1A1A1A) : textHighEmphasis;
    final Color textColorMedium =
        isLight ? Color(0xFF666666) : textMediumEmphasis;
    final Color textColorDisabled = isLight ? Color(0xFFB3B3B3) : textDisabled;

    return TextTheme(
      // Display styles for major headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles for section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles for cards and components
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body text for content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColorMedium,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles for UI elements
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColorMedium,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColorDisabled,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Data typography using JetBrains Mono for analytics and metrics
  static TextStyle dataTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    bool isLight = false,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? (isLight ? Color(0xFF1A1A1A) : textHighEmphasis),
      letterSpacing: 0,
      height: 1.4,
    );
  }
}

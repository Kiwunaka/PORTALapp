import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);

  final AppThemeMode mode;
  final String fontFamily;

  ThemeData lightTheme(ColorScheme? _) {
    return _buildTheme(
      scheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF0C8B80),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF3F7DFF),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFFE85FAD),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFFC23636),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF111827),
        surfaceContainerHighest: Color(0xFFE9F0FB),
        onSurfaceVariant: Color(0xFF5B667B),
        outline: Color(0xFFB7C1D4),
        outlineVariant: Color(0xFFD8E1EE),
        shadow: Color(0x1A0F172A),
        scrim: Color(0x4D0F172A),
        inverseSurface: Color(0xFF0F172A),
        onInverseSurface: Color(0xFFF8FAFC),
        inversePrimary: Color(0xFF7CFFF3),
        surfaceTint: Color(0xFF8FC9FF),
        primaryContainer: Color(0xFFD9F9F3),
        onPrimaryContainer: Color(0xFF003731),
        secondaryContainer: Color(0xFFDDE8FF),
        onSecondaryContainer: Color(0xFF142B62),
        tertiaryContainer: Color(0xFFFFD9EC),
        onTertiaryContainer: Color(0xFF5D103A),
        errorContainer: Color(0xFFFDE2E1),
        onErrorContainer: Color(0xFF561313),
      ),
      tokens: PremiumThemeTokens.light,
      buttonTheme: ConnectionButtonTheme.light,
      scaffoldBackground: const Color(0xFFF4F7FB),
    );
  }

  ThemeData darkTheme(ColorScheme? _) {
    return _buildTheme(
      scheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF7CFFF3),
        onPrimary: Color(0xFF002F2C),
        secondary: Color(0xFF8DB8FF),
        onSecondary: Color(0xFF102B5F),
        tertiary: Color(0xFFFF8FD5),
        onTertiary: Color(0xFF5A1034),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: Color(0xFF111A2E),
        onSurface: Color(0xFFF4F7FB),
        surfaceContainerHighest: Color(0xFF1A2740),
        onSurfaceVariant: Color(0xFFB8C5E0),
        outline: Color(0xFF73809A),
        outlineVariant: Color(0xFF33425D),
        shadow: Color(0x8C010715),
        scrim: Color(0xB3000000),
        inverseSurface: Color(0xFFF4F7FB),
        onInverseSurface: Color(0xFF0F172A),
        inversePrimary: Color(0xFF0C8B80),
        surfaceTint: Color(0xFF7EB8FF),
        primaryContainer: Color(0xFF083936),
        onPrimaryContainer: Color(0xFFABFFF6),
        secondaryContainer: Color(0xFF1D396E),
        onSecondaryContainer: Color(0xFFDDE8FF),
        tertiaryContainer: Color(0xFF6E1946),
        onTertiaryContainer: Color(0xFFFFD9EC),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
      ),
      tokens: PremiumThemeTokens.dark,
      buttonTheme: ConnectionButtonTheme.dark,
      scaffoldBackground:
          mode.trueBlack ? Colors.black : const Color(0xFF0B1020),
    );
  }

  ThemeData _buildTheme({
    required ColorScheme scheme,
    required PremiumThemeTokens tokens,
    required ConnectionButtonTheme buttonTheme,
    required Color scaffoldBackground,
  }) {
    final textTheme = _buildTextTheme(scheme);
    final font = fontFamily.isEmpty ? null : fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: font,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: Colors.transparent,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[
        tokens,
        buttonTheme,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardTheme(
        margin: EdgeInsets.zero,
        color: tokens.shellSurface,
        shadowColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: tokens.outlineSoft),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: tokens.shellSurfaceStrong,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: tokens.outlineSoft),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.shellSurfaceMuted,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: tokens.outlineSoft),
        ),
        side: BorderSide(color: tokens.outlineSoft),
        labelStyle: textTheme.labelLarge,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minLeadingWidth: 28,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.titleSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: tokens.outlineSoft),
          textStyle: textTheme.titleSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: scheme.primary,
          textStyle: textTheme.titleSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.shellSurfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: tokens.outlineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: tokens.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.55)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        backgroundColor: tokens.navSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.brightness == Brightness.light
            ? scheme.primary.withOpacity(0.12)
            : scheme.primary.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : tokens.textMuted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        useIndicator: true,
        indicatorColor: scheme.brightness == Brightness.light
            ? scheme.primary.withOpacity(0.12)
            : scheme.primary.withOpacity(0.18),
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 22),
        unselectedIconTheme: IconThemeData(color: tokens.textMuted, size: 22),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: tokens.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: tokens.shellSurfaceStrong,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: tokens.outlineSoft),
        ),
      ),
    );
  }

  TextTheme _buildTextTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
    ).textTheme;

    return base.copyWith(
      displayLarge: _style(
        base.displayLarge,
        size: 60,
        height: 1.0,
        weight: FontWeight.w700,
        spacing: -1.8,
      ),
      displayMedium: _style(
        base.displayMedium,
        size: 50,
        height: 1.02,
        weight: FontWeight.w700,
        spacing: -1.4,
      ),
      displaySmall: _style(
        base.displaySmall,
        size: 40,
        height: 1.06,
        weight: FontWeight.w700,
        spacing: -1.0,
      ),
      headlineLarge: _style(
        base.headlineLarge,
        size: 34,
        height: 1.08,
        weight: FontWeight.w700,
        spacing: -0.8,
      ),
      headlineMedium: _style(
        base.headlineMedium,
        size: 30,
        height: 1.1,
        weight: FontWeight.w700,
        spacing: -0.7,
      ),
      headlineSmall: _style(
        base.headlineSmall,
        size: 24,
        height: 1.15,
        weight: FontWeight.w700,
        spacing: -0.4,
      ),
      titleLarge: _style(
        base.titleLarge,
        size: 20,
        height: 1.2,
        weight: FontWeight.w700,
        spacing: -0.2,
      ),
      titleMedium: _style(
        base.titleMedium,
        size: 16,
        height: 1.25,
        weight: FontWeight.w600,
        spacing: -0.1,
      ),
      titleSmall: _style(
        base.titleSmall,
        size: 14,
        height: 1.2,
        weight: FontWeight.w600,
        spacing: 0.1,
      ),
      bodyLarge: _style(base.bodyLarge,
          size: 16, height: 1.45, weight: FontWeight.w500,),
      bodyMedium: _style(base.bodyMedium,
          size: 14, height: 1.45, weight: FontWeight.w500,),
      bodySmall: _style(base.bodySmall,
          size: 12, height: 1.35, weight: FontWeight.w500,),
      labelLarge: _style(base.labelLarge,
          size: 13, height: 1.2, weight: FontWeight.w700, spacing: 0.3,),
      labelMedium: _style(base.labelMedium,
          size: 12, height: 1.2, weight: FontWeight.w600, spacing: 0.25,),
      labelSmall: _style(base.labelSmall,
          size: 11, height: 1.2, weight: FontWeight.w600, spacing: 0.25,),
    );
  }

  TextStyle _style(
    TextStyle? base, {
    required double size,
    required double height,
    required FontWeight weight,
    double spacing = 0,
  }) {
    return (base ?? const TextStyle()).copyWith(
      fontFamily: fontFamily.isEmpty ? null : fontFamily,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: spacing,
    );
  }
}

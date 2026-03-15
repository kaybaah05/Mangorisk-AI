import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const background = Color(0xFFFFFFFF);
  static const surface    = Color(0xFFFAFAFA);
  static const primary    = Color(0xFF111111);
  static const secondary  = Color(0xFF6B6B6B);
  static const muted      = Color(0xFFAAAAAA);
  static const border     = Color(0xFFE8E8E8);
  static const accent     = Color(0xFFF5A623);
  static const win        = Color(0xFF16A34A);
  static const loss       = Color(0xFFDC2626);
  static const white      = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: C.background,
      primaryColor: C.primary,
      colorScheme: const ColorScheme.light(
        primary:   C.primary,
        secondary: C.accent,
        surface:   C.surface,
        error:     C.loss,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold,   color: C.primary),
        displayMedium:  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold,   color: C.primary),
        displaySmall:   GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold,   color: C.primary),
        headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,   color: C.primary),
        headlineSmall:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,   color: C.primary),
        titleLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,   color: C.primary),
        titleMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,   color: C.primary),
        bodyLarge:      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: C.secondary),
        bodyMedium:     GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.normal, color: C.secondary),
        bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: C.muted),
        labelSmall:     GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.normal, color: C.muted),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:        C.background,
        foregroundColor:        C.primary,
        elevation:              0,
        scrolledUnderElevation: 0,
        centerTitle:            false,
        titleTextStyle: GoogleFonts.inter(
          fontSize:   18,
          fontWeight: FontWeight.w600,
          color:      C.primary,
        ),
        iconTheme: const IconThemeData(color: C.primary),
      ),

      cardTheme: CardThemeData(
        color:     C.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: C.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: C.primary,
          foregroundColor: C.white,
          elevation:       0,
          minimumSize:     const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize:   15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: C.primary,
          textStyle: GoogleFonts.inter(
            fontSize:   14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   C.surface,
        hintStyle:   GoogleFonts.inter(fontSize: 14, color: C.muted),
        labelStyle:  GoogleFonts.inter(fontSize: 14, color: C.secondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.loss, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.loss, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     C.background,
        selectedItemColor:   C.accent,
        unselectedItemColor: C.muted,
        elevation:           0,
        type:                BottomNavigationBarType.fixed,
        selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      dividerTheme: const DividerThemeData(
        color:     C.border,
        thickness: 1,
        space:     1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor:     C.surface,
        selectedColor:       C.primary,
        labelStyle:          GoogleFonts.inter(fontSize: 12, color: C.secondary),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, color: C.white),
        side:                const BorderSide(color: C.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: C.background,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: C.border),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  C.primary,
        contentTextStyle: GoogleFonts.inter(fontSize: 13, color: C.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

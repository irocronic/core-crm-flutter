// lib/config/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ana Renk Paleti (Örnek - Kendi renklerinizi ekleyin)
const Color primaryColor = Color(0xFF1A73E8); // Google Mavisi gibi
const Color secondaryColor = Color(0xFFFBC02D); // Google Sarısı gibi
const Color accentColor = Color(0xFF188038); // Google Yeşili gibi
const Color errorColor = Color(0xFFD93025); // Google Kırmızısı gibi
const Color backgroundColor = Color(0xFFF5F5F5); // Açık Gri Arkaplan
const Color surfaceColor = Colors.white; // Kartlar vb. için beyaz
const Color textColorPrimary = Color(0xFF202124); // Koyu Gri Metin
const Color textColorSecondary = Color(0xFF5F6368); // Orta Gri Metin

ThemeData buildLightTheme() {
  final baseTheme = ThemeData.light();

  return baseTheme.copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textColorPrimary,
      onBackground: textColorPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // İkonlar vs. için
      elevation: 0,
      titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Açık temada başlık rengi (Opsiyonel, foregroundColor yeterli olabilir)
    ),
    cardTheme: CardThemeData(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: surfaceColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
      headlineLarge: GoogleFonts.lato(fontWeight: FontWeight.bold, color: textColorPrimary),
      headlineMedium: GoogleFonts.lato(fontWeight: FontWeight.bold, color: textColorPrimary),
      headlineSmall: GoogleFonts.lato(fontWeight: FontWeight.bold, color: textColorPrimary),
      titleLarge: GoogleFonts.lato(fontWeight: FontWeight.w600, color: textColorPrimary),
      titleMedium: GoogleFonts.lato(fontWeight: FontWeight.w600, color: textColorPrimary),
      titleSmall: GoogleFonts.lato(fontWeight: FontWeight.w600, color: textColorPrimary),
      bodyLarge: GoogleFonts.lato(color: textColorPrimary),
      bodyMedium: GoogleFonts.lato(color: textColorSecondary),
      labelLarge: GoogleFonts.lato(fontWeight: FontWeight.bold), // Butonlar için
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: primaryColor),
      selectedColor: primaryColor,
      secondarySelectedColor: primaryColor, // Ensure consistency
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    ),
    // Diğer tema özelleştirmeleri...
  );
}

// Karanlık tema için benzer bir yapı oluşturulabilir
ThemeData buildDarkTheme() {
  final baseTheme = ThemeData.dark();
  return baseTheme.copyWith(
    primaryColor: primaryColor, // Veya karanlık tema için farklı bir ana renk
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor, // Veya karanlık tema için daha parlak mavi
      secondary: secondaryColor, // Veya karanlık tema için daha parlak sarı
      surface: Color(0xFF1E1E1E), // Kartlar vb. için koyu gri
      background: Color(0xFF121212),
      error: errorColor, // Kırmızı genellikle aynı kalır
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white, // Koyu yüzeylerde beyaz metin
      onBackground: Colors.white,
      onError: Colors.black, // Kırmızı butonlarda siyah metin
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E), // Koyu AppBar
      foregroundColor: Colors.white, // İkonlar ve genel metin için
      elevation: 0,
      // ------------------------------------
      // DEĞİŞİKLİK BURADA: titleTextStyle'a renk eklendi
      // ------------------------------------
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white, // <<<--- BU SATIR EKLENDİ
      ),
      // ------------------------------------
      // DEĞİŞİKLİK SONU
      // ------------------------------------
    ),
    cardTheme: CardThemeData(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: const Color(0xFF1E1E1E), // Kart rengi
    ),
    // Diğer karanlık tema ayarları...
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0), // Odak rengi aynı kalabilir
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C), // Daha koyu dolgu rengi
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // Ana renk butonlar için genellikle iyi çalışır
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
      headlineLarge: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.lato(color: Colors.white.withOpacity(0.87)),
      bodyMedium: GoogleFonts.lato(color: Colors.white.withOpacity(0.60)),
      labelLarge: GoogleFonts.lato(fontWeight: FontWeight.bold),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.2), // Biraz daha belirgin olabilir
      labelStyle: const TextStyle(color: primaryColor), // Veya daha açık bir renk
      selectedColor: primaryColor,
      secondarySelectedColor: primaryColor,
      checkmarkColor: Colors.black, // Veya seçilen renge göre kontrast
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    ),
  );
}

// ✅ YENİ CLASS: AppTheme
// Hatanın çözümü için buildLightTheme ve buildDarkTheme metotlarını
// bir sınıf içine alıyoruz ki app.dart içinden erişilebilsin.
class AppTheme {
  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();
}
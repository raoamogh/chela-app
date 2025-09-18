import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.purple.shade300, // A nice purple accent
  hintColor: Colors.amberAccent, // Used for accent colors in some widgets
  canvasColor: const Color(0xFF121212), // Dark background for Scaffold
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E), // Slightly lighter dark for cards
  dividerColor: Colors.white12,
  appBarTheme: const AppBarTheme(
    color: Colors.transparent, // AppBar can be transparent to show background
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1A1A1A),
    selectedItemColor: Colors.purple.shade300,
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed, // Use fixed for more than 3 items
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white70),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white54),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.purple, // Base color swatch
    brightness: Brightness.dark,
  ).copyWith(
    secondary: Colors.amberAccent, // Accent color
    background: const Color(0xFF121212), // General background
    surface: const Color(0xFF1E1E1E), // Card/dialog surface
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white70,
    onError: Colors.white,
  ),
  // Input field decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.purple.shade300, width: 2.0),
    ),
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: Colors.white70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.purple.shade300),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple.shade300,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
);
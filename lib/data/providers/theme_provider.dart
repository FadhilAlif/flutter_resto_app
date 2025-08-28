import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ColorSeed _colorSeed = ColorSeed.orange;

  ThemeMode get themeMode => _themeMode;
  ColorSeed get colorSeed => _colorSeed;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setColorSeed(ColorSeed color) {
    _colorSeed = color;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _colorSeed.color,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _colorSeed.color,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}

enum ColorSeed {
  orange(Colors.deepOrange),
  indigo(Colors.indigo),
  purple(Colors.deepPurple),
  green(Colors.green),
  red(Colors.red);

  final Color color;
  const ColorSeed(this.color);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String themeKey = 'theme_mode';
  static const String colorKey = 'color_seed';

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  ColorSeed _colorSeed = ColorSeed.orange;

  ThemeMode get themeMode => _themeMode;
  ColorSeed get colorSeed => _colorSeed;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeString = _prefs.getString(themeKey) ?? 'light';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.light,
    );

    // Load color seed
    final colorSeedString = _prefs.getString(colorKey) ?? 'orange';
    _colorSeed = ColorSeed.values.firstWhere(
      (e) => e.name == colorSeedString,
      orElse: () => ColorSeed.orange,
    );

    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeMode();
    notifyListeners();
  }

  void setColorSeed(ColorSeed color) {
    _colorSeed = color;
    _saveColorSeed();
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final themeModeString = _themeMode.toString().split('.').last;
    await _prefs.setString(themeKey, themeModeString);
  }

  Future<void> _saveColorSeed() async {
    await _prefs.setString(colorKey, _colorSeed.name);
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

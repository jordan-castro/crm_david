import 'package:crm_david/utils/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeModel with ChangeNotifier {
  final darkTheme = ThemeData(
    primaryColor: Colors.black,
    dividerColor: Colors.grey,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    canvasColor: Colors.black,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) => Colors.white,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => Colors.white54,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.black,
      shadowColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(background: Colors.black).copyWith(
          secondary: const Color.fromARGB(255, 141, 81, 81),
        ),
  );

  final lightTheme = ThemeData(
    primaryColor: Colors.white,
    dividerColor: Colors.black,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(background: const Color(0xFFE5E5E5)).copyWith(
          secondary: Colors.black,
        ),
  );

  // A blue-ish theme. Should be primarily blue (background).
  final blueTheme = ThemeData(
    scaffoldBackgroundColor: Colors.blue[200],
    appBarTheme: AppBarTheme(
      color: Colors.blue[300],
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ).headlineLarge,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: Colors.blueGrey[800],
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue[400],
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(secondary: Colors.blueAccent),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );

  // A pink theme
  final pinkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.pink[200],
      appBarTheme: AppBarTheme(
        color: Colors.pink[300],
        toolbarTextStyle: TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headlineLarge,
        titleTextStyle: TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headlineMedium,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pink[400],
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
          .copyWith(secondary: Colors.pinkAccent),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
        iconColor: WidgetStateProperty.all(Colors.white),
      )));

  ThemeMode mode = ThemeMode.system;

  /// La tema nigga.
  ThemeData? _themeData;

  /// El gettor.
  ThemeData getTheme() => _themeData ?? darkTheme;
  // ThemeModel getMode() =>

  ThemeModel() {
    // Synchronizo leando
    StorageManager.readData('themeMode').then((value) {
      // Defaulto es "light" AKA luz
      var themeMode = value ?? 'light';
      // Classifica la _themeData
      if (themeMode == 'light') {
        _themeData = lightTheme;
        mode = ThemeMode.light;
      } else if (themeMode == 'dark') {
        _themeData = darkTheme;
        mode = ThemeMode.dark;
      } else if (themeMode == 'blue') {
        _themeData = blueTheme;
        mode = ThemeMode.dark;
      } else if (themeMode == 'pink') {
        _themeData = pinkTheme;
        mode = ThemeMode.dark;
      }
      notifyListeners();
    });
  }

  // void setDarkMode() async {
  //   _themeData = darkTheme;
  //   StorageManager.saveData('themeMode', 'dark');
  //   StorageManager.saveData('settheme', true);
  //   notifyListeners();
  // }

  void setTheme(ThemeData themeData) async {
    _themeData = themeData;

    var name = "";

    if (themeData == darkTheme) {
      name = "dark";
    } else if (themeData == lightTheme) {
      name = "light";
    } else if (themeData == blueTheme) {
      name = "blue";
    } else if (themeData == pinkTheme) {
      name = "pink";
    }
    StorageManager.saveData('themeMode', name);
    StorageManager.saveData('settheme', true);
    notifyListeners();
  }

  // void setLightMode() async {
  //   _themeData = lightTheme;
  //   StorageManager.saveData('themeMode', 'light');
  //   StorageManager.saveData('settheme', true);
  //   notifyListeners();
  // }

  Future<bool> alreadyHasTheme() async {
    var data = await StorageManager.readData('settheme');
    return data ?? false;
  }

  static ThemeModel of(BuildContext context, {bool listen = true}) =>
      Provider.of<ThemeModel>(context, listen: listen);
}

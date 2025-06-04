import 'package:dji_mapper/layouts/home.dart';
import 'package:dji_mapper/presets/preset_manager.dart';
import 'package:dji_mapper/shared/map_provider.dart';
import 'package:dji_mapper/shared/theme_manager.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  PresetManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ValueListenables()),
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(create: (context) => MapProvider()),
      ],
      child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return Consumer<ThemeManager>(builder: (context, theme, child) {
          return MaterialApp(
            title: 'DJI Mapper',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: lightColorScheme ??
                  ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme ??
                  ColorScheme.fromSeed(
                      seedColor: Colors.blue, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            themeMode: theme.themeMode,
            home: const HomeLayout(),
          );
        });
      }),
    );
  }
}

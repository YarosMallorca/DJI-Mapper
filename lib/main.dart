import 'package:dji_waypoint_mapping/layouts/home.dart';
import 'package:dji_waypoint_mapping/shared/theme_manager.dart';
import 'package:dji_waypoint_mapping/shared/value_listeneables.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      ],
      child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return Consumer<ThemeManager>(builder: (context, theme, child) {
          return MaterialApp(
            title: 'DJI Waypoint Mapping',
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

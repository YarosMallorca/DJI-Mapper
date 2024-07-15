import 'package:dji_mapper/shared/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MappingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MappingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, theme, child) => AppBar(
        title: const Text("DJI Waypoint Mapping"),
        elevation: 10,
        actions: [
          PopupMenuButton(
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: "theme",
                  child: ListTile(
                    leading: Icon(
                        Theme.of(context).brightness == Brightness.light
                            ? Icons.light_mode
                            : Icons.dark_mode),
                    title: const Text("Theme"),
                  )),
              const PopupMenuItem(
                value: "github",
                child: ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: Text("GitHub"),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case "theme":
                  theme.toggleTheme();
                  break;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

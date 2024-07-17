import 'package:dji_mapper/shared/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MappingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MappingAppBar({super.key});

  @override
  State<MappingAppBar> createState() => _MappingAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _MappingAppBarState extends State<MappingAppBar> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        _version = "V${value.version} (build ${value.buildNumber})";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, theme, child) => AppBar(
        title: GestureDetector(
            onTap: () => showAboutDialog(
                context: context,
                applicationVersion: _version,
                applicationLegalese: "© 2024 Yaroslav Syubayev",
                applicationIcon: Image.asset(
                  "assets/logo.png",
                  width: 60,
                )),
            child: const Text("DJI Mapper")),
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
              const PopupMenuItem(
                  value: "help",
                  child: ListTile(
                      leading: Icon(Icons.help_outline),
                      title: Text("Help loading mission"))),
            ],
            onSelected: (value) {
              switch (value) {
                case "theme":
                  theme.toggleTheme();
                  break;
                case "github":
                  launchUrl(
                      Uri.https("github.com", "YarosMallorca/DJI-Mapper"));
                case "help":
                  launchUrl(Uri.https("mavicpilots.com",
                      "/threads/waypoints-how-to-back-up-export-import.135283"));
              }
            },
          )
        ],
      ),
    );
  }
}

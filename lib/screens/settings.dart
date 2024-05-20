import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatabaseConfigScreen extends StatefulWidget {
  static const routeName = "/databaseconfig";
  const DatabaseConfigScreen({super.key});

  @override
  State<DatabaseConfigScreen> createState() => _DatabaseConfigScreenState();
}

class _DatabaseConfigScreenState extends State<DatabaseConfigScreen> {
  final TextEditingController host = TextEditingController();
  final TextEditingController port = TextEditingController();
  final TextEditingController user = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text button with backgroud color
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeModel.darkTheme.primaryColor,
              ),
              onPressed: () {
                themeModel.setTheme(themeModel.darkTheme);
              },
              child: const Text(
                'Dark Theme',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            // Text button for light theme
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeModel.lightTheme.primaryColor,
              ),
              onPressed: () {
                themeModel.setTheme(themeModel.lightTheme);
              },
              child: const Text(
                'Light Theme',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            // Blue theme
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeModel.blueTheme.primaryColor,
              ),
              onPressed: () {
                themeModel.setTheme(themeModel.blueTheme);
              },
              child: const Text(
                'Blue Theme',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            // Pink theme button
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeModel.pinkTheme.primaryColor,
              ),
              onPressed: () {
                themeModel.setTheme(themeModel.pinkTheme);
              },
              child: const Text(
                'Pink Theme',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:oktoast/oktoast.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Colors.blue,
        ),
        body: Consumer<LoadData>(
          builder: (context, loadData, child) {
            if (loadData.settings.isEmpty) {
              loadData.loadSettings();
              return child!;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var setting in loadData.settings)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            setting['name'],
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            setting['value'],
                            style: const TextStyle(fontSize: 15.0),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}

import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  String _macAddress = "";

  set macAddress(String value) {
    _macAddress = value;
    notifyListeners();
  }

  String get macAddress => _macAddress;
}

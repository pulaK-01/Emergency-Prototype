import 'package:flutter/material.dart';

class DriverProvider extends ChangeNotifier {
  bool isOnline = false;

  void toggleOnlineStatus() {
    isOnline = !isOnline;
    notifyListeners();
  }
}

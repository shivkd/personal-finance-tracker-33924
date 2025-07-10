import 'package:flutter/material.dart';

// Simple in-app notification state holder for critical budget/low-balance alerts
// PUBLIC_INTERFACE
class NotificationProvider extends ChangeNotifier {
  List<String> notifications = [];

  // PUBLIC_INTERFACE
  void setNotifications(List<String> notes) {
    notifications = notes;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  void addNotification(String msg) {
    notifications.add(msg);
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }
}

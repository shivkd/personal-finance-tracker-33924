import 'package:flutter/material.dart';
import '../services/backend_service.dart';

// PUBLIC_INTERFACE
class DashboardProvider extends ChangeNotifier {
  double balance = 0.0;
  List<Map<String, dynamic>> recentTransactions = [];
  List<String> budgetAlerts = [];
  bool isLoading = false;

  // PUBLIC_INTERFACE
  Future<void> fetchDashboardData(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final dashboard = await BackendService.getDashboard(token);
      balance = dashboard['balance'] ?? 0.0;
      recentTransactions = List<Map<String, dynamic>>.from(dashboard['recent_transactions'] ?? []);
      budgetAlerts = List<String>.from(dashboard['budget_alerts'] ?? []);
    } catch (_) {
      // Optionally set error message
    }
    isLoading = false;
    notifyListeners();
  }
}

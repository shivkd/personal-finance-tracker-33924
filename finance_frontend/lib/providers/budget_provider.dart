import 'package:flutter/material.dart';
import '../services/backend_service.dart';

// PUBLIC_INTERFACE
class BudgetProvider extends ChangeNotifier {
  List<Map<String, dynamic>> budgets = [];
  bool isLoading = false;

  // PUBLIC_INTERFACE
  Future<void> fetchBudgets(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      budgets = await BackendService.getBudgets(token);
    } catch (_) {
      budgets = [];
    }
    isLoading = false;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> addBudget(Map<String, dynamic> payload, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.addBudget(payload, token);
      if (success) await fetchBudgets(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> editBudget(
      int budgetId, Map<String, dynamic> payload, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.editBudget(budgetId, payload, token);
      if (success) await fetchBudgets(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> deleteBudget(int budgetId, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.deleteBudget(budgetId, token);
      if (success) await fetchBudgets(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }
}

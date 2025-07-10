import 'package:flutter/material.dart';
import '../services/backend_service.dart';

// PUBLIC_INTERFACE
class TransactionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;

  // PUBLIC_INTERFACE
  Future<void> fetchTransactions(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await BackendService.getTransactions(token);
      transactions = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      transactions = [];
    }
    isLoading = false;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> addTransaction(Map<String, dynamic> payload, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.addTransaction(payload, token);
      if (success) await fetchTransactions(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> editTransaction(
      int transactionId, Map<String, dynamic> payload, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.editTransaction(transactionId, payload, token);
      if (success) await fetchTransactions(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> deleteTransaction(int transactionId, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await BackendService.deleteTransaction(transactionId, token);
      if (success) await fetchTransactions(token);
      isLoading = false;
      return success;
    } catch (_) {
      isLoading = false;
      return false;
    }
  }
}

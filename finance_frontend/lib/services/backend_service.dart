import 'dart:convert';
import 'package:http/http.dart' as http;

// Update this URL to your FastAPI backend endpoint
const String backendUrl = 'http://127.0.0.1:8000';

// PUBLIC_INTERFACE
class BackendService {
  // PUBLIC_INTERFACE
  static Future<Map<String, dynamic>> getDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$backendUrl/dashboard/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Dashboard fetch failed');
    }
  }

  // PUBLIC_INTERFACE
  static Future<List<Map<String, dynamic>>> getTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$backendUrl/transactions/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Transactions fetch failed');
    }
  }

  // PUBLIC_INTERFACE
  static Future<bool> addTransaction(Map<String, dynamic> payload, String token) async {
    final response = await http.post(
      Uri.parse('$backendUrl/transactions/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );
    return response.statusCode == 201;
  }

  // PUBLIC_INTERFACE
  static Future<bool> editTransaction(
      int transactionId, Map<String, dynamic> payload, String token) async {
    final response = await http.put(
      Uri.parse('$backendUrl/transactions/$transactionId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );
    return response.statusCode == 200;
  }

  // PUBLIC_INTERFACE
  static Future<bool> deleteTransaction(int transactionId, String token) async {
    final response = await http.delete(
      Uri.parse('$backendUrl/transactions/$transactionId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  // PUBLIC_INTERFACE
  static Future<List<Map<String, dynamic>>> getBudgets(String token) async {
    final response = await http.get(
      Uri.parse('$backendUrl/budgets/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Budgets fetch failed');
    }
  }

  // PUBLIC_INTERFACE
  static Future<bool> addBudget(Map<String, dynamic> payload, String token) async {
    final response = await http.post(
      Uri.parse('$backendUrl/budgets/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );
    return response.statusCode == 201;
  }

  // PUBLIC_INTERFACE
  static Future<bool> editBudget(
      int budgetId, Map<String, dynamic> payload, String token) async {
    final response = await http.put(
      Uri.parse('$backendUrl/budgets/$budgetId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );
    return response.statusCode == 200;
  }

  // PUBLIC_INTERFACE
  static Future<bool> deleteBudget(int budgetId, String token) async {
    final response = await http.delete(
      Uri.parse('$backendUrl/budgets/$budgetId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for budget management.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Goals'),
      ),
      body: const Center(
        child: Text(
          "Budget management screen placeholder",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

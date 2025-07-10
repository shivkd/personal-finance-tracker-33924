import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In full implementation, would use Provider to fetch and display dashboard data.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text(
          "Dashboard content goes here",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Import Supabase

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initializeDashboard();
      initialized = true;
    }
  }

  Future<void> initializeDashboard() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token != null) {
      await dashboardProvider.fetchDashboardData(token);
      // Set notifications from dashboard alerts
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.setNotifications(dashboardProvider.budgetAlerts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    Widget errorOrEmptyDashboard() {
      if (!dashboardProvider.isLoading &&
          dashboardProvider.balance == 0.0 &&
          dashboardProvider.recentTransactions.isEmpty &&
          dashboardProvider.budgetAlerts.isEmpty) {
        // Could be first time or fetch error; communicate both
        return Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Center(
            child: Text(
              "Could not load dashboard content.\n(Check connection or try later.)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade400, fontSize: 16),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          )
        ],
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => initializeDashboard(),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _BalanceCard(balance: dashboardProvider.balance),
                  const SizedBox(height: 24),
                  errorOrEmptyDashboard(),
                  if (notificationProvider.notifications.isNotEmpty)
                    _AlertList(notifications: notificationProvider.notifications),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...dashboardProvider.recentTransactions.isEmpty
                      ? [const Text('No recent transactions.')]
                      : dashboardProvider.recentTransactions.take(5).map(
                          (tx) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.payments_outlined),
                              title: Text(tx['description'] ?? 'Transaction'),
                              subtitle: Text(
                                tx['date'] != null ? tx['date'].toString() : '',
                              ),
                              trailing: Text(
                                '\$${tx['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (tx['amount'] ?? 0) < 0
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text("View all transactions"),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/transactions');
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: const Text("Manage Budgets"),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/budget');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Current Balance",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  final List<String> notifications;
  const _AlertList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Alerts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 4),
        ...notifications.map(
          (msg) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(msg, style: const TextStyle(color: Colors.red))),
              ],
            ),
          ),
        )
      ],
    );
  }
}

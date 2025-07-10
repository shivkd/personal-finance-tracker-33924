import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

// PUBLIC_INTERFACE
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications.",
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final msg = notificationProvider.notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: Text(
                    msg,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
            ),
      floatingActionButton: notificationProvider.notifications.isNotEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                notificationProvider.clearNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All notifications cleared.")),
                );
              },
              label: const Text("Clear All"),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            )
          : null,
    );
  }
}

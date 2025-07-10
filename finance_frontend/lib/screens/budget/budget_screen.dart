import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Import Supabase

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initBudgets();
      initialized = true;
    }
  }

  // Helper to get token because accessToken needs async sometimes with Supabase v2.
  Future<String?> getAccessToken(AuthProvider provider) async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  Future<void> initBudgets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final token = await getAccessToken(authProvider);
    if (token != null) {
      await budgetProvider.fetchBudgets(token);
    }
  }

  Widget apiErrorOverlay(BudgetProvider budgetProvider) {
    if (!budgetProvider.isLoading && budgetProvider.budgets.isEmpty) {
      return const Center(
        child: Text(
          'No budgets yet. Add your first budget!',
          style: TextStyle(fontSize: 17),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final Future<String?> tokenFuture = getAccessToken(authProvider);

    return FutureBuilder<String?>(
      future: tokenFuture,
      builder: (context, snapshot) {
        final token = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Budgets & Goals'),
          ),
          body: budgetProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: initBudgets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (budgetProvider.budgets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: apiErrorOverlay(budgetProvider),
                        ),
                      if (budgetProvider.budgets.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: budgetProvider.budgets.length,
                            itemBuilder: (context, idx) {
                              final b = budgetProvider.budgets[idx];
                              final double spent = (b['spent'] ?? 0.0) is num
                                  ? (b['spent'] ?? 0.0)
                                  : double.tryParse(b['spent']?.toString() ?? '0.0') ?? 0.0;
                              final double limit = (b['limit'] ?? 0.0) is num
                                  ? (b['limit'] ?? 0.0)
                                  : double.tryParse(b['limit']?.toString() ?? '0.0') ?? 0.0;
                              final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                              return Card(
                                child: ListTile(
                                  title: Text(b['category'] ?? 'Budget'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearPercentIndicator(
                                        lineHeight: 8,
                                        percent: progress,
                                        progressColor: progress >= 1.0 ? Colors.red : Theme.of(context).colorScheme.primary,
                                        backgroundColor: Colors.grey.shade300,
                                        animation: true,
                                        barRadius: const Radius.circular(4),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("\$${spent.toStringAsFixed(2)} spent of \$${limit.toStringAsFixed(2)}"),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                                      const PopupMenuItem(value: 'delete', child: Text("Delete")),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        // No async gap, safe to use context
                                        showAddEditDialog(context, b, token);
                                      } else if (value == 'delete') {
                                        // Use a helper method to handle async logic after getting out of this sync callback.
                                        onDeleteBudget(b['id'], token, context);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    // No async gap, context is safe to use here.
                                    showAddEditDialog(context, b, token);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add Budget',
            child: const Icon(Icons.add),
            onPressed: () async {
              final tokenVal = await tokenFuture; // This is safe; only one await, after which we check mounted
              if (!mounted) return;
              showAddEditDialog(context, null, tokenVal);
            },
          ),
        );
      },
    );
  }

  // Helper for delete operation to handle async gap
  Future<void> onDeleteBudget(int? id, String? token, BuildContext context) async {
    if (token == null || id == null) return;
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await bp.deleteBudget(id, token);
    if (!context.mounted) return;
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text("Deleted")));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text("Error deleting budget.")));
    }
  }

  void showAddEditDialog(BuildContext context, Map<String, dynamic>? b, String? token) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddEditBudgetDialog(
          initialData: b,
          token: token,
        ),
      ),
    );
  }
}

// _showAddEditDialog has been removed as it's not referenced.

class AddEditBudgetDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? token;
  const AddEditBudgetDialog({super.key, this.initialData, required this.token});

  @override
  State<AddEditBudgetDialog> createState() => _AddEditBudgetDialogState();
}

class _AddEditBudgetDialogState extends State<AddEditBudgetDialog> {
  late TextEditingController _categoryCtrl;
  late TextEditingController _limitCtrl;
  @override
  void initState() {
    super.initState();
    _categoryCtrl = TextEditingController(text: widget.initialData?['category'] ?? '');
    _limitCtrl = TextEditingController(text: widget.initialData?['limit']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    bool isEdit = widget.initialData != null;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? "Edit Budget" : "Add Budget", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _limitCtrl,
              decoration: const InputDecoration(labelText: 'Limit (\$)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'category': _categoryCtrl.text.trim(),
                  'limit': double.tryParse(_limitCtrl.text) ?? 0.0,
                };
                if (widget.token == null) return;
                bool success;
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                success = (isEdit && widget.initialData?['id'] != null)
                    ? await bp.editBudget(widget.initialData!['id'], payload, widget.token!)
                    : await bp.addBudget(payload, widget.token!);
                if (!context.mounted) return;
                if (success) {
                  navigator.pop();
                  if (!context.mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text(isEdit ? "Saved." : "Budget added.")));
                } else {
                  messenger.showSnackBar(const SnackBar(content: Text("Error saving budget.")));
                }
              },
              child: Text(isEdit ? "Save Changes" : "Add Budget"),
            ),
            if (isEdit)
              TextButton(
                onPressed: () {
                  // No async gap, safe usage
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Import Supabase

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initTransactions();
      initialized = true;
    }
  }

  Future<String?> getAccessToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  Future<void> initTransactions() async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final token = await getAccessToken();
    if (token != null) {
      await txProvider.fetchTransactions(token);
    }
  }

  Widget errorOrEmpty(TransactionProvider txProvider) {
    if (!txProvider.isLoading && txProvider.transactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions to show.\n(Check your connection if you expect items.)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);

    return FutureBuilder<String?>(
      future: getAccessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Transactions'),
          ),
          body: txProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: initTransactions,
                  child: txProvider.transactions.isEmpty
                      ? errorOrEmpty(txProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: txProvider.transactions.length,
                          itemBuilder: (context, idx) {
                            final tx = txProvider.transactions[idx];
                            return Dismissible(
                              key: ValueKey(tx['id']),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.redAccent,
                                padding: const EdgeInsets.only(right: 30),
                                child: const Icon(Icons.delete, color: Colors.white, size: 30),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Transaction"),
                                    content: const Text("Are you sure you want to delete this transaction?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete")),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) async {
                                if (token == null) return;
                                final ok = await txProvider.deleteTransaction(tx['id'], token);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ok ? "Transaction deleted." : "Error deleting transaction.")),
                                  );
                                }
                              },
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      tx['category'] != null && tx['category'].isNotEmpty
                                          ? tx['category'][0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: Text(tx['description'] ?? 'Transaction'),
                                  subtitle: Text(
                                    tx['date'] != null ? tx['date'].toString() : '',
                                  ),
                                  trailing: Text(
                                    '\$${tx['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (tx['amount'] ?? 0) < 0 ? Colors.red : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  onTap: () {
                                    showAddEditDialog(context, tx, token);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add Transaction',
            child: const Icon(Icons.add),
            onPressed: () => showAddEditDialog(context, null, token),
          ),
        );
      },
    );
  }

  void showAddEditDialog(BuildContext context, Map<String, dynamic>? tx, String? token) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddEditTransactionDialog(
          initialData: tx,
          token: token,
        ),
      ),
    );
  }
}

class AddEditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? token;
  const AddEditTransactionDialog({super.key, this.initialData, required this.token});

  @override
  State<AddEditTransactionDialog> createState() => _AddEditTransactionDialogState();
}

class _AddEditTransactionDialogState extends State<AddEditTransactionDialog> {
  late TextEditingController _descCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _dateCtrl;
  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.initialData?['description'] ?? '');
    _amountCtrl = TextEditingController(text: widget.initialData?['amount']?.toString() ?? '');
    _categoryCtrl = TextEditingController(text: widget.initialData?['category'] ?? '');
    _dateCtrl = TextEditingController(text: widget.initialData?['date'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    bool isEdit = widget.initialData != null;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? "Edit Transaction" : "Add Transaction", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'description': _descCtrl.text.trim(),
                  'amount': double.tryParse(_amountCtrl.text) ?? 0.0,
                  'category': _categoryCtrl.text.trim(),
                  'date': _dateCtrl.text.trim(),
                };
                if (widget.token == null) return;
                bool success;
                if (isEdit && widget.initialData?['id'] != null) {
                  success = await txProvider.editTransaction(widget.initialData!['id'], payload, widget.token!);
                } else {
                  success = await txProvider.addTransaction(payload, widget.token!);
                }
                if (!context.mounted) return;
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "Edited successfully." : "Added successfully.")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving transaction.")));
                }
              },
              child: Text(isEdit ? "Save Changes" : "Add Transaction"),
            ),
            if (isEdit)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transactions/transaction_list_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/splash_screen.dart';

const bool devMode = false; // Set to true to enable developer/test integration of Supabase demo widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // PUBLIC_INTERFACE
  // Initialize Supabase with publishable/anon key (safe for frontend/mobile apps).
  // DO NOT use service_role or admin keys in mobile/web applications.
  // Replace <YOUR_SUPABASE_PUBLISHABLE_KEY> below with your project's anon/public key from Supabase dashboard.
  //
  // For reference, see: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
  await Supabase.initialize(
    url: 'https://xihtrwadyqfimillpxff.supabase.co',
    // Best Practice: Never use service_role or admin key in app builds (see Supabase docs).
    // Only use public/publishable 'anon keys' here for client mobile/web apps.
    anonKey: '<YOUR_SUPABASE_PUBLISHABLE_KEY>',
  );
  runApp(const FinanceApp());
}

///
/// The main app for Personal Finance
class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
        ChangeNotifierProvider<TransactionProvider>(create: (_) => TransactionProvider()),
        ChangeNotifierProvider<BudgetProvider>(create: (_) => BudgetProvider()),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Finance',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF3F51B5),
            secondary: Color(0xFFFF9800),
            surface: Colors.white,
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Colors.black,
            onError: Colors.white,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/transactions': (context) => const TransactionListScreen(),
          '/budget': (context) => const BudgetScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          // Example: add '/sample-supabase' for dev/test demo (not in prod router).
        },
        // Example demonstration for fetching finance 'transactions' directly from Supabase table (replaceable or for dev only)
        builder: (context, child) {
          // ========================= Developer/Testing Only =========================
          // Set devMode=true ONLY for developer previews/tests, disable in production!
          // See comments above for integration, security, and usage directions.
          if (devMode) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: () async {
                final supabase = Supabase.instance.client;
                final session = supabase.auth.currentSession;
                // Only proceed if user is logged in/session is valid.
                if (session != null) {
                  final response = await supabase
                      .from('transactions')
                      .select()
                      .order('date', ascending: false)
                      .limit(10);
                  // The Supabase Dart API returns a List<Map<String, dynamic>>
                  return List<Map<String, dynamic>>.from(response);
                }
                return <Map<String, dynamic>>[];
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Material(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Material(
                    child: Center(
                      child: Text(
                        "Failed to fetch transactions: ${snapshot.error}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }
                final transactions = snapshot.data ?? [];
                return Material(
                  child: ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final tx = transactions[idx];
                      final double? amount = _castNum(tx['amount']);
                      final desc = tx['description']?.toString() ?? 'Transaction';
                      final date = tx['date']?.toString() ?? '';
                      return ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: Text(desc),
                        subtitle: Text(date),
                        trailing: Text(
                          '\$${amount?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (amount != null && amount < 0)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          // Production: use app as usual.
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Developer utility to type-cast numeric or string to double safely
double? _castNum(dynamic val) {
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

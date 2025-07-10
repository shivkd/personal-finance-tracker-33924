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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // PUBLIC_INTERFACE
  // Initialize Supabase with safest publishable key (anon/public) for frontend usage.
  await Supabase.initialize(
    url: 'https://xihtrwadyqfimillpxff.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpaHRyd2FkeXFmaW1pbGxweGZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxMTE2OTksImV4cCI6MjA2NzY4NzY5OX0.d_AuwOkKczE_j7oQOb37rGmVgX_XTGf2_UbSy8g9OAA',
    // The above is the public anon key and is safe for frontend.
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
          // To demonstrate correct FutureBuilder logic for Supabase, not 'todos'.
          // Remove if this is not needed in the widget tree.
          return Expanded(child: child ?? const SizedBox.shrink());
          // --- The demo FutureBuilder for Supabase 'transactions' was removed to fix dead code warning.
          // To re-enable for development, add the sample back with a proper condition. 
        },
      ),
    );
  }
}

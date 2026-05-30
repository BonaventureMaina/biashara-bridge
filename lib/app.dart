import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class BiasharaBridgeApp extends ConsumerWidget {
  const BiasharaBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Biashara Bridge',
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            // User is signed in; show dashboard (placeholder for now)
            return const Scaffold(
              body: Center(child: Text('Dashboard - coming soon')),
            );
          }
          return const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('Something went wrong: $error')),
        ),
      ),
    );
  }
}

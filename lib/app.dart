import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/registration/presentation/pages/business_profile_page.dart';

class BiasharaBridgeApp extends ConsumerWidget {
  const BiasharaBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    return MaterialApp(
      title: 'Biashara Bridge',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user != null) return const DashboardPage();
          return const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('Something went wrong: $error')),
        ),
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'business') {
          final code = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (_) => BusinessProfilePage(biasharaCode: code),
          );
        }
        // Fallback to home (should not happen)
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

class BiasharaBridgeApp extends ConsumerWidget {
  const BiasharaBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Biashara Bridge',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(child: Text('Biashara Bridge MVP')),
      ),
    );
  }
}

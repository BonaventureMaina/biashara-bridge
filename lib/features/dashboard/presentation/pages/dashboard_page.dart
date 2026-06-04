import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../registration/domain/entities/business.dart';
import '../../../registration/presentation/providers/registration_provider.dart';
import '../../../registration/presentation/pages/business_registration_page.dart';
import '../../../payments/presentation/pages/invoice_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final businessesAsync = ref.watch(businessesByOwnerProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biashara Bridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authControllerProvider).signOut(),
          ),
        ],
      ),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome, ${user.displayName ?? user.email}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_business),
                    label: const Text('Register your first business'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BusinessRegistrationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Your Businesses',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final biz = businesses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(biz.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${biz.biasharaCode}'),
                            Text(biz.addressLine,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InvoicePage(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'invoice',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InvoicePage()),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text('Invoice'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_business',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const BusinessRegistrationPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Business'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../registration/presentation/providers/registration_provider.dart';
import '../../domain/entities/bulk_deal.dart';
import '../providers/procurement_provider.dart';

class DealsPage extends ConsumerWidget {
  const DealsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(activeDealsProvider);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;
    final userBusinessesAsync = user != null
        ? ref.watch(businessesByOwnerProvider(user.id))
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Deals')),
      body: dealsAsync.when(
        data: (deals) {
          if (deals.isEmpty) {
            return const Center(child: Text('No active deals'));
          }

          // Get first business ID for claiming
          String? firstBusinessId;
          if (userBusinessesAsync?.valueOrNull != null &&
              userBusinessesAsync!.valueOrNull!.isNotEmpty) {
            firstBusinessId = userBusinessesAsync.valueOrNull!.first.id;
          }

          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return _DealCard(
                deal: deal,
                businessId: firstBusinessId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DealCard extends ConsumerWidget {
  final BulkDeal deal;
  final String? businessId;
  const _DealCard({required this.deal, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasClaimed =
        businessId != null && deal.claimedBy.contains(businessId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deal.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(deal.description),
            const SizedBox(height: 8),
            Text('KES ${deal.pricePerUnit.toStringAsFixed(2)} per unit'),
            Text('Min order: ${deal.minOrderQuantity} | Available: ${deal.availableQuantity}'),
            Text('Expires: ${deal.expiresAt.toString().substring(0, 10)}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (businessId == null || hasClaimed)
                    ? null
                    : () async {
                        final controller =
                            ref.read(procurementControllerProvider);
                        final result = await controller.claimDeal(
                          dealId: deal.id,
                          businessId: businessId!,
                        );
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                          },
                          (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deal claimed!')),
                            );
                          },
                        );
                      },
                child: Text(
                  hasClaimed
                      ? 'Claimed'
                      : businessId == null
                          ? 'Register a business first'
                          : 'Claim this deal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

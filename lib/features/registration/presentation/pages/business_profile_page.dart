import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/business.dart';
import '../providers/registration_provider.dart';

class BusinessProfilePage extends ConsumerStatefulWidget {
  final String biasharaCode;
  const BusinessProfilePage({super.key, required this.biasharaCode});

  @override
  ConsumerState<BusinessProfilePage> createState() =>
      _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  @override
  Widget build(BuildContext context) {
    final businessAsync =
        ref.watch(businessByBiasharaCodeProvider(widget.biasharaCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Chip(label: Text(business.category.toUpperCase())),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 20),
                    const SizedBox(width: 8),
                    Text('Biashara Code: ${business.biasharaCode}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(business.addressLine)),
                  ],
                ),
                if (business.phoneNumber != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 20),
                      const SizedBox(width: 8),
                      Text(business.phoneNumber!),
                    ],
                  ),
                ],
                if (business.description != null &&
                    business.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('About',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(business.description!),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

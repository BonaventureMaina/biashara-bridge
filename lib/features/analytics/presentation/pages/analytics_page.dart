import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../registration/domain/entities/business.dart';
import '../../../registration/presentation/providers/registration_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedCategory = 'all';

  final List<String> _categories = ['all', 'retail', 'agritech', 'logistics', 'other'];

  @override
  Widget build(BuildContext context) {
    final allBusinessesAsync = ref.watch(allBusinessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Market Analytics')),
      body: Column(
        children: [
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Map
          Expanded(
            child: allBusinessesAsync.when(
              data: (businesses) {
                final filtered = _selectedCategory == 'all'
                    ? businesses
                    : businesses.where((b) => b.category == _selectedCategory).toList();

                final markers = filtered.map((b) {
                  return Marker(
                    point: LatLng(b.location.latitude, b.location.longitude),
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 28),
                        Text(b.name,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                }).toList();

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(-1.2921, 36.8219),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.biasharabridge.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

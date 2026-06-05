import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../registration/domain/entities/business.dart';
import '../../../registration/presentation/providers/registration_provider.dart';
import 'dart:convert';

/// Static GeoJSON of 3 underserved Nairobi polygons (simplified).
/// In production, this would come from a live dataset (KNBS).
const String _underservedGeoJson = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": { "name": "Mathare", "density": "low" },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[36.88,-1.26],[36.90,-1.26],[36.90,-1.28],[36.88,-1.28],[36.88,-1.26]]]
      }
    },
    {
      "type": "Feature",
      "properties": { "name": "Kibera", "density": "low" },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[36.78,-1.31],[36.80,-1.31],[36.80,-1.33],[36.78,-1.33],[36.78,-1.31]]]
      }
    },
    {
      "type": "Feature",
      "properties": { "name": "Dandora", "density": "medium" },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[36.92,-1.24],[36.94,-1.24],[36.94,-1.26],[36.92,-1.26],[36.92,-1.24]]]
      }
    }
  ]
}
''';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedCategory = 'all';
  bool _showHeatmap = true;

  final List<String> _categories = [
    'all',
    'retail',
    'agritech',
    'logistics',
    'other'
  ];

  Color _colorForDensity(String density) {
    switch (density) {
      case 'low':
        return Colors.red.withOpacity(0.35);
      case 'medium':
        return Colors.orange.withOpacity(0.35);
      default:
        return Colors.green.withOpacity(0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allBusinessesAsync = ref.watch(allBusinessesProvider);

    // Parse the static GeoJSON into polygons
    final geoData = json.decode(_underservedGeoJson) as Map<String, dynamic>;
    final features = geoData['features'] as List<dynamic>;
    final heatmapPolygons = features.map((f) {
      final properties = f['properties'] as Map<String, dynamic>;
      final name = properties['name'] as String;
      final density = properties['density'] as String;
      final coords = f['geometry']['coordinates'] as List<dynamic>;
      final outerRing = coords[0] as List<dynamic>;
      final points = outerRing.map((c) {
        final lng = (c as List<dynamic>)[0] as double;
        final lat = c[1] as double;
        return LatLng(lat, lng);
      }).toList();
      return Polygon(
        points: points,
        color: _colorForDensity(density),
        borderStrokeWidth: 1,
        borderColor: Colors.black38,
        label: name,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Analytics'),
        actions: [
          IconButton(
            icon: Icon(_showHeatmap ? Icons.layers_clear : Icons.layers),
            tooltip: _showHeatmap ? 'Hide heatmap' : 'Show heatmap',
            onPressed: () {
              setState(() => _showHeatmap = !_showHeatmap);
            },
          ),
        ],
      ),
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
                    : businesses
                        .where((b) => b.category == _selectedCategory)
                        .toList();

                final markers = filtered.map((b) {
                  return Marker(
                    point:
                        LatLng(b.location.latitude, b.location.longitude),
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.blue, size: 28),
                        Text(b.name,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                }).toList();

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(-1.2921, 36.8219),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.biasharabridge.app',
                    ),
                    // Heatmap layer
                    if (_showHeatmap)
                      PolygonLayer(polygons: heatmapPolygons.toList()),
                    // Business markers
                    MarkerLayer(markers: markers),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

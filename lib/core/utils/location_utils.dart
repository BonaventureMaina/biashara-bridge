import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationUtils {
  /// Reverse geocode [lat], [lon] using OpenStreetMap Nominatim.
  /// Returns a human-readable address string or null on failure.
  static Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$lat'
        '&lon=$lon'
        '&zoom=18'
        '&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'BiasharaBridge/1.0 (biasharabridge@gmail.com)'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

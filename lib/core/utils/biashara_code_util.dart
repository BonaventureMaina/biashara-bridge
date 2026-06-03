import 'dart:math';

class BiasharaCodeUtil {
  /// Temporary code generator (will be replaced by Cloud Function).
  /// Produces e.g. BSH-NAI-####
  static String generate({required double latitude, required double longitude}) {
    final countyPrefix = _countyPrefixFor(latitude, longitude);
    final random = Random();
    final number = (random.nextInt(9000) + 1000).toString();
    return 'BSH-$countyPrefix-$number';
  }

  static String _countyPrefixFor(double lat, double lon) {
    if (lat >= -1.47 && lat <= -1.2 && lon >= 36.6 && lon <= 37.1) {
      return 'NAI';
    } else if (lat >= -4.1 && lat <= -3.9 && lon >= 39.6 && lon <= 39.8) {
      return 'MSA';
    } else if (lat >= -0.15 && lat <= 0.05 && lon >= 34.7 && lon <= 34.85) {
      return 'KSM';
    }
    return 'GEN';
  }
}

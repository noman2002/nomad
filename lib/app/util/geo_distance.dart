import 'dart:math' as math;

import '../models/geo.dart';

class GeoDistance {
  static const double _earthRadiusKm = 6371;

  static double kmBetween(LatLng a, LatLng b) {
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);

    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final h = _hav(dLat) + (math.cos(lat1) * math.cos(lat2) * _hav(dLng));
    return 2 * _earthRadiusKm * math.asin(math.sqrt(h));
  }

  static double _hav(double x) {
    final s = math.sin(x / 2);
    return s * s;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180);
}

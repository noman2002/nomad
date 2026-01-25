import 'geo.dart';

class NomadLocation {
  const NomadLocation({required this.userId, required this.position});

  final String userId;
  final LatLng position;
}

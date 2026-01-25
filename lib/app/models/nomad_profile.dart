import 'geo.dart';
import 'nomad_user.dart';

class NomadProfile {
  const NomadProfile({
    required this.user,
    required this.bio,
    required this.onTheRoadSince,
    required this.currentLocationLabel,
    required this.nextDestinationLabel,
    required this.vanType,
    required this.vanYear,
    required this.vanName,
    required this.buildHighlights,
    required this.last30DaysRoute,
    required this.next2WeeksRoute,
    required this.mutualConnections,
  });

  final NomadUser user;
  final String bio;
  final DateTime onTheRoadSince;
  final String currentLocationLabel;
  final String nextDestinationLabel;

  final String vanType;
  final int vanYear;
  final String vanName;
  final List<String> buildHighlights;

  final List<LatLng> last30DaysRoute;
  final List<LatLng> next2WeeksRoute;

  final List<String> mutualConnections;
}

import '../models/geo.dart';
import '../models/nomad_profile.dart';
import 'mock_data.dart';

class MockProfiles {
  static final profilesByUserId = <String, NomadProfile>{
    'u1': NomadProfile(
      user: MockData.nearbyNomads[0],
      bio: 'Climber and coffee nerd. Chasing sunrises and quiet camps.',
      onTheRoadSince: DateTime(2022, 4, 1),
      currentLocationLabel: 'Los Angeles, CA',
      nextDestinationLabel: 'Joshua Tree, CA',
      vanType: 'Sprinter',
      vanYear: 2019,
      vanName: 'Mochi',
      buildHighlights: const ['solar', 'hot shower', 'diesel heater'],
      last30DaysRoute: const [
        LatLng(34.0400, -118.2700),
        LatLng(34.0480, -118.2600),
        LatLng(34.0550, -118.2500),
        LatLng(34.0600, -118.2450),
      ],
      next2WeeksRoute: const [
        LatLng(34.0622, -118.2437),
        LatLng(34.0900, -116.3500),
        LatLng(36.1700, -115.1400),
      ],
      mutualConnections: const ['Sarah & Mike', 'Alex'],
    ),
    'u2': NomadProfile(
      user: MockData.nearbyNomads[1],
      bio: 'Slow travel, big views. Always down for a campfire chat.',
      onTheRoadSince: DateTime(2021, 8, 12),
      currentLocationLabel: 'Los Angeles, CA',
      nextDestinationLabel: 'Big Sur, CA',
      vanType: 'Transit',
      vanYear: 2017,
      vanName: 'Dusty',
      buildHighlights: const ['roof rack', 'inverter', 'full kitchen'],
      last30DaysRoute: const [
        LatLng(34.0300, -118.2800),
        LatLng(34.0350, -118.2700),
        LatLng(34.0400, -118.2620),
        LatLng(34.0450, -118.2550),
      ],
      next2WeeksRoute: const [
        LatLng(34.0450, -118.2550),
        LatLng(35.6762, -121.2250),
        LatLng(36.2704, -121.8081),
      ],
      mutualConnections: const ['Jordan'],
    ),
    'u3': NomadProfile(
      user: MockData.nearbyNomads[2],
      bio: 'Weekend warrior turned full-timer. Yoga at sunrise.',
      onTheRoadSince: DateTime(2023, 2, 5),
      currentLocationLabel: 'Los Angeles, CA',
      nextDestinationLabel: 'San Diego, CA',
      vanType: 'School Bus',
      vanYear: 2008,
      vanName: 'Sunset Bus',
      buildHighlights: const ['wood stove', 'skylight', 'huge bed'],
      last30DaysRoute: const [
        LatLng(34.0500, -118.2600),
        LatLng(34.0520, -118.2500),
        LatLng(34.0540, -118.2420),
        LatLng(34.0555, -118.2350),
      ],
      next2WeeksRoute: const [
        LatLng(34.0555, -118.2350),
        LatLng(33.7701, -118.1937),
        LatLng(32.7157, -117.1611),
      ],
      mutualConnections: const ['Taylor', 'Sam'],
    ),
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../firebase/firestore/locations_service.dart';
import '../../firebase/firestore/profile_service.dart';
import '../../models/geo.dart';
import '../../models/nomad_location.dart';
import '../../models/nomad_profile.dart';
import '../../models/nomad_user.dart';
import '../../revenuecat/revenuecat_paywall_sheet.dart';
import '../../state/session_state.dart';
import '../../util/geo_distance.dart';
import '../map/nomad_bottom_sheet.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final _mapController = MapController();

  LookingFor? _filter;
  double _radiusKm = 50;
  double _zoom = 13;
  bool _clusterEnabled = true;

  // Cache for user profiles
  final Map<String, NomadProfile> _profileCache = {};

  Future<void> _showRangeUpgradePrompt() async {
    if (!mounted) return;
    final session = context.read<SessionState>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Range'),
        content: const Text(
          'Free discovery radius is up to 50 km. Upgrade to Premium to unlock up to 500 km.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Later')),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final upgraded = await showRevenueCatPaywall(this.context);
              if (upgraded) {
                await session.refreshSubscriptionStatus();
              }
            },
            child: const Text('View plans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final currentUser = session.currentUser;
    final maxRadiusKm = session.maxDiscoveryRadiusKm;
    final effectiveRadiusKm = _radiusKm > maxRadiusKm ? maxRadiusKm : _radiusKm;

    // Default position (Los Angeles)
    final myPosition = const LatLng(34.0522, -118.2437);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nomad'),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Text(
                    '${currentUser.adventureScore}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.local_fire_department, color: AppColors.accent),
                ],
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<NomadLocation>>(
        stream: LocationsService.watchLocations(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allLocations = snapshot.data!;

          // Load profiles for visible users
          _loadProfiles(allLocations);

          final locations = _filteredLocations(allLocations, myPosition, effectiveRadiusKm);
          final markers = _buildMarkers(context, locations, myPosition);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: myPosition,
                  initialZoom: 13,
                  onPositionChanged: (pos, _) {
                    final z = pos.zoom;
                    if ((_zoom - z).abs() < 0.001) return;
                    setState(() => _zoom = z);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nomad',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: _FilterBar(
                  filter: _filter,
                  radiusKm: effectiveRadiusKm,
                  maxRadiusKm: maxRadiusKm,
                  clusterEnabled: _clusterEnabled,
                  onFilterChanged: (v) => setState(() => _filter = v),
                  onRadiusChanged: (v) {
                    if (v > maxRadiusKm) {
                      setState(() => _radiusKm = maxRadiusKm);
                      _showRangeUpgradePrompt();
                      return;
                    }
                    setState(() => _radiusKm = v);
                  },
                  onToggleCluster: () => setState(() => _clusterEnabled = !_clusterEnabled),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _mapController.move(myPosition, 13.5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Showing ${locations.length} nearby nomads')),
                    );
                  },
                  label: const Text('Discover Nearby'),
                  icon: const Icon(Icons.radar),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadProfiles(List<NomadLocation> locations) async {
    final userIds = locations
        .map((l) => l.userId)
        .where((id) => !_profileCache.containsKey(id))
        .toList();
    if (userIds.isEmpty) return;

    final profiles = await ProfileService.getProfiles(userIds);
    setState(() {
      _profileCache.addAll(profiles);
    });
  }

  Marker _buildMyMarker(LatLng position) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: _PulsingDot(color: AppColors.primary, size: 14),
    );
  }

  List<NomadLocation> _filteredLocations(
    List<NomadLocation> allLocations,
    LatLng center,
    double radiusKm,
  ) {
    return allLocations.where((loc) {
      final profile = _profileCache[loc.userId];
      if (profile == null) return false;

      if (_filter != null && profile.user.lookingFor != _filter) return false;

      final km = GeoDistance.kmBetween(center, loc.position);
      if (km > radiusKm) return false;

      return true;
    }).toList();
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    List<NomadLocation> locations,
    LatLng myPosition,
  ) {
    final markers = <Marker>[_buildMyMarker(myPosition)];

    final shouldCluster = _clusterEnabled && _zoom < 13.2;
    if (!shouldCluster) {
      markers.addAll(_buildNomadMarkers(context, locations));
      return markers;
    }

    final buckets = <String, List<NomadLocation>>{};
    final decimals = _zoom < 11
        ? 1
        : _zoom < 12.2
        ? 2
        : 3;

    for (final loc in locations) {
      final key = _bucketKey(loc.position, decimals);
      (buckets[key] ??= <NomadLocation>[]).add(loc);
    }

    for (final entry in buckets.entries) {
      final bucketLocations = entry.value;
      if (bucketLocations.length == 1) {
        markers.addAll(_buildNomadMarkers(context, bucketLocations));
        continue;
      }

      final center = _centroid(bucketLocations);
      markers.add(
        Marker(
          point: center,
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              _mapController.move(center, _zoom + 1.2);
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '${bucketLocations.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  String _bucketKey(LatLng p, int decimals) {
    final lat = p.latitude.toStringAsFixed(decimals);
    final lng = p.longitude.toStringAsFixed(decimals);
    return '$lat,$lng';
  }

  LatLng _centroid(List<NomadLocation> locations) {
    var lat = 0.0;
    var lng = 0.0;
    for (final l in locations) {
      lat += l.position.latitude;
      lng += l.position.longitude;
    }
    return LatLng(lat / locations.length, lng / locations.length);
  }

  List<Marker> _buildNomadMarkers(BuildContext context, List<NomadLocation> locations) {
    return locations
        .map((loc) {
          final profile = _profileCache[loc.userId];
          if (profile == null) return null;

          final user = profile.user;
          final color = switch (user.lookingFor) {
            LookingFor.dating => Colors.redAccent,
            LookingFor.friends => Colors.greenAccent,
            LookingFor.both => Colors.amberAccent,
          };

          return Marker(
            point: loc.position,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => NomadBottomSheet(nomad: user),
                );
              },
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
          );
        })
        .whereType<Marker>()
        .toList();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.radiusKm,
    required this.maxRadiusKm,
    required this.clusterEnabled,
    required this.onFilterChanged,
    required this.onRadiusChanged,
    required this.onToggleCluster,
  });

  final LookingFor? filter;
  final double radiusKm;
  final double maxRadiusKm;
  final bool clusterEnabled;
  final ValueChanged<LookingFor?> onFilterChanged;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onToggleCluster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _FilterChip(label: 'All', selected: filter == null, onTap: () => onFilterChanged(null)),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Dating',
            selected: filter == LookingFor.dating,
            onTap: () => onFilterChanged(LookingFor.dating),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Friends',
            selected: filter == LookingFor.friends,
            onTap: () => onFilterChanged(LookingFor.friends),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Both',
            selected: filter == LookingFor.both,
            onTap: () => onFilterChanged(LookingFor.both),
          ),
          const Spacer(),
          SizedBox(
            width: 78,
            child: DropdownButton<double>(
              isExpanded: true,
              isDense: true,
              value: radiusKm,
              underline: const SizedBox.shrink(),
              dropdownColor: theme.colorScheme.surface,
              items: <double>[10, 25, 50, 100, 250, 500].map((km) {
                return DropdownMenuItem(value: km, child: Text('${km.toInt()}k'));
              }).toList(),
              selectedItemBuilder: (context) {
                return <double>[
                  10,
                  25,
                  50,
                  100,
                  250,
                  500,
                ].map((km) => Text('${km.toInt()}k')).toList();
              },
              onChanged: (v) {
                if (v != null) onRadiusChanged(v);
              },
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onToggleCluster,
            icon: Icon(clusterEnabled ? Icons.bubble_chart : Icons.scatter_plot),
            tooltip: clusterEnabled ? 'Clustering on' : 'Clustering off',
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final haloSize = widget.size + (18 * t);
        final haloOpacity = (1 - t) * 0.35;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: haloOpacity),
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

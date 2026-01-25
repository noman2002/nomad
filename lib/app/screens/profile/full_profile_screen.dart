import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:video_player/video_player.dart';

import '../../models/nomad_profile.dart';

class FullProfileScreen extends StatefulWidget {
  const FullProfileScreen({super.key, required this.profile});

  final NomadProfile profile;

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      appBar: AppBar(title: Text(p.user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _controller != null && _controller!.value.isInitialized
                  ? VideoPlayer(_controller!)
                  : Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${p.user.name}, ${p.user.age}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.currentLocationLabel} → ${p.nextDestinationLabel}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(p.bio),
          const SizedBox(height: 16),
          _SectionTitle('Van Details'),
          const SizedBox(height: 8),
          Text('${p.vanYear} ${p.vanType} • “${p.vanName}”'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in p.buildHighlights) Chip(label: Text(h)),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle('Activities & Vibe'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in p.user.activities) Chip(label: Text(a)),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle('Route Preview'),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: p.next2WeeksRoute.first,
                  initialZoom: 9,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nomad',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: p.last30DaysRoute,
                        color: Colors.white54,
                        strokeWidth: 4,
                      ),
                      Polyline(
                        points: p.next2WeeksRoute,
                        color: Colors.orangeAccent,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Mutual Connections'),
          const SizedBox(height: 8),
          Text(
            p.mutualConnections.isEmpty
                ? 'No mutual connections yet'
                : p.mutualConnections.join(', '),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).pop('connect');
                  },
                  child: const Text('Connect'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop('interested');
                  },
                  child: const Text('Interested'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../models/geo.dart';

class ShareLocationSheet extends StatefulWidget {
  const ShareLocationSheet({super.key});

  @override
  State<ShareLocationSheet> createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  final _labelController = TextEditingController(text: '');

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = MockData.myPosition;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              'Current (mock): ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                hintText: 'e.g. Coffee shop in Venice',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(ShareLocationResult(
                    position: LatLng(pos.latitude, pos.longitude),
                    label: _labelController.text.trim(),
                  ));
                },
                child: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareLocationResult {
  const ShareLocationResult({required this.position, required this.label});

  final LatLng position;
  final String label;
}

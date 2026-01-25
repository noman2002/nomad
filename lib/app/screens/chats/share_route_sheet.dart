import 'package:flutter/material.dart';

class ShareRouteSheet extends StatefulWidget {
  const ShareRouteSheet({super.key});

  @override
  State<ShareRouteSheet> createState() => _ShareRouteSheetState();
}

class _ShareRouteSheetState extends State<ShareRouteSheet> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Share route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                hintText: 'e.g. LA',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                hintText: 'e.g. Joshua Tree',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    ShareRouteResult(
                      from: _fromController.text.trim(),
                      to: _toController.text.trim(),
                    ),
                  );
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

class ShareRouteResult {
  const ShareRouteResult({required this.from, required this.to});

  final String from;
  final String to;

  String get summary {
    final f = from.isEmpty ? 'Somewhere' : from;
    final t = to.isEmpty ? 'Somewhere' : to;
    return '$f → $t';
  }
}

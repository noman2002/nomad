import 'dart:math' as math;

import 'package:flutter/material.dart';

class LevelUpConfetti extends StatefulWidget {
  const LevelUpConfetti({super.key});

  @override
  State<LevelUpConfetti> createState() => _LevelUpConfettiState();
}

class _LevelUpConfettiState extends State<LevelUpConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return CustomPaint(
            painter: _ConfettiPainter(progress: t),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = <Color>[
    Color(0xFFFFD23F),
    Color(0xFFFF6B35),
    Color(0xFF00B4D8),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rand = math.Random(42);

    for (var i = 0; i < 80; i++) {
      final x = rand.nextDouble() * size.width;
      final startY = -20.0 - (rand.nextDouble() * 200);
      final y = startY + (size.height + 260) * progress;
      final rot = rand.nextDouble() * math.pi * 2;
      final w = 6 + rand.nextDouble() * 6;
      final h = 10 + rand.nextDouble() * 10;

      paint.color = _colors[i % _colors.length].withValues(alpha: 0.85);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot + (progress * 2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

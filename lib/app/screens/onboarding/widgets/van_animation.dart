import 'package:flutter/material.dart';

class VanAnimation extends StatefulWidget {
  const VanAnimation({super.key});

  @override
  State<VanAnimation> createState() => _VanAnimationState();
}

class _VanAnimationState extends State<VanAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            final x = (constraints.maxWidth - 64) * t;
            return Stack(
              children: [
                Positioned(
                  left: x,
                  bottom: 0,
                  child: const Icon(Icons.airport_shuttle, size: 64),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

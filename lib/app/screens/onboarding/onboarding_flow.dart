import 'package:flutter/material.dart';

import 'steps/basic_info_step.dart';
import 'steps/invite_code_step.dart';
import 'steps/location_permission_step.dart';
import 'steps/video_intro_step.dart';
import 'steps/vibe_step.dart';
import 'steps/welcome_step.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _index = 0;

  void _next() {
    if (_index >= 5) return;
    setState(() => _index++);
    _pageController.animateToPage(
      _index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_index <= 0) return;
    setState(() => _index--);
    _pageController.animateToPage(
      _index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _index == 0 ? null : _back,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_index + 1) / 6,
                      borderRadius: BorderRadius.circular(999),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_index + 1}/6'),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeStep(onNext: _next),
                  VideoIntroStep(onNext: _next),
                  BasicInfoStep(onNext: _next),
                  VibeStep(onNext: _next),
                  InviteCodeStep(onNext: _next),
                  LocationPermissionStep(onFinish: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/nav_state.dart';
import '../state/session_state.dart';
import 'onboarding/onboarding_flow.dart';
import 'tabs/chats_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/quests_tab.dart';
import 'tabs/stories_tab.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    if (!session.onboardingComplete) {
      return const OnboardingFlow();
    }

    final nav = context.watch<NavState>();

    final tabs = <Widget>[
      const MapTab(),
      const StoriesTab(),
      const QuestsTab(),
      const ChatsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[nav.index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.index,
        onTap: nav.setIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Quests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

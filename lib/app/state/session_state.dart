import 'package:flutter/foundation.dart';

import '../mock/mock_data.dart';
import '../models/nomad_user.dart';

class OnboardingDraft {
  String name = '';
  int? age;
  String gender = '';
  String vanType = '';
  String travelingWith = '';
  LookingFor lookingFor = LookingFor.both;

  final List<String> activities = <String>[];
  TravelStyle travelStyle = TravelStyle.slowExplorer;
  WorkSituation workSituation = WorkSituation.remoteWorker;

  String inviteCode = '';
  bool inviteRequested = false;
  bool locationEnabled = false;

  bool introVideoRecorded = false;
}

class SessionState extends ChangeNotifier {
  NomadUser currentUser = MockData.currentUser;

  void refresh() => notifyListeners();

  bool onboardingComplete = false;

  final OnboardingDraft onboarding = OnboardingDraft();

  void updateOnboarding(void Function(OnboardingDraft) update) {
    update(onboarding);
    notifyListeners();
  }

  final Set<UserId> connected = <UserId>{};
  final Set<UserId> interested = <UserId>{};
  final Set<UserId> matches = <UserId>{};

  void toggleConnect(UserId userId) {
    if (connected.contains(userId)) {
      connected.remove(userId);
    } else {
      connected.add(userId);
    }
    notifyListeners();
  }

  void toggleInterested(UserId userId) {
    if (interested.contains(userId)) {
      interested.remove(userId);
    } else {
      interested.add(userId);
      final theyAlsoInterested = MockData.mutualInterested.contains(userId);
      if (theyAlsoInterested) {
        matches.add(userId);
      }
    }
    notifyListeners();
  }

  void completeOnboarding() {
    currentUser = NomadUser(
      id: 'me',
      name: onboarding.name.isEmpty ? 'You' : onboarding.name,
      age: onboarding.age ?? 0,
      lookingFor: onboarding.lookingFor,
      activities:
          onboarding.activities.isEmpty ? MockData.currentUser.activities : onboarding.activities,
      travelStyle: onboarding.travelStyle,
      workSituation: onboarding.workSituation,
      adventureScore: 0,
    );

    onboardingComplete = true;
    notifyListeners();
  }
}

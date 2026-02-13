import 'package:flutter/foundation.dart';

import '../firebase/auth/auth_service.dart';
import '../firebase/firestore/user_service.dart';
import '../models/nomad_user.dart';
import '../revenuecat/revenuecat_bootstrap.dart';

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
  static const int freeProfileViewsDailyLimit = 10;
  static const int freeConnectsDailyLimit = 5;
  static const double freeDiscoveryRadiusKm = 50;
  static const double premiumDiscoveryRadiusKm = 500;

  NomadUser? _currentUser;
  bool _loading = false;
  bool _hasPremiumAccess = false;
  int _profilesViewedToday = 0;
  int _connectsToday = 0;
  DateTime _usageDate = DateTime.now();

  NomadUser? get currentUser => _currentUser;
  bool get isLoading => _loading;
  bool get hasPremiumAccess => _hasPremiumAccess;
  int get profilesViewedToday {
    _resetDailyUsageIfNeeded();
    return _profilesViewedToday;
  }

  int get connectsToday {
    _resetDailyUsageIfNeeded();
    return _connectsToday;
  }

  int get profileViewsRemaining {
    if (_hasPremiumAccess) return -1;
    return (freeProfileViewsDailyLimit - profilesViewedToday).clamp(0, freeProfileViewsDailyLimit);
  }

  int get connectsRemaining {
    if (_hasPremiumAccess) return -1;
    return (freeConnectsDailyLimit - connectsToday).clamp(0, freeConnectsDailyLimit);
  }

  double get maxDiscoveryRadiusKm {
    return _hasPremiumAccess ? premiumDiscoveryRadiusKm : freeDiscoveryRadiusKm;
  }

  /// Load current user from Firestore
  Future<void> loadCurrentUser() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final userDoc = await UserService.getUser(uid);
      if (userDoc != null) {
        _currentUser = _parseUser(uid, userDoc);
      }
      await syncRevenueCatUser(uid);
      _hasPremiumAccess = await hasActiveEntitlement();
    } catch (e) {
      debugPrint('Error loading current user: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void refresh() => notifyListeners();

  Future<void> refreshSubscriptionStatus() async {
    try {
      _hasPremiumAccess = await hasActiveEntitlement();
    } catch (e) {
      debugPrint('Error refreshing subscription status: $e');
    }
    notifyListeners();
  }

  bool onboardingComplete = false;

  final OnboardingDraft onboarding = OnboardingDraft();

  void updateOnboarding(void Function(OnboardingDraft) update) {
    update(onboarding);
    notifyListeners();
  }

  final Set<UserId> connected = <UserId>{};
  final Set<UserId> interested = <UserId>{};
  final Set<UserId> matches = <UserId>{};

  bool toggleConnect(UserId userId) {
    _resetDailyUsageIfNeeded();

    if (connected.contains(userId)) {
      connected.remove(userId);
      notifyListeners();
      return true;
    }

    if (!_hasPremiumAccess && _connectsToday >= freeConnectsDailyLimit) {
      return false;
    }

    connected.add(userId);
    if (!_hasPremiumAccess) {
      _connectsToday++;
    } else {
    }
    notifyListeners();
    return true;
  }

  Future<void> toggleInterested(UserId userId) async {
    if (interested.contains(userId)) {
      interested.remove(userId);
    } else {
      interested.add(userId);

      // TODO: Check in Firestore if they're also interested in us
      // For now, we'll just add to matches if they're in our interested set
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    final userData = {
      'name': onboarding.name.isEmpty ? 'You' : onboarding.name,
      'age': onboarding.age ?? 0,
      'lookingFor': onboarding.lookingFor.name,
      'activities': onboarding.activities,
      'travelStyle': onboarding.travelStyle.name,
      'workSituation': onboarding.workSituation.name,
      'adventureScore': 0,
    };

    await UserService.upsertUser(uid: uid, data: userData);
    await loadCurrentUser();

    onboardingComplete = true;
    notifyListeners();
  }

  NomadUser _parseUser(String uid, Map<String, dynamic> data) {
    return NomadUser(
      id: uid,
      name: (data['name'] as String?) ?? 'Unknown',
      age: (data['age'] as num?)?.toInt() ?? 0,
      lookingFor: _parseLookingFor(data['lookingFor'] as String?),
      activities: (data['activities'] as List?)?.whereType<String>().toList() ?? [],
      travelStyle: _parseTravelStyle(data['travelStyle'] as String?),
      workSituation: _parseWorkSituation(data['workSituation'] as String?),
      adventureScore: (data['adventureScore'] as num?)?.toInt() ?? 0,
    );
  }

  LookingFor _parseLookingFor(String? value) {
    return LookingFor.values.firstWhere((e) => e.name == value, orElse: () => LookingFor.both);
  }

  TravelStyle _parseTravelStyle(String? value) {
    return TravelStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TravelStyle.slowExplorer,
    );
  }

  WorkSituation _parseWorkSituation(String? value) {
    return WorkSituation.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkSituation.remoteWorker,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await clearRevenueCatUser();
    await AuthService.signOut();
    _currentUser = null;
    _hasPremiumAccess = false;
    _profilesViewedToday = 0;
    _connectsToday = 0;
    _usageDate = DateTime.now();
    connected.clear();
    interested.clear();
    matches.clear();
    notifyListeners();
  }

  bool consumeProfileView() {
    _resetDailyUsageIfNeeded();
    if (_hasPremiumAccess) return true;
    if (_profilesViewedToday >= freeProfileViewsDailyLimit) return false;
    _profilesViewedToday++;
    notifyListeners();
    return true;
  }

  void _resetDailyUsageIfNeeded() {
    final now = DateTime.now();
    if (_isSameDay(now, _usageDate)) return;
    _usageDate = now;
    _profilesViewedToday = 0;
    _connectsToday = 0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

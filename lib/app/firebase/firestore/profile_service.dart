import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/geo.dart';
import '../../models/nomad_profile.dart';
import '../../models/nomad_user.dart';
import '../firebase_refs.dart';

class ProfileService {
  /// Get a user's profile by their user ID
  static Future<NomadProfile?> getProfile(String userId) async {
    final userDoc = await FirebaseRefs.users().doc(userId).get();
    if (!userDoc.exists) return null;

    final data = userDoc.data();
    if (data == null) return null;

    return _fromFirestore(userId, data);
  }

  /// Get multiple profiles at once
  static Future<Map<String, NomadProfile>> getProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final profiles = <String, NomadProfile>{};
    
    // Firestore has a limit of 10 items per "in" query, so we batch
    for (var i = 0; i < userIds.length; i += 10) {
      final batch = userIds.skip(i).take(10).toList();
      final snapshot = await FirebaseRefs.users()
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final profile = _fromFirestore(doc.id, data);
        profiles[doc.id] = profile;
      }
    }

    return profiles;
  }

  /// Update profile data
  static Future<void> updateProfile({
    required String userId,
    required Map<String, Object?> data,
  }) async {
    await FirebaseRefs.users().doc(userId).set(
          {
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  static NomadProfile _fromFirestore(String userId, Map<String, dynamic> data) {
    final user = NomadUser(
      id: userId,
      name: (data['name'] as String?) ?? 'Unknown',
      age: (data['age'] as num?)?.toInt() ?? 0,
      lookingFor: _parseLookingFor(data['lookingFor'] as String?),
      activities: (data['activities'] as List?)?.whereType<String>().toList() ?? [],
      travelStyle: _parseTravelStyle(data['travelStyle'] as String?),
      workSituation: _parseWorkSituation(data['workSituation'] as String?),
      adventureScore: (data['adventureScore'] as num?)?.toInt() ?? 0,
    );

    return NomadProfile(
      user: user,
      bio: (data['bio'] as String?) ?? '',
      onTheRoadSince: (data['onTheRoadSince'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentLocationLabel: (data['currentLocationLabel'] as String?) ?? '',
      nextDestinationLabel: (data['nextDestinationLabel'] as String?) ?? '',
      vanType: (data['vanType'] as String?) ?? '',
      vanYear: (data['vanYear'] as num?)?.toInt() ?? 0,
      vanName: (data['vanName'] as String?) ?? '',
      buildHighlights: (data['buildHighlights'] as List?)?.whereType<String>().toList() ?? [],
      last30DaysRoute: _parseRoute(data['last30DaysRoute']),
      next2WeeksRoute: _parseRoute(data['next2WeeksRoute']),
      mutualConnections: (data['mutualConnections'] as List?)?.whereType<String>().toList() ?? [],
    );
  }

  static LookingFor _parseLookingFor(String? value) {
    return LookingFor.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LookingFor.both,
    );
  }

  static TravelStyle _parseTravelStyle(String? value) {
    return TravelStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TravelStyle.slowExplorer,
    );
  }

  static WorkSituation _parseWorkSituation(String? value) {
    return WorkSituation.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkSituation.remoteWorker,
    );
  }

  static List<LatLng> _parseRoute(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map>().map((point) {
      final lat = (point['lat'] as num?)?.toDouble() ?? 0;
      final lng = (point['lng'] as num?)?.toDouble() ?? 0;
      return LatLng(lat, lng);
    }).toList();
  }
}

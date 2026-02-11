import 'package:cloud_firestore/cloud_firestore.dart';

import '../../mock/mock_data.dart';
import '../../mock/mock_profiles.dart';
import '../../mock/mock_stories.dart';
import '../firebase_refs.dart';

/// Service to migrate mock data to Firestore
/// This should be run once to populate the database with sample data
class DataMigration {
  /// Upload all mock data to Firestore
  static Future<void> uploadMockData() async {
    await uploadUsers();
    await uploadLocations();
    await uploadStories();
    print('✅ Mock data uploaded to Firestore successfully!');
  }

  /// Upload mock users and their profiles
  static Future<void> uploadUsers() async {
    print('Uploading users...');
    
    // Upload nearby nomads
    for (final user in MockData.nearbyNomads) {
      final profile = MockProfiles.profilesByUserId[user.id];
      if (profile == null) continue;

      final userData = {
        'name': user.name,
        'age': user.age,
        'lookingFor': user.lookingFor.name,
        'activities': user.activities,
        'travelStyle': user.travelStyle.name,
        'workSituation': user.workSituation.name,
        'adventureScore': user.adventureScore,
        // Profile data
        'bio': profile.bio,
        'onTheRoadSince': Timestamp.fromDate(profile.onTheRoadSince),
        'currentLocationLabel': profile.currentLocationLabel,
        'nextDestinationLabel': profile.nextDestinationLabel,
        'vanType': profile.vanType,
        'vanYear': profile.vanYear,
        'vanName': profile.vanName,
        'buildHighlights': profile.buildHighlights,
        'last30DaysRoute': profile.last30DaysRoute
            .map((ll) => {'lat': ll.latitude, 'lng': ll.longitude})
            .toList(),
        'next2WeeksRoute': profile.next2WeeksRoute
            .map((ll) => {'lat': ll.latitude, 'lng': ll.longitude})
            .toList(),
        'mutualConnections': profile.mutualConnections,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseRefs.users().doc(user.id).set(userData);
      print('  ✓ Uploaded user: ${user.name}');
    }
  }

  /// Upload mock locations
  static Future<void> uploadLocations() async {
    print('Uploading locations...');
    
    for (final location in MockData.nearbyLocations) {
      final locationData = {
        'userId': location.userId,
        'lat': location.position.latitude,
        'lng': location.position.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseRefs.locations().doc(location.userId).set(locationData);
      print('  ✓ Uploaded location for user: ${location.userId}');
    }
  }

  /// Upload mock stories
  static Future<void> uploadStories() async {
    print('Uploading stories...');
    
    for (final story in MockStories.stories) {
      final storyData = {
        'authorId': story.author.id,
        'authorName': story.author.name,
        'authorAge': story.author.age,
        'authorLookingFor': story.author.lookingFor.name,
        'authorActivities': story.author.activities,
        'authorTravelStyle': story.author.travelStyle.name,
        'authorWorkSituation': story.author.workSituation.name,
        'authorAdventureScore': story.author.adventureScore,
        'videoUrl': story.videoUrl,
        'caption': story.caption,
        'category': story.category.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseRefs.stories().doc(story.id).set(storyData);
      print('  ✓ Uploaded story: ${story.id}');
    }
  }

  /// Clear all mock data from Firestore (useful for testing)
  static Future<void> clearMockData() async {
    print('Clearing mock data from Firestore...');
    
    // Delete users
    for (final user in MockData.nearbyNomads) {
      await FirebaseRefs.users().doc(user.id).delete();
    }
    
    // Delete locations
    for (final location in MockData.nearbyLocations) {
      await FirebaseRefs.locations().doc(location.userId).delete();
    }
    
    // Delete stories
    for (final story in MockStories.stories) {
      await FirebaseRefs.stories().doc(story.id).delete();
    }
    
    print('✅ Mock data cleared from Firestore!');
  }
}

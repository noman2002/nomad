import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/nomad_user.dart';
import '../../models/story.dart';
import '../firebase_refs.dart';

class StoriesService {
  static Stream<List<Story>> watchStories({StoryCategory? category, int limit = 50}) {
    Query<Map<String, dynamic>> query = FirebaseRefs.stories().orderBy(
      'createdAt',
      descending: true,
    );

    if (category != null && category != StoryCategory.forYou) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  static Stream<Set<StoryId>> watchLikedStoryIds({required String uid}) {
    return FirebaseRefs.users().doc(uid).collection('likedStories').snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toSet();
    });
  }

  static Future<void> setLiked({
    required String uid,
    required StoryId storyId,
    required bool liked,
  }) async {
    final ref = FirebaseRefs.users().doc(uid).collection('likedStories').doc(storyId);
    if (liked) {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  static Story _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final authorId = (data['authorId'] as String?) ?? 'unknown';
    final authorName = (data['authorName'] as String?) ?? 'Unknown';
    final authorAge = (data['authorAge'] as num?)?.toInt() ?? 0;

    final lookingForStr = (data['authorLookingFor'] as String?) ?? 'both';
    final lookingFor = LookingFor.values.firstWhere(
      (e) => e.name == lookingForStr,
      orElse: () => LookingFor.both,
    );

    final activities = (data['authorActivities'] as List?)?.whereType<String>().toList() ?? const [];

    final travelStyleStr = (data['authorTravelStyle'] as String?) ?? 'slowExplorer';
    final travelStyle = TravelStyle.values.firstWhere(
      (e) => e.name == travelStyleStr,
      orElse: () => TravelStyle.slowExplorer,
    );

    final workSituationStr = (data['authorWorkSituation'] as String?) ?? 'remoteWorker';
    final workSituation = WorkSituation.values.firstWhere(
      (e) => e.name == workSituationStr,
      orElse: () => WorkSituation.remoteWorker,
    );

    final adventureScore = (data['authorAdventureScore'] as num?)?.toInt() ?? 0;

    final categoryStr = (data['category'] as String?) ?? StoryCategory.forYou.name;
    final category = StoryCategory.values.firstWhere(
      (e) => e.name == categoryStr,
      orElse: () => StoryCategory.forYou,
    );

    final videoUrl = (data['videoUrl'] as String?) ?? '';
    final caption = (data['caption'] as String?) ?? '';

    return Story(
      id: doc.id,
      author: NomadUser(
        id: authorId,
        name: authorName,
        age: authorAge,
        lookingFor: lookingFor,
        activities: activities,
        travelStyle: travelStyle,
        workSituation: workSituation,
        adventureScore: adventureScore,
      ),
      videoUrl: videoUrl,
      caption: caption,
      category: category,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_refs.dart';

class UserService {
  static Future<void> upsertUser({
    required String uid,
    required Map<String, Object?> data,
  }) async {
    await FirebaseRefs.users().doc(uid).set(
          {
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await FirebaseRefs.users().doc(uid).get();
    return doc.data();
  }

  static Stream<Map<String, dynamic>?> watchUser(String uid) {
    return FirebaseRefs.users().doc(uid).snapshots().map((doc) => doc.data());
  }
}

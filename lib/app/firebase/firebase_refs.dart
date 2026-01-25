import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseRefs {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static CollectionReference<Map<String, dynamic>> users() =>
      firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> locations() =>
      firestore.collection('locations');

  static CollectionReference<Map<String, dynamic>> stories() =>
      firestore.collection('stories');

  static CollectionReference<Map<String, dynamic>> matches() =>
      firestore.collection('matches');

  static CollectionReference<Map<String, dynamic>> conversations() =>
      firestore.collection('conversations');

  static CollectionReference<Map<String, dynamic>> messages(
    String conversationId,
  ) => conversations().doc(conversationId).collection('messages');
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat.dart';
import '../../models/nomad_user.dart';
import '../firebase_refs.dart';

class ChatService {
  static Stream<List<Conversation>> watchConversations({required String uid, int limit = 50}) {
    final query = FirebaseRefs.conversations()
        .where('memberUids', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map(_conversationFromDoc).toList();
    });
  }

  static Stream<List<ChatMessage>> watchMessages({required ConversationId conversationId, int limit = 100}) {
    return FirebaseRefs.messages(conversationId)
        .orderBy('sentAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_messageFromDoc).toList();
    });
  }

  static Future<void> sendText({
    required ConversationId conversationId,
    required String fromUserId,
    required String text,
  }) async {
    final msgRef = FirebaseRefs.messages(conversationId).doc();
    final msg = <String, Object?>{
      'fromUserId': fromUserId,
      'kind': MessageKind.text.name,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    };

    await FirebaseRefs.firestore.runTransaction((txn) async {
      txn.set(msgRef, msg);
      txn.set(
        FirebaseRefs.conversations().doc(conversationId),
        {
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageText': text,
          'lastMessageKind': MessageKind.text.name,
          'lastMessageAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  static Future<void> sendCoffeePing({
    required ConversationId conversationId,
    required String fromUserId,
    required String text,
  }) async {
    final msgRef = FirebaseRefs.messages(conversationId).doc();
    final msg = <String, Object?>{
      'fromUserId': fromUserId,
      'kind': MessageKind.coffeePing.name,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    };

    await FirebaseRefs.firestore.runTransaction((txn) async {
      txn.set(msgRef, msg);
      txn.set(
        FirebaseRefs.conversations().doc(conversationId),
        {
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageText': text,
          'lastMessageKind': MessageKind.coffeePing.name,
          'lastMessageAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  static Future<void> markRead({
    required ConversationId conversationId,
    required String uid,
  }) async {
    await FirebaseRefs.conversations().doc(conversationId).set(
      {
        'lastReadAt': {uid: FieldValue.serverTimestamp()},
      },
      SetOptions(merge: true),
    );
  }

  static Conversation _conversationFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final withUserId = (data['withUserId'] as String?) ?? '';
    final unreadCount = (data['unreadCount'] as num?)?.toInt() ?? 0;
    final isMoving = (data['isMoving'] as bool?) ?? false;

    final lastText = data['lastMessageText'] as String?;
    final lastKindStr = data['lastMessageKind'] as String?;
    final lastKind = MessageKind.values.firstWhere(
      (e) => e.name == lastKindStr,
      orElse: () => MessageKind.text,
    );

    final lastAtTs = data['lastMessageAt'] as Timestamp?;

    final messages = <ChatMessage>[];
    if (lastText != null) {
      messages.add(
        ChatMessage(
          id: 'last',
          fromUserId: withUserId,
          sentAt: lastAtTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
          kind: lastKind,
          text: lastText,
        ),
      );
    }

    return Conversation(
      id: doc.id,
      withUserId: withUserId,
      messages: messages,
      unreadCount: unreadCount,
      isMoving: isMoving,
    );
  }

  static ChatMessage _messageFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final kindStr = data['kind'] as String?;
    final kind = MessageKind.values.firstWhere(
      (e) => e.name == kindStr,
      orElse: () => MessageKind.text,
    );

    return ChatMessage(
      id: doc.id,
      fromUserId: (data['fromUserId'] as String?) ?? 'unknown',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      kind: kind,
      text: (data['text'] as String?) ?? '',
    );
  }
}

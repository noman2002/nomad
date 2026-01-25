import 'nomad_user.dart';

typedef MessageId = String;

enum MessageKind { text, coffeePing, location, route }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.fromUserId,
    required this.sentAt,
    required this.kind,
    required this.text,
  });

  final MessageId id;
  final UserId fromUserId;
  final DateTime sentAt;
  final MessageKind kind;
  final String text;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.withUserId,
    required this.messages,
    required this.unreadCount,
    required this.isMoving,
  });

  final ConversationId id;
  final UserId withUserId;
  final List<ChatMessage> messages;
  final int unreadCount;
  final bool isMoving;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

import 'package:flutter/foundation.dart';

import '../mock/mock_data.dart';
import '../models/chat.dart';
import '../models/nomad_user.dart';

class ChatState extends ChangeNotifier {
  final Map<ConversationId, Conversation> _conversations = <ConversationId, Conversation>{
    'c1': Conversation(
      id: 'c1',
      withUserId: 'u1',
      unreadCount: 2,
      isMoving: true,
      messages: [
        ChatMessage(
          id: 'm1',
          fromUserId: 'u1',
          sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
          kind: MessageKind.text,
          text: 'Hey! Headed to Joshua Tree too?',
        ),
        ChatMessage(
          id: 'm2',
          fromUserId: 'me',
          sentAt: DateTime.now().subtract(const Duration(minutes: 6)),
          kind: MessageKind.text,
          text: 'Yeah! I\'m leaving tomorrow morning.',
        ),
      ],
    ),
    'c2': Conversation(
      id: 'c2',
      withUserId: 'u2',
      unreadCount: 0,
      isMoving: false,
      messages: [
        ChatMessage(
          id: 'm3',
          fromUserId: 'u2',
          sentAt: DateTime.now().subtract(const Duration(hours: 3)),
          kind: MessageKind.text,
          text: 'Found a great camp spot, want coords?',
        ),
      ],
    ),
  };

  List<Conversation> get conversations => _conversations.values.toList();

  Conversation conversationById(ConversationId id) {
    return _conversations[id]!;
  }

  NomadUser userFor(UserId id) {
    if (id == 'me') return MockData.currentUser;
    return MockData.nearbyNomads.firstWhere((u) => u.id == id);
  }

  void sendText(ConversationId id, String text) {
    _appendMessage(
      id: id,
      kind: MessageKind.text,
      text: text,
    );
  }

  void sendCoffeePing(ConversationId id, String locationLabel) {
    _appendMessage(
      id: id,
      kind: MessageKind.coffeePing,
      text: 'Hey! I\'m grabbing coffee at $locationLabel, want to join?',
    );
  }

  void sendLocation(ConversationId id, {required String label, required double lat, required double lng}) {
    final text = label.trim().isEmpty
        ? 'Shared location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
        : 'Shared location: $label (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

    _appendMessage(
      id: id,
      kind: MessageKind.location,
      text: text,
    );
  }

  void sendRoute(ConversationId id, {required String from, required String to}) {
    final f = from.trim().isEmpty ? 'Somewhere' : from.trim();
    final t = to.trim().isEmpty ? 'Somewhere' : to.trim();

    _appendMessage(
      id: id,
      kind: MessageKind.route,
      text: 'Shared route: $f → $t',
    );
  }

  void _appendMessage({
    required ConversationId id,
    required MessageKind kind,
    required String text,
  }) {
    final conv = _conversations[id]!;
    final msg = ChatMessage(
      id: 'm-${DateTime.now().microsecondsSinceEpoch}',
      fromUserId: 'me',
      sentAt: DateTime.now(),
      kind: kind,
      text: text,
    );

    _conversations[id] = Conversation(
      id: conv.id,
      withUserId: conv.withUserId,
      unreadCount: conv.unreadCount,
      isMoving: conv.isMoving,
      messages: [...conv.messages, msg],
    );
    notifyListeners();
  }

  void markRead(ConversationId id) {
    final conv = _conversations[id]!;
    if (conv.unreadCount == 0) return;
    _conversations[id] = Conversation(
      id: conv.id,
      withUserId: conv.withUserId,
      unreadCount: 0,
      isMoving: conv.isMoving,
      messages: conv.messages,
    );
    notifyListeners();
  }
}

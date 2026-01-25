import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/chat_state.dart';
import '../chats/chat_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatState>();
    final conversations = chat.conversations;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = conversations[index];
          final other = chat.userFor(c.withUserId);
          final last = c.lastMessage;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            tileColor: const Color(0xFF111114),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              child: Text(other.name.characters.first),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    other.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (c.isMoving)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'On the road',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              last?.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: c.unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${c.unreadCount}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(conversationId: c.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

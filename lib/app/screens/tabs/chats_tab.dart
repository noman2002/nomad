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

          final theme = Theme.of(context);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            tileColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.primary,
              child: Text(other.name.characters.first),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    other.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (c.isMoving)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'On the road',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              last?.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: c.unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${c.unreadCount}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
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

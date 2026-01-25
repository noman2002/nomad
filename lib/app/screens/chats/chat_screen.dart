import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat.dart';
import '../../models/nomad_user.dart';
import '../../state/chat_state.dart';
import 'share_location_sheet.dart';
import 'share_route_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final ConversationId conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatState>().markRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatState>();
    final conv = chat.conversationById(widget.conversationId);
    final other = chat.userFor(conv.withUserId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(other.name),
            const SizedBox(width: 10),
            if (conv.isMoving)
              const Text(
                'On the road',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final location = await _askCoffeeLocation(context);
              if (location == null || location.trim().isEmpty) return;
              if (!context.mounted) return;
              chat.sendCoffeePing(widget.conversationId, location.trim());
            },
            icon: const Icon(Icons.local_cafe_outlined),
            tooltip: 'Coffee Ping',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                final m = conv.messages[index];
                final mine = m.fromUserId == 'me';
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: mine
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: mine ? Colors.black : Colors.white,
                        fontWeight: m.kind == MessageKind.coffeePing
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<ShareLocationResult>(
                        context: context,
                        backgroundColor: const Color(0xFF111114),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const ShareLocationSheet(),
                      );
                      if (result == null || !context.mounted) return;
                      chat.sendLocation(
                        widget.conversationId,
                        label: result.label,
                        lat: result.position.latitude,
                        lng: result.position.longitude,
                      );
                    },
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Send location',
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<ShareRouteResult>(
                        context: context,
                        backgroundColor: const Color(0xFF111114),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const ShareRouteSheet(),
                      );
                      if (result == null || !context.mounted) return;
                      chat.sendRoute(
                        widget.conversationId,
                        from: result.from,
                        to: result.to,
                      );
                    },
                    icon: const Icon(Icons.route_outlined),
                    tooltip: 'Send route',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(chat),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _send(chat),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(ChatState chat) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    chat.sendText(widget.conversationId, text);
  }

  Future<String?> _askCoffeeLocation(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Coffee Ping'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Where are you grabbing coffee?',
              hintText: 'e.g. Blue Bottle - Venice',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}

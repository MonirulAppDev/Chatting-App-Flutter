import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/message_widget.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final myId = ref.read(userProvider);
    final receiverId = ref.read(recipientProvider);
    
    if (_controller.text.trim().isNotEmpty && myId != null && receiverId != null) {
      ref.read(chatNotifierProvider.notifier).sendMessage(
            to: receiverId,
            from: myId,
            content: _controller.text.trim(),
          );
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allMessages = ref.watch(messageListProvider);
    final myId = ref.watch(userProvider) ?? "Unknown";
    final receiverId = ref.watch(recipientProvider) ?? "Unknown";

    // ফিল্টার করা মেসেজ
    final messages = allMessages.where((m) => 
      (m.from == myId && m.to == receiverId) || 
      (m.from == receiverId && m.to == myId)
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // WhatsApp Background Color
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 18,
              child: Text(receiverId[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receiverId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("Online", style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty 
              ? const Center(child: Text("No messages yet. Send a message to start!"))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageWidget(
                      message: message,
                      isMe: message.from == myId,
                    );
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      prefixIcon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                      suffixIcon: const Icon(Icons.attach_file, color: Colors.grey),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

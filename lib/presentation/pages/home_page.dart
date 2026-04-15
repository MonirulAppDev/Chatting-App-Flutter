import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import 'chat_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _startNewChat(BuildContext context, WidgetRef ref) {
    final TextEditingController userController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: TextField(
          controller: userController,
          decoration: const InputDecoration(hintText: "Enter username (e.g. brian)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (userController.text.trim().isNotEmpty) {
                ref.read(recipientProvider.notifier).state = userController.text.trim();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(userProvider) ?? "Unknown";
    final messages = ref.watch(messageListProvider);
    
    // ইউনিক ইউজার লিস্ট বের করা (যাদের সাথে কথা হয়েছে)
    final chatUsers = <String>{};
    for (var m in messages) {
      if (m.from != myId) chatUsers.add(m.from);
      if (m.to != myId) chatUsers.add(m.to);
    }
    final users = chatUsers.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text("No chats yet. Start a new one!"))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(user[0].toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Tap to chat"),
                  trailing: const Text("10:00 AM", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    ref.read(recipientProvider.notifier).state = user;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context, ref),
        backgroundColor: Colors.green,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

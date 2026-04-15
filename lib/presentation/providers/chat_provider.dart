import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import 'user_provider.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: remoteDataSource);
});

// মেসেজ লিস্ট ম্যানেজ করার জন্য নটিফায়ার
class MessageListNotifier extends StateNotifier<List<Message>> {
  final ChatRepository repository;
  final Ref ref;

  MessageListNotifier(this.repository, this.ref) : super([]) {
    final userId = ref.read(userProvider);
    if (userId != null) {
      repository.connect(userId);
      _listenToMessages();
    }
  }

  void _listenToMessages() {
    repository.getMessages().listen(
      (message) {
        state = [...state, message];
      },
      onError: (error) => print("Stream Error: $error"),
    );
  }

  void addLocalMessage(Message message) {
    state = [...state, message];
  }

  // নির্দিষ্ট ইউজারের সাথে মেসেজ ফিল্টার করা
  List<Message> getMessagesWith(String otherUser) {
    final myId = ref.read(userProvider);
    return state.where((m) => 
      (m.from == myId && m.to == otherUser) || 
      (m.from == otherUser && m.to == myId)
    ).toList();
  }

  // যাদের সাথে চ্যাট হয়েছে তাদের লিস্ট
  List<String> getChatUsers() {
    final myId = ref.read(userProvider);
    final users = <String>{};
    for (var m in state) {
      if (m.from != myId) users.add(m.from);
      if (m.to != myId) users.add(m.to);
    }
    return users.toList();
  }
}

final messageListProvider = StateNotifierProvider<MessageListNotifier, List<Message>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return MessageListNotifier(repository, ref);
});

class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository repository;
  final Ref ref;

  ChatNotifier(this.repository, this.ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({required String to, required String from, required String content}) async {
    final message = Message(
      to: to,
      from: from,
      content: content,
      timestamp: DateTime.now(),
    );

    ref.read(messageListProvider.notifier).addLocalMessage(message);

    try {
      await repository.sendMessage(message);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository, ref);
});

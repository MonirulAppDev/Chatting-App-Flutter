import '../entities/message.dart';

abstract class ChatRepository {
  Stream<Message> getMessages();
  Future<void> sendMessage(Message message);
  void connect(String userId); // userId প্যারামিটার যোগ করা হয়েছে
  void disconnect();
}

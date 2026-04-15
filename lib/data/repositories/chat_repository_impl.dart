import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  void connect(String userId) { // userId যোগ করা হয়েছে
    remoteDataSource.connect(userId);
  }

  @override
  void disconnect() {
    remoteDataSource.disconnect();
  }

  @override
  Stream<Message> getMessages() {
    return remoteDataSource.getMessages();
  }

  @override
  Future<void> sendMessage(Message message) async {
    remoteDataSource.sendMessage(MessageModel.fromEntity(message));
  }
}

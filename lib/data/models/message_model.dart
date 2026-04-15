import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.to,
    required super.from,
    required super.content,
    required super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      to: json['to'] ?? '',
      from: json['from'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'from': from,
      'content': content,
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      to: message.to,
      from: message.from,
      content: message.content,
      timestamp: message.timestamp,
    );
  }
}

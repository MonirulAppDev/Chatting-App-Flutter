import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String to;
  final String from;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.to,
    required this.from,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [to, from, content, timestamp];
}

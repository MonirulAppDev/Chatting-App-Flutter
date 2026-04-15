import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> getMessages();
  void sendMessage(MessageModel message);
  void connect(String userId); // userId প্যারামিটার যোগ করা হয়েছে
  void disconnect();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  WebSocketChannel? _channel;
  // গুরুত্বপূর্ণ: আপনার পিসির লোকাল আইপি এখানে দিন (যেমন: 10.192.168.34)
  // ইমুলেটর হলে 10.0.2.2 ব্যবহার করা যায়।
  final String baseUrl = 'ws://10.192.168.34:8080/ws'; 

  @override
  void connect(String userId) {
    // আগের কানেকশন থাকলে সেটি বন্ধ করে নতুন করে কানেক্ট করা ভাল
    if (_channel != null) disconnect();
    
    final url = '$baseUrl?user_id=$userId';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      log("WebSocket Connected to: $url");
    } catch (e) {
      log("WebSocket Connection Error: $e");
    }
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  @override
  Stream<MessageModel> getMessages() {
    if (_channel == null) {
      log("Error: WebSocket not connected. Call connect() first.");
      return const Stream.empty();
    }
    return _channel!.stream.map((event) {
      log("Server Received Raw: $event");
      final Map<String, dynamic> data = jsonDecode(event);
      return MessageModel.fromJson(data);
    }).handleError((error) {
      log("Stream Error: $error");
    });
  }

  @override
  void sendMessage(MessageModel message) {
    if (_channel == null) {
      log("Cannot send message: WebSocket not connected.");
      return;
    }
    try {
      final jsonStr = jsonEncode(message.toJson());
      _channel?.sink.add(jsonStr);
      log("Sent to Server: $jsonStr");
    } catch (e) {
      log("Send Error: $e");
    }
  }
}

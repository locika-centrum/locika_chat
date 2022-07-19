import 'dart:io';

class ChatResponse<T> {
  late int statusCode;
  Cookie? cookie;
  String? message;
  String? advisorID;
  String? chatID;

  List<T> data = [];

  ChatResponse({
    required this.statusCode,
    this.advisorID,
    this.chatID,
    this.cookie,
  });

  @override
  String toString() =>
      'Status: $statusCode, AdvisorID: $advisorID, ChatID: $chatID, Cookie: $cookie, Data length: ${data.length}';
}

class ChatMessage {
  late String advisorID;
  late String chatID;
  late DateTime dateTime;
  late String time;
  late String sysMessage;
  late String message;

  ChatMessage({
    required this.advisorID,
    required this.chatID,
    required this.time,
    required this.dateTime,
    required this.sysMessage,
    required this.message,
  });

  @override
  String toString() => '($sysMessage: $advisorID [$chatID]) - $message';
}

import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String? chatID;

  const ChatScreen({Key? key, this.chatID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text('Chat s Locika $chatID'),
          elevation: 0,
        ),
    );
  }
}

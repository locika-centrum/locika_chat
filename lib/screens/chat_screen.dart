import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:bubble/bubble.dart';

import '../models/chat_id.dart';
import '../providers/app_settings.dart';
import '../services/neziskovky_parser.dart';
import '../models/chat_message.dart';

Logger _log = Logger('ChatScreen');

class ChatScreen extends StatefulWidget {
  final String advisorID;

  const ChatScreen({
    Key? key,
    required this.advisorID,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  StreamController<List<ChatMessage>> controller =
      StreamController<List<ChatMessage>>();
  Timer? timer;
  ChatID? chatID;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    startChat();
    timer = Timer.periodic(
      /// Fetch the status of the available rooms every x seconds
      const Duration(seconds: 2),
      (Timer t) => fetchChat(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> startChat() async {
    /// Retrieve the chatID and cookies from local storage if it exists
    /// otherwise get new session with new chatID
    chatID = (AppSettings.chatID.value != null &&
            AppSettings.storedCookies.value != null)
        ? ChatID(
            advisorID: widget.advisorID,
            chatID: AppSettings.chatID.value!,
            cookies: AppSettings.storedCookies.value!,
          )
        : await NeziskovkyChatParser.initiateChat(widget.advisorID);
    await fetchChat();

    _log.info('Logged to ChatID ${chatID?.chatID}');
    setState(() {
      AppSettings.setChatID(chatID?.chatID);
      AppSettings.setCookies(chatID?.cookies);

      isReady = true;
    });
  }

  Future<void> fetchChat() async {
    List<ChatMessage> result =
        await NeziskovkyChatParser.getChatHistory(chatID: chatID!);
    controller.add(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Chat s ${widget.advisorID}'),
        elevation: 0,
      ),
      body: isReady
          ? StreamBuilder(
              stream: controller.stream,
              builder: (BuildContext ctx,
                  AsyncSnapshot<List<ChatMessage>> snapshot) {
                return Column(
                  children: [
                    Expanded(
                      child: SafeArea(
                        child: snapshot.data != null
                            ? ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: _buildChatItem(
                                        snapshot.data![index], context),
                                  );
                                },
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    SafeArea(
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 8,
                          ),
                          Text('TODO - tady bude input field'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Bubble _buildChatItem(ChatMessage message, BuildContext context) {
    _log.finest('${message.sysMessage} > ${message.message}');
    return Bubble(
      nip: BubbleNip.leftBottom,
      color: message.sysMessage == 'Pracovník chatu' ? Colors.lime : null,
      alignment: Alignment.topLeft,
      child: Text(message.message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black)),
    );
  }
}

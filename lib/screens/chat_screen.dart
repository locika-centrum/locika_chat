import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:bubble/bubble.dart';

import '../providers/app_settings.dart';
import '../services/neziskovky_parser.dart';
import '../models/chat_response.dart';
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
  final TextEditingController _inputController = TextEditingController();
  bool sendButton = false;

  Timer? timer;
  String? chatID;
  Cookie? cookie;
  String username = AppSettings.nickName.value ?? '';
  String password = 'too_many_secrets';
  String timestamp = '';
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    cookie = AppSettings.cookie.value;

    // TODO - manage login
    login(username, password);
    // last login : cookie: id_session=20220626082858098bf1931d886d2a; Expires=Mon, 27 Jun 2022 06:28:58 GMT; Domain=chat.neziskovky.com; Path=/; Secure
    connectToChat(widget.advisorID, cookie!, username);

    timer = Timer.periodic(
      // Fetch the status of the available rooms every x seconds
      const Duration(seconds: 2),
      (Timer t) => getChatHistory(widget.advisorID, chatID!, cookie!, username),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> login(String username, String password) async {
    ChatResponse result =
        await authenticate(username: username, password: password);
    _log.finest('login: ${result.statusCode}');
    _log.finest('cookie: ${result.cookie}');
    cookie = result.cookie;
    if (!isReady) {
      AppSettings.setCookie(cookie!);
    }
  }

  /// Retrieve the chatID and cookies from local storage if it exists
  /// otherwise get new session with new chatID
  Future<void> connectToChat(
      String advisorID, Cookie cookie, String nickName) async {
    ChatResponse response;

    // Open new chat or connect to existing
    response = await initChat(
      advisorID: advisorID,
      cookie: cookie,
    );
    this.cookie = response.cookie;
    chatID = response.chatID;
    AppSettings.setChatID(chatID);

    // Get initial chat history
    await getChatHistory(advisorID, chatID!, cookie, nickName);
    _log.finest('ChatID: ${response.chatID} with ${response.advisorID}');

    setState(() {
      isReady = true;
    });
  }

  Future<void> getChatHistory(
      String advisorID, String chatID, Cookie cookie, String nickName) async {
    _log.finest('getChatHistory> Original timestamp: $timestamp');
    String newTimestamp =
        await getChatTimestamp(chatID: chatID, cookie: cookie);
    _log.finest('getChatHistory> New timestamp: $newTimestamp');

    if (timestamp != newTimestamp) {
      timestamp = newTimestamp;

      _log.finest(
          'getChatHistory> Retrieving chat history for ChatID: $chatID with $advisorID - $cookie');
      ChatResponse<ChatMessage> result = await getChatMessages(
          advisorID: advisorID,
          chatID: chatID,
          cookie: cookie,
          nickName: nickName);

      _log.finest(
          'getChatHistory> ChatID: $chatID - with ${result.data.length} messages');
      for (ChatMessage message in result.data) {
        _log.finest(message);
      }

      controller.add(result.data);
    }
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
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 70,
                            child: Card(
                              margin: const EdgeInsets.only(
                                  left: 2, right: 2, bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: TextFormField(
                                  controller: _inputController,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 5,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        sendButton = true;
                                      });
                                    } else {
                                      setState(() {
                                        sendButton = false;
                                      });
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Napiš zprávu',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              left: 2,
                              right: 2,
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              child: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  if (sendButton) {
                                    _log.finest(
                                        'Sending: ${_inputController.text}');
                                    postMessage(
                                      text: _inputController.text,
                                      chatID: chatID!,
                                      cookie: cookie!,
                                    );

                                    _inputController.clear();
                                    setState(() {
                                      sendButton = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
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
      nip: message.sysMessage == username
          ? BubbleNip.rightBottom
          : BubbleNip.leftBottom,
      color: message.sysMessage == 'Pracovník chatu'
          ? Colors.lime
          : (message.sysMessage == username ? Colors.lightBlue.shade200 : null),
      alignment: message.sysMessage == username
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Text(message.message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black)),
    );
  }
}

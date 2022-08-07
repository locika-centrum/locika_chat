import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:bubble/bubble.dart';

import '../services/neziskovky_parser.dart';
import '../models/chat_response.dart';
import '../models/chat_message.dart';
import '../widgets/emergency_call.dart';
import '../widgets/chat_navigation_bar.dart';

Logger _log = Logger('ChatScreen');

class ChatScreen extends StatefulWidget {
  final String advisorID;
  final String nickName;
  final Function setCookie;
  final Cookie cookie;

  const ChatScreen({
    required this.nickName,
    required this.advisorID,
    required this.cookie,
    required this.setCookie,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  StreamController<List<ChatMessage>> controller =
      StreamController<List<ChatMessage>>();
  ScrollController _listScrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool sendButton = false;

  Timer? timer;
  String? chatID;
  late Cookie cookie;
  String timestamp = '';
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    this.cookie = widget.cookie;
    connectToChat(widget.advisorID, this.cookie, widget.nickName);

    timer = Timer.periodic(
      // Fetch the status of the available rooms every x seconds
      const Duration(seconds: 2),
      (Timer t) => getChatHistory(
          widget.advisorID, chatID!, this.cookie, widget.nickName),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
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
    chatID = response.chatID;

    // Get initial chat history
    await getChatHistory(advisorID, chatID!, cookie, nickName);
    _log.finest('ChatID: ${response.chatID} with ${response.advisorID}');

    setState(() {
      isReady = true;
    });
  }

  Future<void> getChatHistory(
    String advisorID,
    String chatID,
    Cookie cookie,
    String nickName,
  ) async {
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
      this.cookie = cookie;
      widget.setCookie(cookie);

      _log.finest(
          'getChatHistory> ChatID: $chatID - with ${result.data.length} messages');
      for (ChatMessage message in result.data) {
        _log.finest(message);
      }

      controller.add(result.data);
      if (isReady) {
        Future.delayed(Duration(seconds: 1), () {
          _listScrollController.jumpTo(_listScrollController.position.maxScrollExtent);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Chat'),
        actions: [
          EmergencyCallWidget(),
        ],
        elevation: 0,
      ),
      bottomNavigationBar: ChatNavigationBar(),
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
                                controller: _listScrollController,
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: _buildChatItem(
                                        snapshot.data![index], context, index),
                                  );
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
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
                                      cookie: this.cookie,
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

  Widget _buildChatItem(ChatMessage message, BuildContext context, int index) {
    _log.finest('${message.sysMessage} > ${message.message}');
    if (index == 0)
      return Center(child: Text('${message.dateTime.day}.${message.dateTime.month}.${message.dateTime.year}'));

    return Bubble(
      nip: message.sysMessage == widget.nickName
          ? BubbleNip.rightBottom
          : BubbleNip.leftBottom,
      color: message.sysMessage == 'Pracovník chatu'
          ? Colors.grey.shade200
          : (message.sysMessage == widget.nickName
              ? Colors.green.shade100
              : null),
      alignment: message.sysMessage == widget.nickName
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(message.message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black)),
          Text(message.time, style: TextStyle(color: Colors.black45),),
        ],
      ),
    );
  }
}

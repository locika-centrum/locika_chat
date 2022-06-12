import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../services/neziskovky_parser.dart';
import '../models/chat_room.dart';

Logger _log = Logger('ChatRoomScreen');

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({Key? key}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  StreamController<List<ChatRoom>> controller =
      StreamController<List<ChatRoom>>();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    fetchAvailableRooms();
    timer = Timer.periodic(
      /// Fetch the status of the available rooms every x seconds
      const Duration(seconds: 10),
      (Timer t) => fetchAvailableRooms(),
    );
  }

  Future<void> fetchAvailableRooms() async {
    List<ChatRoom> result = await NeziskovkyChatParser.getChatRooms();
    controller.add(result);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Vyber volný chat'),
        elevation: 0,
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: controller.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ChatRoom>> snapshot) {
          return SafeArea(
              child: ListView.builder(
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context)
                      .push('/chat/${snapshot.data![index].chatID}');
                },
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/person_icon.jpg'),
                    ),
                    title: Text(
                      snapshot.data![index].name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      snapshot.data![index].status,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              );
            },
            itemCount: snapshot.hasData ? snapshot.data?.length : 0,
          ));
        },
      ),
    );
  }
}

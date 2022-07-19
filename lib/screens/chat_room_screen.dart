import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../services/neziskovky_parser.dart';
import '../models/chat_room.dart';
import '../models/chat_response.dart';

Logger _log = Logger('ChatRoomScreen');

class ChatRoomScreen extends StatefulWidget {
  final Cookie cookie;

  const ChatRoomScreen({required Cookie this.cookie, Key? key})
      : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  StreamController<List<ChatRoom>> controller =
      StreamController<List<ChatRoom>>();
  Timer? timer;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    fetchAvailableRooms(widget.cookie);
    timer = Timer.periodic(
      /// Fetch the status of the available rooms every x seconds
      const Duration(seconds: 10),
      (Timer t) => fetchAvailableRooms(widget.cookie),
    );
  }

  Future<void> fetchAvailableRooms(Cookie cookie) async {
    ChatResponse<ChatRoom> result = await getChatRooms(cookie: cookie);
    if (!isReady) {
      setState(() {
        isReady = true;
      });
    }

    controller.add(result.data);
  }

  @override
  void dispose() {
    super.dispose();

    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Vyber volný chat'),
        elevation: 0,
      ),
      body: isReady
          ? StreamBuilder<List<ChatRoom>>(
              stream: controller.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ChatRoom>> snapshot) {
                if (snapshot.data?.length == 0) {
                  return Column(
                    children: [
                      SvgPicture.asset(
                          'assets/images/ErrorLochness.svg'),
                      SizedBox(height: 48.0),
                      Text('Omlouváme se, ale žádný operátor není volný.'),
                    ],
                  );
                }
                return SafeArea(
                    child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return GestureDetector(
                      onTap: () {
                        if (snapshot.data![index].advisorID != null) {
                          Navigator.pop(context);
                          GoRouter.of(context)
                              .push('/chat/${snapshot.data![index].advisorID}');
                        } else {
                          SnackBar snackBar = const SnackBar(
                            content: Text('Vybraný pracovník není online.'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
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
                            '${snapshot.data![index].status} - ${snapshot.data![index].advisorID}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.hasData ? snapshot.data?.length : 0,
                ));
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

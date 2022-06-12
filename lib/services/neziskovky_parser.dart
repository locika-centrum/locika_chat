import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/chat_id.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

Logger _log = Logger('NeziskovkyChatParser');

class NeziskovkyChatParser {
  static const String _scheme = 'https';
  static const String _host = 'chat.neziskovky.com';
  //static const String _host = 'locika.neziskovky.com';
  static const String _cgiPath = 'fcgi/sonic.cgi';

  static Future<List<ChatMessage>> getChatHistory(
      {required ChatID chatID}) async {
    String query = 'templ=p_chat_zpravy&id_chat=${chatID.chatID}';
    List<ChatMessage> result = [];

    final response = await http.Client().get(
        Uri(
          scheme: _scheme,
          host: _host,
          path: _cgiPath,
          query: query,
        ),
        headers: {
          'cookie': 'id_session=${chatID.sessionID}',
        });

    _log.finest('readFullChat: request = ${response.request?.url}');
    if (response.statusCode == 200) {
      Document document = parse(response.body);

      List<Element> elements = document.getElementsByClassName('chat_zprava');
      for (var element in elements) {
        Element time = element.getElementsByTagName('abbr').first;
        Element sysMessage = element.getElementsByTagName('b').first;
        Element? message;
        switch (sysMessage.text.trim()) {
          case 'Zpráva systému':
            message = element.getElementsByTagName('span').first;
            break;
          case 'Pracovník chatu':
            message = Element.tag('div');
            message.text = _cleanChatText(element.nodes.last.toString());
            break;
          default:
        }

        result.add(ChatMessage(
          advisorID: chatID.advisorID,
          chatID: chatID.chatID,
          time: time.text.trim(),
          sysMessage: sysMessage.text.trim(),
          message: message != null ? message.text.trim() : '',
        ));
      }
    }

    _log.finest('Chat history: $result');
    return result;
  }

  /// Removes leading double quotes and leading colon
  static String _cleanChatText(String text) {
    String result = text.replaceAll(RegExp(r'^":|"$'), '');

    return result.trim();
  }

  static Future<ChatID?> initiateChat(String advisorID) async {
    String query = 'templ=index&page_include=p_chat_det&chat_start=$advisorID';
    ChatID? result;

    final response = await http.Client().get(Uri(
      scheme: _scheme,
      host: _host,
      path: _cgiPath,
      query: query,
    ));

    _log.finest('readFullChat: request = ${response.request?.url}');
    if (response.statusCode == 200) {
      Document document = parse(response.body);
      List<Element> iFrameElements = document.getElementsByTagName('iframe');
      _log.finest('Length of the iFrame element: ${iFrameElements.length}');
      _log.finest('Chat id: ${iFrameElements[0].attributes['name']}');

      List<String>? splitChatId =
          iFrameElements[0].attributes['name']?.split('_');
      result = ChatID(
        advisorID: advisorID,
        chatID: splitChatId![splitChatId.length - 1],
        cookies: response.headers['set-cookie'] as String,
      );
    }

    _log.finest('Logged to chatID: $result');
    return result;
  }

  static Future<List<ChatRoom>> getChatRooms() async {
    String query = 'templ=p_chat_pracovnik';
    List<ChatRoom> result = [];

    final response = await http.Client().get(Uri(
      scheme: _scheme,
      host: _host,
      path: _cgiPath,
      query: query,
    ));

    _log.finest('getChatRooms: request = ${response.request?.url}');
    if (response.statusCode == 200) {
      Document document = parse(response.body);
      List<Element> elements = document.getElementsByClassName('text-center');

      for (Element element in elements) {
        List<Element> elementStatus = element.getElementsByClassName('label');
        result.add(ChatRoom(
          roomUri: element.parent?.attributes['data-href'],
          name: element.nodes[0].toString(),
          status: elementStatus[0].nodes[0].toString(),
        ));
      }
    } else {
      _log.severe('error [${response.statusCode}] returned in getChatRooms');
    }

    _log.finest('Chat rooms: $result');
    return result;
  }
}

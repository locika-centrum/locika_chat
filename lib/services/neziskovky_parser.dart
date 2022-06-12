import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/chat_room.dart';

Logger _log = Logger('NeziskovkyChatParser');

class NeziskovkyChatParser {
  static const String _scheme = 'https';
  static const String _host = 'chat.neziskovky.com';
  //static const String _host = 'locika.neziskovky.com';
  static const String _cgiPath = 'fcgi/sonic.cgi';

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

    _log.finest(result);
    return result;
  }
}

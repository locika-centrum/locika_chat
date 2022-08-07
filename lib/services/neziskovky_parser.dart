/// HTML parsing of the neziskovky.com chat application
library chat_parser;

import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/chat_response.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

const String _scheme = 'https';
const String _host = 'chat.neziskovky.com';
// const String _host = 'locika.neziskovky.com';
const String _cgiPath = 'fcgi/sonic.cgi';

const int _OK = 200;
const int _BAD_REQUEST = 400;
const int _UNAUTHORIZED = 401;
const int _METHOD_NOT_ALLOWED = 405;
const int _INTERNAL_SERVER_ERROR = 500;

enum _HttpMethod {
  get,
  post,
}

extension _ParseToString on _HttpMethod {
  String text() => toString().split('.').last.toUpperCase();
}

Logger _log = Logger('NeziskovkyChatParser');
http.Client? _client;

/// Retrieves list of chat rooms
Future<ChatResponse<ChatRoom>> getChatRooms({Cookie? cookie}) async {
  ChatResponse<ChatRoom> result;

  http.Response response = await _queryServer(
    method: _HttpMethod.get,
    query: 'templ=p_chat_pracovnik',
    cookie: cookie,
  );
  result = ChatResponse(
      statusCode: response.statusCode,
      cookie: response.headers.containsKey('set-cookie')
          ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
          : null);
  if (result.statusCode == 200) {
    Document document = parse(response.body);
    List<Element> elements = document.getElementsByClassName('text-center');

    for (Element element in elements) {
      List<Element> elementStatus = element.getElementsByClassName('label');

      if (element.parent?.attributes['data-href'] != null) {
        result.data.add(ChatRoom(
          roomUri: element.parent?.attributes['data-href'],
          name: element.nodes[0].toString(),
          status: elementStatus[0].nodes[0].toString(),
        ));
      }
    }
  }

  return result;
}

Future<ChatResponse> authenticate({
  required String username,
  required String password,
}) async {
  ChatResponse result;
  PostParameters body;

  body = PostParameters();
  body.add('refer_login', 'login');
  body.add('modal_login_id', '');
  body.add('p_login_reg_simple_redirect_href_register', '');
  body.add('templ', 'p_login_reg_simple');
  body.add('page_include', '');
  body.add('search', '');
  body.add('uvod', '');
  body.add('id_tree', '');
  body.add('forum_refer', '');
  body.add('login_name', username);
  body.add('login_pwd', password);

  http.Response response = await _queryServer(
    method: _HttpMethod.post,
    query: 'templ=p_login_reg_simple',
    body: body.parameters,
  );
  result = ChatResponse(
      statusCode: response.statusCode,
      cookie: response.headers.containsKey('set-cookie')
          ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
          : null);
  if (result.statusCode == 200) {
    Document document = parse(response.body);
    List<Element> elements = document.getElementsByTagName('center');
    if (elements.length == 2) {
      if (elements[0].text.trim().length == 0 ||
          elements[0].text.contains('Chyba')) {
        _log.warning('Login not successful');
        result.statusCode = _UNAUTHORIZED;
      } else {
        _log.info('Login successful');
      }
    } else {
      _log.warning('Unexpected HTML response');
      result.statusCode = _BAD_REQUEST;
    }
  }

  return result;
}

Future<ChatResponse> register({
  required String username,
  required String password,
}) async {
  ChatResponse result;
  String? token;
  PostParameters body;
  Cookie? cookie;

  http.Response response = await _queryServer(
    method: _HttpMethod.get,
    query: 'templ=p_login_reg_simple',
  );
  cookie = response.headers.containsKey('set-cookie')
      ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
      : null;
  result = ChatResponse(
      statusCode: response.statusCode,
      cookie: cookie);
  if (result.statusCode == _OK) {
    Document document = parse(response.body);
    for (var element in document.getElementsByTagName('input')) {
      if (element.attributes.containsKey('name')) {
        if (element.attributes['name'] == 'pisnicka_bezi') {
          token = element.attributes['value'];
        }
      }
    }

    body = PostParameters();
    body.add('refer_login', 'login');
    body.add('pisnicka_bezi', token);
    body.add('registrovat_simple', 'yes');
    body.add('modal_login_id', '');
    body.add('p_login_reg_simple_redirect_href_register', '');
    body.add('templ', 'p_login_reg_simple');
    body.add('page_include', '');
    body.add('search', '');
    body.add('uvod', '');
    body.add('id_tree', '');
    body.add('forum_refer', '');
    body.add('reg_uname', username);
    body.add('reg_pwd', password);
    body.add('reg_pwd2', password);

    response = await _queryServer(
      method: _HttpMethod.post,
      query: 'templ=p_login_reg_simple',
      body: body.parameters,
      cookie: cookie,
    );
    result = ChatResponse(
        statusCode: response.statusCode,
        cookie: response.headers.containsKey('set-cookie')
            ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
            : null);
    if (result.statusCode == 200) {
      Document document = parse(response.body);
      List<Element> elements = document.getElementsByTagName('center');

      if (elements.length == 2) {
        if (elements[1].text.trim().length == 0 ||
            elements[1].text.contains('Chyba')) {
          result.message = elements[1].text.trim().replaceAll(RegExp(r'^\(Chyba registrace. |\)$'), '');
          _log.warning('Registration not successful - ${result.message}');
          result.statusCode = _UNAUTHORIZED;
        } else {
          _log.info('Registration successful');
        }
      } else {
        _log.warning('Unexpected HTML response');
        result.statusCode = _BAD_REQUEST;
      }
    }
  }

  return result;
}

/// Initiates chat - returns chatID - either already opened, or new
Future<ChatResponse> initChat({
  required String advisorID,
  Cookie? cookie,
}) async {
  ChatResponse result;

  _log.finest('initChat: Cookie = $cookie');
  // Else open new chat
  http.Response response = await _queryServer(
    method: _HttpMethod.get,
    query: 'templ=p_chat_control&chat_start=$advisorID',
    cookie: cookie,
  );
  result = ChatResponse(
    statusCode: response.statusCode,
    cookie: response.headers.containsKey('set-cookie')
        ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
        : null,
    advisorID: advisorID,
  );
  if (result.statusCode == 200) {
    _log.finest('initChat: ${response.body}');
    Document document = parse(response.body);
    for (Node node in document.nodes) {
      if (node.nodeType == Node.COMMENT_NODE) {
        List items = node.toString().split('#');
        if (items.isNotEmpty) {
          int index = items.indexOf('APP:ID_CHAT');
          if (index >= 0 && index < items.length - 1) {
            result.chatID = items[index + 1];
            break;
          }
        }
      }
    }
    _log.finest('after parsing: $result');
  }
  return result;
}

Future<String> getChatTimestamp({
  required String chatID,
  required Cookie cookie,
}) async {
  String result = '';

  http.Response response = await _queryServer(
    method: _HttpMethod.get,
    query: 'storage_free/1110/p_chat_${chatID}_nova_zprava.txt',
    cookie: cookie,
    file: true,
  );
  if (response.statusCode == 200) {
    result = response.body;
  }

  return result;
}

Future<ChatResponse<ChatMessage>> getChatMessages({
  required String advisorID,
  required String chatID,
  required Cookie cookie,
  required String nickName,
}) async {
  ChatResponse<ChatMessage> result;

  _log.finest('getChatMessages: Cookie = $cookie');
  // Open new chat, or connect to already existing
  http.Response response = await _queryServer(
    method: _HttpMethod.get,
    query: 'templ=p_chat_zpravy&id_chat=$chatID',
    cookie: cookie,
  );

  result = ChatResponse(
      statusCode: response.statusCode,
      cookie: response.headers.containsKey('set-cookie')
          ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
          : null);
  if (result.statusCode == 200) {
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
          if (sysMessage.text.trim() == nickName) {
            message = Element.tag('div');
            message.text = _cleanChatText(element.nodes.last.toString());
          }
      }

      result.data.add(ChatMessage(
        advisorID: advisorID,
        chatID: chatID,
        time: time.text.trim(),
        dateTime: DateTime.parse(time.attributes.values.first),
        sysMessage: sysMessage.text.trim(),
        message: message != null ? message.text.trim() : '',
      ));
    }
  }

  return result;
}

Future<ChatResponse> postMessage({
  required String text,
  required String chatID,
  required Cookie cookie,
}) async {
  ChatResponse result;
  PostParameters body;

  body = PostParameters();
  body.add('templ', 'p_chat_zpravy');
  body.add('id_chat', chatID);
  body.add('ulozit', 'yes');
  body.add('zprava', text);

  http.Response response = await _queryServer(
    method: _HttpMethod.post,
    query: 'templ=p_chat_zpravy&id_chat=$chatID',
    body: body.parameters,
    cookie: cookie,
  );
  result = ChatResponse(
      statusCode: response.statusCode,
      cookie: response.headers.containsKey('set-cookie')
          ? Cookie.fromSetCookieValue(response.headers['set-cookie']!)
          : null);
  if (result.statusCode == 200) {
    // TODO parse response if necessary
    Document document = parse(response.body);
    _log.finest('after parsing');
  }

  return result;
}

Future<http.Response> _queryServer({
  required _HttpMethod method,
  required String query,
  Object? body,
  Cookie? cookie,
  bool file = false,
}) async {
  http.Response result;

  _log.finest('queryServer: ${method.text()}, $query');
  _log.finest('client: ${_client?.hashCode}');

  _client ??= http.Client();
  Uri url = Uri(
    scheme: _scheme,
    host: _host,
    path: file ? query : _cgiPath,
    query: file ? null : query,
  );
  Map<String, String>? headers =
      cookie == null ? null : {'cookie': cookie.toString()};
  _log.finest('url: $url}');
  _log.finest('headers: $headers');
  try {
    switch (method) {
      case _HttpMethod.get:
        result = await http.Client().get(url, headers: headers);
//      result = await _client!.get(url, headers: headers);
        break;
      case _HttpMethod.post:
        result = await http.Client().post(url, headers: headers, body: body);
//      result = await _client!.post(url, headers: headers, body: body);
        break;
      default:
        // Method not found
        result = http.Response('', _METHOD_NOT_ALLOWED);
    }
  } catch (e) {
    _log.severe(e.toString());
    result = http.Response('', _INTERNAL_SERVER_ERROR);
  }

  _log.finest('Response: ${result.statusCode}');
  return result;
}

/// Removes leading double quotes and leading colon
String _cleanChatText(String text) {
  String result = text.replaceAll(RegExp(r'^":|"$'), '');

  return result.trim();
}

class PostParameters {
  final Map<String, String?> _parameters = {};

  Map<String, String?> get parameters => _parameters;

  void add(String key, String? value) =>
      _parameters.putIfAbsent(key, () => value);
}

import '../providers/app_settingsOLD.dart';

@Deprecated('Should be replaced in new parser')
class ChatID {
  late String advisorID;
  late String chatID;
  late String cookies;
  late String _sessionID;

  ChatID({
    required this.advisorID,
    required this.chatID,
    required this.cookies,
  }) {
    List<String> parsedCookies = cookies.split(';');
    for (String cookieItem in parsedCookies) {
      List<String> params = cookieItem.trim().split('=');
      if (params.length == 2) {
        switch (params[0]) {
          case 'id_session':
            _sessionID = params[1];
            break;
          default:
        }
      }
    }
  }

  String get sessionID => _sessionID;

//id_session=20220612171540c45d3d81d33c90a9; domain=chat.neziskovky.com; path=/; expires=Mon, 13-Jun-2022 15:15:40 GMT; secure; SameSite=Lax
}

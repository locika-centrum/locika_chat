class ChatRoom {
  late String? roomUri;
  late String name;
  late String status;
  late String? advisorID;

  ChatRoom({required this.roomUri, required this.name, required this.status}) {
    name = name.replaceAll('"', '');
    status = status.replaceAll('"', '');

    List<String>? parsedUri = roomUri?.split('=');
    advisorID = parsedUri != null ? parsedUri[parsedUri.length - 1] : null;
  }

  @override
  String toString() => '$name [$status] - $advisorID';
}
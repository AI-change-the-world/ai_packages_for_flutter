import 'package:isar/isar.dart';

part 'chat_history.g.dart';

enum ChatRole {
  system(name: "system"),
  user(name: "user"),
  assistant(name: "assistant");

  final String name;

  const ChatRole({required this.name});
  static ChatRole fromName(String name) {
    return ChatRole.values.firstWhere((element) => element.name == name);
  }
}

@collection
class ChatHistory {
  Id id = Isar.autoIncrement;
  int createAt = DateTime.now().millisecondsSinceEpoch;
  late String content;

  @enumerated
  ChatRole role = ChatRole.user;
}

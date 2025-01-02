import 'package:isar/isar.dart';

part 'chat_history.g.dart';

enum ChatRole { system, user, assistant }

@collection
class ChatHistory {
  Id id = Isar.autoIncrement;
  int createAt = DateTime.now().millisecondsSinceEpoch;
  late String content;

  @enumerated
  ChatRole role = ChatRole.user;
}

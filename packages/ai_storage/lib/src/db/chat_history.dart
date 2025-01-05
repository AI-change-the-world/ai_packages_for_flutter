/*
   对话持久化存储
*/

import 'package:ai_storage/src/isar_adapter.dart';
import 'package:isar/isar.dart';
import 'package:ai_packages_core/ai_packages_core.dart' as core;

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

enum ChatMessageType {
  text,
  image,
  audio,
  video,
  file,
  unknown;

  static ChatMessageType fromName(String name) {
    return ChatMessageType.values.firstWhere((element) => element.name == name);
  }
}

@collection
class ChatHistory {
  Id id = Isar.autoIncrement;
  late String topic;
  late List<ChatMessage> messages;

  core.ChatHistory toChatHistory() {
    return core.ChatHistory(
      topic: topic,
      messages: messages.map((e) => e.toChatMessage()).toList(),
    );
  }

  static ChatHistory fromChatHistory(core.ChatHistory chatHistory) {
    return ChatHistory()
      ..topic = chatHistory.topic
      ..messages = chatHistory.messages
          .map((e) => ChatMessage().fromChatMessage(e))
          .toList();
  }
}

@embedded
class ChatMessage {
  late String content;
  @enumerated
  ChatRole role = ChatRole.user;
  @enumerated
  ChatMessageType type = ChatMessageType.text;
  int createAt = DateTime.now().millisecondsSinceEpoch;

  core.ChatMessage toChatMessage<String>() {
    return core.ChatMessage(
      content: content,
      role: role.name,
      type: type.name,
      createAt: createAt,
    );
  }

  ChatMessage fromChatMessage(core.ChatMessage chatMessage) {
    return ChatMessage()
      ..content = chatMessage.content
      ..createAt = chatMessage.createAt
      ..role = ChatRole.fromName(chatMessage.role)
      ..type = ChatMessageType.fromName(chatMessage.type);
  }
}

final chatHistoryAdaptor = GenericIsarAdapter(
    fromThirdPartyClassImpl: (d) => ChatHistory.fromChatHistory(d),
    toThirdPartyClassImpl: (ChatHistory d) => d.toChatHistory());

final chatMessageAdaptor = GenericIsarAdapter(
    fromThirdPartyClassImpl: (d) => ChatMessage().fromChatMessage(d),
    toThirdPartyClassImpl: (ChatMessage d) => d.toChatMessage());

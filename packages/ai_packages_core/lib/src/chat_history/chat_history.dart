class ChatHistory {
  final String topic;
  final List<ChatMessage> messages;

  ChatHistory({required this.topic, required this.messages});
}

class ChatMessage<C> {
  final String role;
  final C content;
  final int createAt;
  final String type;

  ChatMessage(
      {required this.role,
      required this.content,
      required this.createAt,
      this.type = 'text'});

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'createAt': createAt,
      'type': type
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role'] as String,
      content: map['content'] as C,
      createAt: map['createAt'] as int,
      type: map['type'] as String,
    );
  }
}

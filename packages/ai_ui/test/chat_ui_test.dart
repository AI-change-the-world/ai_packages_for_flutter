import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:ai_ui/src/chat_ui.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Stream<ChatResponse> fetchResponseStream(String input) async* {
    ChatResponse chatResponse = ChatResponse(uuid: "123", stage: "waiting...");
    // 模拟流式数据返回
    for (var i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      chatResponse.content = "Chunk $i from input: $input";
      if (i == 4) {
        chatResponse.stage = "done";
        chatResponse.done = true;
      }
      yield chatResponse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatUi(
        onChat: (input) {
          return fetchResponseStream(input);
        },
        onChatDone: (map) {},
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

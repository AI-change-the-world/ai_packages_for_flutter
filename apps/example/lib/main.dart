import 'package:ai_agent_compose/ai_agent_compose.dart';
import 'package:ai_ui/ai_ui.dart';
import 'package:flutter/material.dart';
import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:uuid/v4.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Stream<ChatResponse> fetchResponseStream(String input) async* {
    ChatResponse chatResponse =
        ChatResponse(uuid: UuidV4().generate(), stage: "waiting...");
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
        onChatDone: (map) {
          if (map != null) {
            debugPrint(map.toString());
          }
        },
      ),
    );
  }
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AgentComposer(),
    );
  }
}

void main() {
  runApp(const MyApp2());
}

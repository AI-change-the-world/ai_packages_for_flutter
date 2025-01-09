import 'dart:convert';

import 'package:ai_agent_compose/ai_agent_compose.dart';
import 'package:ai_ui/ai_ui.dart';
import 'package:flutter/material.dart';
import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flutter/services.dart';
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

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  late Map<String, dynamic> config = {};

  Future loadConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      debugPrint("response ====> $response");
      setState(() {
        config = jsonDecode(response);
      });
    } catch (e) {
      debugPrint("Error loading config: $e");
    }
  }

  late Future<void> future;

  @override
  void initState() {
    super.initState();
    future = loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: future,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.done) {
            if (config.isEmpty || !config.containsKey('llm-sk')) {
              return Scaffold(
                body: Center(child: Text('Configuration data is missing!')),
              );
            }
            String sk = config['llm-sk']!;
            String model = config['llm-model-name']!;
            String baseUrl = config['llm-base']!;
            OpenAIInfo openAIInfo = OpenAIInfo(baseUrl, sk, model);
            ModelInfo modelInfo = ModelInfo(
              ModelType.openai,
              ModelFor.nlp,
              "default",
              openAIInfo,
            );
            return AgentComposer(
              models: [modelInfo],
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyApp2(),
  ));
}

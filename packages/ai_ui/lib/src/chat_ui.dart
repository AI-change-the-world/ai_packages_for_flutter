import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:ai_ui/src/messagebox/controller.dart';
import 'package:flutter/material.dart';

import 'messagebox/input_field.dart';
import 'messagebox/llm_request_message_box.dart';
import 'messagebox/state.dart';

typedef OnChat = Stream<ChatResponse> Function(String input);

class ChatUi extends StatefulWidget {
  const ChatUi({super.key, required this.onChat});
  final OnChat onChat;

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  late MessageStateController messageStateController;

  @override
  void initState() {
    super.initState();
    messageStateController = MessageStateController();
  }

  @override
  void dispose() {
    messageStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: messageStateController.state,
        builder: (c, state, _) {
          return Scaffold(
            body: Column(
              children: [
                Flexible(
                    child: SizedBox.expand(
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children:
                          state.messages.map((e) => e.toWidget()).toList(),
                    ),
                  ),
                )),
                InputField(onSubmit: (s) => _handleInputMessage(s, state))
              ],
            ),
          );
        });
  }

  _handleInputMessage(String s, MessageState state) async {
    if (state.isLoading) {
      return;
    }

    messageStateController
        .addMessageBox(RequestMessageBox(content: s, stage: "waiting..."));

    widget.onChat(s).listen((event) {
      messageStateController.updateMessageBox(event);
    });
  }
}

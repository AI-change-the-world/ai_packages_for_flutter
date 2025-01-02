import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flutter/material.dart';

import 'llm_response_message_box.dart';
import 'state.dart';

class MessageStateController {
  final ValueNotifier<MessageState> state = ValueNotifier(MessageState());

  void dispose() {
    state.dispose();
  }

  MessageBox? getByUuid(String uuid) {
    return state.value.messages
        .where((element) => element is ResponseMessageBox && element.id == uuid)
        .firstOrNull;
  }

  MessageBox? getLastMessage() {
    return state.value.messages.lastOrNull;
  }

  void setLoading(bool b) {
    if (b == state.value.isLoading) return;
    state.value = state.value.copyWith(isLoading: b);
  }

  void addMessageBox(MessageBox box) {
    if (state.value.isLoading) return;
    state.value =
        state.value.copyWith(messages: [...state.value.messages, box]);
  }

  void updateMessageBox(ChatResponse response) {
    final box = state.value.messages
        .where((element) =>
            element is ResponseMessageBox && element.id == response.uuid)
        .firstOrNull;

    if (box != null) {
      final l = List<MessageBox>.from(state.value.messages)..remove(box);
      box.content += response.content ?? "";
      if (box is ResponseMessageBox) {
        box.stage = response.stage ?? "";
        box.tokenGenetated = response.tokenGenerated ?? 0;
        box.tps = response.tps ?? 0;
      }
      state.value = state.value.copyWith(
        messages: [...l, box],
        isLoading: !(response.done ?? false),
      );
    } else {
      final l = List<MessageBox>.from(state.value.messages)
        ..add(ResponseMessageBox(
            content: response.content ?? "",
            id: response.uuid!,
            stage: response.stage ?? ""));

      state.value = state.value.copyWith(
        messages: l,
        isLoading: !(response.done ?? false),
      );
    }
  }
}

import 'package:ai_agent_compose/nodes/llm_node/llm_node.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkflowNotifier extends Notifier<INode?> {
  final controller = BoardController(
      initialState: BoardState(data: [], edges: {}),
      nodes: [LlmNode(label: "Llm 节点", uuid: "", offset: Offset.zero)]);

  @override
  INode? build() {
    return null;
  }

  changeCurrentNode(INode? node) {
    if (node?.getUuid() == state?.getUuid()) {
      return;
    }
    state = node;
  }

  bool isNodeSelected(INode node) {
    return state?.getUuid() == node.getUuid();
  }
}

final workflowProvider =
    NotifierProvider<WorkflowNotifier, INode?>(() => WorkflowNotifier());

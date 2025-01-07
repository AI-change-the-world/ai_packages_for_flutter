import 'package:ai_agent_compose/nodes/begin_node/begin_node.dart';
import 'package:ai_agent_compose/nodes/llm_node/llm_node.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Context = Map<String, dynamic>;

class WorkflowState {
  final Context context;
  final INode? current;
  WorkflowState({this.context = const {}, this.current});

  WorkflowState copyWith({
    Context? context,
    INode? current,
  }) {
    return WorkflowState(
      context: context ?? this.context,
      current: current,
    );
  }
}

class WorkflowNotifier extends Notifier<WorkflowState> {
  final controller =
      BoardController(initialState: BoardState(data: [], edges: {}), nodes: [
    BeginNode(label: "开始节点", uuid: "", offset: Offset.zero),
    LlmNode(label: "Llm 节点", uuid: "", offset: Offset.zero),
  ]);

  @override
  WorkflowState build() {
    return WorkflowState();
  }

  List<String> getSimilar(String c) {
    if (state.context.isEmpty) {
      return [];
    }
    List<String> result = [];
    for (final d in state.context.values) {
      if (d['node'] == "BeginNode") {
        result.addAll((d['inputs'] as List<Map<String, dynamic>>)
            .map((e) => e['key'] as String)
            .where((String e1) => e1.contains(c))
            .toList());
      }
    }

    return result;
  }

  List<String> getAllGlobalInputs() {
    if (state.context.isEmpty) {
      return [];
    }
    List<String> result = [];
    for (final d in state.context.values) {
      if (d['node'] == "BeginNode") {
        result.addAll((d['inputs'] as List<Map<String, dynamic>>)
            .map((e) => e['key'] as String)
            .toList());
      }
    }

    return result;
  }

  void addData(String uuid, Map<String, dynamic> data) {
    state = state.copyWith(context: {...state.context, uuid: data});
  }

  changeCurrentNode(INode? node) {
    if (node?.getUuid() == state.current?.getUuid()) {
      return;
    }
    state = state.copyWith(current: node);
  }

  bool isNodeSelected(INode node) {
    return state.current?.getUuid() == node.getUuid();
  }

  bool couldSave() {
    return controller.state.value.data
                .where((v) => v.builderName == "BeginNode")
                .length ==
            1 ||
        controller.state.value.data.isEmpty;
  }
}

final workflowProvider =
    NotifierProvider<WorkflowNotifier, WorkflowState>(() => WorkflowNotifier());

import 'package:ai_agent_compose/nodes/begin_node/begin_node.dart';
import 'package:ai_agent_compose/nodes/llm_node/llm_node.dart';
import 'package:ai_agent_compose/workflow/workflow_graph.dart';
import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 节点数据 ,只支持多输入单输出
///  {"uuid" : {"node":buildName,"data":{"inputs":[],"output":[]}} ,"global" :{"uuid":"output"} }
typedef Context = Map<String, dynamic>;

class WorkflowState {
  final Context context;
  final INode? current;
  List<ModelInfo> models;

  WorkflowState(
      {this.context = const {}, this.current, this.models = const []});

  WorkflowState copyWith({
    Context? context,
    INode? current,
    List<ModelInfo>? models,
  }) {
    return WorkflowState(
      context: context ?? this.context,
      current: current,
      models: models ?? this.models,
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

  setModels(List<ModelInfo> models) {
    state.models = models;
  }

  Future excute({String? thisJobUniqueId, required WidgetRef ref_}) async {
    WorkflowGraph workflowGraph = WorkflowGraph(
        controller.state.value.data, controller.state.value.edges.toList());
    workflowGraph.executeWorkflow(ref_);
  }

  ModelInfo getByName(String name) {
    return state.models.firstWhere((element) => element.modelName == name);
  }

  Map<String, dynamic> getGlobal() {
    return state.context["global"] as Map<String, dynamic>;
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
      } else {
        result.add((d['output'] as String));
      }
    }

    return result;
  }

  void addData(String uuid, Map<String, dynamic> data) {
    state = state.copyWith(context: {...state.context, uuid: data});
  }

  void addToGlobal(String key, String value) {
    state = state.copyWith(context: {
      ...state.context,
      "global": {
        ...(state.context["global"] ?? <String, dynamic>{})
            as Map<String, dynamic>,
        key: value,
      }
    });
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

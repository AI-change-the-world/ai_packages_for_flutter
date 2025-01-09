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

class GraphExcuteState {
  final Context nodesInfo;
  final Context global;

  const GraphExcuteState({this.nodesInfo = const {}, this.global = const {}});

  GraphExcuteState copyWith({
    Context? nodesInfo,
    Context? global,
  }) {
    return GraphExcuteState(
      nodesInfo: nodesInfo ?? this.nodesInfo,
      global: global ?? this.global,
    );
  }

  @override
  String toString() {
    return 'GraphExcuteState(nodesInfo: $nodesInfo, global: $global)';
  }
}

class WorkflowState {
  final GraphExcuteState context;
  final INode? current;
  List<ModelInfo> models;

  WorkflowState(
      {this.context = const GraphExcuteState(),
      this.current,
      this.models = const []});

  WorkflowState copyWith({
    GraphExcuteState? context,
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
    return state.context.global;
  }

  List<String> getSimilar(String c) {
    if (state.context.nodesInfo.isEmpty) {
      return [];
    }
    List<String> result = [];
    for (final d in state.context.nodesInfo.values) {
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
    if (state.context.nodesInfo.isEmpty) {
      return [];
    }
    List<String> result = [];
    for (final d in state.context.nodesInfo.values) {
      if (d['node'] == "BeginNode") {
        result.addAll((d['inputs'] as List<Map<String, dynamic>>)
            .map((e) => e['key'] as String)
            .toList());
      } else {
        if (d['output'] != null) {
          result.add((d['output'] as String));
        }
      }
    }

    return result;
  }

  void addData(String uuid, Map<String, dynamic> data) {
    final context = state.context
        .copyWith(nodesInfo: {...state.context.nodesInfo, uuid: data});

    state = state.copyWith(context: context);
    debugPrint("context: ${state.context}");
  }

  void addToGlobal(String key, String value) {
    final context =
        state.context.copyWith(global: {...state.context.global, key: value});

    state = state.copyWith(context: context);
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

  void clearGlobal() {
    final context = state.context.copyWith(global: {});
    state = state.copyWith(context: context);
  }
}

final workflowProvider =
    NotifierProvider<WorkflowNotifier, WorkflowState>(() => WorkflowNotifier());

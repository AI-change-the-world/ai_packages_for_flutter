import 'package:ai_agent_compose/nodes/begin_node/begin_node.dart';
import 'package:ai_agent_compose/nodes/llm_node/llm_node.dart';
import 'package:ai_agent_compose/workflow/workflow_notifier.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension PromptFormat on String {
  String formatWithMap(Map<String, dynamic> map) {
    String result = this;
    map.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }
}

extension Excuter on INode {
  Future<void> execute(WidgetRef ref) async {
    // 执行节点逻辑
    debugPrint('Executing node: $label ===> $data');
    if (this is BeginNode) {
      /// 开始节点的执行逻辑
      /// 将所有的 inputs 塞到全局变量中
      for (final Map<String, dynamic> i in data?['inputs'] ?? []) {
        // TODO 支持上传文件的逻辑
        ref
            .read(workflowProvider.notifier)
            .addToGlobal(i['key'] ?? "", i['content'] ?? "");
      }
    }

    if (this is LlmNode) {
      print("data?['prompt']  ${data?['prompt']}");
      final prompt = ((data?['prompt'] ?? "") as String)
          .formatWithMap(ref.read(workflowProvider.notifier).getGlobal());
      print("prompt  ${prompt}");
    }

    await Future.delayed(Duration(seconds: 3));
    debugPrint('Node executed done: ${ref.read(workflowProvider).context}');
  }
}

class WorkflowGraph {
  final List<INode> nodes;
  final List<Edge> edges;

  final Map<String, List<String>> adjList = {};
  final Map<String, int> inDegree = {};

  WorkflowGraph(this.nodes, this.edges) {
    // 初始化图
    for (var node in nodes) {
      adjList[node.uuid] = [];
      inDegree[node.uuid] = 0;
    }

    // 添加边关系
    for (var edge in edges) {
      if (edge.target != null) {
        adjList[edge.source]?.add(edge.target!);
        inDegree[edge.target!] = (inDegree[edge.target] ?? 0) + 1;
      }
    }
  }

  void executeWorkflow(WidgetRef ref) async {
    // 拓扑排序
    final executionOrder = _topologicalSort();
    debugPrint('Execution order: $executionOrder');
    if (executionOrder == null) {
      throw Exception('Workflow is not a DAG!');
    }

    // 按顺序执行节点
    for (var nodeId in executionOrder) {
      final node = nodes.firstWhere((n) => n.uuid == nodeId);
      await node.execute(ref);
    }
  }

  Stream executeWorkflowInStream() async* {
    // 拓扑排序
    final executionOrder = _topologicalSort();
    debugPrint('Execution order: $executionOrder');
    if (executionOrder == null) {
      throw Exception('Workflow is not a DAG!');
    }

    // 按顺序执行节点
    /// TODO: 添加流支持
  }

  List<String>? _topologicalSort() {
    final queue = <String>[];
    final result = <String>[];

    // 入度为0的节点入队
    inDegree.forEach((node, degree) {
      if (degree == 0) queue.add(node);
    });

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      result.add(current);

      for (var neighbor in adjList[current] ?? []) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 0) - 1;
        if (inDegree[neighbor] == 0) queue.add(neighbor);
      }
    }

    // 如果结果数量和节点数量不一致，说明有环
    return result.length == nodes.length ? result : null;
  }
}

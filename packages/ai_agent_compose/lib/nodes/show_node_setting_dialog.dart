import 'package:ai_agent_compose/nodes/begin_node/begin_node.dart';
import 'package:ai_agent_compose/nodes/llm_node/llm_node.dart';
import 'package:ai_agent_compose/workflow/workflow_notifier.dart';
import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drawer_builder.dart';

Future<Map<String, dynamic>?> showNodeSettingDialog(
    BuildContext context, INode node, WidgetRef ref,
    {Map<String, dynamic>? data, String name = "节点配置"}) async {
  debugPrint("runtimeType: ${node.runtimeType}");
  if (node is LlmNode) {
    return showGeneralDialog(
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: "LlmNode Dialog",
        context: context,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          List<ModelInfo> models = ref.read(workflowProvider).models;
          return drawerBuilder(
              context,
              LlmNodeSettingsWidget(
                availableModels: models,
                node: node,
                name: name,
              ));
        });
  }

  if (node is BeginNode) {
    return showGeneralDialog(
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: "BeginNode Dialog",
        context: context,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return drawerBuilder(
              context,
              BeginNodeConfigWidget(
                node: node,
                name: name,
              ));
        });
  }

  return null;
}

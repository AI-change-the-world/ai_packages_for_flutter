import 'package:ai_agent_compose/nodes/show_node_setting_dialog.dart';
import 'package:ai_agent_compose/workflow/workflow_notifier.dart';
import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part './widget.dart';

class LlmNode extends INode {
  LlmNode(
      {required super.label,
      required super.uuid,
      required super.offset,
      super.children,
      super.height = 200,
      super.width = 300,
      super.nodeName = "大语言模型调用",
      super.description = "大语言模型调用节点",
      super.builder,
      super.builderName = "LlmNode",
      super.data}) {
    builder = (context) => LlmNodeWidget(
          node: this,
        );
  }

  factory LlmNode.fromJson(Map<String, dynamic> json) {
    String uuid = json["uuid"] ?? "";
    String label = json["label"] ?? "";
    Offset offset = Offset(json["offset"]["dx"], json["offset"]["dy"]);
    double width = json["width"] ?? 300;
    double height = json["height"] ?? 400;
    String nodeName = json["nodeName"] ?? "base";
    String description =
        json["description"] ?? "Base node, just for testing purposes";
    String builderName = json["builderName"] ?? "base";
    Map<String, dynamic>? data = json["data"];

    return LlmNode(
      offset: offset,
      width: width,
      height: height,
      nodeName: nodeName,
      description: description,
      builderName: builderName,
      label: label,
      uuid: uuid,
      data: data,
    );
  }

  @override
  INode copyWith(
      {double? width,
      double? height,
      String? label,
      String? uuid,
      int? depth,
      Offset? offset,
      List<INode>? children,
      Map<String, dynamic>? data}) {
    return LlmNode(
        width: width ?? this.width,
        height: height ?? this.height,
        label: label ?? this.label,
        uuid: uuid ?? this.uuid,
        offset: offset ?? this.offset,
        children: children ?? this.children);
  }
}

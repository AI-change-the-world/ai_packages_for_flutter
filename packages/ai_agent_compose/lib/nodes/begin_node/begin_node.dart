import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';

part 'widget.dart';

class BeginNode extends INode {
  BeginNode(
      {required super.label,
      required super.uuid,
      required super.offset,
      super.children,
      super.height = 100,
      super.width = 150,
      super.nodeName = "开始节点",
      super.description = "开始节点，用于一些变量声明或者文件上传",
      super.builder,
      super.builderName = "BeginNode",
      super.data}) {
    builder = (context) => BeginNodeWidget(
          node: this,
        );
  }

  factory BeginNode.fromJson(Map<String, dynamic> json) {
    String uuid = json["uuid"] ?? "";
    String label = json["label"] ?? "";
    Offset offset = Offset(json["offset"]["dx"], json["offset"]["dy"]);
    double width = json["width"] ?? 300;
    double height = json["height"] ?? 200;
    String nodeName = json["nodeName"] ?? "base";
    String description =
        json["description"] ?? "Base node, just for testing purposes";
    String builderName = json["builderName"] ?? "base";
    Map<String, dynamic>? data = json["data"];

    return BeginNode(
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
    return BeginNode(
        width: width ?? this.width,
        height: height ?? this.height,
        label: label ?? this.label,
        uuid: uuid ?? this.uuid,
        offset: offset ?? this.offset,
        children: children ?? this.children);
  }
}

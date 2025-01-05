/*
  智能体编排节点持久化存储
*/

import 'package:isar/isar.dart';

part 'agent.g.dart';

@collection
class Agent {
  Id id = Isar.autoIncrement;
  int createAt = DateTime.now().millisecondsSinceEpoch;
  late String jsonStr;
  late List<AgentNode> nodes;
}

@embedded
class AgentNode {
  String builderName;
  String description;
  String nodeName;
  double width;
  double height;
  String uuid;
  String label;
  double dx;
  double dy;
  List<AgentData> data;

  AgentNode({
    this.builderName = "",
    this.description = "",
    this.nodeName = "",
    this.width = 300,
    this.height = 200,
    this.uuid = "",
    this.label = "",
    this.dx = 0,
    this.dy = 0,
    this.data = const [],
  });
}

@embedded
class AgentData {
  String key;
  String? text;
  String? path;
  List<int>? bytes;

  AgentData({
    this.key = "",
    this.text,
    this.path,
    this.bytes,
  }) {
    assert(text != null || path != null || bytes != null);
  }
}

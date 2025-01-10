import 'package:flow_compose/flow_compose.dart';

enum NodeRunningState {
  running("running"),
  done("done"),
  error("error");

  const NodeRunningState(this.value);

  final String value;
}

class RunningLog {
  final String key;
  String value;

  RunningLog({
    required this.key,
    this.value = "",
  });

  RunningLog copyWith({
    String? key,
    String? value,
  }) {
    return RunningLog(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'RunningLog(key: $key, value: $value)';
  }
}

class RunningNodeState {
  final INode node;
  final NodeRunningState state;
  final List<RunningLog> logs;

  RunningNodeState({
    required this.node,
    required this.state,
    this.logs = const [],
  });

  RunningNodeState copyWith({
    INode? node,
    NodeRunningState? state,
    List<RunningLog>? logs,
  }) {
    return RunningNodeState(
      node: node ?? this.node,
      state: state ?? this.state,
      logs: logs ?? this.logs,
    );
  }

  RunningNodeState addLog(RunningLog log) {
    return copyWith(logs: [...logs, log]);
  }

  RunningNodeState changeLogsByKey(RunningLog log) {
    return copyWith(
        logs: logs
            .map((e) => e.key == log.key
                ? RunningLog(key: log.key, value: e.value + log.value)
                : e)
            .toList());
  }
}

class RunningState {
  final List<RunningNodeState> nodes;

  RunningState({
    this.nodes = const [],
  });

  RunningState copyWith({
    List<RunningNodeState>? nodes,
  }) {
    return RunningState(
      nodes: nodes ?? this.nodes,
    );
  }

  RunningState addNode(RunningNodeState node) {
    return copyWith(
      nodes: [...nodes, node],
    );
  }

  RunningState changeNodeByUuid(RunningNodeState node) {
    RunningNodeState nodeState = nodes.firstWhere(
      (element) => element.node.uuid == node.node.uuid,
    );
    nodeState = nodeState.copyWith(state: node.state);

    return copyWith(
      nodes: nodes
          .map((e) => e.node.uuid == node.node.uuid ? nodeState : e)
          .toList(),
    );
  }

  RunningState addLogToNode(RunningLog log, String uuid) {
    return RunningState(
      nodes: nodes.map((e) => e.node.uuid == uuid ? e.addLog(log) : e).toList(),
    );
  }

  RunningState changeLogsByKey(RunningLog log, String uuid) {
    return RunningState(
      nodes: nodes
          .map((e) => e.node.uuid == uuid ? e.changeLogsByKey(log) : e)
          .toList(),
    );
  }
}

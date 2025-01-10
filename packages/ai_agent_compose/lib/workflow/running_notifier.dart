import 'package:flow_compose/flow_compose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'running_state.dart';

class RunningNotifier extends Notifier<RunningState> {
  @override
  RunningState build() {
    return RunningState();
  }

  void addNode(INode node) {
    RunningNodeState nodeState =
        RunningNodeState(node: node, state: NodeRunningState.running);
    state = state.addNode(nodeState);
  }

  void changeNodeState(INode node, NodeRunningState s) {
    RunningNodeState nodeState = RunningNodeState(node: node, state: s);
    state = state.changeNodeByUuid(nodeState);
  }

  void addLogToNode(RunningLog log, String uuid) {
    final newState = state.addLogToNode(log, uuid);
    state = newState;
  }

  void changeNodeLog(RunningLog log, String uuid) {
    state = state.changeLogsByKey(log, uuid);
  }
}

final runningProvider =
    NotifierProvider<RunningNotifier, RunningState>(RunningNotifier.new);

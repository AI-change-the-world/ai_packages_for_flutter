library;

import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workflow/workflow_notifier.dart';

class AgentComposer extends StatelessWidget {
  const AgentComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: _Composer());
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer();

  @override
  ConsumerState<_Composer> createState() => __ComposerState();
}

class __ComposerState extends ConsumerState<_Composer> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(workflowProvider.notifier).controller;

    return Scaffold(
        body: InfiniteDrawingBoard(
      controller: controller,
    ));
  }
}

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
  late final controller = ref.read(workflowProvider.notifier).controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        InfiniteDrawingBoard(
          controller: controller,
        ),
        if (ref.watch(workflowProvider.select((c) => c.context.isNotEmpty)))
          Positioned(
            right: 20,
            top: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.greenAccent,
                backgroundColor: Colors.greenAccent.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (ref.read(workflowProvider.notifier).couldSave()) {
                  print(controller.dumpToString());
                }
              },
              child: Text(
                '创建',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
      ],
    ));
  }
}

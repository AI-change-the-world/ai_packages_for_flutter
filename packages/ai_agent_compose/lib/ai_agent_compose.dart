library;

import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flow_compose/flow_compose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workflow/workflow_notifier.dart';
export './models/openai_model_info.dart';

class AgentComposer extends StatelessWidget {
  const AgentComposer({super.key, this.models = const []});
  final List<ModelInfo> models;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: _Composer(
      models: models,
    ));
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.models});
  final List<ModelInfo> models;

  @override
  ConsumerState<_Composer> createState() => __ComposerState();
}

class __ComposerState extends ConsumerState<_Composer> {
  late final controller = ref.read(workflowProvider.notifier).controller;

  @override
  void initState() {
    super.initState();
    ref.read(workflowProvider.notifier).setModels(widget.models);
  }

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
              child: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '创建',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if (ref.watch(workflowProvider.select((c) => c.context.isNotEmpty)))
          Positioned(
            right: 20,
            top: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.blueAccent.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.read(workflowProvider.notifier).excute(ref_: ref);
              },
              child: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '试运行',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
      ],
    ));
  }
}

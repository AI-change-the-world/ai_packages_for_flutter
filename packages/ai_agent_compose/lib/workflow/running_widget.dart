import 'package:ai_agent_compose/workflow/running_notifier.dart';
import 'package:ai_agent_compose/workflow/running_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class RunningWidget extends ConsumerWidget {
  const RunningWidget({super.key, required this.nodeState});
  final RunningNodeState nodeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: nodeState.state == NodeRunningState.running
                ? Colors.blue
                : Colors.grey,
            width: nodeState.state == NodeRunningState.running ? 2 : 1),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    nodeState.node.label,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...nodeState.logs.map(
                (e) => _renderRunningLog(e),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _renderRunningLog(RunningLog log) {
  return Text.rich(TextSpan(children: [
    TextSpan(text: log.key, style: TextStyle(fontWeight: FontWeight.bold)),
    TextSpan(text: ': '),
    TextSpan(text: "${log.value} "),
    TextSpan(
        text: DateTime.now().toLocal().toString().split(".").first,
        style: TextStyle(
            fontSize: 10,
            color: Colors.white,
            background: Paint()..color = Colors.blue))
  ]));
}

class RunningListWidget extends ConsumerWidget {
  const RunningListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runningNodes = ref.watch(runningProvider);

    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: runningNodes.nodes.mapIndexed((i, e) {
          if (i == runningNodes.nodes.length - 1) {
            return Row(children: [
              RunningWidget(nodeState: e),
            ]);
          }
          return Row(spacing: 10, children: [
            RunningWidget(nodeState: e),
            ArrowPainterWidget(),
          ]);
        }).toList(),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // 箭头主干的宽度和高度
    // ignore: unused_local_variable
    final double arrowHeadWidth = size.width * 0.4; // 箭头部分宽度
    final double arrowBodyWidth = size.width * 0.6; // 主干部分宽度
    final double arrowHeight = size.height * 0.2; // 箭头高度

    // 主干上下边界
    final double bodyTop = (size.height - arrowHeight) / 2;
    final double bodyBottom = bodyTop + arrowHeight;

    // 绘制箭头朝右的路径
    final path = Path()
      ..moveTo(0, bodyTop) // 主干左上角
      ..lineTo(arrowBodyWidth, bodyTop) // 主干右上角
      ..lineTo(arrowBodyWidth, 0) // 箭头上角
      ..lineTo(size.width, size.height / 2) // 箭头尖端
      ..lineTo(arrowBodyWidth, size.height) // 箭头下角
      ..lineTo(arrowBodyWidth, bodyBottom) // 主干右下角
      ..lineTo(0, bodyBottom) // 主干左下角
      ..close(); // 闭合路径

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ArrowPainterWidget extends StatelessWidget {
  const ArrowPainterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: ArrowPainter(),
    );
  }
}

part of 'begin_node.dart';

class BeginNodeWidget extends StatefulWidget {
  const BeginNodeWidget({super.key, required this.node});
  final INode node;

  @override
  State<BeginNodeWidget> createState() => _BeginNodeWidgetState();
}

class _BeginNodeWidgetState extends State<BeginNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      width: widget.node.width,
      height: widget.node.height,
      child: Center(
        child: Text(
          widget.node.nodeName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

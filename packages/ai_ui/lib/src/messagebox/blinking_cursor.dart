import 'dart:async';

import 'package:flutter/material.dart';

class BlinkingCursor extends StatefulWidget {
  final double width; // 光标宽度
  final double height; // 光标高度
  final Color color; // 光标颜色
  final Duration blinkDuration; // 闪烁持续时间

  const BlinkingCursor({
    super.key,
    this.width = 8.0,
    this.height = 20.0,
    this.color = Colors.black,
    this.blinkDuration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> {
  bool _isVisible = true; // 控制光标的可见性
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 每隔 blinkDuration 切换光标的可见性
    _timer = Timer.periodic(widget.blinkDuration, (timer) {
      setState(() {
        _isVisible = !_isVisible; // 切换可见性
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: _isVisible ? widget.color : Colors.transparent, // 根据可见性切换颜色
    );
  }
}

import 'package:flutter/material.dart';

class SimpleTag extends StatelessWidget {
  const SimpleTag(
      {super.key,
      this.backgroundColor = Colors.blueAccent,
      this.textColor = Colors.white,
      required this.text});
  final Color backgroundColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: backgroundColor),
      padding: EdgeInsets.all(4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 12),
        ),
      ),
    );
  }
}

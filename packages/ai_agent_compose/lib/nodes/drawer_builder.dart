import 'package:flutter/material.dart';

Widget drawerBuilder(BuildContext context, Widget child) {
  return Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: EdgeInsets.only(right: 20),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(20),
          width: 400,
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    ),
  );
}

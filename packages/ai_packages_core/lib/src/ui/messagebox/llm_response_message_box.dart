import 'package:flutter/material.dart';

import 'message_box.dart';

abstract class ResponseMessageBox extends MessageBox<String> {
  String id;
  int tokenGenetated;
  double tps;

  ResponseMessageBox(
      {required super.content,
      required this.id,
      required super.stage,
      this.tokenGenetated = 0,
      this.tps = 0});

  static const double iconSize = 20;

  @override
  Widget toWidget();
}

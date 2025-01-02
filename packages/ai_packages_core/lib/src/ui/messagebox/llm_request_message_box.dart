import 'package:flutter/material.dart';

import 'message_box.dart';

abstract class RequestMessageBox extends MessageBox<String> {
  RequestMessageBox({required super.content, super.stage = ""});

  @override
  Widget toWidget();
}

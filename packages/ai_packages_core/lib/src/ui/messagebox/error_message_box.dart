import 'package:flutter/material.dart';

import 'message_box.dart';

abstract class ErrorMessageBox extends MessageBox<String> {
  ErrorMessageBox({required super.content, super.stage = ""});

  @override
  Widget toWidget();
}

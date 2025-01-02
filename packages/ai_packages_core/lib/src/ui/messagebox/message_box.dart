import 'package:flutter/material.dart';

abstract class MessageBox<T> {
  // String; bytes; path
  T content;
  String stage;

  MessageBox({required this.content, required this.stage});

  Widget toWidget();

  Map<String, dynamic> toMap(String chatRole) {
    return {
      'content': content,
      'chatRole': chatRole,
    };
  }
}

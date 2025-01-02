import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'blinking_cursor.dart';

class ResponseMessageBox extends MessageBox<String> {
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
  Widget toWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: HexColor('#f5f5f5'),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                offset: const Offset(0, 0),
                blurRadius: 5,
                spreadRadius: 5,
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            if (stage != "done")
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(stage == "" ? "回答中..." : stage),
                  SizedBox(
                    width: 10,
                  ),
                  BlinkingCursor()
                ],
              ),
            if (stage == "done")
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueAccent.withAlpha(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tokenGenetated == 0 || tps == 0)
                        Text(
                          "回答结束",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      if (tokenGenetated != 0 && tps != 0)
                        Text(
                          "Token使用: $tokenGenetated, TPS: ${tps.toStringAsFixed(2)} tokens/秒, 响应时间: ${(tokenGenetated / (tps)).toInt()} 秒",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topLeft,
              child: MarkdownBlock(data: content),
            ),
            Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.thumb_up_outlined,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.thumb_down_outlined,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: content));
                      },
                      child: const Icon(
                        Icons.copy,
                        size: iconSize,
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

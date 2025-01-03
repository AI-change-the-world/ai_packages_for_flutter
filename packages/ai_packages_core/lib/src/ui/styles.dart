import 'package:ai_packages_core/src/ui/utils.dart';
import 'package:flutter/material.dart';

class Styles {
  Styles._();

  static Color black515A6E = HexColor('#515A6E');
  static Color divider = HexColor('#DCDFE6');
  static Color blue247AF2 = HexColor('#247AF2');

  static Color appColor = Color.fromARGB(255, 132, 142, 209);

  static InputDecoration inputDecoration = InputDecoration(
      errorStyle: TextStyle(height: 0),
      hintStyle:
          TextStyle(color: Color.fromARGB(255, 159, 159, 159), fontSize: 12),
      contentPadding: EdgeInsets.only(left: 10, bottom: 15),
      border: InputBorder.none,
      // focusedErrorBorder:
      //     OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder:
          OutlineInputBorder(borderSide: BorderSide(color: appColor)),
      errorBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: appColor)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 159, 159, 159))));
}

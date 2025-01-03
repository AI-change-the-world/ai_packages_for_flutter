import 'dart:ui';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class PromptUtils {
  static bool promptValidator(String inputKey, String prompt) {
    return prompt.isEmpty || prompt.contains("{{$inputKey}}");
  }

  static bool multiplePromptValidator(String prompt, List<String> inputKeys) {
    return prompt.isEmpty ||
        inputKeys.every((element) => prompt.contains("{{$element}}"));
  }
}

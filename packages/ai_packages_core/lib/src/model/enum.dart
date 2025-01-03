part of 'model_info.dart';

enum ModelType {
  openai /*like*/,
  candle /*local host*/;

  String get name {
    switch (this) {
      case ModelType.openai:
        return "OpenAI";
      case ModelType.candle:
        return "Candle";
    }
  }
}

enum ModelFor {
  cv,
  mm /* 多模态  Multimodal */,
  nlp;

  String get name {
    switch (this) {
      case ModelFor.cv:
        return "CV";
      case ModelFor.nlp:
        return "NLP";
      case ModelFor.mm:
        return "MM";
    }
  }
}

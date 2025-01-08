part of 'model_info.dart';

/// 模型类型
/// 包括 [支持openai接口的模型] 和 本地运行的[candle] 模型
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

/// 模型用途
/// 包括 [cv] 和 [nlp]和 [mm] 多模态
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

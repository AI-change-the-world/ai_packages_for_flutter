part 'enum.dart';

abstract class ModelCallBase<R, S> {
  Stream<String> streamChat(Map<String, dynamic> history);

  Future<String> chat(Map<String, dynamic> history);

  Future<R> exec(S source);
}

/// [example]
/// ```dart
/// class OpenAIInfo extends ModelCallBase {
///   final String baseUrl;
///   final String secretKey;
///   final String defaultModel;

///   OpenAIInfo(this.baseUrl, this.secretKey, this.defaultModel);

///   @override
///   Future<String> chat(Map<String, dynamic> history) {
///     doSomething();
///   }

///   @override
///   Stream<String> streamChat(Map<String, dynamic> history) {
///       doSomething();
///   }

///   @override
///   Future exec(source) async {
///     // not valid for openai models
///     return null;
///   }
/// }

/// class CandleInfo extends ModelCallBase {
///   final String path;

///   CandleInfo(this.path);

///   @override
///   Future<String> chat(Map<String, dynamic> history) {
///        doSomething();
///   }

///   @override
///   Stream<String> streamChat(Map<String, dynamic> history) {
///        doSomething();
///   }

///   @override
///   Future exec(source) async {
///     // for yolo and other models
///      doSomething();
///   }
/// }
/// ```
class ModelInfo<I extends ModelCallBase> {
  ModelType modelType;
  ModelFor modelFor;
  String modelName;
  I info;
  ModelInfo(this.modelType, this.modelFor, this.modelName, this.info);
}

import 'package:ai_packages_core/ai_packages_core.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain/langchain.dart' as lc;

import 'utils.dart';

class OpenAIInfo extends ModelCallBase {
  final String baseUrl;
  final String secretKey;
  final String defaultModel;

  OpenAIInfo(this.baseUrl, this.secretKey, this.defaultModel);

  late final ChatOpenAI client = ChatOpenAI(
    apiKey: secretKey,
    baseUrl: baseUrl,
    defaultOptions: ChatOpenAIOptions(model: defaultModel),
  );

  @override
  Future<String> chat(List<ChatMessage> history) async {
    final prompt = lc.PromptValue.chat(getMessagesFromList(history));
    return (await client.invoke(prompt)).output.content;
  }

  @override
  Stream<String> streamChat(List<ChatMessage> history) {
    final prompt = lc.PromptValue.chat(getMessagesFromList(history));
    return client.stream(prompt).map((e) => e.output.content);
  }

  @override
  Future exec(source) async {
    // not valid for openai models
    return null;
  }
}

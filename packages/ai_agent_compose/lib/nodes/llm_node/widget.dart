part of 'llm_node.dart';

class LlmNodeWidget extends StatefulWidget {
  const LlmNodeWidget({super.key, required this.node});
  final LlmNode node;

  @override
  State<LlmNodeWidget> createState() => _LlmNodeWidgetState();
}

class _LlmNodeWidgetState extends State<LlmNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        showNodeSettingDialog(context, widget.node);
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        width: widget.node.width,
        height: widget.node.height,
      ),
    );
  }
}

/// multiple inputs, single output
class LlmNodeSettingsWidget extends StatefulWidget {
  const LlmNodeSettingsWidget(
      {super.key,
      required this.availableModels,
      required this.data,
      this.name = "节点配置"});
  final List<ModelInfo> availableModels;
  final Map<String, dynamic> data;
  final String name;

  @override
  State<LlmNodeSettingsWidget> createState() => _LlmNodeSettingsWidgetState();
}

class _LlmNodeSettingsWidgetState extends State<LlmNodeSettingsWidget> {
  late final TextEditingController _outputController = TextEditingController()
    ..text = widget.data["output"]?.toString() ?? "";
  late final TextEditingController _promptController = TextEditingController()
    ..text = widget.data["prompt"]?.toString() ?? "";
  late final TextEditingController _inputController = TextEditingController();
  late String selectedModel = widget.data["model"]?.toString() ?? "";
  late List<String> inputs = widget.data["inputs"] ?? [];

  bool showInput = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.name),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text("模型选择"),
              DropdownButtonFormField2<ModelInfo>(
                isExpanded: true,
                decoration: InputDecoration(
                  // Add Horizontal padding using menuItemStyleData.padding so it matches
                  // the menu padding when button's width is not specified.
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // Add more decoration..
                ),
                hint: const Text(
                  '选择模型',
                  style: TextStyle(fontSize: 14),
                ),
                items: widget.availableModels
                    .map((item) => DropdownMenuItem<ModelInfo>(
                          value: item,
                          child: Text(
                            item.modelName,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModel = value?.modelName ?? "";
                  });
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.only(right: 8),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black45,
                  ),
                  iconSize: 24,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              Row(
                children: [
                  Text("输入"),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showInput = !showInput;
                      });
                    },
                    child: Icon(
                      !showInput ? Icons.add : Icons.cancel,
                      size: 24,
                    ),
                  )
                ],
              ),
              Text("输出"),
              TextField(
                controller: _outputController,
                decoration: Styles.inputDecoration,
              ),
              Text("提示词"),
              TextField(
                controller: _promptController,
                decoration: Styles.inputDecoration,
                maxLines: 5,
              ),
            ],
          ),
        )),
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "output": _outputController.text,
                      "prompt": _promptController.text,
                      "model": selectedModel,
                      "inputs": inputs
                    });
                  },
                  child: Text("确定"))
            ],
          ),
        )
      ],
    );
  }
}

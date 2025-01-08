part of 'llm_node.dart';

class LlmNodeWidget extends ConsumerStatefulWidget {
  const LlmNodeWidget({super.key, required this.node});
  final LlmNode node;

  @override
  ConsumerState<LlmNodeWidget> createState() => _LlmNodeWidgetState();
}

class _LlmNodeWidgetState extends ConsumerState<LlmNodeWidget> {
  @override
  Widget build(BuildContext context) {
    final l = ref.read(workflowProvider.notifier).getAllGlobalInputs();
    if (widget.node.data?["globalInputs"] == null) {
      widget.node.data = {"globalInputs": l};
    } else {
      widget.node.data!["globalInputs"] = l;
    }

    return GestureDetector(
      onDoubleTap: () async {
        Map<String, dynamic>? result =
            await showNodeSettingDialog(context, widget.node, ref);
        if (result != null) {
          ref.read(workflowProvider.notifier).addData(widget.node.uuid, result);
          setState(() {
            widget.node.data!.addAll(result);
            widget.node.nodeName = result["name"] ?? widget.node.nodeName;
            widget.node.description =
                result["description"] ?? widget.node.description;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        width: widget.node.width,
        height: widget.node.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text(
              widget.node.nodeName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(widget.node.description)
          ],
        ),
      ),
    );
  }
}

/// multiple inputs, single output
class LlmNodeSettingsWidget extends StatefulWidget {
  const LlmNodeSettingsWidget({
    super.key,
    required this.availableModels,
    required this.node,
    this.name = "节点配置",
  });
  final List<ModelInfo> availableModels;
  final LlmNode node;
  final String name;

  @override
  State<LlmNodeSettingsWidget> createState() => _LlmNodeSettingsWidgetState();
}

class _LlmNodeSettingsWidgetState extends State<LlmNodeSettingsWidget> {
  late final TextEditingController _outputController = TextEditingController()
    ..text = widget.node.data?["output"]?.toString() ?? "";
  late final TextEditingController _promptController = TextEditingController()
    ..text = widget.node.data?["prompt"]?.toString() ?? "";
  late final TextEditingController _inputController = TextEditingController();
  late String selectedModel = widget.node.data?["model"]?.toString() ?? "";
  late List<String> inputs = widget.node.data?["inputs"] ?? [];
  late final TextEditingController _nameController = TextEditingController()
    ..text = widget.node.nodeName;
  late final TextEditingController _descriptionController =
      TextEditingController()..text = widget.node.description;
  late List<String> globalInputs = widget.node.data?["globalInputs"] ?? [];

  bool showInput = false;
  bool promptError = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _promptController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
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
              Text("1. 节点名"),
              TextField(
                controller: _nameController,
                decoration: Styles.inputDecoration,
              ),
              Text("2. 描述"),
              TextField(
                controller: _descriptionController,
                decoration: Styles.inputDecoration,
                maxLines: 5,
              ),
              Text("3. 模型选择"),
              DropdownButtonFormField2<ModelInfo>(
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 159, 159, 159),
                    ),
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
                          child: Row(
                            spacing: 10,
                            children: [
                              Text(
                                item.modelName,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SimpleTag(
                                text: item.modelType.name,
                              ),
                              SimpleTag(text: item.modelFor.name)
                            ],
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
                  Text("4. 输入 (多输入)"),
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
              Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.start,
                children: inputs
                    .map((e) => Chip(
                          onDeleted: () {
                            setState(() {
                              inputs.remove(e);
                            });
                          },
                          label: Text(e),
                          deleteIcon: Icon(Icons.delete),
                        ))
                    .toList(),
              ),
              if (showInput)
                Row(
                  spacing: 10,
                  children: [
                    // Expanded(
                    //     child: TextField(
                    //   controller: _inputController,
                    //   decoration: Styles.inputDecoration,
                    // )),

                    Expanded(
                      child: DropDownSearchField(
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration: Styles.inputDecoration,
                              controller: _inputController),
                          itemBuilder: (c, s) {
                            // return ListTile(
                            //   leading: Chip(label: Text("全局变量")),
                            //   title: Text(s),
                            // );
                            return SizedBox(
                              height: 35,
                              child: Row(
                                spacing: 5,
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.blueAccent,
                                    ),
                                    child: Text(
                                      "全局变量",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Text(s),
                                ],
                              ),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            _inputController.text = suggestion;
                          },
                          suggestionsCallback: (pattern) {
                            return globalInputs
                                .where((e) => e.contains(pattern))
                                .toList();
                          },
                          displayAllSuggestionWhenTap: false,
                          isMultiSelectDropdown: false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_inputController.text.isEmpty ||
                            inputs.contains(_inputController.text)) {
                          return;
                        }
                        setState(() {
                          inputs.add(_inputController.text);
                          _inputController.clear();
                        });
                      },
                      child: Text("添加"),
                    ),
                    Tooltip(
                      message: "仅支持全局变量中存在的输入，并且输入不能重复",
                      child: Icon(Icons.info),
                    )
                  ],
                ),
              Text("5. 输出 (单输出)"),
              TextField(
                controller: _outputController,
                decoration: Styles.inputDecoration,
              ),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("6. 提示词"),
                  if (promptError)
                    Tooltip(
                      message: "提示词格式错误! 此prompt中未包含一个或多个输入",
                      child: Icon(Icons.error, color: Colors.red),
                    )
                ],
              ),
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
                    if (inputs.isNotEmpty) {
                      final r = PromptUtils.multiplePromptValidator(
                          _promptController.text, inputs);
                      if (!r) {
                        setState(() {
                          promptError = true;
                        });
                        return;
                      } else {
                        setState(() {
                          promptError = false;
                        });
                      }
                    } else {
                      setState(() {
                        promptError = false;
                      });
                    }

                    Navigator.pop(context, {
                      "output": _outputController.text,
                      "prompt": _promptController.text,
                      "model": selectedModel,
                      "inputs": inputs,
                      "name": _nameController.text,
                      "description": _descriptionController.text,
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

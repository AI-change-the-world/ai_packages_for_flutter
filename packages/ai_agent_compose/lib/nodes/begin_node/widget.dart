part of 'begin_node.dart';

class BeginNodeWidget extends ConsumerStatefulWidget {
  const BeginNodeWidget({super.key, required this.node});
  final INode node;

  @override
  ConsumerState<BeginNodeWidget> createState() => _BeginNodeWidgetState();
}

class _BeginNodeWidgetState extends ConsumerState<BeginNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        final Map<String, dynamic>? d =
            await showNodeSettingDialog(context, widget.node, ref);
        if (d != null) {
          ref.read(workflowProvider.notifier).addData(widget.node.uuid, d);
          widget.node.data = d;
          setState(() {});
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
        child: Center(
          child: Text(
            widget.node.nodeName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class BeginNodeConfigWidget extends StatefulWidget {
  const BeginNodeConfigWidget(
      {super.key, required this.node, this.name = "节点配置"});
  final BeginNode node;
  final String name;

  @override
  State<BeginNodeConfigWidget> createState() => _BeginNodeConfigWidgetState();
}

extension AddIfExists on List<Input> {
  void addIfExists(Input input) {
    if (!contains(input)) {
      add(input);
    } else {
      remove(input);
      add(input);
    }
  }
}

class _BeginNodeConfigWidgetState extends State<BeginNodeConfigWidget> {
  bool showInput = false;
  late final TextEditingController _inputController = TextEditingController();
  late final TextEditingController _contentController = TextEditingController();
  late List<Input> inputs = ((widget.node.data?["inputs"] ??
          <Map<String, dynamic>>[]) as List<Map<String, dynamic>>)
      .map((e) => Input.fromJson(e))
      .toList();

  // ignore: avoid_init_to_null
  InputType? inputType = InputType.text;

  @override
  void dispose() {
    _inputController.dispose();
    _contentController.dispose();
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
                Row(
                  children: [
                    Text("添加多变量"),
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
                      .map((e) => InkWell(
                            onTap: () {
                              setState(() {
                                showInput = true;
                                inputType = e.type;
                                _inputController.text = e.key!;
                                _contentController.text = e.content ?? "";
                              });
                            },
                            child: Chip(
                              label: Text(e.key!),
                              deleteIcon: Icon(Icons.delete),
                              onDeleted: () {
                                setState(() {
                                  inputs.remove(e);
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
                if (showInput)
                  SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Row(
                          spacing: 20,
                          children: [
                            Expanded(
                                child: TextField(
                              controller: _inputController,
                              decoration:
                                  Styles.inputDecorationWithHint("输入名称"),
                            )),
                            SizedBox(
                              width: 50,
                              child: DropdownButtonFormField2<InputType>(
                                isExpanded: true,
                                customButton: Icon(
                                  inputType == InputType.file
                                      ? Icons.file_open
                                      : inputType == InputType.text
                                          ? Icons.abc
                                          : Icons.list,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 159, 159, 159),
                                    ),
                                  ),
                                  // Add more decoration..
                                ),
                                items: InputType.values
                                    .map((item) => DropdownMenuItem<InputType>(
                                          value: item,
                                          child: Text(
                                            item.value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  if (value != null) {
                                    setState(() {
                                      inputType = value;
                                    });
                                    if (inputType == InputType.file) {
                                      final result = await openFile();
                                      if (result != null) {
                                        _contentController.text = result.path;
                                      } else {
                                        setState(() {
                                          inputType = null;
                                        });
                                      }
                                    }
                                  }
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
                                  width: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        TextField(
                          enabled: inputType != InputType.file,
                          maxLines: 5,
                          decoration: Styles.inputDecorationWithHint("输入内容"),
                          controller: _contentController,
                        ),
                        Spacer(),
                        SizedBox(
                          height: 30,
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
                                    showInput = false;
                                    setState(() {});
                                  },
                                  child: Text("取消")),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (inputType == null ||
                                        _inputController.text.isEmpty) {
                                      return;
                                    }
                                    inputs.addIfExists(Input()
                                      ..type = inputType
                                      ..key = _inputController.text
                                      ..content = _contentController.text);
                                    inputType = null;
                                    _inputController.text = "";
                                    _contentController.text = "";
                                    setState(() {});
                                  },
                                  child: Text("添加"))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
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
                      "inputs": inputs.map((e) => e.toJson()).toList(),
                      "node": "BeginNode"
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

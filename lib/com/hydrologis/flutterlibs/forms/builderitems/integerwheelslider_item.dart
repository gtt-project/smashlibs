part of smashlibs;

class IntWheelSliderWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  IntWheelSliderWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return TYPE_INTCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(IntWheelSliderValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ComboboxWidget<int>(getKey(widgetKey), formItem, label,
          presentationMode, constraints, formItem.isUrlItem, formHelper),
    );
    return widget!;
  }
}

/// Configuration widget for a int list value of a [SmashFormItem]. Ex of a combo box.
///
/// If the values are of form:
///     item1: value1
///     item2: value2
///     item3: value3
///     ...
/// then the first will be used as label and the second as value.
/// Else the line is the value.
class IntWheelSliderValuesConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final bool emptyIsNull;
  IntWheelSliderValuesConfigWidget(this.formItem,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _IntWheelSliderValuesConfigWidgetState createState() =>
      _IntWheelSliderValuesConfigWidgetState();
}

class _IntWheelSliderValuesConfigWidgetState
    extends State<IntWheelSliderValuesConfigWidget> {
  var _url;
  @override
  Widget build(BuildContext context) {
    var mapItem = widget.formItem.getMapItem(TAG_VALUES);
    var items = mapItem[TAG_ITEMS];
    var valStr = "";
    if (items != null) {
      for (var item in items) {
        var itemContent = item[TAG_ITEM];
        // if it is a map, then it is a label:value pair
        if (itemContent is Map) {
          var label = itemContent[TAG_LABEL];
          var value = itemContent[TAG_VALUE];
          valStr += label + ": " + value.toString() + "\n";
        } else {
          valStr += itemContent.toString() + "\n";
        }
      }
    }
    _url = mapItem[TAG_URL];

    var textEditingController = new TextEditingController(text: valStr);
    var inputDecoration = new InputDecoration(
      labelText: SLL.of(context).insert_one_item_per_line,

      // hintText: hintText,
    );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: inputDecoration,
      validator: (inputText) {
        return validationFunction(inputText);
      },
      onChanged: (inputText) {
        var ret = validationFunction(inputText);
        if (ret == null) {
          dynamic finalText = inputText;
          if (widget.emptyIsNull && inputText.isEmpty) {
            finalText = null;
          }

          // split into lines
          var lines = finalText.split("\n");
          var itemList = [];
          for (var line in lines) {
            if (line.trim().isEmpty) {
              continue;
            }
            // if line contains colon then it is a label:value pair
            if (line.contains(":")) {
              var parts = line.split(":");
              var label = parts[0].trim();
              var value = parts[1].trim();
              int finalValue = int.tryParse(value) ?? -1;
              itemList.add({
                "item": {"label": label, "value": finalValue}
              });
            } else {
              int finalValue = int.tryParse(line.trim()) ?? -1;
              itemList.add({"item": finalValue});
            }
          }
          var values = <String, dynamic>{"items": itemList};
          if (_url != null) {
            values = {
              "items": itemList,
              TAG_URL: _url,
            };
          }
          widget.formItem.setMapItem(TAG_VALUES, values);
        }
      },
    );
    return textWidget;
  }

  String? validationFunction(String? inputText) {
    // activate if necessary
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class _MultiDropdownFormField<T extends Object> extends FormField<List<T>> {
  _MultiDropdownFormField({
    super.key,
    super.onSaved,
    required widget,
    required getValue,
    required List<DropdownItem<T>> items,
    required MultiSelectController<T> controller,
    super.validator,
  }) : super(
          initialValue: items
              .where((item) => item.selected)
              .map((item) => item.value)
              .toList(),
          builder: (FormFieldState<List<T>> state) {
            return MultiDropdown<T>(
              items: items,
              controller: controller,
              singleSelect: !widget.selectMultiple,
              enabled: true,
              searchEnabled: true,
              chipDecoration: const ChipDecoration(
                backgroundColor: Colors.yellow,
                wrap: true,
                runSpacing: 2,
                spacing: 10,
              ),
              fieldDecoration: FieldDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: Colors.black87),
                prefixIcon: widget.leading,
                suffixIcon: widget.trailing,
                showClearIcon: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black87,
                  ),
                ),
              ),
              dropdownDecoration: const DropdownDecoration(
                marginTop: 2,
                maxHeight: 500,
              ),
              dropdownItemDecoration: DropdownItemDecoration(
                selectedIcon: const Icon(Icons.check_box, color: Colors.green),
                disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
              ),
              validator: widget.validator,
              onSelectionChange: (value) {
                state.didChange(value);
                if (widget.onChange != null) {
                  widget.onChange!(widget.name, getValue(value));
                }
              },
            );
          },
        );
}

class Field<T extends Object> extends StatefulWidget {
  final String? name;
  final bool required;
  final dynamic controller;
  List<TextInputFormatter>? inputFormatters;
  TextInputType? keyboardType;
  final String? placeholder;
  final Color? borderColor;
  final double? borderRadius;
  final dynamic initialValue;
  final String? type;
  final String? selectLabelField;
  final String? selectSearchLabel;
  final String? invalidMessage;
  final List<dynamic>? selectOptions;
  final bool selectMultiple;
  final Widget? leading;
  final Widget? trailing;
  final void Function(String?, dynamic)? onSave;
  final void Function(String?, dynamic)? onChange;

  Field(
      {super.key,
      this.required = false,
      this.controller,
      this.inputFormatters,
      this.keyboardType,
      this.placeholder,
      this.borderColor,
      this.borderRadius,
      this.initialValue,
      this.name,
      this.type,
      this.invalidMessage,
      this.selectOptions,
      this.selectMultiple = false,
      this.selectLabelField,
      this.leading,
      this.trailing,
      this.selectSearchLabel,
      this.onSave,
      this.onChange});

  @override
  State<Field<T>> createState() => _FieldState();

  String? validator(dynamic value) {
    if (required && (value == null || value.isEmpty)) {
      return "Ce champ est requis";
    }
    switch (type) {
      case "email":
        const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
            r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
            r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
            r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
            r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
            r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
            r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
        final regex = RegExp(pattern);
        return value!.isEmpty || !regex.hasMatch(value)
            ? (invalidMessage ?? 'Saisir une adresse email valide')
            : null;
      default:
        return null;
    }
  }
}

class _FieldState<T extends Object> extends State<Field<T>> {
  Color? borderColor;
  String? dropdownValue;
  dynamic controller;
  List<DropdownItem<T>> dropdownValues = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    borderColor = widget.borderColor ?? Colors.grey.shade300;
    dropdownValues = widget.selectOptions?.map((option) {
          bool isString = option is String;
          bool selected = false;
          if (widget.initialValue != null) {
            if (widget.initialValue is String) {
              if (option == widget.initialValue) {
                selected = true;
              }
              if (!isString &&
                  option[widget.selectLabelField ?? "id"] ==
                      widget.initialValue) {
                selected = true;
              }
            } else if (widget.initialValue is! List) {
              if (option ==
                  widget.initialValue[widget.selectLabelField ?? "id"]) {
                selected = true;
              }
              if (!isString &&
                  option[widget.selectLabelField ?? "id"] ==
                      widget.initialValue[widget.selectLabelField ?? "id"]) {
                selected = true;
              }
            } else {
              if (widget.initialValue.contains(option)) {
                selected = true;
              } else if (!isString &&
                  widget.initialValue
                      .contains(option[widget.selectLabelField ?? "id"])) {
                selected = true;
              }
            }
          }
          return DropdownItem<T>(
              label:
                  isString ? option : option[widget.selectLabelField ?? "id"],
              value: option,
              selected: selected);
        }).toList() ??
        [];
  }

  dynamic _getValue(dynamic value) {
    switch (T) {
      case int:
        return int.parse(value!) as T;
      case double:
        return double.parse(value!) as T;
      default:
        var type = widget.type ?? "text";
        if (type == "select" && !widget.selectMultiple) {
          return value.isNotEmpty ? value[0] as T : null;
        } else if (type == "select" && widget.selectMultiple) {
          return value as List<T>;
        } else {
          return value as T;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = widget.borderRadius ?? 10;
    List<TextInputFormatter>? inputFormatters = widget.inputFormatters;
    TextInputType? keyboardType = widget.keyboardType;
    String type = widget.type ?? "text";
    controller = widget.controller;

    switch (type) {
      case "select":
        controller ??= MultiSelectController<T>();
        print(T);
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: _MultiDropdownFormField<T>(
            widget: widget,
            getValue: _getValue,
            items: dropdownValues,
            controller: controller,
            onSaved: (value) {
              if (widget.onSave != null) {
                widget.onSave!(widget.name, _getValue(value));
              }
            },
          ),
        );
      default:
        controller ??=
            TextEditingController(text: "${widget.initialValue ?? ''}");
        switch (type) {
          case "number":
            inputFormatters = [
              T == int
                  ? FilteringTextInputFormatter.digitsOnly
                  : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}'))
            ];
            keyboardType = TextInputType.number;
            break;
          case "email":
            inputFormatters = [
              FilteringTextInputFormatter.allow(RegExp("[0-9@a-zA-Z.]"))
            ];
            keyboardType = TextInputType.emailAddress;
            break;
        }
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextFormField(
            inputFormatters: inputFormatters,
            autocorrect: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: widget.leading,
              suffixIcon: widget.trailing,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              hintText: widget.placeholder,
              hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
              fillColor: Colors.grey.shade200,
              filled: true,
              counterText: "",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor!, width: 1.0),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            keyboardType: keyboardType,
            validator: widget.validator,
            onChanged: (value) {
              if (widget.onChange != null) {
                widget.onChange!(widget.name, _getValue(value));
              }
            },
            onSaved: (value) {
              if (widget.onSave != null) {
                widget.onSave!(widget.name, _getValue(value));
              }
            },
          ),
        );
    }
  }
}

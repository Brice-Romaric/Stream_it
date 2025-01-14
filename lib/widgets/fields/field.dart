import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class Field<T> extends StatefulWidget {
  final String? name;
  final bool required;
  final dynamic controller;
  List<TextInputFormatter>? inputFormatters;
  TextInputType? keyboardType;
  final String? placeholder;
  final Color? borderColor;
  final double? borderRadius;
  final dynamic initialValue;
  final Map<String, dynamic>? fields;
  final String? type;
  final String? selectLabelField;
  final String? selectSearchLabel;
  final String? invalidMessage;
  final List<dynamic>? selectOptions;
  final bool selectMultiple;
  final Widget? leading;
  final Widget? trailing;

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
      this.fields,
      this.type,
      this.invalidMessage,
      this.selectOptions,
      this.selectMultiple = false,
      this.selectLabelField,
      this.leading,
      this.trailing,
      this.selectSearchLabel});

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

class _FieldState<T> extends State<Field<T>> {
  Color? borderColor;
  String? dropdownValue;
  List<DropdownItem<Object>> dropdownValues = [];

  @override
  void initState() {
    super.initState();
    borderColor = widget.borderColor ?? Colors.grey.shade300;
    dropdownValues = widget.selectOptions?.map((option) {
          bool isString = option is String;
          bool selected = false;
          if (widget.initialValue != null) {
            if (widget.initialValue is String) {
              if (isString && option == widget.initialValue) {
                selected = true;
              }
              if (!isString &&
                  option[widget.selectLabelField ?? "id"] ==
                      widget.initialValue) {
                selected = true;
              }
            } else if (widget.initialValue is! List) {
              if (isString &&
                  option ==
                      widget.initialValue[widget.selectLabelField ?? "id"]) {
                selected = true;
              }
              if (!isString &&
                  option[widget.selectLabelField ?? "id"] ==
                      widget.initialValue[widget.selectLabelField ?? "id"]) {
                selected = true;
              }
            } else {
              if (isString && widget.initialValue.contains(option)) {
                selected = true;
              }
              if (!isString &&
                  widget.initialValue
                      .contains(option[widget.selectLabelField ?? "id"])) {
                selected = true;
              }
            }
          }
          return DropdownItem(
              label:
                  isString ? option : option[widget.selectLabelField ?? "id"],
              value: option as Object,
              selected: selected);
        }).toList() ??
        [];
  }

  onChanged(dynamic value) {
    if (widget.fields != null && widget.name != null) {
      switch (T) {
        case int:
          widget.fields![widget.name!] = int.parse(value!);
          break;
        case double:
          widget.fields![widget.name!] = double.parse(value!);
          break;
        default:
          if ((widget.type ?? "text") == "select" && !widget.selectMultiple) {
            widget.fields![widget.name!] = value[0];
          } else {
            widget.fields![widget.name!] = value;
          }
      }
    }
    print(widget.fields);
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = widget.borderRadius ?? 10;
    List<TextInputFormatter>? inputFormatters = widget.inputFormatters;
    TextInputType? keyboardType = widget.keyboardType;
    String type = widget.type ?? "text";

    switch (type) {
      case "select":
        return MultiDropdown(
          items: dropdownValues,
          controller: widget.controller,
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
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Select countries from the list',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: const Icon(Icons.check_box, color: Colors.green),
            disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
          ),
          validator: widget.validator,
          onSelectionChange: (selectedItems) {
            onChanged(selectedItems);
          },
        );
      default:
        switch (type) {
          case "email":
            inputFormatters = [
              FilteringTextInputFormatter.allow(RegExp("[0-9@a-zA-Z.]"))
            ];
            keyboardType = TextInputType.emailAddress;
            break;
        }
        return TextFormField(
          initialValue: "${widget.initialValue ?? ''}",
          inputFormatters: inputFormatters,
          autocorrect: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
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
            onChanged(value);
            setState(() {
              if (widget.validator(value) == null) {
                borderColor = Color(0xFFE91e63);
              } else {
                borderColor = Colors.grey.shade300;
              }
            });
          },
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.min,
      required this.max,
      required this.defaultValue,
      this.decimal});

  final String labelText;
  final double min;
  final double max;
  final double defaultValue;
  final bool? decimal;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SpinBox(
          step: decimal != null ? 0.1 : 1,
          decimals: decimal != null ? 1 : 0,
          keyboardType: TextInputType.number,
          min: min,
          max: max,
          value: defaultValue,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
        ));
  }
}

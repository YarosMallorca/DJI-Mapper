import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'dart:math' as math;

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.min,
      required this.max,
      required this.defaultValue,
      required this.onChanged,
      this.enabled = true,
      this.decimals});

  final String labelText;
  final double min;
  final double max;
  final num defaultValue;
  final int? decimals;
  final bool enabled;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SpinBox(
          enabled: enabled,
          step: decimals != null ? math.pow(10.0, -decimals!).toDouble() : 1,
          decimals: decimals ?? 0,
          keyboardType: TextInputType.number,
          min: min,
          max: max,
          onChanged: onChanged,
          value: defaultValue.toDouble(),
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
        ));
  }
}


// pages/calculator_display.dart
import 'package:flutter/material.dart';

class CalculatorDisplay extends StatelessWidget {
  final TextEditingController controller;
  final double fontSize;
  final FontWeight fontWeight;

  const CalculatorDisplay({
    super.key,
    required this.controller,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: fontSize, color: Colors.black, fontWeight: fontWeight),
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}


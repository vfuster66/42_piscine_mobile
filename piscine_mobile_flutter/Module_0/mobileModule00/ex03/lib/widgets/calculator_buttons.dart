
// pages/calculator_buttons.dart
import 'package:flutter/material.dart';

typedef ButtonPressedCallback = void Function(String text);

class CalculatorButtonGrid extends StatelessWidget {
  final ButtonPressedCallback onButtonPressed;

  const CalculatorButtonGrid({super.key, required this.onButtonPressed});

  Widget _buildButton(String text, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['7', '8', '9', 'C', 'AC']),
        _buildRow(['4', '5', '6', '+', '-']),
        _buildRow(['1', '2', '3', '*', '/']),
        _buildRow(['0', '.', '00', '=']),
      ],
    );
  }

  Widget _buildRow(List<String> texts) {
    return Expanded(
      child: Row(
        children: texts.map((text) {
          final color = _getButtonColor(text);
          return _buildButton(text, color);
        }).toList(),
      ),
    );
  }

  Color _getButtonColor(String text) {
    const defaultColor = Colors.blueGrey;
    const operatorColor = Colors.blue;
    const controlColor = Colors.red;
    const equalsColor = Colors.green;

    switch (text) {
      case '+':
      case '-':
      case '*':
      case '/':
        return operatorColor;
      case 'C':
      case 'AC':
        return controlColor;
      case '=':
        return equalsColor;
      default:
        return defaultColor;
    }
  }
}


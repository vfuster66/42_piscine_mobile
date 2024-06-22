
// lib/calculator_buttons.dart

import 'package:flutter/material.dart';

Widget buildButtons(Orientation orientation, Function(String) onButtonPressed) {
  final List<List<String>> buttons = [
    ['7', '8', '9', 'C', 'AC'],
    ['4', '5', '6', '+', '*'],
    ['1', '2', '3', '-', '/'],
    ['0', '.', '00', '=', ''],
  ];

  return Column(
    children: buttons.map((row) {
      return Expanded(
        child: Row(
          children: row.map((buttonText) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: buttonText.isNotEmpty
                    ? ElevatedButton(
                  onPressed: () => onButtonPressed(buttonText),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: orientation == Orientation.portrait ? 12 : 12,
                      horizontal: 12,
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: orientation == Orientation.portrait ? 24 : 20,
                    ),
                  ),
                )
                    : Container(),
              ),
            );
          }).toList(),
        ),
      );
    }).toList(),
  );
}


// lib/calculator.dart

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'calculator_buttons.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  String _expression = '';
  String _result = '0';

  void _onButtonPressed(String buttonText) {
    setState(() {
      print('Button pressed: $buttonText'); // Debug: Affiche le bouton pressé dans la console

      if (buttonText == 'AC') {
        _expression = '';
        _result = '0';
      } else if (buttonText == 'C') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (buttonText == '=') {
        // Pour le moment, on affiche juste "0" comme résultat
        _result = '0';
      } else {
        _expression += buttonText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            _expression.isEmpty ? '0' : _expression, // Affiche "0" si l'expression est vide
                            style: TextStyle(
                              fontSize: orientation == Orientation.portrait ? 28 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AutoSizeText(
                          _result,
                          style: TextStyle(
                            fontSize: orientation == Orientation.portrait ? 48 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              Flexible(
                flex: 3,
                child: buildButtons(orientation, _onButtonPressed),
              ),
            ],
          );
        },
      ),
    );
  }
}


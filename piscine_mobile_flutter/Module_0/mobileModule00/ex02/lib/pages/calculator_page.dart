import 'package:flutter/material.dart';
import '../logic/calculator_logic.dart';
import '../widgets/calculator_buttons.dart';
import '../widgets/calculator_display.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  CalculatorPageState createState() => CalculatorPageState();
}

class CalculatorPageState extends State<CalculatorPage> {
  final CalculatorLogic logic = CalculatorLogic();

  final TextEditingController _expressionController = TextEditingController(text: '0');
  final TextEditingController _resultController = TextEditingController(text: '0');

  void _onButtonPressed(String text) {
    print('Button pressed: $text');
    setState(() {
      if (text == 'AC') {
        logic.reset();
        _expressionController.text = '0';
        _resultController.text = '0';
      } else if (text == 'C') {
        logic.deleteLast();
        _expressionController.text = logic.expression;
      } else if (text == '=') {
        try {
          _resultController.text = logic.evaluate();
        } catch (e) {
          _resultController.text = 'Error';
        }
      } else {
        logic.appendExpression(text);
        _expressionController.text = logic.expression;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                CalculatorDisplay(controller: _expressionController, fontSize: 24),
                CalculatorDisplay(controller: _resultController, fontSize: 48, fontWeight: FontWeight.bold),
                const SizedBox(height: 20),
                Expanded(child: CalculatorButtonGrid(onButtonPressed: _onButtonPressed)),
              ],
            ),
          );
        },
      ),
    );
  }
}

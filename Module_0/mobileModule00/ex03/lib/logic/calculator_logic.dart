
// pages/calculator_logic.dart
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String expression = '0';
  String result = '0';

  void reset() {
    expression = '0';
    result = '0';
  }

  void deleteLast() {
    if (expression.isNotEmpty && expression != '0') {
      expression = expression.substring(0, expression.length - 1);
    }
    if (expression.isEmpty) {
      expression = '0';
    }
  }

  void appendExpression(String input) {
    if (expression == '0') {
      expression = input;
    } else {
      expression += input;
    }
  }

  String evaluate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();
      return result;
    } catch (e) {
      return 'Error';
    }
  }
}
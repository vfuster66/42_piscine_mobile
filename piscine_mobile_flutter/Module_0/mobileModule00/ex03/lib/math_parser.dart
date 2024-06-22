
// lib/math_parser.dart

import 'package:math_expressions/math_expressions.dart';

double evaluateExpression(String expression) {
  try {
    Parser parser = Parser();
    Expression exp = parser.parse(expression);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);
    return result;
  } catch (e) {
    throw const FormatException('Invalid expression');
  }
}


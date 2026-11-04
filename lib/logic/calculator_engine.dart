class CalculatorException implements Exception {
  const CalculatorException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CalculatorEngine {
  static const _precedence = <String, int>{
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    'u+': 3,
    'u-': 3,
  };

  static double evaluate(String expression) {
    final tokens = _tokenize(expression);
    final postfix = _toPostfix(tokens);
    final values = <double>[];

    for (final token in postfix) {
      if (token == '%') {
        if (values.isEmpty) {
          throw const CalculatorException('Invalid expression');
        }
        values.add(values.removeLast() / 100);
      } else if (token == 'u+' || token == 'u-') {
        if (values.isEmpty) {
          throw const CalculatorException('Invalid expression');
        }
        final value = values.removeLast();
        values.add(token == 'u-' ? -value : value);
      } else if (_precedence.containsKey(token)) {
        if (values.length < 2) {
          throw const CalculatorException('Invalid expression');
        }
        final right = values.removeLast();
        final left = values.removeLast();
        final result = switch (token) {
          '+' => left + right,
          '-' => left - right,
          '*' => left * right,
          '/' when right == 0 => throw const CalculatorException(
            'Cannot divide by zero',
          ),
          '/' => left / right,
          _ => throw const CalculatorException('Invalid expression'),
        };
        if (!result.isFinite) {
          throw const CalculatorException('Result is out of range');
        }
        values.add(result);
      } else {
        final value = double.tryParse(token);
        if (value == null || !value.isFinite) {
          throw const CalculatorException('Invalid number');
        }
        values.add(value);
      }
    }

    if (values.length != 1) {
      throw const CalculatorException('Invalid expression');
    }
    return values.single;
  }

  static String formatNumber(double value) {
    if (!value.isFinite) {
      throw const CalculatorException('Result is out of range');
    }
    if (value == 0) return '0';

    final magnitude = value.abs();
    if (magnitude >= 1e12 || magnitude < 1e-7) {
      return _trimDecimal(value.toStringAsExponential(10));
    }
    return _trimDecimal(value.toStringAsPrecision(15));
  }

  static String _trimDecimal(String value) {
    final exponentIndex = value.indexOf('e');
    final mantissa = exponentIndex == -1
        ? value
        : value.substring(0, exponentIndex);
    final exponent = exponentIndex == -1 ? '' : value.substring(exponentIndex);
    final trimmedMantissa = mantissa.contains('.')
        ? mantissa
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : mantissa;
    return '$trimmedMantissa$exponent';
  }

  static List<String> _tokenize(String expression) {
    final normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    final tokens = <String>[];
    var index = 0;
    var expectsOperand = true;

    while (index < normalized.length) {
      final character = normalized[index];
      if (character.trim().isEmpty) {
        index++;
        continue;
      }

      if (_isDigit(character) || character == '.') {
        final start = index;
        var decimalPoints = 0;
        var digits = 0;
        while (index < normalized.length &&
            (_isDigit(normalized[index]) || normalized[index] == '.')) {
          if (normalized[index] == '.') {
            decimalPoints++;
          } else {
            digits++;
          }
          index++;
        }
        if (decimalPoints > 1 || digits == 0 || !expectsOperand) {
          throw const CalculatorException('Invalid number');
        }
        if (index < normalized.length &&
            (normalized[index] == 'e' || normalized[index] == 'E')) {
          index++;
          if (index < normalized.length &&
              (normalized[index] == '+' || normalized[index] == '-')) {
            index++;
          }
          final exponentStart = index;
          while (index < normalized.length && _isDigit(normalized[index])) {
            index++;
          }
          if (index == exponentStart) {
            throw const CalculatorException('Invalid number');
          }
        }
        tokens.add(normalized.substring(start, index));
        expectsOperand = false;
        continue;
      }

      if (character == '(') {
        if (!expectsOperand) {
          throw const CalculatorException('Invalid expression');
        }
        tokens.add(character);
        expectsOperand = true;
        index++;
        continue;
      }

      if (character == ')') {
        if (expectsOperand) {
          throw const CalculatorException('Invalid expression');
        }
        tokens.add(character);
        expectsOperand = false;
        index++;
        continue;
      }

      if (character == '%') {
        if (expectsOperand) {
          throw const CalculatorException('Invalid expression');
        }
        tokens.add(character);
        expectsOperand = false;
        index++;
        continue;
      }

      if ('+-*/'.contains(character)) {
        if (expectsOperand && character != '+' && character != '-') {
          throw const CalculatorException('Invalid expression');
        }
        tokens.add(expectsOperand ? 'u$character' : character);
        expectsOperand = true;
        index++;
        continue;
      }

      throw const CalculatorException('Invalid expression');
    }

    if (tokens.isEmpty || expectsOperand) {
      throw const CalculatorException('Incomplete expression');
    }
    return tokens;
  }

  // Shunting-yard keeps operator precedence explicit without evaluating code.
  static List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final operators = <String>[];

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          output.add(operators.removeLast());
        }
        if (operators.isEmpty) {
          throw const CalculatorException('Mismatched parentheses');
        }
        operators.removeLast();
        if (operators.isNotEmpty &&
            (operators.last == 'u+' || operators.last == 'u-')) {
          output.add(operators.removeLast());
        }
      } else if (token == '%') {
        output.add(token);
      } else {
        final isUnary = token == 'u+' || token == 'u-';
        while (operators.isNotEmpty && operators.last != '(') {
          final top = operators.last;
          final topPrecedence = _precedence[top] ?? 4;
          final tokenPrecedence = _precedence[token]!;
          if (topPrecedence > tokenPrecedence ||
              (!isUnary && topPrecedence == tokenPrecedence)) {
            output.add(operators.removeLast());
          } else {
            break;
          }
        }
        operators.add(token);
      }
    }

    while (operators.isNotEmpty) {
      final operator = operators.removeLast();
      if (operator == '(') {
        throw const CalculatorException('Mismatched parentheses');
      }
      output.add(operator);
    }
    return output;
  }

  static bool _isDigit(String character) =>
      character.codeUnitAt(0) >= 48 && character.codeUnitAt(0) <= 57;
}

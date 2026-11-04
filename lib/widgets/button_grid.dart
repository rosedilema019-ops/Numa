import 'package:flutter/material.dart';

import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({required this.onAction, super.key});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_ButtonDefinition>>[
      [
        _ButtonDefinition(
          'C',
          'Clear all',
          CalculatorButtonKind.utility,
          'clear',
        ),
        _ButtonDefinition(
          '⌫',
          'Delete last digit',
          CalculatorButtonKind.utility,
          'delete',
        ),
        _ButtonDefinition(
          '%',
          'Percent',
          CalculatorButtonKind.utility,
          'percent',
        ),
        _ButtonDefinition(
          '÷',
          'Divide',
          CalculatorButtonKind.operator,
          'divide',
        ),
      ],
      [
        _number('7'),
        _number('8'),
        _number('9'),
        _ButtonDefinition(
          '×',
          'Multiply',
          CalculatorButtonKind.operator,
          'multiply',
        ),
      ],
      [
        _number('4'),
        _number('5'),
        _number('6'),
        _ButtonDefinition(
          '−',
          'Subtract',
          CalculatorButtonKind.operator,
          'subtract',
        ),
      ],
      [
        _number('1'),
        _number('2'),
        _number('3'),
        _ButtonDefinition('+', 'Add', CalculatorButtonKind.operator, 'add'),
      ],
      [
        _ButtonDefinition(
          '+/-',
          'Toggle sign',
          CalculatorButtonKind.utility,
          'sign',
        ),
        _number('0'),
        _ButtonDefinition(
          '.',
          'Decimal point',
          CalculatorButtonKind.number,
          'decimal',
        ),
        _ButtonDefinition('=', 'Equals', CalculatorButtonKind.equals, 'equals'),
      ],
    ];

    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final definition in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: CalculatorButton(
                        label: definition.label,
                        semanticLabel: definition.semanticLabel,
                        kind: definition.kind,
                        keyName: definition.keyName,
                        onPressed: () => onAction(
                          definition.keyName == 'digit'
                              ? definition.label
                              : definition.keyName,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static _ButtonDefinition _number(String digit) => _ButtonDefinition(
    digit,
    'Digit $digit',
    CalculatorButtonKind.number,
    'digit_$digit',
  );
}

class _ButtonDefinition {
  const _ButtonDefinition(
    this.label,
    this.semanticLabel,
    this.kind,
    this.keyName,
  );

  final String label;
  final String semanticLabel;
  final CalculatorButtonKind kind;
  final String keyName;
}

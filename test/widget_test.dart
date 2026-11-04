import 'package:calculator_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keypad input and equals update the display', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.bySemanticsLabel('Calculator mascot'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('digit_5')));
    await tester.tap(find.byKey(const ValueKey('add')));
    await tester.tap(find.byKey(const ValueKey('digit_3')));
    await tester.tap(find.byKey(const ValueKey('equals')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calculator_result')),
        matching: find.text('8'),
      ),
      findsOneWidget,
    );
    expect(find.text('5 + 3'), findsOneWidget);
  });

  testWidgets('history shows completed calculations', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const ValueKey('digit_5')));
    await tester.tap(find.byKey(const ValueKey('add')));
    await tester.tap(find.byKey(const ValueKey('digit_3')));
    await tester.tap(find.byKey(const ValueKey('equals')));
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('5 + 3'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('8'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('multi-digit input and operator replacement work', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const ValueKey('digit_1')));
    await tester.tap(find.byKey(const ValueKey('digit_2')));
    await tester.tap(find.byKey(const ValueKey('add')));
    await tester.tap(find.byKey(const ValueKey('multiply')));
    await tester.tap(find.byKey(const ValueKey('digit_3')));
    await tester.tap(find.byKey(const ValueKey('equals')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calculator_result')),
        matching: find.text('36'),
      ),
      findsOneWidget,
    );
    expect(find.text('12 × 3'), findsOneWidget);
  });

  testWidgets('decimal input is unique and delete removes the last digit', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const ValueKey('digit_1')));
    await tester.tap(find.byKey(const ValueKey('decimal')));
    await tester.tap(find.byKey(const ValueKey('decimal')));
    await tester.tap(find.byKey(const ValueKey('digit_2')));
    await tester.tap(find.byKey(const ValueKey('delete')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calculator_result')),
        matching: find.text('1.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('sign toggle and percent transform the current entry', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const ValueKey('digit_5')));
    await tester.tap(find.byKey(const ValueKey('digit_0')));
    await tester.tap(find.byKey(const ValueKey('sign')));
    await tester.tap(find.byKey(const ValueKey('percent')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calculator_result')),
        matching: find.text('-0.5'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('clear recovers from division by zero', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const ValueKey('digit_1')));
    await tester.tap(find.byKey(const ValueKey('divide')));
    await tester.tap(find.byKey(const ValueKey('digit_0')));
    await tester.tap(find.byKey(const ValueKey('equals')));
    await tester.pumpAndSettle();
    expect(find.text('Cannot divide by zero'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calculator_result')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
  });
}

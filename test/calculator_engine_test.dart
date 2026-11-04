import 'package:calculator_app/logic/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine', () {
    test('evaluates basic arithmetic', () {
      expect(CalculatorEngine.evaluate('8+4'), 12);
      expect(CalculatorEngine.evaluate('8-4'), 4);
      expect(CalculatorEngine.evaluate('8*4'), 32);
      expect(CalculatorEngine.evaluate('8/4'), 2);
    });

    test('applies multiplication and division before addition', () {
      expect(CalculatorEngine.evaluate('5+3*2'), 11);
      expect(CalculatorEngine.evaluate('20/5-1'), 3);
    });

    test('handles decimals without floating-point display artifacts', () {
      expect(
        CalculatorEngine.formatNumber(CalculatorEngine.evaluate('0.1+0.2')),
        '0.3',
      );
      expect(
        CalculatorEngine.formatNumber(CalculatorEngine.evaluate('1.50+2.5')),
        '4',
      );
    });

    test('supports negative values and unary operators', () {
      expect(CalculatorEngine.evaluate('-3*2'), -6);
      expect(CalculatorEngine.evaluate('5+-2'), 3);
      expect(CalculatorEngine.evaluate('-(2+3)'), -5);
    });

    test('treats percent as a postfix percentage', () {
      expect(CalculatorEngine.evaluate('10%'), 0.1);
      expect(CalculatorEngine.evaluate('50+10%'), 50.1);
    });

    test('reports division by zero clearly', () {
      expect(
        () => CalculatorEngine.evaluate('1/0'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.message,
            'message',
            'Cannot divide by zero',
          ),
        ),
      );
    });

    test('supports chained operations and display symbols', () {
      expect(CalculatorEngine.evaluate('5 + 3 × 2'), 11);
      expect(CalculatorEngine.evaluate('10 ÷ 2 × 3'), 15);
    });

    test('formats very large and very small results with exponents', () {
      expect(CalculatorEngine.formatNumber(1e15), '1e+15');
      expect(CalculatorEngine.formatNumber(1e-10), '1e-10');
    });

    test('rejects repeated decimal points', () {
      expect(
        () => CalculatorEngine.evaluate('1.2.3'),
        throwsA(isA<CalculatorException>()),
      );
    });
  });
}

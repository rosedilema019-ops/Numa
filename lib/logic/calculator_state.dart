import 'package:flutter/foundation.dart';

import '../core/constants/calculator_constants.dart';
import 'calculator_engine.dart';

class CalculatorState extends ChangeNotifier {
  static const _maxHistoryEntries = 50;

  String _expression = '';
  String _display = '0';
  String _currentEntry = '';
  int _entryStart = 0;
  bool _justEvaluated = false;
  bool _hasError = false;
  final List<CalculationHistoryEntry> _history = [];

  String get expression => _formatExpression(_expression);
  String get display => _display;
  bool get hasError => _hasError;
  List<CalculationHistoryEntry> get history =>
      List.unmodifiable(_history);

  void inputDigit(String digit) {
    if (_hasError ||
        digit.length != 1 ||
        digit.codeUnitAt(0) < 48 ||
        digit.codeUnitAt(0) > 57) {
      return;
    }
    if (_justEvaluated) _startFreshEntry();
    if (_currentEntry.length >= CalculatorConstants.maxOperandLength ||
        _entryStart + _currentEntry.length >=
            CalculatorConstants.maxExpressionLength) {
      return;
    }

    if (_currentEntry.isEmpty) {
      _currentEntry = digit;
    } else if (_currentEntry == '0') {
      _currentEntry = digit == '0' ? '0' : digit;
    } else if (_currentEntry == '-0') {
      _currentEntry = digit == '0' ? '-0' : '-$digit';
    } else {
      _currentEntry += digit;
    }
    _replaceCurrentEntryInExpression();
    _display = _currentEntry;
    notifyListeners();
  }

  void inputDecimal() {
    if (_hasError) return;
    if (_justEvaluated) _startFreshEntry();
    if (_currentEntry.contains('.')) return;
    if (_currentEntry.length >= CalculatorConstants.maxOperandLength ||
        _entryStart + _currentEntry.length >=
            CalculatorConstants.maxExpressionLength) {
      return;
    }

    _currentEntry = switch (_currentEntry) {
      '' => '0.',
      '-' => '-0.',
      _ => '$_currentEntry.',
    };
    _replaceCurrentEntryInExpression();
    _display = _currentEntry;
    notifyListeners();
  }

  void inputOperator(String operator) {
    if (_hasError || !'+-*/'.contains(operator) || operator.length != 1) return;
    if (_justEvaluated) {
      _expression = _display;
      _currentEntry = _display;
      _entryStart = 0;
      _justEvaluated = false;
    }

    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
        _currentEntry = '-';
        _entryStart = 0;
        _display = '-';
        notifyListeners();
      }
      return;
    }

    if ('+-*/'.contains(_expression[_expression.length - 1])) {
      if (_expression.length == 1 && _expression == '-') return;
      _expression =
          '${_expression.substring(0, _expression.length - 1)}$operator';
    } else {
      if (_expression.length >= CalculatorConstants.maxExpressionLength) return;
      if (_expression.endsWith('.')) {
        _expression += '0';
        _currentEntry += '0';
      }
      _expression += operator;
    }
    _currentEntry = '';
    _entryStart = _expression.length;
    notifyListeners();
  }

  void toggleSign() {
    if (_hasError) return;
    if (_justEvaluated) {
      _expression = _display;
      _currentEntry = _display;
      _entryStart = 0;
      _justEvaluated = false;
    }
    if (_currentEntry.isEmpty) {
      if (_expression.isEmpty ||
          '+-*/'.contains(_expression[_expression.length - 1])) {
        if (_expression.length >= CalculatorConstants.maxExpressionLength)
          return;
        _entryStart = _expression.length;
        _currentEntry = '-';
        _expression += '-';
      } else {
        _currentEntry = _expression;
        _entryStart = 0;
        _currentEntry = _currentEntry.startsWith('-')
            ? _currentEntry.substring(1)
            : '-$_currentEntry';
        _expression = _currentEntry;
      }
    } else {
      _currentEntry = _currentEntry.startsWith('-')
          ? _currentEntry.substring(1)
          : '-$_currentEntry';
      _replaceCurrentEntryInExpression();
    }
    _display = _currentEntry.isEmpty ? '0' : _currentEntry;
    notifyListeners();
  }

  void inputPercent() {
    if (_hasError || _currentEntry.isEmpty || _currentEntry == '-') return;
    if (_justEvaluated) {
      _expression = _display;
      _currentEntry = _display;
      _entryStart = 0;
      _justEvaluated = false;
    }
    final value = double.tryParse(_currentEntry);
    if (value == null) return;
    _currentEntry = CalculatorEngine.formatNumber(value / 100);
    _replaceCurrentEntryInExpression();
    _display = _currentEntry;
    notifyListeners();
  }

  void deleteLast() {
    if (_hasError || _expression.isEmpty) return;
    if (_justEvaluated) {
      _expression = _display;
      _currentEntry = _display;
      _entryStart = 0;
      _justEvaluated = false;
    }

    if (_currentEntry.isNotEmpty) {
      _currentEntry = _currentEntry.substring(0, _currentEntry.length - 1);
      _expression = '${_expression.substring(0, _entryStart)}$_currentEntry';
      _display = _currentEntry.isEmpty ? '0' : _currentEntry;
    } else {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_expression.isNotEmpty &&
          !'+-*/'.contains(_expression[_expression.length - 1])) {
        final match = RegExp(r'(-?\d*\.?\d*)$').firstMatch(_expression);
        _currentEntry = match?.group(0) ?? '';
        _entryStart = match?.start ?? _expression.length;
      } else {
        _entryStart = _expression.length;
      }
      _display = _currentEntry.isEmpty ? '0' : _currentEntry;
    }
    notifyListeners();
  }

  void evaluate() {
    if (_hasError || _expression.isEmpty) return;
    try {
      _display = CalculatorEngine.formatNumber(
        CalculatorEngine.evaluate(_expression),
      );
      _history.insert(
        0,
        CalculationHistoryEntry(
          expression: _formatExpression(_expression),
          result: _display,
        ),
      );
      if (_history.length > _maxHistoryEntries) _history.removeLast();
      _justEvaluated = true;
      _currentEntry = _display;
    } on CalculatorException catch (error) {
      _display = error.message;
      _hasError = true;
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void restoreHistoryEntry(CalculationHistoryEntry entry) {
    _expression = entry.result;
    _display = entry.result;
    _currentEntry = entry.result;
    _entryStart = 0;
    _justEvaluated = true;
    _hasError = false;
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _display = '0';
    _currentEntry = '';
    _entryStart = 0;
    _justEvaluated = false;
    _hasError = false;
    notifyListeners();
  }

  void _startFreshEntry() {
    _expression = '';
    _currentEntry = '';
    _entryStart = 0;
    _display = '0';
    _justEvaluated = false;
  }

  void _replaceCurrentEntryInExpression() {
    final prefix = _expression.substring(0, _entryStart);
    _expression = '$prefix$_currentEntry';
  }

  static String _formatExpression(String value) =>
      value.replaceAllMapped(RegExp(r'(?<![eE])([+*/-])'), (match) {
        return switch (match[1]) {
          '*' => ' × ',
          '/' => ' ÷ ',
          '+' => ' + ',
          '-' => ' − ',
          _ => match[0]!,
        };
      }).trim();
}

class CalculationHistoryEntry {
  const CalculationHistoryEntry({required this.expression, required this.result});

  final String expression;
  final String result;
}

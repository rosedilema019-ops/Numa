import 'package:flutter/material.dart';

import '../core/constants/calculator_constants.dart';
import '../logic/calculator_state.dart';
import '../widgets/button_grid.dart';
import '../widgets/display_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorState _calculator = CalculatorState();

  @override
  void dispose() {
    _calculator.dispose();
    super.dispose();
  }

  void _handleAction(String action) {
    switch (action) {
      case 'clear':
        _calculator.clear();
      case 'delete':
        _calculator.deleteLast();
      case 'percent':
        _calculator.inputPercent();
      case 'sign':
        _calculator.toggleSign();
      case 'decimal':
        _calculator.inputDecimal();
      case 'equals':
        _calculator.evaluate();
      case 'add':
        _calculator.inputOperator('+');
      case 'subtract':
        _calculator.inputOperator('-');
      case 'multiply':
        _calculator.inputOperator('*');
      case 'divide':
        _calculator.inputOperator('/');
      default:
        if (action.startsWith('digit_')) {
          _calculator.inputDigit(action.substring('digit_'.length));
        }
    }
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _CalculatorHistorySheet(
        calculator: _calculator,
        onSelect: (entry) {
          Navigator.pop(context);
          _calculator.restoreHistoryEntry(entry);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CalculatorConstants.maxCalculatorWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(CalculatorConstants.pagePadding),
              child: AnimatedBuilder(
                animation: _calculator,
                builder: (context, _) => LayoutBuilder(
                  builder: (context, constraints) {
                    final landscape =
                        constraints.maxWidth > constraints.maxHeight;
                    final display = DisplayPanel(
                      expression: _calculator.expression,
                      display: _calculator.display,
                      hasError: _calculator.hasError,
                      onShowHistory: _showHistory,
                    );
                    final grid = ButtonGrid(onAction: _handleAction);

                    if (landscape) {
                      return Row(
                        children: [
                          Expanded(flex: 2, child: display),
                          Expanded(flex: 3, child: grid),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        const Spacer(flex: 2),
                        Expanded(flex: 3, child: display),
                        Expanded(flex: 5, child: grid),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorHistorySheet extends StatelessWidget {
  const _CalculatorHistorySheet({
    required this.calculator,
    required this.onSelect,
  });

  final CalculatorState calculator;
  final ValueChanged<CalculationHistoryEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: calculator,
      builder: (context, _) {
        final entries = calculator.history;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Clear history',
                        onPressed: entries.isEmpty ? null : calculator.clearHistory,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            'No calculations yet',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 24,
                            endIndent: 24,
                          ),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return ListTile(
                              title: Text(entry.expression),
                              trailing: Text(
                                entry.result,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onTap: () => onSelect(entry),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

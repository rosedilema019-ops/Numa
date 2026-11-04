import 'package:flutter/material.dart';

import 'calculator_mascot.dart';

class DisplayPanel extends StatelessWidget {
  const DisplayPanel({
    required this.expression,
    required this.display,
    required this.hasError,
    required this.onShowHistory,
    super.key,
  });

  final String expression;
  final String display;
  final bool hasError;
  final VoidCallback onShowHistory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CalculatorMascot(),
              IconButton(
                tooltip: 'History',
                onPressed: onShowHistory,
                icon: const Icon(Icons.history),
              ),
            ],
          ),
          const Spacer(),
          _ScrollableText(
            text: expression,
            baseFontSize: 22,
            minimumFontSize: 16,
            color: colors.onSurfaceVariant,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          _ScrollableText(
            text: display,
            key: const ValueKey('calculator_result'),
            baseFontSize: hasError ? 36 : 64,
            minimumFontSize: hasError ? 24 : 32,
            color: hasError ? colors.error : colors.onSurface,
            textAlign: TextAlign.right,
            weight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

class _ScrollableText extends StatelessWidget {
  const _ScrollableText({
    super.key,
    required this.text,
    required this.baseFontSize,
    required this.minimumFontSize,
    required this.color,
    required this.textAlign,
    this.weight = FontWeight.w400,
  });

  final String text;
  final double baseFontSize;
  final double minimumFontSize;
  final Color color;
  final TextAlign textAlign;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize =
            (baseFontSize - (text.length > 12 ? text.length - 12 : 0))
                .clamp(minimumFontSize, baseFontSize)
                .toDouble();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              textAlign: textAlign,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: weight,
                height: 1.1,
              ),
            ),
          ),
        );
      },
    );
  }
}

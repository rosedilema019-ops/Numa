import 'package:flutter/material.dart';

enum CalculatorButtonKind { number, operator, utility, equals }

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    required this.kind,
    required this.keyName,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final CalculatorButtonKind kind;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (kind) {
      CalculatorButtonKind.number => (
        colors.surfaceContainerHigh,
        colors.onSurface,
      ),
      CalculatorButtonKind.operator => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      CalculatorButtonKind.utility => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      CalculatorButtonKind.equals => (colors.primary, colors.onPrimary),
    };

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.expand(
          child: FilledButton(
            key: ValueKey(keyName),
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              padding: EdgeInsets.zero,
              minimumSize: const Size(56, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

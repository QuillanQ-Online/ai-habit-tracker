import 'package:flutter/material.dart';

/// Shared layout for onboarding wizard steps.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.child,
    required this.onPrimaryPressed,
    required this.primaryLabel,
    this.onBack,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.tertiaryLabel,
    this.onTertiaryPressed,
    this.isPrimaryEnabled = true,
    this.helperText,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final Widget child;
  final VoidCallback? onPrimaryPressed;
  final String primaryLabel;
  final VoidCallback? onBack;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String? tertiaryLabel;
  final VoidCallback? onTertiaryPressed;
  final bool isPrimaryEnabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalSteps == 0 ? 0.0 : (stepIndex + 1) / totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${stepIndex + 1} of $totalSteps',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: child,
              ),
            ),
          ),
          if (helperText != null) ...[
            Text(
              helperText!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tertiaryLabel != null && onTertiaryPressed != null) ...[
                TextButton(
                  onPressed: onTertiaryPressed,
                  child: Text(tertiaryLabel!),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (onBack != null)
                    OutlinedButton(
                      onPressed: onBack,
                      child: Text(secondaryLabel ?? 'Back'),
                    ),
                  if (onBack != null) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isPrimaryEnabled ? onPrimaryPressed : null,
                      child: Text(primaryLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

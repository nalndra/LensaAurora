import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Shared progress stepper for the Gaze → Speech → Motor screening flow.
/// Ties the three otherwise-separate full-screen routes together as one
/// visible sequence instead of each page silently claiming "Step N" in
/// plain text.
class TestStepHeader extends StatelessWidget {
  const TestStepHeader({super.key, required this.currentStep});

  /// 1-indexed: 1 = Gaze, 2 = Speech, 3 = Motor.
  final int currentStep;

  static const _labels = ['Gaze', 'Bicara', 'Motorik'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftStep = (i ~/ 2) + 1;
            final filled = leftStep < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: filled ? AppTheme.accentGreen : AppTheme.fieldFill,
              ),
            );
          }

          final step = (i ~/ 2) + 1;
          final isDone = step < currentStep;
          final isCurrent = step == currentStep;
          final active = isDone || isCurrent;

          return Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppTheme.accentGreen : Colors.white,
                  border: Border.all(
                    color: active
                        ? AppTheme.accentGreen
                        : AppTheme.textLight.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        )
                      : Text(
                          '$step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? Colors.white
                                : AppTheme.textLight,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step - 1],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppTheme.textDark : AppTheme.textLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

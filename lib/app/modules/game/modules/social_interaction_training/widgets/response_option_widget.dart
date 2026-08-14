import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../models/social_scenario_model.dart';

class ResponseOptionWidget extends StatelessWidget {
  final SocialResponse response;
  final bool isSelected;
  final bool showFeedback;
  final VoidCallback onSelected;

  const ResponseOptionWidget({
    super.key,
    required this.response,
    required this.isSelected,
    required this.showFeedback,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showFeedback ? null : onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _getBackgroundColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBorderColor(),
                      width: 2,
                    ),
                    color: isSelected ? _getBorderColor() : Colors.transparent,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    response.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.accentGreenDark : AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: (showFeedback && isSelected)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 260),
                        opacity: showFeedback && isSelected ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: response.isAppropriate
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                response.isAppropriate
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: response.isAppropriate
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  response.explanation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: response.isAppropriate
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (!isSelected) return Colors.grey[300]!;
    if (showFeedback) {
      return response.isAppropriate ? Colors.green : Colors.red;
    }
    return AppTheme.accentGreenDark;
  }

  Color _getBackgroundColor() {
    if (!isSelected) return Colors.transparent;
    if (showFeedback) {
      return response.isAppropriate
          ? Colors.green.withValues(alpha: 0.05)
          : Colors.red.withValues(alpha: 0.05);
    }
    return AppTheme.accentGreen.withValues(alpha: 0.05);
  }
}

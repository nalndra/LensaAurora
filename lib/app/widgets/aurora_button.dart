import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/accessibility_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Full-width gradient CTA with a soft colored glow shadow. Used in place of
/// the old flat-bordered ElevatedButton across auth/onboarding flows.
class AuroraPrimaryButton extends StatelessWidget {
  const AuroraPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 56,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final double height;
  final Widget? icon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final a11y = Get.isRegistered<AccessibilityController>()
        ? Get.find<AccessibilityController>()
        : null;
    final activeGradient = gradient ?? AppTheme.accentGradient;
    final useOutline = a11y?.useOutline.value ?? false;
    final foreground = useOutline ? activeGradient.colors.last : Colors.white;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _enabled ? 1 : 0.6,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppTheme.br16,
          color: useOutline ? Colors.white : null,
          gradient: useOutline ? null : activeGradient,
          border: useOutline
              ? Border.all(color: activeGradient.colors.last, width: 2)
              : null,
          boxShadow: _enabled && !useOutline
              ? AppTheme.shadowButton(activeGradient.colors.last)
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppTheme.br16,
          child: InkWell(
            borderRadius: AppTheme.br16,
            onTap: _enabled ? onPressed : null,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[icon!, const SizedBox(width: 10)],
                        Text(
                          label,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular, shadow-elevated (borderless) social/auth provider button.
class AuroraSocialButton extends StatelessWidget {
  const AuroraSocialButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 56,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppTheme.shadowCard,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/accessibility_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Draggable round button. Tap opens Outline + Accent (and extra a11y) beside it.
class AccessibilityOverlay extends StatelessWidget {
  const AccessibilityOverlay({super.key});

  static const double _fabSize = 52;
  static const double _panelWidth = 248;
  static const double _panelGap = 10;
  static const double _edgeMargin = 8;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccessibilityController>();
    final screenSize = MediaQuery.sizeOf(context);

    return Obx(() {
      final isOpen = controller.isPanelOpen.value;
      final offsetX = controller.offsetX.value;
      final offsetY = controller.offsetY.value;
      final onRightHalf = offsetX < screenSize.width / 2;
      final accent = controller.accentColor;
      final animDuration = controller.isDragging.value
          ? Duration.zero
          : const Duration(milliseconds: 220);

      final button = _DraggableAccessibilityButton(
        controller: controller,
        screenSize: screenSize,
        isOpen: isOpen,
        accent: accent,
      );

      // Button edges in screen coordinates (it's anchored via `right`).
      final buttonLeft = screenSize.width - offsetX - _fabSize;
      final buttonRight = screenSize.width - offsetX;

      // Anchor the panel beside the button, but clamp it within the
      // screen so it can never be pushed off-screen — e.g. when the
      // button is snapped to the left edge, opening the panel to its
      // "left" would otherwise push most of the panel off-screen.
      double? panelLeft;
      double? panelRightInset;
      if (onRightHalf) {
        var panelRight = buttonLeft - _panelGap;
        var left = panelRight - _panelWidth;
        if (left < _edgeMargin) {
          left = _edgeMargin;
          panelRight = left + _panelWidth;
        }
        panelRightInset = screenSize.width - panelRight;
      } else {
        var left = buttonRight + _panelGap;
        var right = left + _panelWidth;
        if (right > screenSize.width - _edgeMargin) {
          right = screenSize.width - _edgeMargin;
          left = right - _panelWidth;
        }
        panelLeft = left;
      }

      return Positioned.fill(
        child: Stack(
          children: [
            if (isOpen)
              AnimatedPositioned(
                duration: animDuration,
                curve: Curves.easeOut,
                left: panelLeft,
                right: panelRightInset,
                bottom: offsetY,
                child: _SettingsPanel(controller: controller),
              ),
            AnimatedPositioned(
              duration: animDuration,
              curve: Curves.easeOut,
              right: offsetX,
              bottom: offsetY,
              child: button,
            ),
          ],
        ),
      );
    });
  }
}

class _DraggableAccessibilityButton extends StatefulWidget {
  const _DraggableAccessibilityButton({
    required this.controller,
    required this.screenSize,
    required this.isOpen,
    required this.accent,
  });

  final AccessibilityController controller;
  final Size screenSize;
  final bool isOpen;
  final Color accent;

  @override
  State<_DraggableAccessibilityButton> createState() =>
      _DraggableAccessibilityButtonState();
}

class _DraggableAccessibilityButtonState
    extends State<_DraggableAccessibilityButton> {
  Offset _dragTotal = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {
        _dragTotal = Offset.zero;
        widget.controller.isDragging.value = true;
      },
      onPanUpdate: (details) {
        _dragTotal += details.delta;
        widget.controller.updatePosition(
          details.delta.dx,
          details.delta.dy,
          widget.screenSize,
        );
      },
      onPanEnd: (_) {
        widget.controller.isDragging.value = false;
        if (_dragTotal.distance < 10) {
          widget.controller.togglePanel();
        } else {
          widget.controller.snapToNearestEdge(widget.screenSize);
        }
        _dragTotal = Offset.zero;
      },
      child: Semantics(
        label:
            'Aksesibilitas. Geser untuk pindah, ketuk untuk Outline dan Accent.',
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AccessibilityOverlay._fabSize,
          height: AccessibilityOverlay._fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isOpen ? widget.accent : Colors.white,
            border: Border.all(color: widget.accent, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.accessibility_new_rounded,
            color: widget.isOpen ? Colors.white : widget.accent,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.controller});

  final AccessibilityController controller;

  @override
  Widget build(BuildContext context) {
    final accent = controller.accentColor;

    return ConstrainedBox(
      // Cap the panel's height and let it scroll instead of overflowing
      // off the top of the screen when the button is dragged up high.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Container(
        width: 248,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.accessibility_new_rounded, color: accent, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Aksesibilitas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: controller.closePanel,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Obx(() => _ToggleRow(
                  label: 'Outline',
                  subtitle: 'Tepi tombol & kartu lebih tegas',
                  value: controller.useOutline.value,
                  onChanged: controller.setOutline,
                  accent: accent,
                )),
            Obx(() => _ToggleRow(
                  label: 'Accent',
                  subtitle: controller.useAltAccent.value
                      ? 'Warna biru'
                      : 'Warna hijau tosca',
                  value: controller.useAltAccent.value,
                  onChanged: controller.setAltAccent,
                  accent: accent,
                )),
            const Divider(height: 20),
            Obx(() => _ToggleRow(
                  label: 'Opacity',
                  subtitle: 'Redakan intensitas layar',
                  value: controller.reduceOpacity.value,
                  onChanged: controller.setOpacityEnabled,
                  accent: accent,
                )),
            Obx(() {
              if (!controller.reduceOpacity.value) {
                return const SizedBox.shrink();
              }
              return Slider(
                value: controller.opacityLevel.value,
                min: 0.5,
                max: 1.0,
                activeColor: accent,
                inactiveColor: AppTheme.lightCyan,
                onChanged: controller.setOpacityLevel,
              );
            }),
            Obx(() => _ToggleRow(
                  label: 'Kontras',
                  subtitle: 'Teks dan tepi lebih jelas',
                  value: controller.highContrast.value,
                  onChanged: controller.setHighContrast,
                  accent: accent,
                )),
            const SizedBox(height: 10),
            const Text(
              'Font',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AccessibilityFont.values.map((font) {
                    final selected = controller.selectedFont.value == font;
                    return ChoiceChip(
                      label: Text(
                        font.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      selected: selected,
                      selectedColor: accent,
                      backgroundColor: AppTheme.surfaceTint,
                      side: BorderSide(
                        color: selected ? accent : AppTheme.primaryBlue,
                      ),
                      onSelected: (_) => controller.setFont(font),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 8),
            Obx(() => Slider(
                  value: controller.fontScale.value,
                  min: 0.85,
                  max: 1.5,
                  divisions: 13,
                  activeColor: accent,
                  inactiveColor: AppTheme.lightCyan,
                  onChanged: controller.setFontScale,
                )),
          ],
        ),
        ),
      ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: accent,
            activeTrackColor: accent.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

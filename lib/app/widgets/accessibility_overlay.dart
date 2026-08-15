import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/accessibility_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Draggable round button. Tap opens Outline + Accent (and extra a11y) panel beside it.
class AccessibilityOverlay extends StatelessWidget {
  const AccessibilityOverlay({super.key});

  static const double _fabSize = 52;
  static const double _panelGap = 12;
  static const double _edgeMargin = 12;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccessibilityController>();
    final screenSize = MediaQuery.sizeOf(context);

    return Obx(() {
      final isOpen = controller.isPanelOpen.value;
      final offsetX = controller.offsetX.value;
      final offsetY = controller.offsetY.value;
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

      // Dynamic responsive panel width (clamps between 280 and 320 for clean mobile/tablet fit)
      final panelWidth = (screenSize.width - 32).clamp(280.0, 320.0);
      final buttonCenter = screenSize.width - offsetX - (_fabSize / 2);
      final onRightHalf = buttonCenter > screenSize.width / 2;

      double? panelLeft;
      double? panelRightInset;

      if (onRightHalf) {
        // Position panel to the left of the button
        final panelRight = screenSize.width - offsetX + _panelGap;
        panelRightInset = panelRight.clamp(_edgeMargin, screenSize.width - panelWidth - _edgeMargin);
      } else {
        // Position panel to the right of the button
        final leftPos = offsetX + _fabSize + _panelGap;
        panelLeft = leftPos.clamp(_edgeMargin, screenSize.width - panelWidth - _edgeMargin);
      }

      // Clamp vertical offset so the panel never overflows top of screen
      final maxOffsetY = (screenSize.height * 0.15).clamp(16.0, 120.0);
      final clampedBottom = offsetY.clamp(16.0, screenSize.height - maxOffsetY);

      return Positioned.fill(
        child: Stack(
          children: [
            if (isOpen)
              AnimatedPositioned(
                duration: animDuration,
                curve: Curves.easeOut,
                left: panelLeft,
                right: panelRightInset,
                bottom: clampedBottom,
                child: _SettingsPanel(
                  controller: controller,
                  panelWidth: panelWidth,
                ),
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
            'Aksesibilitas. Geser untuk pindah, ketuk untuk membuka menu aksesibilitas.',
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AccessibilityOverlay._fabSize,
          height: AccessibilityOverlay._fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isOpen ? widget.accent : Colors.white,
            border: Border.all(color: widget.accent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
  const _SettingsPanel({
    required this.controller,
    required this.panelWidth,
  });

  final AccessibilityController controller;
  final double panelWidth;

  @override
  Widget build(BuildContext context) {
    final accent = controller.accentColor;
    final screenSize = MediaQuery.sizeOf(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: panelWidth,
        maxHeight: screenSize.height * 0.72,
      ),
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: Container(
          width: panelWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
            boxShadow: AppTheme.shadowLg,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.accessibility_new_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Aksesibilitas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: controller.closePanel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 12),
                const SizedBox(height: 4),

                // Toggles
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
                          ? 'Warna biru utama'
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Tingkat Opasitas: ${(controller.opacityLevel.value * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                      Slider(
                        value: controller.opacityLevel.value,
                        min: 0.5,
                        max: 1.0,
                        activeColor: accent,
                        inactiveColor: AppTheme.lightCyan,
                        onChanged: controller.setOpacityLevel,
                      ),
                    ],
                  );
                }),
                Obx(() => _ToggleRow(
                      label: 'Kontras',
                      subtitle: 'Teks dan tepi lebih jelas',
                      value: controller.highContrast.value,
                      onChanged: controller.setHighContrast,
                      accent: accent,
                    )),
                const Divider(height: 20),

                // Font Family Section
                const Text(
                  'Jenis Font',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          selected: selected,
                          selectedColor: accent,
                          backgroundColor: AppTheme.surfaceTint,
                          side: BorderSide(
                            color: selected ? accent : AppTheme.primaryBlue.withValues(alpha: 0.5),
                          ),
                          onSelected: (_) => controller.setFont(font),
                        );
                      }).toList(),
                    )),
                const SizedBox(height: 14),

                // Font Size Scale Section
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ukuran Teks',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${(controller.fontScale.value * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 4),
                Obx(() => Slider(
                      value: controller.fontScale.value,
                      min: 0.85,
                      max: 1.4,
                      divisions: 11,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: accent,
            thumbColor: WidgetStateProperty.all(Colors.white),
            inactiveTrackColor: AppTheme.fieldFill,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

import 'package:flauncher/models/tv_appearance_config.dart';
import 'package:flutter/material.dart';

/// Shared 60 fps D-pad focus overlay & dimming layer used by both [AppCard]
/// and [WatchNextCard] to guarantee visual consistency and avoid duplicated logic.
class TvFocusOverlay extends StatelessWidget {
  final TvAppearanceConfig appearance;
  final bool isHighlighted;
  final AnimationController pulseController;

  const TvFocusOverlay({
    super.key,
    required this.appearance,
    required this.isHighlighted,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final double borderWidth = appearance.resolvedBorderWidth;
    final bool showBorder =
        isHighlighted && !appearance.hideHighlightOutline && borderWidth > 0;

    final bool shouldPulse = showBorder &&
        appearance.highlightAnimationEnabled &&
        appearance.customBorderWidth == null &&
        (appearance.theme == 'modern' ||
            appearance.theme == 'squircle' ||
            appearance.theme == 'capsule');

    if (shouldPulse) {
      if (!pulseController.isAnimating) {
        pulseController.repeat(reverse: true);
      }
    } else if (pulseController.isAnimating) {
      pulseController.stop();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Subtle color dimming on unfocused tiles (cheaper than Opacity widget with Skia/Impeller).
        IgnorePointer(
          child: AnimatedContainer(
            duration: appearance.transitionAnimationEnabled
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: appearance.borderRadius,
              color: Colors.black.withOpacity(isHighlighted ? 0.0 : 0.14),
            ),
          ),
        ),
        if (showBorder)
          shouldPulse
              ? AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, _) {
                    final double opacity = 0.55 + (pulseController.value * 0.45);
                    return _buildDualBorder(borderWidth, opacity);
                  },
                )
              : _buildCrispBorder(borderWidth),
      ],
    );
  }

  Widget _buildCrispBorder(double width) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: appearance.borderRadius,
          border: Border.all(
            color: appearance.accentColor,
            width: width,
          ),
        ),
      ),
    );
  }

  Widget _buildDualBorder(double width, double opacity) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: appearance.borderRadius,
              border: Border.all(
                color: appearance.accentColor.withOpacity(opacity),
                width: width,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: appearance.innerBorderRadius,
                border: Border.all(
                  color: Colors.black.withOpacity(opacity * 0.75),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

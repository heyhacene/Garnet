import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';

/// Immutable snapshot of all Home TV appearance & D-pad focus parameters.
///
/// Designed for use with `context.select<SettingsService, TvAppearanceConfig>(...)`
/// so cards only rebuild when a visual parameter actually changes.
class TvAppearanceConfig {
  final String theme;
  final Color accentColor;
  final bool hideHighlightOutline;
  final bool highlightAnimationEnabled;
  final bool transitionAnimationEnabled;
  final double? customFocusScale;
  final int? customCornerRadius;
  final double? customBorderWidth;
  final double focusGlowIntensity;
  final double rowVerticalSpacing;
  final double cardHorizontalSpacing;
  final double wallpaperScrimIntensity;
  final double wallpaperBlurSigma;
  final double homeTopSpacing;

  const TvAppearanceConfig({
    required this.theme,
    required this.accentColor,
    required this.hideHighlightOutline,
    required this.highlightAnimationEnabled,
    required this.transitionAnimationEnabled,
    required this.customFocusScale,
    required this.customCornerRadius,
    required this.customBorderWidth,
    required this.focusGlowIntensity,
    required this.rowVerticalSpacing,
    required this.cardHorizontalSpacing,
    required this.wallpaperScrimIntensity,
    required this.wallpaperBlurSigma,
    required this.homeTopSpacing,
  });

  factory TvAppearanceConfig.fromSettings(SettingsService settings) {
    final String rawHex = settings.accentColorHex;
    final Color accent = rawHex.length == 6
        ? Color(int.tryParse('0xFF$rawHex') ?? 0xFFE11D48)
        : const Color(0xFFE11D48);
    final String activeTheme = settings.themes.isEmpty ? 'modern' : settings.themes;

    return TvAppearanceConfig(
      theme: activeTheme,
      accentColor: accent,
      hideHighlightOutline: settings.hideHighlightOutlineOnHomescreen,
      highlightAnimationEnabled: settings.appHighlightAnimationEnabled,
      transitionAnimationEnabled: settings.appSelectorTransitionAnimationEnabled,
      customFocusScale: settings.cardFocusScale,
      customCornerRadius: settings.customCardCornerRadius,
      customBorderWidth: settings.customFocusBorderWidth,
      focusGlowIntensity: settings.focusGlowIntensity.clamp(0.0, 1.0),
      rowVerticalSpacing: settings.rowVerticalSpacing > 0
          ? settings.rowVerticalSpacing.clamp(8.0, 40.0)
          : 16.0,
      cardHorizontalSpacing: settings.cardHorizontalSpacing > 0
          ? settings.cardHorizontalSpacing.clamp(8.0, 32.0)
          : 16.0,
      wallpaperScrimIntensity: settings.wallpaperScrimIntensity > 0
          ? settings.wallpaperScrimIntensity.clamp(0.15, 0.90)
          : 0.45,
      wallpaperBlurSigma: settings.wallpaperBlurSigma.clamp(0.0, 16.0),
      homeTopSpacing: settings.homeTopSpacing.clamp(0.0, 200.0),
    );
  }

  double get resolvedCornerRadius {
    if (customCornerRadius != null) {
      return customCornerRadius!.clamp(0, 28).toDouble();
    }
    switch (theme) {
      case 'premium':
        return 16.0;
      case 'glow':
        return 12.0;
      case 'squircle':
        return 24.0;
      case 'classic':
        return 0.0;
      case 'minimal':
        return 4.0;
      case 'capsule':
        return 100.0;
      case 'modern':
      default:
        return 12.0;
    }
  }

  BorderRadius get borderRadius {
    final r = resolvedCornerRadius;
    return r <= 0 ? BorderRadius.zero : BorderRadius.circular(r);
  }

  BorderRadius get innerBorderRadius {
    final r = (resolvedCornerRadius - 2.0).clamp(0.0, 100.0);
    return r <= 0 ? BorderRadius.zero : BorderRadius.circular(r);
  }

  double get resolvedFocusScale {
    if (customFocusScale != null && customFocusScale! >= 1.0) {
      return customFocusScale!.clamp(1.0, 1.18);
    }
    switch (theme) {
      case 'premium':
        return 1.15;
      case 'classic':
        return 1.0;
      case 'minimal':
        return 1.05;
      case 'glow':
      case 'squircle':
        return 1.12;
      case 'modern':
      default:
        return 1.10;
    }
  }

  double get resolvedBorderWidth {
    if (customBorderWidth != null) {
      return customBorderWidth!.clamp(0.0, 5.0);
    }
    switch (theme) {
      case 'premium':
        return 0.0;
      case 'classic':
        return 4.0;
      case 'minimal':
        return 2.0;
      case 'glow':
        return 3.0;
      case 'modern':
      default:
        return 2.5;
    }
  }

  double effectiveScaleForWidth(double maxWidth, {required bool isHighlighted}) {
    if (!isHighlighted) return 1.0;
    double scale = resolvedFocusScale;
    if (maxWidth > 0) {
      // Keep horizontal expansion strictly inside neighbor spacing to avoid clipping.
      final double maxHorizontalExpansion = (cardHorizontalSpacing * 2.0 - 4.0).clamp(10.0, 48.0);
      final double maxScale = 1.0 + (maxHorizontalExpansion / maxWidth);
      if (scale > maxScale) {
        scale = maxScale;
      }
    }
    return scale;
  }

  double elevationForFocus(bool isHighlighted) {
    if (!isHighlighted) return 0.0;
    if (theme == 'minimal') return 6.0;
    if (theme == 'classic') return 8.0;
    return 14.0;
  }

  List<BoxShadow>? focusShadows(bool isHighlighted) {
    if (!isHighlighted) return null;
    final double glow = focusGlowIntensity;
    final List<BoxShadow> shadows = [
      const BoxShadow(
        color: Color(0x99000000),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ];
    if (glow > 0.01) {
      shadows.add(
        BoxShadow(
          color: accentColor.withOpacity((glow * 0.65).clamp(0.0, 0.85)),
          blurRadius: 10.0 + (glow * 18.0),
          spreadRadius: glow * 1.5,
        ),
      );
    }
    return shadows;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TvAppearanceConfig &&
        other.theme == theme &&
        other.accentColor == accentColor &&
        other.hideHighlightOutline == hideHighlightOutline &&
        other.highlightAnimationEnabled == highlightAnimationEnabled &&
        other.transitionAnimationEnabled == transitionAnimationEnabled &&
        other.customFocusScale == customFocusScale &&
        other.customCornerRadius == customCornerRadius &&
        other.customBorderWidth == customBorderWidth &&
        other.focusGlowIntensity == focusGlowIntensity &&
        other.rowVerticalSpacing == rowVerticalSpacing &&
        other.cardHorizontalSpacing == cardHorizontalSpacing &&
        other.wallpaperScrimIntensity == wallpaperScrimIntensity &&
        other.wallpaperBlurSigma == wallpaperBlurSigma &&
        other.homeTopSpacing == homeTopSpacing;
  }

  @override
  int get hashCode => Object.hash(
        theme,
        accentColor,
        hideHighlightOutline,
        highlightAnimationEnabled,
        transitionAnimationEnabled,
        customFocusScale,
        customCornerRadius,
        customBorderWidth,
        focusGlowIntensity,
        rowVerticalSpacing,
        cardHorizontalSpacing,
        wallpaperScrimIntensity,
        wallpaperBlurSigma,
        homeTopSpacing,
      );
}

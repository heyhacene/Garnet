import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/tv_appearance_config.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/focusable_slider_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppearanceTuningPage extends StatelessWidget {
  static const String routeName = "appearance_tuning_panel";

  const AppearanceTuningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();
    final appearance = TvAppearanceConfig.fromSettings(settings);

    return Column(
      children: [
        Text(localizations.cardsAndFocus, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          localizations.dpadAdjustHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              FocusableSliderTile(
                autofocus: true,
                icon: Icons.zoom_out_map,
                title: localizations.focusScale,
                valueLabel: '${(appearance.resolvedFocusScale * 100).round()}%',
                value: appearance.resolvedFocusScale,
                min: 1.0,
                max: 1.18,
                step: 0.02,
                onChanged: (v) => settings.setCardFocusScale(v),
              ),
              FocusableSliderTile(
                icon: Icons.rounded_corner,
                title: localizations.cardCornerRadius,
                valueLabel: '${appearance.resolvedCornerRadius.round()} dp',
                value: appearance.resolvedCornerRadius.clamp(0.0, 28.0),
                min: 0,
                max: 28,
                step: 2,
                onChanged: (v) => settings.setCustomCardCornerRadius(v.round()),
              ),
              FocusableSliderTile(
                icon: Icons.border_style,
                title: localizations.focusBorderWidth,
                valueLabel: '${appearance.resolvedBorderWidth.toStringAsFixed(1)} dp',
                value: appearance.resolvedBorderWidth,
                min: 0.0,
                max: 5.0,
                step: 0.5,
                onChanged: (v) => settings.setCustomFocusBorderWidth(v),
              ),
              FocusableSliderTile(
                icon: Icons.flare,
                title: localizations.focusGlowIntensity,
                valueLabel: '${(appearance.focusGlowIntensity * 100).round()}%',
                value: appearance.focusGlowIntensity,
                min: 0.0,
                max: 1.0,
                step: 0.1,
                onChanged: (v) => settings.setFocusGlowIntensity(v),
              ),
              const Divider(),
              FocusableSliderTile(
                icon: Icons.view_agenda_outlined,
                title: localizations.rowVerticalSpacing,
                valueLabel: '${appearance.rowVerticalSpacing.round()} dp',
                value: appearance.rowVerticalSpacing,
                min: 8,
                max: 40,
                step: 4,
                onChanged: (v) => settings.setRowVerticalSpacing(v),
              ),
              FocusableSliderTile(
                icon: Icons.view_column_outlined,
                title: localizations.cardHorizontalSpacing,
                valueLabel: '${appearance.cardHorizontalSpacing.round()} dp',
                value: appearance.cardHorizontalSpacing,
                min: 8,
                max: 32,
                step: 4,
                onChanged: (v) => settings.setCardHorizontalSpacing(v),
              ),
              FocusableSliderTile(
                icon: Icons.vertical_align_bottom,
                title: localizations.homeTopSpacing,
                valueLabel: '${appearance.homeTopSpacing.round()} dp',
                value: appearance.homeTopSpacing,
                min: 0,
                max: 200,
                step: 20,
                onChanged: (v) => settings.setHomeTopSpacing(v),
              ),
              const Divider(),
              FocusableSliderTile(
                icon: Icons.contrast,
                title: localizations.wallpaperDimming,
                valueLabel: '${(appearance.wallpaperScrimIntensity * 100).round()}%',
                value: appearance.wallpaperScrimIntensity,
                min: 0.15,
                max: 0.90,
                step: 0.05,
                onChanged: (v) => settings.setWallpaperScrimIntensity(v),
              ),
              FocusableSliderTile(
                icon: Icons.blur_on,
                title: localizations.wallpaperBlur,
                valueLabel: '${appearance.wallpaperBlurSigma.round()} px',
                value: appearance.wallpaperBlurSigma,
                min: 0,
                max: 16,
                step: 1,
                onChanged: (v) => settings.setWallpaperBlurSigma(v),
              ),
              const Divider(),
              FocusableSettingsTile(
                leading: const Icon(Icons.restore),
                title: Text(
                  localizations.resetAppearanceDefaults,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () => settings.resetAppearanceDefaults(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

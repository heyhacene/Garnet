import 'package:flauncher/models/tv_appearance_config.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  });

  test('TvAppearanceConfig resolves Cinema defaults and respects custom overrides', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    final defaults = TvAppearanceConfig.fromSettings(settings);
    expect(defaults.resolvedFocusScale, 1.10);
    expect(defaults.resolvedCornerRadius, 12.0);
    expect(defaults.focusGlowIntensity, 0.60);
    expect(defaults.rowVerticalSpacing, 16.0);
    expect(defaults.cardHorizontalSpacing, 16.0);
    expect(defaults.wallpaperScrimIntensity, 0.68);
    expect(defaults.wallpaperBlurSigma, 0.0);
    expect(defaults.homeTopSpacing, 40.0);

    await settings.setCardFocusScale(1.16);
    await settings.setCustomCardCornerRadius(20);
    await settings.setCustomFocusBorderWidth(3.5);
    await settings.setFocusGlowIntensity(0.8);
    await settings.setRowVerticalSpacing(24.0);
    await settings.setCardHorizontalSpacing(20.0);
    await settings.setWallpaperScrimIntensity(0.75);
    await settings.setWallpaperBlurSigma(6.0);
    await settings.setHomeTopSpacing(80.0);

    final updated = TvAppearanceConfig.fromSettings(settings);
    expect(updated.resolvedFocusScale, 1.16);
    expect(updated.resolvedCornerRadius, 20.0);
    expect(updated.resolvedBorderWidth, 3.5);
    expect(updated.focusGlowIntensity, 0.8);
    expect(updated.rowVerticalSpacing, 24.0);
    expect(updated.cardHorizontalSpacing, 20.0);
    expect(updated.wallpaperScrimIntensity, 0.75);
    expect(updated.wallpaperBlurSigma, 6.0);
    expect(updated.homeTopSpacing, 80.0);

    // Export & re-import preserves all new settings
    final exported = settings.exportSettingsMap();
    await prefs.clear();
    final restored = SettingsService(prefs);
    await restored.importSettingsMap(exported);
    expect(TvAppearanceConfig.fromSettings(restored), updated);

    // Reset restores Cinema defaults
    await restored.resetAppearanceDefaults();
    expect(TvAppearanceConfig.fromSettings(restored), defaults);
  });

  test('effectiveScaleForWidth clamps focus zoom to avoid clipping neighbor cards', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    await settings.setCardFocusScale(1.18);
    await settings.setCardHorizontalSpacing(8.0);

    final config = TvAppearanceConfig.fromSettings(settings);
    final clamped = config.effectiveScaleForWidth(100.0, isHighlighted: true);
    expect(clamped, lessThan(1.18));
    expect(config.effectiveScaleForWidth(100.0, isHighlighted: false), 1.0);
  });
}

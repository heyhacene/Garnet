/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flauncher/widgets/settings/back_button_actions.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _appHighlightAnimationEnabledKey = "app_highlight_animation_enabled";
const _appKeyClickEnabledKey = "app_key_click_enabled";
const _autoHideAppBarKey = "auto_hide_app_bar";
const _gradientUuidKey = "gradient_uuid";
const _backButtonActionKey = "back_button_action";
const _dateFormatKey = "date_format";
const _showCategoryTitlesKey = "show_category_titles";
const _showCategoryAppCountKey = "show_category_app_count";
const _showAppNamesBelowIconsKey = "show_app_names_below_icons";
const _themesKey = "app_banner_shape";
const _hideHighlightOutlineOnHomescreenKey = "hide_highlight_outline_on_homescreen";
const _appSelectorTransitionAnimationEnabledKey = "app_selector_transition_animation_enabled";
const _showDateInStatusBarKey = "show_date_in_status_bar";
const _showTimeInStatusBarKey = "show_time_in_status_bar";
const _timeFormatKey = "time_format";
const _dataUsagePeriodKey = "wifi_usage_period";
const _showDataWidgetInStatusBarKey = "show_wifi_widget_in_status_bar";
const String _showNetworkIndicatorInStatusBarKey = "show_network_indicator_in_status_bar";
const String _accentColorKey = "accent_color";
const String _screensaverClockStyleKey = "screensaver_clock_style";
const String _screensaverAnimationStyleKey = "screensaver_animation_style";
const String _timeBasedWallpaperEnabledKey = "time_based_wallpaper_enabled";
const String _showInputsWidgetInStatusBarKey = "show_inputs_widget_in_status_bar";
const String _showContinueWatchingKey = "show_continue_watching";
const String _continueWatchingCardSizeKey = "continue_watching_card_size";
const String _continueWatchingMaxItemsKey = "continue_watching_max_items";
const String _continueWatchingShowProgressKey = "continue_watching_show_progress";
const String _continueWatchingShowPercentageKey = "continue_watching_show_percentage";
const String _continueWatchingShowDescriptionKey = "continue_watching_show_description";
const String _continueWatchingOrderKey = "continue_watching_order";
const String _continueWatchingHideThresholdKey = "continue_watching_hide_threshold";
const String _hiddenWatchNextProgramIdsKey = "hidden_watch_next_program_ids";
const String _hiddenWatchNextPackagesKey = "hidden_watch_next_packages";
const String _startOnBootKey = "start_on_boot";
const String _showNotificationsWidgetInStatusBarKey = "show_notifications_widget_in_status_bar";
const String _autoHideNotificationsWidgetKey = "auto_hide_notifications_widget";
const String _appLanguageKey = "app_language";
const String _showWeatherInStatusBarKey = "show_weather_in_status_bar";
const String _showWeatherWarningsKey = "show_weather_warnings";
const String _temperatureUnitKey = "temperature_unit";
const String _autoAddNewAppsKey = "auto_add_new_apps";
const String _showBatteryIconInStatusBarKey = "show_battery_icon_in_status_bar";
const String _showBatteryPercentageInStatusBarKey = "show_battery_percentage_in_status_bar";
const String _cardFocusScaleKey = "card_focus_scale";
const String _customCardCornerRadiusKey = "custom_card_corner_radius";
const String _customFocusBorderWidthKey = "custom_focus_border_width";
const String _focusGlowIntensityKey = "focus_glow_intensity";
const String _rowVerticalSpacingKey = "row_vertical_spacing";
const String _cardHorizontalSpacingKey = "card_horizontal_spacing";
const String _wallpaperScrimIntensityKey = "wallpaper_scrim_intensity";
const String _wallpaperBlurSigmaKey = "wallpaper_blur_sigma";
const String _homeTopSpacingKey = "home_top_spacing";

const String TEMPERATURE_UNIT_CELSIUS = "celsius";
const String TEMPERATURE_UNIT_FAHRENHEIT = "fahrenheit";

// WiFi usage period options
const String DATA_USAGE_DAILY = "daily";
const String DATA_USAGE_WEEKLY = "weekly";
const String DATA_USAGE_MONTHLY = "monthly";

// Accent color presets (hex values)
const String ACCENT_COLOR_GARNET = "E11D48";
const String ACCENT_COLOR_PURPLE = "7C4DFF";
const String ACCENT_COLOR_TEAL = "00BFA5";
const String ACCENT_COLOR_BLUE = "2979FF";
const String ACCENT_COLOR_ORANGE = "FF6D00";
const String ACCENT_COLOR_PINK = "F50057";
const String ACCENT_COLOR_GREEN = "00C853";
const String ACCENT_COLOR_WHITE = "FFFFFF";
const String ACCENT_COLOR_YELLOW = "FFD600";
const String ACCENT_COLOR_RED = "D50000";
const String ACCENT_COLOR_CYAN = "00E5FF";
const String ACCENT_COLOR_INDIGO = "536DFE";
const String ACCENT_COLOR_LIME = "AEEA00";
const String ACCENT_COLOR_AMBER = "FFAB00";
const String ACCENT_COLOR_ROSE = "FF4081";
const String ACCENT_COLOR_ICE_BLUE = "80D8FF";

// Screensaver animation options
const String SCREENSAVER_ANIMATION_BOUNCE = "bounce";
const String SCREENSAVER_ANIMATION_FADE = "fade";
const String SCREENSAVER_ANIMATION_SCATTER = "scatter";

class SettingsService extends ChangeNotifier {
  static final defaultDateFormat = "EEEE d";
  static final defaultTimeFormat = "H:mm";
  final SharedPreferences _sharedPreferences;

  late bool _appHighlightAnimationEnabled;
  late bool _appKeyClickEnabled;
  late bool _autoHideAppBarEnabled;
  late bool _showCategoryTitles;
  late bool _showCategoryAppCount;
  late bool _showAppNamesBelowIcons;
  late String _themes;
  late bool _hideHighlightOutlineOnHomescreen;
  late bool _appSelectorTransitionAnimationEnabled;
  late bool _showDateInStatusBar;
  late bool _showTimeInStatusBar;
  late String? _gradientUuid;
  late String _backButtonAction;
  late String _dateFormat;
  late String _timeFormat;
  late String _dataUsagePeriod;
  late bool _showDataWidgetInStatusBar;
  late bool _showNetworkIndicatorInStatusBar;
  late String _accentColorHex;
  late String _screensaverClockStyle;
  late String _screensaverAnimationStyle;
  late bool _timeBasedWallpaperEnabled;
  late bool _showInputsWidgetInStatusBar;
  late bool _showContinueWatching;
  late String _continueWatchingCardSize;
  late int _continueWatchingMaxItems;
  late bool _continueWatchingShowProgress;
  late bool _continueWatchingShowPercentage;
  late bool _continueWatchingShowDescription;
  late int _continueWatchingOrder;
  late int _continueWatchingHideThreshold;
  late List<String> _hiddenWatchNextProgramIds;
  late List<String> _hiddenWatchNextPackages;
  late bool _startOnBoot;
  late bool _showNotificationsWidgetInStatusBar;
  late bool _autoHideNotificationsWidget;
  late String _appLanguage;
  late bool _showWeatherInStatusBar;
  late bool _showWeatherWarnings;
  late String _temperatureUnit;
  late bool _autoAddNewApps;
  late bool _showBatteryIconInStatusBar;
  late bool _showBatteryPercentageInStatusBar;
  double? _cardFocusScale;
  int? _customCardCornerRadius;
  double? _customFocusBorderWidth;
  late double _focusGlowIntensity;
  late double _rowVerticalSpacing;
  late double _cardHorizontalSpacing;
  late double _wallpaperScrimIntensity;
  late double _wallpaperBlurSigma;
  late double _homeTopSpacing;

  bool get autoAddNewApps => _autoAddNewApps;
  bool get showBatteryIconInStatusBar => _showBatteryIconInStatusBar;
  bool get showBatteryPercentageInStatusBar => _showBatteryPercentageInStatusBar;
  double? get cardFocusScale => _cardFocusScale;
  int? get customCardCornerRadius => _customCardCornerRadius;
  double? get customFocusBorderWidth => _customFocusBorderWidth;
  double get focusGlowIntensity => _focusGlowIntensity;
  double get rowVerticalSpacing => _rowVerticalSpacing;
  double get cardHorizontalSpacing => _cardHorizontalSpacing;
  double get wallpaperScrimIntensity => _wallpaperScrimIntensity;
  double get wallpaperBlurSigma => _wallpaperBlurSigma;
  double get homeTopSpacing => _homeTopSpacing;
  bool get appHighlightAnimationEnabled => _appHighlightAnimationEnabled;

  bool get appKeyClickEnabled => _appKeyClickEnabled;

  bool get autoHideAppBarEnabled => _autoHideAppBarEnabled;

  bool get showCategoryTitles => _showCategoryTitles;

  bool get showCategoryAppCount => _showCategoryAppCount;

  bool get showAppNamesBelowIcons => _showAppNamesBelowIcons;

  String get themes => _themes;

  bool get hideHighlightOutlineOnHomescreen => _hideHighlightOutlineOnHomescreen;

  bool get appSelectorTransitionAnimationEnabled => _appSelectorTransitionAnimationEnabled;

  bool get showDateInStatusBar => _showDateInStatusBar;

  bool get showTimeInStatusBar => _showTimeInStatusBar;

  String? get gradientUuid => _gradientUuid;

  String get backButtonAction => _backButtonAction;

  String get dateFormat => _dateFormat;

  String get timeFormat => _timeFormat;

  String get dataUsagePeriod => _dataUsagePeriod;

  bool get showDataWidgetInStatusBar => _showDataWidgetInStatusBar;

  bool get showNetworkIndicatorInStatusBar => _showNetworkIndicatorInStatusBar;

  bool get showInputsWidgetInStatusBar => _showInputsWidgetInStatusBar;
  bool get showContinueWatching => _showContinueWatching;
  String get continueWatchingCardSize => _continueWatchingCardSize;
  int get continueWatchingMaxItems => _continueWatchingMaxItems;
  bool get continueWatchingShowProgress => _continueWatchingShowProgress;
  bool get continueWatchingShowPercentage => _continueWatchingShowPercentage;
  bool get continueWatchingShowDescription => _continueWatchingShowDescription;
  int get continueWatchingOrder => _continueWatchingOrder;
  int get continueWatchingHideThreshold => _continueWatchingHideThreshold;
  List<String> get hiddenWatchNextProgramIds => List.unmodifiable(_hiddenWatchNextProgramIds);
  List<String> get hiddenWatchNextPackages => List.unmodifiable(_hiddenWatchNextPackages);
  bool get startOnBoot => _startOnBoot;
  bool get showNotificationsWidgetInStatusBar => _showNotificationsWidgetInStatusBar;
  bool get autoHideNotificationsWidget => _autoHideNotificationsWidget;
  bool get showWeatherInStatusBar => _showWeatherInStatusBar;
  bool get showWeatherWarnings => _showWeatherWarnings;
  String get temperatureUnit => _temperatureUnit;
  bool get useFahrenheit => _temperatureUnit == TEMPERATURE_UNIT_FAHRENHEIT;

  String get appLanguage => _appLanguage;

  Locale? get appLocale {
    if (_appLanguage.isEmpty) {
      return null;
    }
    return _appLanguage == 'iw' ? const Locale('he') : Locale(_appLanguage);
  }

  String get accentColorHex => _accentColorHex;

  String get screensaverClockStyle => _screensaverClockStyle;

  String get screensaverAnimationStyle => _screensaverAnimationStyle;

  Color get accentColor {
    final hex = accentColorHex;
    final int value = int.tryParse("0xFF$hex") ?? 0xFF7C4DFF;
    return Color(value);
  }

  SettingsService(this._sharedPreferences) {
    reload();
  }

  void reload() {
    _appHighlightAnimationEnabled = _sharedPreferences.getBool(_appHighlightAnimationEnabledKey) ?? true;
    _appKeyClickEnabled = _sharedPreferences.getBool(_appKeyClickEnabledKey) ?? true;
    _autoHideAppBarEnabled = _sharedPreferences.getBool(_autoHideAppBarKey) ?? false;
    _showCategoryTitles = _sharedPreferences.getBool(_showCategoryTitlesKey) ?? true;
    _showCategoryAppCount = _sharedPreferences.getBool(_showCategoryAppCountKey) ?? false;
    _showAppNamesBelowIcons = _sharedPreferences.getBool(_showAppNamesBelowIconsKey) ?? false;
    _themes = _sharedPreferences.getString(_themesKey) ?? "modern";
    _hideHighlightOutlineOnHomescreen = _sharedPreferences.getBool(_hideHighlightOutlineOnHomescreenKey) ?? false;
    _appSelectorTransitionAnimationEnabled = _sharedPreferences.getBool(_appSelectorTransitionAnimationEnabledKey) ?? true;
    _showDateInStatusBar = _sharedPreferences.getBool(_showDateInStatusBarKey) ?? true;
    _showTimeInStatusBar = _sharedPreferences.getBool(_showTimeInStatusBarKey) ?? true;
    _gradientUuid = _sharedPreferences.getString(_gradientUuidKey);
    _backButtonAction = _sharedPreferences.getString(_backButtonActionKey) ?? BACK_BUTTON_ACTION_NOTHING;
    _dateFormat = _sharedPreferences.getString(_dateFormatKey) ?? defaultDateFormat;
    _timeFormat = _sharedPreferences.getString(_timeFormatKey) ?? defaultTimeFormat;
    _dataUsagePeriod = _sharedPreferences.getString(_dataUsagePeriodKey) ?? DATA_USAGE_DAILY;
    _showDataWidgetInStatusBar = _sharedPreferences.getBool(_showDataWidgetInStatusBarKey) ?? false;
    _showNetworkIndicatorInStatusBar = _sharedPreferences.getBool(_showNetworkIndicatorInStatusBarKey) ?? true;
    _accentColorHex = _sharedPreferences.getString(_accentColorKey) ?? ACCENT_COLOR_PURPLE;
    _screensaverClockStyle = _sharedPreferences.getString(_screensaverClockStyleKey) ?? "minimal";
    _screensaverAnimationStyle = _sharedPreferences.getString(_screensaverAnimationStyleKey) ?? SCREENSAVER_ANIMATION_BOUNCE;
    _timeBasedWallpaperEnabled = _sharedPreferences.getBool(_timeBasedWallpaperEnabledKey) ?? false;
    _showInputsWidgetInStatusBar = _sharedPreferences.getBool(_showInputsWidgetInStatusBarKey) ?? true;
    _showContinueWatching = _sharedPreferences.getBool(_showContinueWatchingKey) ?? false;
    _continueWatchingCardSize = _sharedPreferences.getString(_continueWatchingCardSizeKey) ?? "normal";
    _continueWatchingMaxItems = _sharedPreferences.getInt(_continueWatchingMaxItemsKey) ?? 15;
    _continueWatchingShowProgress = _sharedPreferences.getBool(_continueWatchingShowProgressKey) ?? true;
    _continueWatchingShowPercentage = _sharedPreferences.getBool(_continueWatchingShowPercentageKey) ?? true;
    _continueWatchingShowDescription = _sharedPreferences.getBool(_continueWatchingShowDescriptionKey) ?? true;
    _continueWatchingOrder = _sharedPreferences.getInt(_continueWatchingOrderKey) ?? 0;
    _continueWatchingHideThreshold = _sharedPreferences.getInt(_continueWatchingHideThresholdKey) ?? 0;
    _hiddenWatchNextProgramIds = _sharedPreferences.getStringList(_hiddenWatchNextProgramIdsKey) ?? [];
    _hiddenWatchNextPackages = _sharedPreferences.getStringList(_hiddenWatchNextPackagesKey) ?? [];
    _startOnBoot = _sharedPreferences.getBool(_startOnBootKey) ?? false;
    _showNotificationsWidgetInStatusBar = _sharedPreferences.getBool(_showNotificationsWidgetInStatusBarKey) ?? true;
    _autoHideNotificationsWidget = _sharedPreferences.getBool(_autoHideNotificationsWidgetKey) ?? false;
    _appLanguage = _sharedPreferences.getString(_appLanguageKey) ?? "";
    _showWeatherInStatusBar = _sharedPreferences.getBool(_showWeatherInStatusBarKey) ?? false;
    _showWeatherWarnings = _sharedPreferences.getBool(_showWeatherWarningsKey) ?? true;
    _temperatureUnit = _sharedPreferences.getString(_temperatureUnitKey) ?? TEMPERATURE_UNIT_CELSIUS;
    _autoAddNewApps = _sharedPreferences.getBool(_autoAddNewAppsKey) ?? true;
    _showBatteryIconInStatusBar = _sharedPreferences.getBool(_showBatteryIconInStatusBarKey) ?? false;
    _showBatteryPercentageInStatusBar = _sharedPreferences.getBool(_showBatteryPercentageInStatusBarKey) ?? false;
    _cardFocusScale = _sharedPreferences.getDouble(_cardFocusScaleKey);
    _customCardCornerRadius = _sharedPreferences.getInt(_customCardCornerRadiusKey);
    _customFocusBorderWidth = _sharedPreferences.getDouble(_customFocusBorderWidthKey);
    _focusGlowIntensity = _sharedPreferences.getDouble(_focusGlowIntensityKey) ?? 0.60;
    _rowVerticalSpacing = _sharedPreferences.getDouble(_rowVerticalSpacingKey) ?? 16.0;
    _cardHorizontalSpacing = _sharedPreferences.getDouble(_cardHorizontalSpacingKey) ?? 16.0;
    _wallpaperScrimIntensity = _sharedPreferences.getDouble(_wallpaperScrimIntensityKey) ?? 0.68;
    _wallpaperBlurSigma = _sharedPreferences.getDouble(_wallpaperBlurSigmaKey) ?? 0.0;
    _homeTopSpacing = _sharedPreferences.getDouble(_homeTopSpacingKey) ?? 40.0;
    notifyListeners();
  }

  Map<String, dynamic> exportSettingsMap() {
    return {
      _autoAddNewAppsKey: _autoAddNewApps,
      _showBatteryIconInStatusBarKey: _showBatteryIconInStatusBar,
      _showBatteryPercentageInStatusBarKey: _showBatteryPercentageInStatusBar,
      if (_cardFocusScale != null) _cardFocusScaleKey: _cardFocusScale,
      if (_customCardCornerRadius != null) _customCardCornerRadiusKey: _customCardCornerRadius,
      if (_customFocusBorderWidth != null) _customFocusBorderWidthKey: _customFocusBorderWidth,
      _focusGlowIntensityKey: _focusGlowIntensity,
      _rowVerticalSpacingKey: _rowVerticalSpacing,
      _cardHorizontalSpacingKey: _cardHorizontalSpacing,
      _wallpaperScrimIntensityKey: _wallpaperScrimIntensity,
      _wallpaperBlurSigmaKey: _wallpaperBlurSigma,
      _homeTopSpacingKey: _homeTopSpacing,
      _appHighlightAnimationEnabledKey: _appHighlightAnimationEnabled,
      _appKeyClickEnabledKey: _appKeyClickEnabled,
      _autoHideAppBarKey: _autoHideAppBarEnabled,
      _showCategoryTitlesKey: _showCategoryTitles,
      _showCategoryAppCountKey: _showCategoryAppCount,
      _showAppNamesBelowIconsKey: _showAppNamesBelowIcons,
      _themesKey: _themes,
      _hideHighlightOutlineOnHomescreenKey: _hideHighlightOutlineOnHomescreen,
      _appSelectorTransitionAnimationEnabledKey: _appSelectorTransitionAnimationEnabled,
      _showDateInStatusBarKey: _showDateInStatusBar,
      _showTimeInStatusBarKey: _showTimeInStatusBar,
      if (_gradientUuid != null) _gradientUuidKey: _gradientUuid,
      _backButtonActionKey: _backButtonAction,
      _dateFormatKey: _dateFormat,
      _timeFormatKey: _timeFormat,
      _dataUsagePeriodKey: _dataUsagePeriod,
      _showDataWidgetInStatusBarKey: _showDataWidgetInStatusBar,
      _showNetworkIndicatorInStatusBarKey: _showNetworkIndicatorInStatusBar,
      _accentColorKey: _accentColorHex,
      _screensaverClockStyleKey: _screensaverClockStyle,
      _screensaverAnimationStyleKey: _screensaverAnimationStyle,
      _timeBasedWallpaperEnabledKey: _timeBasedWallpaperEnabled,
      _showInputsWidgetInStatusBarKey: _showInputsWidgetInStatusBar,
      _showContinueWatchingKey: _showContinueWatching,
      _continueWatchingCardSizeKey: _continueWatchingCardSize,
      _continueWatchingMaxItemsKey: _continueWatchingMaxItems,
      _continueWatchingShowProgressKey: _continueWatchingShowProgress,
      _continueWatchingShowPercentageKey: _continueWatchingShowPercentage,
      _continueWatchingShowDescriptionKey: _continueWatchingShowDescription,
      _continueWatchingOrderKey: _continueWatchingOrder,
      _continueWatchingHideThresholdKey: _continueWatchingHideThreshold,
      _hiddenWatchNextProgramIdsKey: _hiddenWatchNextProgramIds,
      _hiddenWatchNextPackagesKey: _hiddenWatchNextPackages,
      _startOnBootKey: _startOnBoot,
      _showNotificationsWidgetInStatusBarKey: _showNotificationsWidgetInStatusBar,
      _autoHideNotificationsWidgetKey: _autoHideNotificationsWidget,
      _appLanguageKey: _appLanguage,
      _showWeatherInStatusBarKey: _showWeatherInStatusBar,
      _showWeatherWarningsKey: _showWeatherWarnings,
      _temperatureUnitKey: _temperatureUnit,
    };
  }

  Future<void> importSettingsMap(Map<String, dynamic> settingsMap) async {
    for (final entry in settingsMap.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is bool) {
        await _sharedPreferences.setBool(key, value);
      } else if (value is int) {
        await _sharedPreferences.setInt(key, value);
      } else if (value is double) {
        await _sharedPreferences.setDouble(key, value);
      } else if (value is String) {
        await _sharedPreferences.setString(key, value);
      } else if (value is List) {
        await _sharedPreferences.setStringList(key, value.map((e) => e.toString()).toList());
      }
    }
    reload();
  }

  Future<void> setAppLanguage(String value) async {
    await _sharedPreferences.setString(_appLanguageKey, value);
    _appLanguage = value;
    notifyListeners();
  }

  Future<void> setAppHighlightAnimationEnabled(bool value) async {
    await _sharedPreferences.setBool(_appHighlightAnimationEnabledKey, value);
    _appHighlightAnimationEnabled = value;
    notifyListeners();
  }

  Future<void> setAppKeyClickEnabled(bool value) async {
    await _sharedPreferences.setBool(_appKeyClickEnabledKey, value);
    _appKeyClickEnabled = value;
    notifyListeners();
  }

  Future<void> setAutoHideAppBarEnabled(bool value) async {
    await _sharedPreferences.setBool(_autoHideAppBarKey, value);
    _autoHideAppBarEnabled = value;
    notifyListeners();
  }

  Future<void> setGradientUuid(String value) async {
    await _sharedPreferences.setString(_gradientUuidKey, value);
    _gradientUuid = value;
    notifyListeners();
  }

  Future<void> setBackButtonAction(String value) async {
    await _sharedPreferences.setString(_backButtonActionKey, value);
    _backButtonAction = value;
    notifyListeners();
  }

  Future<void> setDateTimeFormat(String dateFormatString, String timeFormatString) async {
    await Future.wait([
      _sharedPreferences.setString(_dateFormatKey, dateFormatString),
      _sharedPreferences.setString(_timeFormatKey, timeFormatString)
    ]);
    _dateFormat = dateFormatString;
    _timeFormat = timeFormatString;
    notifyListeners();
  }

  Future<void> setShowCategoryTitles(bool show) async {
    await _sharedPreferences.setBool(_showCategoryTitlesKey, show);
    _showCategoryTitles = show;
    notifyListeners();
  }

  Future<void> setShowCategoryAppCount(bool show) async {
    await _sharedPreferences.setBool(_showCategoryAppCountKey, show);
    _showCategoryAppCount = show;
    notifyListeners();
  }

  Future<void> setShowAppNamesBelowIcons(bool show) async {
    await _sharedPreferences.setBool(_showAppNamesBelowIconsKey, show);
    _showAppNamesBelowIcons = show;
    notifyListeners();
  }

  Future<void> setThemes(String shape) async {
    await _sharedPreferences.setString(_themesKey, shape);
    _themes = shape;
    notifyListeners();
  }

  Future<void> setHideHighlightOutlineOnHomescreen(bool enabled) async {
    await _sharedPreferences.setBool(_hideHighlightOutlineOnHomescreenKey, enabled);
    _hideHighlightOutlineOnHomescreen = enabled;
    notifyListeners();
  }

  Future<void> setAppSelectorTransitionAnimationEnabled(bool enabled) async {
    await _sharedPreferences.setBool(_appSelectorTransitionAnimationEnabledKey, enabled);
    _appSelectorTransitionAnimationEnabled = enabled;
    notifyListeners();
  }

  Future<void> setShowDateInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showDateInStatusBarKey, show);
    _showDateInStatusBar = show;
    notifyListeners();
  }

  Future<void> setShowTimeInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showTimeInStatusBarKey, show);
    _showTimeInStatusBar = show;
    notifyListeners();
  }

  Future<void> setDataUsagePeriod(String period) async {
    await _sharedPreferences.setString(_dataUsagePeriodKey, period);
    _dataUsagePeriod = period;
    notifyListeners();
  }

  Future<void> setShowDataWidgetInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showDataWidgetInStatusBarKey, show);
    _showDataWidgetInStatusBar = show;
    notifyListeners();
  }

  Future<void> setShowNetworkIndicatorInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showNetworkIndicatorInStatusBarKey, show);
    _showNetworkIndicatorInStatusBar = show;
    notifyListeners();
  }

  Future<void> setAccentColor(String colorHex) async {
    await _sharedPreferences.setString(_accentColorKey, colorHex);
    _accentColorHex = colorHex;
    notifyListeners();
  }

  Future<void> setScreensaverClockStyle(String style) async {
    await _sharedPreferences.setString(_screensaverClockStyleKey, style);
    _screensaverClockStyle = style;
    notifyListeners();
  }

  Future<void> setScreensaverAnimationStyle(String style) async {
    await _sharedPreferences.setString(_screensaverAnimationStyleKey, style);
    _screensaverAnimationStyle = style;
    notifyListeners();
  }

  bool get timeBasedWallpaperEnabled => _timeBasedWallpaperEnabled;

  Future<void> setTimeBasedWallpaperEnabled(bool enabled) async {
    await _sharedPreferences.setBool(_timeBasedWallpaperEnabledKey, enabled);
    _timeBasedWallpaperEnabled = enabled;
    notifyListeners();
  }

  Future<void> setShowInputsWidgetInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showInputsWidgetInStatusBarKey, show);
    _showInputsWidgetInStatusBar = show;
    notifyListeners();
  }

  Future<void> setShowContinueWatching(bool show) async {
    await _sharedPreferences.setBool(_showContinueWatchingKey, show);
    _showContinueWatching = show;
    notifyListeners();
  }

  Future<void> setContinueWatchingCardSize(String size) async {
    await _sharedPreferences.setString(_continueWatchingCardSizeKey, size);
    _continueWatchingCardSize = size;
    notifyListeners();
  }

  Future<void> setContinueWatchingMaxItems(int count) async {
    await _sharedPreferences.setInt(_continueWatchingMaxItemsKey, count);
    _continueWatchingMaxItems = count;
    notifyListeners();
  }

  Future<void> setContinueWatchingShowProgress(bool show) async {
    await _sharedPreferences.setBool(_continueWatchingShowProgressKey, show);
    _continueWatchingShowProgress = show;
    notifyListeners();
  }

  Future<void> setContinueWatchingShowPercentage(bool show) async {
    await _sharedPreferences.setBool(_continueWatchingShowPercentageKey, show);
    _continueWatchingShowPercentage = show;
    notifyListeners();
  }

  Future<void> setContinueWatchingShowDescription(bool show) async {
    await _sharedPreferences.setBool(_continueWatchingShowDescriptionKey, show);
    _continueWatchingShowDescription = show;
    notifyListeners();
  }

  Future<void> setContinueWatchingOrder(int order) async {
    await _sharedPreferences.setInt(_continueWatchingOrderKey, order);
    _continueWatchingOrder = order;
    notifyListeners();
  }

  Future<void> setContinueWatchingHideThreshold(int threshold) async {
    await _sharedPreferences.setInt(_continueWatchingHideThresholdKey, threshold);
    _continueWatchingHideThreshold = threshold;
    notifyListeners();
  }

  Future<void> hideWatchNextProgram(int id) async {
    final strId = id.toString();
    if (!_hiddenWatchNextProgramIds.contains(strId)) {
      _hiddenWatchNextProgramIds = List<String>.from(_hiddenWatchNextProgramIds)..add(strId);
      await _sharedPreferences.setStringList(_hiddenWatchNextProgramIdsKey, _hiddenWatchNextProgramIds);
      notifyListeners();
    }
  }

  Future<void> unhideWatchNextProgram(int id) async {
    final strId = id.toString();
    if (_hiddenWatchNextProgramIds.contains(strId)) {
      _hiddenWatchNextProgramIds = List<String>.from(_hiddenWatchNextProgramIds)..remove(strId);
      await _sharedPreferences.setStringList(_hiddenWatchNextProgramIdsKey, _hiddenWatchNextProgramIds);
      notifyListeners();
    }
  }

  Future<void> hideWatchNextPackage(String packageName) async {
    if (!_hiddenWatchNextPackages.contains(packageName)) {
      _hiddenWatchNextPackages = List<String>.from(_hiddenWatchNextPackages)..add(packageName);
      await _sharedPreferences.setStringList(_hiddenWatchNextPackagesKey, _hiddenWatchNextPackages);
      notifyListeners();
    }
  }

  Future<void> unhideWatchNextPackage(String packageName) async {
    if (_hiddenWatchNextPackages.contains(packageName)) {
      _hiddenWatchNextPackages = List<String>.from(_hiddenWatchNextPackages)..remove(packageName);
      await _sharedPreferences.setStringList(_hiddenWatchNextPackagesKey, _hiddenWatchNextPackages);
      notifyListeners();
    }
  }

  Future<void> unhideAllWatchNextPackages() async {
    _hiddenWatchNextPackages = [];
    await _sharedPreferences.remove(_hiddenWatchNextPackagesKey);
    notifyListeners();
  }

  Future<void> clearHiddenWatchNextPrograms() async {
    _hiddenWatchNextProgramIds = [];
    await _sharedPreferences.remove(_hiddenWatchNextProgramIdsKey);
    notifyListeners();
  }

  Future<void> clearAllHiddenWatchNext() async {
    _hiddenWatchNextProgramIds = [];
    _hiddenWatchNextPackages = [];
    await _sharedPreferences.remove(_hiddenWatchNextProgramIdsKey);
    await _sharedPreferences.remove(_hiddenWatchNextPackagesKey);
    notifyListeners();
  }

  Future<void> setStartOnBoot(bool enabled) async {
    await _sharedPreferences.setBool(_startOnBootKey, enabled);
    _startOnBoot = enabled;
    notifyListeners();
  }

  Future<void> setShowNotificationsWidgetInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showNotificationsWidgetInStatusBarKey, show);
    _showNotificationsWidgetInStatusBar = show;
    notifyListeners();
  }

  Future<void> setAutoHideNotificationsWidget(bool value) async {
    await _sharedPreferences.setBool(_autoHideNotificationsWidgetKey, value);
    _autoHideNotificationsWidget = value;
    notifyListeners();
  }

  Future<void> setShowWeatherInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showWeatherInStatusBarKey, show);
    _showWeatherInStatusBar = show;
    notifyListeners();
  }

  Future<void> setShowWeatherWarnings(bool show) async {
    await _sharedPreferences.setBool(_showWeatherWarningsKey, show);
    _showWeatherWarnings = show;
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    await _sharedPreferences.setString(_temperatureUnitKey, unit);
    _temperatureUnit = unit;
    notifyListeners();
  }

  Future<void> setAutoAddNewApps(bool enabled) async {
    await _sharedPreferences.setBool(_autoAddNewAppsKey, enabled);
    _autoAddNewApps = enabled;
    notifyListeners();
  }

  Future<void> setShowBatteryIconInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showBatteryIconInStatusBarKey, show);
    _showBatteryIconInStatusBar = show;
    notifyListeners();
  }

  Future<void> setShowBatteryPercentageInStatusBar(bool show) async {
    await _sharedPreferences.setBool(_showBatteryPercentageInStatusBarKey, show);
    _showBatteryPercentageInStatusBar = show;
    notifyListeners();
  }

  Future<void> setCardFocusScale(double? value) async {
    if (value == null) {
      await _sharedPreferences.remove(_cardFocusScaleKey);
      _cardFocusScale = null;
    } else {
      final clamped = double.parse(value.clamp(1.0, 1.18).toStringAsFixed(2));
      await _sharedPreferences.setDouble(_cardFocusScaleKey, clamped);
      _cardFocusScale = clamped;
    }
    notifyListeners();
  }

  Future<void> setCustomCardCornerRadius(int? value) async {
    if (value == null) {
      await _sharedPreferences.remove(_customCardCornerRadiusKey);
      _customCardCornerRadius = null;
    } else {
      final clamped = value.clamp(0, 28);
      await _sharedPreferences.setInt(_customCardCornerRadiusKey, clamped);
      _customCardCornerRadius = clamped;
    }
    notifyListeners();
  }

  Future<void> setCustomFocusBorderWidth(double? value) async {
    if (value == null) {
      await _sharedPreferences.remove(_customFocusBorderWidthKey);
      _customFocusBorderWidth = null;
    } else {
      final clamped = double.parse(value.clamp(0.0, 5.0).toStringAsFixed(1));
      await _sharedPreferences.setDouble(_customFocusBorderWidthKey, clamped);
      _customFocusBorderWidth = clamped;
    }
    notifyListeners();
  }

  Future<void> setFocusGlowIntensity(double value) async {
    final clamped = double.parse(value.clamp(0.0, 1.0).toStringAsFixed(2));
    await _sharedPreferences.setDouble(_focusGlowIntensityKey, clamped);
    _focusGlowIntensity = clamped;
    notifyListeners();
  }

  Future<void> setRowVerticalSpacing(double value) async {
    final clamped = value.clamp(8.0, 40.0).roundToDouble();
    await _sharedPreferences.setDouble(_rowVerticalSpacingKey, clamped);
    _rowVerticalSpacing = clamped;
    notifyListeners();
  }

  Future<void> setCardHorizontalSpacing(double value) async {
    final clamped = value.clamp(8.0, 32.0).roundToDouble();
    await _sharedPreferences.setDouble(_cardHorizontalSpacingKey, clamped);
    _cardHorizontalSpacing = clamped;
    notifyListeners();
  }

  Future<void> setWallpaperScrimIntensity(double value) async {
    final clamped = double.parse(value.clamp(0.15, 0.90).toStringAsFixed(2));
    await _sharedPreferences.setDouble(_wallpaperScrimIntensityKey, clamped);
    _wallpaperScrimIntensity = clamped;
    notifyListeners();
  }

  Future<void> setWallpaperBlurSigma(double value) async {
    final clamped = value.clamp(0.0, 16.0).roundToDouble();
    await _sharedPreferences.setDouble(_wallpaperBlurSigmaKey, clamped);
    _wallpaperBlurSigma = clamped;
    notifyListeners();
  }

  Future<void> setHomeTopSpacing(double value) async {
    final clamped = value.clamp(0.0, 200.0).roundToDouble();
    await _sharedPreferences.setDouble(_homeTopSpacingKey, clamped);
    _homeTopSpacing = clamped;
    notifyListeners();
  }

  Future<void> resetAppearanceDefaults() async {
    await _sharedPreferences.remove(_cardFocusScaleKey);
    await _sharedPreferences.remove(_customCardCornerRadiusKey);
    await _sharedPreferences.remove(_customFocusBorderWidthKey);
    await _sharedPreferences.setDouble(_focusGlowIntensityKey, 0.60);
    await _sharedPreferences.setDouble(_rowVerticalSpacingKey, 16.0);
    await _sharedPreferences.setDouble(_cardHorizontalSpacingKey, 16.0);
    await _sharedPreferences.setDouble(_wallpaperScrimIntensityKey, 0.68);
    await _sharedPreferences.setDouble(_wallpaperBlurSigmaKey, 0.0);
    await _sharedPreferences.setDouble(_homeTopSpacingKey, 40.0);
    _cardFocusScale = null;
    _customCardCornerRadius = null;
    _customFocusBorderWidth = null;
    _focusGlowIntensity = 0.60;
    _rowVerticalSpacing = 16.0;
    _cardHorizontalSpacing = 16.0;
    _wallpaperScrimIntensity = 0.68;
    _wallpaperBlurSigma = 0.0;
    _homeTopSpacing = 40.0;
    notifyListeners();
  }
}

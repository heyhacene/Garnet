import 'package:flauncher/models/tv_appearance_config.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/actions.dart';
import 'package:flauncher/widgets/app_card_keys.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flauncher/widgets/tv_focus_frame.dart';
import 'package:flauncher/widgets/watch_next_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

class ContinueWatchingRow extends StatelessWidget {
  final bool isFirstSection;

  const ContinueWatchingRow({
    Key? key,
    this.isFirstSection = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    if (!settingsService.showContinueWatching) {
      return const SizedBox.shrink();
    }

    return Consumer2<WatchNextService, AppsService>(
      builder: (context, watchNextService, appsService, _) {
        if (!watchNextService.hasPermission) {
          return const SizedBox.shrink();
        }

        final hiddenProgramIds = settingsService.hiddenWatchNextProgramIds;
        final hiddenPackages = settingsService.hiddenWatchNextPackages;
        final hideThreshold = settingsService.continueWatchingHideThreshold;

        List<WatchNextProgram> programs = watchNextService.programs
            .where((p) =>
                !hiddenProgramIds.contains(p.id.toString()) &&
                !hiddenPackages.contains(p.packageName) &&
                !appsService.applications.any((app) => app.packageName == p.packageName && app.hidden))
            .where((p) {
              if (hideThreshold <= 0) return true;
              if (p.duration <= 0) return true;
              return p.safeProgress < (hideThreshold / 100.0);
            })
            .toList();

        final maxItems = settingsService.continueWatchingMaxItems;
        if (maxItems > 0 && programs.length > maxItems) {
          programs = programs.sublist(0, maxItems);
        }

        if (programs.isEmpty) {
          return const SizedBox.shrink();
        }

        double cardHeight;
        final int? customHeight = int.tryParse(settingsService.continueWatchingCardSize);
        if (customHeight != null) {
          cardHeight = customHeight.toDouble();
        } else {
          switch (settingsService.continueWatchingCardSize) {
            case 'compact':
              cardHeight = 112.0;
              break;
            case 'large':
              cardHeight = 157.0;
              break;
            case 'normal':
            default:
              cardHeight = 135.0;
              break;
          }
        }
        final double rowHeight = cardHeight + 36.0;
        final double rowVerticalPadding = (settingsService.rowVerticalSpacing > 0
                ? settingsService.rowVerticalSpacing.clamp(8.0, 40.0)
                : 16.0) /
            2.0;
        final double cardHalfGap = (settingsService.cardHorizontalSpacing > 0
                ? settingsService.cardHorizontalSpacing.clamp(8.0, 32.0)
                : 16.0) /
            2.0;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: rowVerticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Selector<SettingsService, (bool, bool)>(
                selector: (context, service) =>
                    (service.showCategoryTitles, service.showCategoryAppCount),
                builder: (context, settings, _) {
                  final (showCategoryTitles, showCategoryAppCount) = settings;
                  if (showCategoryTitles) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.continueWatching,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                          if (showCategoryAppCount) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${programs.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white54),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              SizedBox(
                height: rowHeight,
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.all(8),
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Padding(
                      key: ValueKey(program.id),
                      padding: EdgeInsets.symmetric(horizontal: cardHalfGap),
                      child: RepaintBoundary(
                        child: WatchNextCard(
                          program: program,
                          appsService: appsService,
                          watchNextService: watchNextService,
                          handleUpNavigationToSettings: isFirstSection,
                          isFirstInRow: index == 0,
                          isLastInRow: index == programs.length - 1,
                          autofocus: index == 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WatchNextCard extends StatefulWidget {
  final WatchNextProgram program;
  final AppsService appsService;
  final WatchNextService watchNextService;
  final bool handleUpNavigationToSettings;
  final bool isFirstInRow;
  final bool isLastInRow;
  final bool autofocus;

  const WatchNextCard({
    Key? key,
    required this.program,
    required this.appsService,
    required this.watchNextService,
    this.handleUpNavigationToSettings = true,
    this.isFirstInRow = false,
    this.isLastInRow = false,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<WatchNextCard> createState() => _WatchNextCardState();
}

class _WatchNextCardState extends State<WatchNextCard> with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  bool _clicked = false;
  Uint8List? _appIconBytes;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  double _bumpDirection = 0;
  late final AnimationController _bumpController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _bumpAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 1),
  ]).animate(_bumpController);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    FocusManager.instance.addHighlightModeListener(_focusHighlightModeChanged);
    _loadAppIcon();
  }

  void _focusHighlightModeChanged(FocusHighlightMode mode) {
    setState(() {});
  }

  bool _shouldHighlight(BuildContext context) {
    return FocusManager.instance.highlightMode == FocusHighlightMode.traditional && _focusNode.hasFocus;
  }

  Future<void> _loadAppIcon() async {
    try {
      final bytes = await widget.appsService.getAppIcon(widget.program.packageName);
      if (mounted && bytes.isNotEmpty) {
        setState(() => _appIconBytes = bytes);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant WatchNextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.program.packageName != widget.program.packageName) {
      _loadAppIcon();
    }
  }

  void _onFocusChange() {
    setState(() {});
    if (_focusNode.hasFocus) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_focusHighlightModeChanged);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animation.dispose();
    _bumpController.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (!_clicked) {
      setState(() => _clicked = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        widget.watchNextService.launch(widget.program);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _clicked = false);
          }
        });
      });
    }
  }

  void _onLongPress() {
    showDialog(
      context: context,
      builder: (context) => WatchNextInfoPanel(
        program: widget.program,
        watchNextService: widget.watchNextService,
        appsService: widget.appsService,
        appIconBytes: _appIconBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TvAppearanceConfig appearance = context.select<SettingsService, TvAppearanceConfig>(
      TvAppearanceConfig.fromSettings,
    );
    final String cardSize = context.select<SettingsService, String>((s) => s.continueWatchingCardSize);
    final bool showProgress = context.select<SettingsService, bool>((s) => s.continueWatchingShowProgress);
    final bool showPercentage = context.select<SettingsService, bool>((s) => s.continueWatchingShowPercentage);
    final bool showDescription = context.select<SettingsService, bool>((s) => s.continueWatchingShowDescription);

    final Color accentColor = appearance.accentColor;
    double cardWidth;
    double cardHeight;
    final int? customHeight = int.tryParse(cardSize);
    if (customHeight != null) {
      cardHeight = customHeight.toDouble();
      cardWidth = (cardHeight * 16 / 9).roundToDouble();
    } else {
      switch (cardSize) {
        case 'compact':
          cardWidth = 200.0;
          cardHeight = 112.0;
          break;
        case 'large':
          cardWidth = 280.0;
          cardHeight = 157.0;
          break;
        case 'normal':
        default:
          cardWidth = 240.0;
          cardHeight = 135.0;
          break;
      }
    }

    final BorderRadius borderRadius = appearance.borderRadius;
    final bool shouldHighlight = _shouldHighlight(context);
    final double scale = appearance.effectiveScaleForWidth(
      cardWidth,
      isHighlighted: shouldHighlight,
    );
    final double elevation = appearance.elevationForFocus(shouldHighlight);
    final Color shadowColor = (shouldHighlight && appearance.theme == 'glow')
        ? accentColor.withOpacity(0.85)
        : Colors.black;

    // Progress percentage
    final double progress = widget.program.safeProgress;

    return FocusKeyboardListener(
      onPressed: (key) {
        if (key == LogicalKeyboardKey.arrowLeft && widget.isFirstInRow) {
          _bumpDirection = -1.0;
          if (!_bumpController.isAnimating) {
            _bumpController.forward(from: 0.0);
          }
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowRight && widget.isLastInRow) {
          _bumpDirection = 1.0;
          if (!_bumpController.isAnimating) {
            _bumpController.forward(from: 0.0);
          }
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowUp && widget.handleUpNavigationToSettings) {
          Actions.invoke(context, const MoveFocusToSettingsIntent());
          return KeyEventResult.handled;
        } else if (AppCardKeys.validationKeys.contains(key)) {
          _onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      onLongPress: (key) {
        if (AppCardKeys.longPressableKeys.contains(key) || AppCardKeys.menuKeys.contains(key)) {
          _onLongPress();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      builder: (context) {
        return AnimatedBuilder(
          animation: _bumpAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_bumpAnimation.value * _bumpDirection, 0),
              child: child,
            );
          },
          child: InkWell(
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: _onPressed,
          onLongPress: _onLongPress,
          child: AnimatedScale(
              scale: _clicked ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _clicked ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedContainer(
                  duration: appearance.transitionAnimationEnabled
                      ? const Duration(milliseconds: 200)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  width: cardWidth,
                  height: cardHeight,
                  transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    boxShadow: appearance.focusShadows(shouldHighlight),
                  ),
                  child: Material(
                    borderRadius: borderRadius,
                    clipBehavior: Clip.antiAlias,
                    elevation: elevation,
                    shadowColor: shadowColor,
                    color: Colors.transparent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Card surface with subtle dark gradient and border
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF141517),
                                Color(0xFF090A0B),
                              ],
                            ),
                            border: Border.all(
                              color: shouldHighlight ? Colors.transparent : Colors.white.withOpacity(0.06),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: App icon + Progress badge (no text app title)
                              Row(
                                children: [
                                  if (_appIconBytes != null)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.memory(
                                          _appIconBytes!,
                                          cacheWidth: (24 * MediaQuery.devicePixelRatioOf(context)).ceil(),
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.low,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  if (showPercentage && progress > 0)
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: accentColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              // Program Title
                              Text(
                                widget.program.title.trim(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  height: 1.25,
                                ),
                                maxLines: (showDescription &&
                                        widget.program.description.trim().isNotEmpty &&
                                        widget.program.description.trim().toLowerCase() !=
                                            widget.program.title.trim().toLowerCase())
                                    ? 2
                                    : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (showDescription &&
                                  widget.program.description.trim().isNotEmpty &&
                                  widget.program.description.trim().toLowerCase() !=
                                      widget.program.title.trim().toLowerCase()) ...[
                                const SizedBox(height: 3),
                                Text(
                                  widget.program.description.trim(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white60,
                                    fontSize: 10.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const Spacer(),
                              // Bottom progress indicator
                              if (showProgress && progress > 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withOpacity(0.12),
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    minHeight: 3.5,
                                  ),
                                )
                              else
                                const SizedBox(height: 3.5),
                            ],
                          ),
                        ),
                        TvFocusOverlay(
                          appearance: appearance,
                          isHighlighted: shouldHighlight,
                          pulseController: _animation,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      );
    }
}

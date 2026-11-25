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

import 'package:flauncher/actions.dart';
import 'package:flauncher/app_image_type.dart';
import 'package:flauncher/models/tv_appearance_config.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flauncher/widgets/app_card_keys.dart';
import 'package:flauncher/widgets/tv_focus_frame.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../models/category.dart';

class AppCard extends StatefulWidget
{
  final App application;
  final Category category;
  final bool autofocus;
  final void Function(AxisDirection) onMove;
  final VoidCallback onMoveEnd;
  final VoidCallback? onMoveCancel;
  final int index;
  final bool handleUpNavigationToSettings;
  final bool isFirstInRow;
  final bool isLastInRow;

  const AppCard({
    super.key,
    required this.application,
    required this.category,
    required this.autofocus,
    required this.onMove,
    required this.onMoveEnd,
    this.onMoveCancel,
    this.index = 0,
    this.handleUpNavigationToSettings = false,
    this.isFirstInRow = false,
    this.isLastInRow = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  bool _moving = false;
  bool _clicked = false;
  late FocusNode _focusNode;

  late Future<(AppImageType, ImageProvider)> _appImageLoadFuture;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 1200,
    ),
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

  AppsService? _appsService;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _appsService = Provider.of<AppsService>(context, listen: false);
    _appsService!.addListener(_onAppsServiceChanged);

    FocusManager.instance.addHighlightModeListener(_focusHighlightModeChanged);
    _appImageLoadFuture = _loadAppBannerOrIcon(_appsService!);

    // Check if we need to restore focus/reorder mode after a move
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       final appsService = Provider.of<AppsService>(context, listen: false);
       if (appsService.pendingReorderFocusPackage == widget.application.packageName &&
           appsService.pendingReorderFocusCategoryId == widget.category.id) {
          appsService.clearPendingReorderFocusPackage();
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          
          if (!_moving) {
            setState(() {
              _moving = true;
            });
          }
       }
    });
  }

  @override
  void didUpdateWidget(AppCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check for pending focus on update as well
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       final appsService = Provider.of<AppsService>(context, listen: false);
       if (appsService.pendingReorderFocusPackage == widget.application.packageName &&
           appsService.pendingReorderFocusCategoryId == widget.category.id) {
          appsService.clearPendingReorderFocusPackage();
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          
          if (!_moving) {
            setState(() {
              _moving = true;
            });
          }
       }
    });
  }

  @override
  void dispose() {
    if (_appsService != null) {
      _appsService!.removeListener(_onAppsServiceChanged);
    }
    FocusManager.instance.removeHighlightModeListener(_focusHighlightModeChanged);
    _animation.dispose();
    _bumpController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void _onAppsServiceChanged() {
    // Reload the app image when the AppsService notifies of changes
    // (e.g., after setting a custom banner)
    setState(() {
      _appImageLoadFuture = _loadAppBannerOrIcon(_appsService!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppNames = context.select<SettingsService, bool>((s) => s.showAppNamesBelowIcons);
    final TvAppearanceConfig appearance = context.select<SettingsService, TvAppearanceConfig>(
      TvAppearanceConfig.fromSettings,
    );
    final BorderRadius borderRadius = appearance.borderRadius;

    return FocusKeyboardListener(
      onPressed: (key) => _onPressed(context, key),
      onLongPress: (key) => _onLongPress(context, key),
      builder: (context) {
        final bool shouldHighlight = _shouldHighlight(context);

        return AnimatedBuilder(
          animation: _bumpAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_bumpAnimation.value * _bumpDirection, 0),
              child: child,
            );
          },
          child: AnimatedScale(
          scale: _clicked ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _clicked ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: RepaintBoundary(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double scale = _moving
                              ? 1.0
                              : appearance.effectiveScaleForWidth(
                                  constraints.maxWidth,
                                  isHighlighted: shouldHighlight,
                                );
                          return AnimatedContainer(
                            duration: appearance.transitionAnimationEnabled
                                ? const Duration(milliseconds: 200)
                                : Duration.zero,
                            curve: Curves.easeOutCubic,
                            transformAlignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              boxShadow: appearance.focusShadows(shouldHighlight),
                            ),
                            child: Material(
                          borderRadius: borderRadius,
                          clipBehavior: Clip.antiAlias,
                          elevation: appearance.elevationForFocus(shouldHighlight),
                          shadowColor: (shouldHighlight && appearance.theme == 'glow')
                              ? appearance.accentColor.withOpacity(0.85)
                              : Colors.black,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Selector<NotificationsService, int>(
                                selector: (_, service) => service.getNotificationCount(widget.application.packageName),
                                builder: (context, count, _) {
                                  if (count <= 0) return const SizedBox.shrink();
                                  return Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IgnorePointer(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Actions(
                                actions: <Type, Action<Intent>>{
                                  ActivateIntent: CallbackAction<ActivateIntent>(
                                    onInvoke: (_) => _onPressed(context, LogicalKeyboardKey.enter),
                                  ),
                                  ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                                    onInvoke: (_) => _onPressed(context, LogicalKeyboardKey.enter),
                                  ),
                                },
                                child: InkWell(
                                  focusNode: _focusNode,
                                  autofocus: widget.autofocus,
                                  focusColor: Colors.transparent,
                                  child: _appImage(),
                                  onTap: () => _onPressed(context, LogicalKeyboardKey.enter),
                                  onLongPress: () => _onLongPress(context, LogicalKeyboardKey.enter),
                                  onFocusChange: (focused) {
                                    if (!focused) return;
                                    Scrollable.ensureVisible(
                                      context,
                                      alignment: 0.5,
                                      curve: Curves.easeOutCubic,
                                      duration: const Duration(milliseconds: 150),
                                    );
                                  },
                                ),
                              ),
                              if (_moving) ..._arrows(),
                              TvFocusOverlay(
                                appearance: appearance,
                                isHighlighted: shouldHighlight,
                                pulseController: _animation,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (showAppNames)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.application.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Future<(AppImageType, ImageProvider)> _loadAppBannerOrIcon(AppsService service) async {
    Uint8List bytes = Uint8List(0);

    bytes = await service.getAppBanner(widget.application.packageName);
    AppImageType type = AppImageType.Banner;

    if (bytes.isEmpty) {
      type = AppImageType.Icon;
      bytes = await service.getAppIcon(widget.application.packageName);
    }

    return (type, MemoryImage(bytes));
  }

  Widget _appImage()
  {
    App app = widget.application;

    return FutureBuilder(
      future: _appImageLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final record = snapshot.data;
          if (record == null) return const SizedBox();

          if (record.$1 == AppImageType.Banner) {
            return Ink.image(
              image: record.$2,
              fit: BoxFit.cover,
              onImageError: (e, s) => debugPrint('AppCard banner image error: $e'),
            );
          }
          else {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Ink.image(
                      image: record.$2,
                      height: double.maxFinite,
                      onImageError: (e, s) => debugPrint('AppCard icon image error: $e'),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        app.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                app.name,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              )
            ),
          );
        }
        else {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 0, width: 16),
                  Text("Loading")
                ],
              ),
            ),
          );
        }
      }
    );
  }

  void _focusHighlightModeChanged(FocusHighlightMode mode)
  {
    setState(() { });
  }

  bool _shouldHighlight(BuildContext context)
  {
    return FocusManager.instance.highlightMode == FocusHighlightMode.traditional && Focus.of(context).hasFocus;
  }

  List<Widget> _arrows() {
    final arrows = <Widget>[
      _arrow(Alignment.centerLeft, Icons.keyboard_arrow_left, () {
        widget.onMove(AxisDirection.left);
      }),
      _arrow(Alignment.centerRight, Icons.keyboard_arrow_right, () {
        widget.onMove(AxisDirection.right);
      }),
    ];
    
    // Only show Up/Down arrows for grid layouts
    if (widget.category.type == CategoryType.grid) {
      arrows.add(_arrow(Alignment.topCenter, Icons.keyboard_arrow_up, () {
        widget.onMove(AxisDirection.up);
      }));
      arrows.add(_arrow(Alignment.bottomCenter, Icons.keyboard_arrow_down, () {
        widget.onMove(AxisDirection.down);
      }));
    }

    return arrows;
  }

  Widget _arrow(Alignment alignment, IconData icon, VoidCallback onTap) =>
      ExcludeFocus(
        child: Align(
          alignment: alignment,
          child: Ink(
            decoration: ShapeDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              shape: CircleBorder()
            ),
            child: SizedBox(
              height: 36,
              width: 36,
              child: IconButton(
                icon: Icon(icon, size: 24),
                onPressed: onTap,
                padding: EdgeInsets.all(0)
              )
            )
          )
        ),
      );

  DateTime? _lastMoveTime;

  KeyEventResult _onPressed(BuildContext context, LogicalKeyboardKey? key) {
    if (!_moving) {
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
      }
    }

    if (_moving) {
      if (AppCardKeys.isArrowKey(key)) {
        final now = DateTime.now();
        if (_lastMoveTime != null && now.difference(_lastMoveTime!) < const Duration(milliseconds: 50)) {
          return KeyEventResult.handled;
        }
        _lastMoveTime = now;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => Scrollable.ensureVisible(context,
          alignment: 0.1, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut));
      if (key == LogicalKeyboardKey.arrowLeft) {
        widget.onMove(AxisDirection.left);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        widget.onMove(AxisDirection.up);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        widget.onMove(AxisDirection.right);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        widget.onMove(AxisDirection.down);
      } else if (AppCardKeys.validationKeys.contains(key)) {
        setState(() => _moving = false);
        widget.onMoveEnd();
      } else if (AppCardKeys.cancelKeys.contains(key)) {
        setState(() => _moving = false);
        widget.onMoveCancel?.call();
        context.read<LauncherState>().suppressBackNavigation();
      } else {
        return KeyEventResult.ignored;
      }

      return KeyEventResult.handled;
    } else if (key == null || AppCardKeys.validationKeys.contains(key)) {
      if (!_clicked) {
        setState(() => _clicked = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          context.read<AppsService>().launchApp(widget.application);
          // Reset after a short delay so it looks normal when user returns
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _clicked = false);
            }
          });
        });
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp && widget.handleUpNavigationToSettings) {
      Actions.invoke(context, const MoveFocusToSettingsIntent());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onLongPress(BuildContext context, LogicalKeyboardKey? key) {
    if (!_moving && (key == null || AppCardKeys.longPressableKeys.contains(key))) {
      _showPanel(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showPanel(BuildContext context) async {
    try {
      final result = await showDialog<ApplicationInfoPanelResult>(
        context: context,
        builder: (context) => ApplicationInfoPanel(
          category: widget.category,
          application: widget.application,
        ),
      );
      if (result == ApplicationInfoPanelResult.reorderApp) {
        setState(() => _moving = true);
      }
    } catch (e, stackTrace) {
      print('Error showing panel: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

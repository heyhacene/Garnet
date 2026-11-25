import 'dart:ui' show ImageFilter;

import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Atmospheric full-screen wallpaper backdrop with optional static blur and
/// progressive multi-stop dark scrim underneath the app rows for TV contrast.
///
/// Wrapped in a [RepaintBoundary] by the caller so D-pad card navigation never
/// triggers wallpaper or blur repaints on Android TV GPUs.
class TvWallpaperBackdrop extends StatelessWidget {
  const TvWallpaperBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WallpaperService>(
      builder: (context, wallpaperService, _) {
        return Selector<SettingsService, ({double scrim, double blur})>(
          selector: (_, settings) => (
            scrim: settings.wallpaperScrimIntensity > 0
                ? settings.wallpaperScrimIntensity.clamp(0.15, 0.90)
                : 0.45,
            blur: settings.wallpaperBlurSigma.clamp(0.0, 16.0),
          ),
          builder: (context, backdropSettings, _) {
            Widget background;
            if (wallpaperService.wallpaper != null) {
              final physicalSize = MediaQuery.sizeOf(context);
              background = Image(
                image: wallpaperService.wallpaper!,
                key: Key("background_${wallpaperService.version}"),
                fit: BoxFit.cover,
                height: physicalSize.height,
                width: physicalSize.width,
              );
            } else {
              background = Container(
                key: const Key("background"),
                decoration: BoxDecoration(
                  gradient: wallpaperService.gradient.gradient,
                ),
              );
            }

            // Apply ImageFiltered only when blur > 0 to avoid extra GPU pass when crisp.
            if (backdropSettings.blur > 0.1) {
              background = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: backdropSettings.blur,
                  sigmaY: backdropSettings.blur,
                  tileMode: TileMode.clamp,
                ),
                child: background,
              );
            }

            final double s = backdropSettings.scrim;
            final double topOpacity = (s * 0.55).clamp(0.08, 0.70);
            final double heroOpacity = (s * 0.24).clamp(0.04, 0.45);
            final double cardsOpacity = s;
            final double bottomOpacity = (s + 0.18).clamp(0.25, 0.94);

            return Stack(
              fit: StackFit.expand,
              children: [
                background,
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.28, 0.62, 1.0],
                      colors: [
                        Colors.black.withOpacity(topOpacity),
                        Colors.black.withOpacity(heroOpacity),
                        Colors.black.withOpacity(cardsOpacity),
                        Colors.black.withOpacity(bottomOpacity),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

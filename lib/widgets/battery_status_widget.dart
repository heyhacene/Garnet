import 'package:flauncher/providers/battery_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatteryStatusWidget extends StatelessWidget {
  final bool showIcon;
  final bool showPercentage;

  const BatteryStatusWidget({
    super.key,
    required this.showIcon,
    required this.showPercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIcon && !showPercentage) {
      return const SizedBox.shrink();
    }

    final BatteryService batteryService;
    try {
      batteryService = context.watch<BatteryService>();
    } on ProviderNotFoundException {
      return const SizedBox.shrink();
    }

    if (!batteryService.hasBatteryData) {
      return const SizedBox.shrink();
    }

    final int level = batteryService.level;
    final bool charging = batteryService.isCharging;
    final Color iconColor = _batteryColor(level, charging);

    return Container(
      key: const Key('statusbar_battery'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              _batteryIcon(level, charging),
              key: const Key('statusbar_battery_icon'),
              size: 18,
              color: iconColor,
              shadows: const [
                Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          if (showIcon && showPercentage) const SizedBox(width: 6),
          if (showPercentage)
            Text(
              '$level%',
              key: const Key('statusbar_battery_percentage'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static IconData _batteryIcon(int level, bool charging) {
    if (charging) return Icons.battery_charging_full;
    if (level >= 95) return Icons.battery_full;
    if (level >= 80) return Icons.battery_6_bar;
    if (level >= 65) return Icons.battery_5_bar;
    if (level >= 50) return Icons.battery_4_bar;
    if (level >= 35) return Icons.battery_3_bar;
    if (level >= 20) return Icons.battery_2_bar;
    if (level >= 10) return Icons.battery_1_bar;
    return Icons.battery_alert;
  }

  static Color _batteryColor(int level, bool charging) {
    if (charging) return const Color(0xFF34D399);
    if (level <= 15) return const Color(0xFFF87171);
    if (level <= 30) return const Color(0xFFFBBF24);
    return Colors.white;
  }
}

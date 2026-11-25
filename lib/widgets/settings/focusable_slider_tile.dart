import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// D-pad friendly numeric slider/stepper for Android TV settings panels.
///
/// While focused, Left / Right keys adjust the value smoothly in real time
/// (including held-key repeats) while Up / Down traverse normally.
class FocusableSliderTile extends StatefulWidget {
  final String title;
  final String valueLabel;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final bool autofocus;

  const FocusableSliderTile({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<FocusableSliderTile> createState() => _FocusableSliderTileState();
}

class _FocusableSliderTileState extends State<FocusableSliderTile> {
  bool _focused = false;

  void _decrement() {
    final next = (widget.value - widget.step).clamp(widget.min, widget.max);
    if ((next - widget.value).abs() > 1e-6) {
      widget.onChanged(next);
    }
  }

  void _increment() {
    final next = (widget.value + widget.step).clamp(widget.min, widget.max);
    if ((next - widget.value).abs() > 1e-6) {
      widget.onChanged(next);
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _decrement();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _increment();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final double ratio = widget.max > widget.min
        ? ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Focus(
        autofocus: widget.autofocus,
        onKeyEvent: _handleKey,
        onFocusChange: (hasFocus) {
          setState(() => _focused = hasFocus);
          if (hasFocus) {
            Scrollable.ensureVisible(
              context,
              alignment: 0.5,
              duration: const Duration(milliseconds: 100),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _focused ? primary.withOpacity(0.14) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focused ? primary : Colors.white.withOpacity(0.06),
              width: _focused ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon, size: 18, color: _focused ? primary : Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: _focused ? FontWeight.w600 : FontWeight.normal,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _decrement,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: _focused ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _focused ? primary.withOpacity(0.28) : Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.valueLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _increment,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: _focused ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _focused ? primary : primary.withOpacity(0.65),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

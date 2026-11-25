import 'package:flauncher/widgets/settings/focusable_slider_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FocusableSliderTile adjusts value on D-pad Left and Right keys', (tester) async {
    double current = 12.0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: FocusableSliderTile(
              autofocus: true,
              icon: Icons.rounded_corner,
              title: 'Corner radius',
              valueLabel: '${current.round()} dp',
              value: current,
              min: 0,
              max: 28,
              step: 2,
              onChanged: (next) => setState(() => current = next),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 dp'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('14 dp'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('10 dp'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:flauncher/providers/battery_service.dart';
import 'package:flauncher/widgets/battery_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockFLauncherChannel mockChannel;
  late StreamController<Map<String, dynamic>> streamController;

  setUp(() {
    mockChannel = MockFLauncherChannel();
    streamController = StreamController<Map<String, dynamic>>.broadcast();
    when(mockChannel.addBatteryChangedListener(any)).thenAnswer((invocation) {
      final listener = invocation.positionalArguments[0] as void Function(Map<String, dynamic>);
      return streamController.stream.listen(listener);
    });
  });

  tearDown(() async {
    await streamController.close();
  });

  Widget wrap(BatteryService service, {required bool showIcon, required bool showPercentage}) {
    return ChangeNotifierProvider<BatteryService>.value(
      value: service,
      child: MaterialApp(
        home: Scaffold(
          body: BatteryStatusWidget(
            showIcon: showIcon,
            showPercentage: showPercentage,
          ),
        ),
      ),
    );
  }

  testWidgets('hides icon and percentage independently', (tester) async {
    when(mockChannel.getBatteryInfo()).thenAnswer(
      (_) async => {'present': true, 'level': 84, 'charging': false},
    );
    final service = BatteryService(mockChannel);
    await tester.pumpWidget(wrap(service, showIcon: true, showPercentage: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statusbar_battery_icon')), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);

    await tester.pumpWidget(wrap(service, showIcon: true, showPercentage: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statusbar_battery_icon')), findsOneWidget);
    expect(find.text('84%'), findsNothing);

    await tester.pumpWidget(wrap(service, showIcon: false, showPercentage: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statusbar_battery_icon')), findsNothing);
    expect(find.text('84%'), findsOneWidget);

    await tester.pumpWidget(wrap(service, showIcon: false, showPercentage: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statusbar_battery')), findsNothing);

    service.dispose();
  });

  testWidgets('hides cleanly when device reports no battery present', (tester) async {
    when(mockChannel.getBatteryInfo()).thenAnswer(
      (_) async => {'present': false, 'level': -1, 'charging': false},
    );
    final service = BatteryService(mockChannel);
    await tester.pumpWidget(wrap(service, showIcon: true, showPercentage: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statusbar_battery')), findsNothing);
    service.dispose();
  });
}

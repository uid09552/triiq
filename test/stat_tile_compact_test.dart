import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/widgets/stat_tile.dart';

void main() {
  testWidgets('compact tile shows its figure and reports taps', (tester) async {
    var taps = 0;
    var longPresses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              child: StatTile(
                compact: true,
                label: 'TSS today',
                value: '82',
                subtitle: 'of 90 planned',
                icon: Icons.bolt_outlined,
                onTap: () => taps++,
                onLongPress: () => longPresses++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('TSS today'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    await tester.tap(find.text('82'));
    await tester.longPress(find.text('82'));
    expect(taps, 1);
    expect(longPresses, 1);
  });

  testWidgets('a mouse resting on the tile opens its preview card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              child: StatTile(
                compact: true,
                label: 'CTL',
                value: '55.0',
                hoverPreview: (_) => const Text('preview-card'),
              ),
            ),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    expect(find.text('preview-card'), findsNothing);

    await mouse.moveTo(tester.getCenter(find.text('55.0')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('preview-card'), findsOneWidget);

    await mouse.moveTo(const Offset(2, 2));
    await tester.pump();
    expect(find.text('preview-card'), findsNothing);
  });
}

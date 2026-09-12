import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urplant/config/theme.dart';

void main() {
  testWidgets('Theme builds and renders a simple card', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UrPlantTheme.light,
        home: const Scaffold(
          body: Center(
            child: Text('UrPlant', key: Key('brand')),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('brand')), findsOneWidget);
  });

  testWidgets('StaggerIn renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaggerIn(
            index: 1,
            child: const Text('content', key: Key('staggered')),
          ),
        ),
      ),
    );
    // settle the entrance animation
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('staggered')), findsOneWidget);
  });
}

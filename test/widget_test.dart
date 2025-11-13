// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pseudoplay/main.dart';

void main() {
  testWidgets('App renders home view', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PseudoPlayApp()));

    // The splash route should be the initial entry point.
    expect(find.byType(PseudoPlayApp), findsOneWidget);
  });
}

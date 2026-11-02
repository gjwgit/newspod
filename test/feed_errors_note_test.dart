/// Tests for the note that feeds could not be read.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/widgets/feed_errors_note.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('on a desktop or phone it counts the feeds and points to Feeds', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const FeedErrorsNote(count: 2, web: false)));

    expect(find.text('2 feeds could not be read.'), findsOneWidget);
    expect(find.text('Feeds says why.'), findsOneWidget);
    expect(find.text('Install'), findsNothing);
  });

  testWidgets('in a browser it says why and offers the install guide', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const FeedErrorsNote(count: 4, web: true)));

    expect(find.text('A browser cannot read most news feeds.'), findsOneWidget);
    expect(find.textContaining('Install NewsPod on your'), findsOneWidget);
    expect(find.text('Install'), findsOneWidget);
  });
}

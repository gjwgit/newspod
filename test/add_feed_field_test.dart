/// Tests for adding a feed by its address.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/utils/feed_parser.dart';
import 'package:newspod/widgets/add_feed_field.dart';

Future<ParsedFeed> _fetch(String url, {String source = ''}) async {
  if (url.contains('broken')) {
    throw const FormatException('This is not an RSS or Atom feed.');
  }
  return (title: 'Example News', stories: const <Story>[]);
}

Widget _wrap() => const MaterialApp(
  home: Scaffold(body: AddFeedField(fetch: _fetch)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('an empty address says what to enter', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(
      find.text('Enter the address of an RSS or Atom feed.'),
      findsOneWidget,
    );
  });

  testWidgets('a feed already listed is refused', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.enterText(find.byType(TextField), feedList.feeds.first.url);
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('This is already one of your feeds.'), findsOneWidget);
  });

  testWidgets('a broken feed says why and is not added; editing clears it', (
    tester,
  ) async {
    final before = feedList.feeds.length;

    await tester.pumpWidget(_wrap());
    await tester.enterText(find.byType(TextField), 'example.com/broken');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('This is not an RSS or Atom feed.'), findsOneWidget);
    expect(feedList.feeds, hasLength(before));

    await tester.enterText(find.byType(TextField), 'example.com/rss');
    await tester.pump();

    expect(find.text('This is not an RSS or Atom feed.'), findsNothing);
  });

  testWidgets('a working feed is added under its own title', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.enterText(find.byType(TextField), 'example.com/news.xml');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(feedList.contains('https://example.com/news.xml'), isTrue);
    expect(feedList.feeds.last.title, 'Example News');
    expect(find.text('Added Example News.'), findsOneWidget);

    // The bar hides itself after a few seconds, which the test waits for.

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });
}

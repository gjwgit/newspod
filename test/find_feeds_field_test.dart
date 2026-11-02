/// Tests for finding feeds and adding them.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/models/found_feed.dart';
import 'package:newspod/models/story.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/utils/feed_parser.dart';
import 'package:newspod/widgets/find_feeds_field.dart';

Future<List<FoundFeed>> _find(String text) async {
  if (text == 'nothing') throw const FormatException('No feeds were found.');

  return [
    FoundFeed(url: feedList.feeds.first.url, title: 'Already Here'),
    const FoundFeed(
      url: 'https://example.com/news.xml',
      title: 'Example',
      description: 'The news from Example.',
      followers: 42,
    ),
    const FoundFeed(url: 'https://example.com/broken', title: 'Broken'),
  ];
}

Future<ParsedFeed> _fetch(String url, {String source = ''}) async {
  if (url.contains('broken')) {
    throw const FormatException('This is not an RSS or Atom feed.');
  }
  return (title: 'Example News', stories: const <Story>[]);
}

Widget _wrap() => const MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: FindFeedsField(find: _find, fetch: _fetch),
    ),
  ),
);

Future<void> _search(WidgetTester tester, String text) async {
  await tester.pumpWidget(_wrap());
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.text('Find'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('nothing entered says what to enter', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.text('Find'));
    await tester.pump();

    expect(
      find.text('Enter a feed or site address, or words to search for.'),
      findsOneWidget,
    );
  });

  testWidgets('nothing found says so; editing clears it', (tester) async {
    await _search(tester, 'nothing');

    expect(find.text('No feeds were found.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'canberra');
    await tester.pump();

    expect(find.text('No feeds were found.'), findsNothing);
  });

  testWidgets('the feeds found are listed, those added marked', (tester) async {
    await _search(tester, 'news');

    expect(find.text('Already Here'), findsOneWidget);
    expect(find.text('42 followers · The news from Example.'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Add'), findsNWidgets(2));
  });

  testWidgets('a broken feed says why and is not added', (tester) async {
    final before = feedList.feeds.length;

    await _search(tester, 'news');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('This is not an RSS or Atom feed.'), findsOneWidget);
    expect(feedList.feeds, hasLength(before));
  });

  testWidgets('a working feed is added under its own title', (tester) async {
    await _search(tester, 'news');
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(feedList.contains('https://example.com/news.xml'), isTrue);
    expect(feedList.feeds.last.title, 'Example News');
    expect(find.text('Added Example News.'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(2));

    // The bar hides itself after a few seconds, which the test waits for.

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });
}

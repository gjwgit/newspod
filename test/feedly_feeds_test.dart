/// Tests for reading the answer to a Feedly search.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/feedly_feeds.dart';

void main() {
  test('each result is a feed, by address, name and followers', () {
    final found = feedlyFeeds('''
{"results": [
  {"feedId": "feed/https://example.com/rss", "title": "Example &amp; Co",
   "description": "<p>The  news.</p>", "subscribers": 743},
  {"feedId": "feed/http://example.org/feed/"},
  {"feedId": "topic/news", "title": "Not a feed"}
]}
''');

    expect(found, hasLength(2));
    expect(found.first.url, 'https://example.com/rss');
    expect(found.first.title, 'Example & Co');
    expect(found.first.description, 'The news.');
    expect(found.first.followers, 743);
    expect(found.last.url, 'https://example.org/feed/');
    expect(found.last.title, 'http://example.org/feed/');
    expect(found.last.description, isEmpty);
    expect(found.last.followers, isNull);
  });

  test('an answer without results has no feeds', () {
    expect(feedlyFeeds('{}'), isEmpty);
  });
}

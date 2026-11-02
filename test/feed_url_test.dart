/// Tests for the address of a feed as typed.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/feed_url.dart';

void main() {
  test('an address is trimmed and given https:// when it has no scheme', () {
    expect(
      feedUrl('  https://example.com/feed.xml '),
      'https://example.com/feed.xml',
    );
    expect(feedUrl('example.com/rss'), 'https://example.com/rss');
    expect(feedUrl('http://example.com/rss'), 'http://example.com/rss');
  });

  test('anything that cannot be a web address is refused', () {
    expect(feedUrl(''), isNull);
    expect(feedUrl('not a feed'), isNull);
    expect(feedUrl('localhost'), isNull);
    expect(feedUrl('ftp://example.com/feed'), isNull);
  });
}

/// Tests for the feeds a web page links to.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/feed_links.dart';

void main() {
  final base = Uri.parse('https://example.com/news/');

  test('feed links are found, resolved and named', () {
    final found = feedLinks('''
<html><head><title>Example News</title>
<link rel="alternate" type="application/rss+xml" title="Top Stories"
  href="/feeds/top.xml">
<link rel="Alternate" type="application/atom+xml" href="sport.atom">
<link rel="alternate" type="text/html" href="/other">
<link rel="stylesheet" type="application/rss+xml" href="/not-a-feed">
<link rel="alternate" type="application/rss+xml" href="/feeds/top.xml">
</head><body></body></html>
''', base);

    expect(found.map((f) => f.url), [
      'https://example.com/feeds/top.xml',
      'https://example.com/news/sport.atom',
    ]);
    expect(found.map((f) => f.title), ['Top Stories', 'Example News']);
  });

  test('a page without a title names its feeds by the site', () {
    final found = feedLinks(
      '<link rel="alternate" type="application/rss+xml" href="rss">',
      base,
    );

    expect(found.single.title, 'example.com');
  });

  test('a page without feed links has none', () {
    expect(feedLinks('<html><body>News</body></html>', base), isEmpty);
  });
}

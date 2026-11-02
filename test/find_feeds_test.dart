/// Tests for finding feeds by address or by words.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/services/find_feeds.dart';

const _feed = '''
<rss version="2.0"><channel><title>Example News</title></channel></rss>
''';

const _page = '''
<html><head><title>Example</title>
<link rel="alternate" type="application/rss+xml" href="/rss"></head></html>
''';

Future<String> _read(String url) async => switch (url) {
  'https://example.com/rss' => _feed,
  'https://example.com' => _page,
  _ when url.startsWith('https://cloud.feedly.com/') =>
    url.contains('query=nothing')
        ? '{"results": []}'
        : '{"results": [{"feedId": "feed/https://example.com/rss"}]}',
  _ => '<html></html>',
};

void main() {
  test('a feed address finds the feed itself', () async {
    final found = await findFeeds('example.com/rss', read: _read);

    expect(found.single.url, 'https://example.com/rss');
    expect(found.single.title, 'Example News');
  });

  test('a site address finds the feeds the site links to', () async {
    final found = await findFeeds('example.com', read: _read);

    expect(found.single.url, 'https://example.com/rss');
  });

  test('words are searched for on Feedly', () async {
    final found = await findFeeds('canberra news', read: _read);

    expect(found.single.url, 'https://example.com/rss');
  });

  test('finding nothing says so', () async {
    expect(findFeeds('nothing', read: _read), throwsA(isA<FormatException>()));
    expect(
      findFeeds('example.org', read: _read),
      throwsA(isA<FormatException>()),
    );
  });
}

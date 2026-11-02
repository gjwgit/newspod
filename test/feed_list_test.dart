/// Tests for the list of feeds kept on the device.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/constants/default_feeds.dart';
import 'package:newspod/models/feed.dart';
import 'package:newspod/services/feed_list.dart';

const _extra = Feed(url: 'https://example.com/rss', title: 'Example');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a new install starts with the default feeds', () async {
    final list = FeedList(connected: () async => false);
    await list.load();

    expect(list.feeds.map((f) => f.url), defaultFeeds.map((f) => f.url));
  });

  test('added and removed feeds are saved and read back', () async {
    final list = FeedList(connected: () async => false);
    await list.add(_extra);
    await list.remove(defaultFeeds.first);

    final again = FeedList(connected: () async => false);
    await again.load();

    expect(again.contains(_extra.url), isTrue);
    expect(again.contains(defaultFeeds.first.url), isFalse);
    expect(again.feeds.last.title, 'Example');
  });

  test('a removed feed put back returns to where it was', () async {
    final list = FeedList(connected: () async => false);
    final second = defaultFeeds[1];

    final at = await list.remove(second);
    await list.add(second, at: at);

    expect(list.feeds[1].url, second.url);
  });
}

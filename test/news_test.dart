/// Tests for gathering the news from the feeds.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/models/feed.dart';
import 'package:newspod/models/story.dart';
import 'package:newspod/models/story_place.dart';
import 'package:newspod/services/dismissed_links.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/later_stories.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/utils/feed_parser.dart';

Story _story(String link, String source, int? day) => Story(
  title: link,
  link: link,
  source: source,
  published: day == null ? null : DateTime.utc(2026, 11, day),
);

// The news with no Pod, as when not logged in.

News _news(FeedList feeds) => News(
  feeds,
  _fetch,
  DismissedLinks(connected: () async => false),
  LaterStories(connected: () async => false),
);

// Feeds as the fake fetcher answers them, by address.

Future<ParsedFeed> _fetch(String url, {String source = ''}) async {
  return switch (url) {
    'https://a.example/rss' => (
      title: 'A',
      stories: [_story('one', source, 1), _story('undated', source, null)],
    ),
    'https://b.example/rss' => (
      title: 'B',
      stories: [_story('two', source, 2), _story('one', source, 1)],
    ),
    _ => throw const FormatException('This is not an RSS or Atom feed.'),
  };
}

void main() {
  late FeedList feeds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    feeds = FeedList(connected: () async => false);
    for (final f in feeds.feeds) {
      await feeds.remove(f);
    }
    await feeds.add(const Feed(url: 'https://a.example/rss', title: 'A'));
    await feeds.add(const Feed(url: 'https://b.example/rss', title: 'B'));
  });

  test('stories are merged newest first, once each, undated last', () async {
    final news = _news(feeds);
    await news.refresh();

    expect(news.stories.map((s) => s.link), ['two', 'one', 'undated']);
    expect(news.stories.first.source, 'B');
    expect(news.errors, isEmpty);
    expect(news.loading, isFalse);
  });

  test('a feed that fails is noted and the others still read', () async {
    final news = _news(feeds);
    await feeds.add(const Feed(url: 'https://bad.example/', title: 'Bad'));
    await news.refresh();

    expect(news.errors, {
      'https://bad.example/': 'This is not an RSS or Atom feed.',
    });
    expect(news.stories, hasLength(3));
  });

  test('a dismissed story stays out after a refresh, until restored', () async {
    final news = _news(feeds);
    await news.load();
    await news.refresh();

    await news.move(news.stories.first, StoryPlace.dismissed);
    expect(news.stories.map((s) => s.link), ['one', 'undated']);
    expect(news.dismissed.map((s) => s.link), ['two']);

    await news.refresh();
    expect(news.stories.map((s) => s.link), ['one', 'undated']);

    await news.move(_story('two', 'B', 2), StoryPlace.news);
    expect(news.stories.map((s) => s.link), ['two', 'one', 'undated']);
    expect(news.dismissed, isEmpty);
  });

  test('dismissed stories are remembered on the device', () async {
    final news = _news(feeds);
    await news.refresh();
    await news.move(news.stories.first, StoryPlace.dismissed);

    final again = _news(feeds);
    await again.load();
    await again.refresh();

    expect(again.stories.map((s) => s.link), ['one', 'undated']);
  });

  test('a story kept for later leaves the news, stays kept after its feed '
      'drops it, and is remembered on the device', () async {
    final news = _news(feeds);
    await news.load();
    await news.refresh();

    await news.move(news.stories.first, StoryPlace.later);
    expect(news.stories.map((s) => s.link), ['one', 'undated']);
    expect(news.later.single.title, 'two');

    await feeds.remove(feeds.feeds.last);
    await news.refresh();
    expect(news.later.single.published, DateTime.utc(2026, 11, 2));

    final again = _news(feeds);
    await again.load();
    expect(again.later.single.link, 'two');

    await again.move(again.later.single, StoryPlace.dismissed);
    expect(again.later, isEmpty);
  });

  test('changing the feeds reads the news again', () async {
    final news = _news(feeds);
    await news.refresh();

    await feeds.remove(feeds.feeds.last);
    await news.refresh();

    expect(news.stories.map((s) => s.link), ['one', 'undated']);
  });
}

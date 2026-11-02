/// Tests for keeping the feeds and the dismissed stories in step with the
/// Pod, through a Pod in memory.

library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/constants/default_feeds.dart';
import 'package:newspod/models/feed.dart';
import 'package:newspod/services/dismissed_links.dart';
import 'package:newspod/services/feed_list.dart';

/// A Pod in memory, logged in or not, that can be made to fail.

class _Pod {
  final files = <String, Object?>{};
  bool online = false;
  bool failing = false;
  int writes = 0;

  Future<bool> _connected() async => online;

  Future<Object?> _read(String file) async {
    if (failing) throw Exception('No route to the Pod');

    // A copy, as a read from the Pod would be.

    return files[file] == null ? null : jsonDecode(jsonEncode(files[file]));
  }

  Future<void> _write(String file, Object json) async {
    writes++;
    files[file] = json;
  }

  DismissedLinks links() =>
      DismissedLinks(connected: _connected, read: _read, write: _write);

  FeedList feeds() =>
      FeedList(connected: _connected, read: _read, write: _write);
}

const _bbc = 'https://feeds.bbci.co.uk/news/world/rss.xml';
const _extra = Feed(url: 'https://example.com/rss', title: 'Example');

List<String> _urls(Object? json) => [
  for (final feed in json as List) (feed as Map)['url'] as String,
];

void main() {
  late _Pod pod;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    pod = _Pod();
  });

  group('dismissed stories', () {
    test('logged out, a dismissal is kept on the device for later', () async {
      final linux = pod.links();
      await linux.add('a');
      await linux.sync();

      expect(linux.contains('a'), isTrue);
      expect(pod.writes, 0);

      final again = pod.links();
      await again.load();
      expect(again.contains('a'), isTrue);
    });

    test('once logged in, the queue is merged with the Pod', () async {
      pod.files['dismissed.ttl'] = ['from-android'];

      final linux = pod.links();
      await linux.add('a');
      await linux.add('b');

      pod.online = true;
      await linux.sync();

      expect(pod.files['dismissed.ttl'], ['from-android', 'a', 'b']);
      expect(linux.contains('from-android'), isTrue);

      // Nothing queued and nothing new: the Pod is not written again.

      final writes = pod.writes;
      await linux.sync();
      expect(pod.writes, writes);
    });

    test('a story dismissed on one device is gone from another', () async {
      pod.online = true;
      final android = pod.links();
      await android.add('a');
      await android.sync();

      final linux = pod.links();
      var heard = false;
      linux.addListener(() => heard = true);
      await linux.sync();

      expect(linux.contains('a'), isTrue);
      expect(heard, isTrue);
    });

    test('an Undo restores the story on the Pod too', () async {
      pod.files['dismissed.ttl'] = ['a', 'b'];
      final linux = pod.links();
      await linux.remove('a');

      pod.online = true;
      await linux.sync();

      expect(pod.files['dismissed.ttl'], ['b']);
      expect(linux.contains('a'), isFalse);
    });

    test(
      'a Pod that cannot be read keeps the queue for the next sync',
      () async {
        pod
          ..online = true
          ..failing = true;
        final linux = pod.links();
        await linux.add('a');
        await linux.sync();

        expect(pod.writes, 0);
        expect(linux.contains('a'), isTrue);

        pod.failing = false;
        await linux.sync();

        expect(pod.files['dismissed.ttl'], ['a']);
      },
    );

    test('only the latest links are kept', () async {
      pod
        ..online = true
        ..files['dismissed.ttl'] = [
          for (var i = 0; i < DismissedLinks.keep; i++) 'old$i',
        ];
      final linux = pod.links();
      await linux.add('new');
      await linux.sync();

      final links = pod.files['dismissed.ttl'] as List;
      expect(links, hasLength(DismissedLinks.keep));
      expect(links.first, 'old1');
      expect(links.last, 'new');
    });
  });

  group('feeds', () {
    test(
      'a new install starts with the defaults, kept on the device',
      () async {
        final linux = pod.feeds();
        await linux.load();

        expect(linux.feeds.map((f) => f.url), defaultFeeds.map((f) => f.url));
      },
    );

    test('the first device to sync gives the Pod its feeds', () async {
      final android = pod.feeds();
      await android.add(_extra);

      pod.online = true;
      await android.sync();

      expect(_urls(pod.files['feeds.ttl']), [
        ...defaultFeeds.map((f) => f.url),
        _extra.url,
      ]);
    });

    test(
      'another device takes the Pod\'s feeds in place of its defaults',
      () async {
        pod
          ..online = true
          ..files['feeds.ttl'] = [_extra.toJson()];

        final linux = pod.feeds();
        var heard = false;
        linux.addListener(() => heard = true);
        await linux.sync();

        expect(linux.feeds.map((f) => f.url), [_extra.url]);
        expect(heard, isTrue);
      },
    );

    test('feeds added and removed while logged out reach the Pod', () async {
      pod.files['feeds.ttl'] = [for (final f in defaultFeeds) f.toJson()];

      final linux = pod.feeds();
      await linux.remove(defaultFeeds[1]);
      await linux.add(_extra);

      pod.online = true;
      await linux.sync();

      final urls = _urls(pod.files['feeds.ttl']);
      expect(urls, isNot(contains(_bbc)));
      expect(urls.last, _extra.url);
    });

    test('a feed removed and put back returns to where it was', () async {
      final linux = pod.feeds();
      final second = defaultFeeds[1];

      final at = await linux.remove(second);
      await linux.add(second, at: at);

      expect(linux.feeds[1].url, second.url);

      final again = pod.feeds();
      await again.load();
      expect(again.feeds[1].url, second.url);
    });
  });
}

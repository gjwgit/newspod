/// The stories from all the feeds, newest first.
//
// Time-stamp: <>
//
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/foundation.dart';

import 'package:newspod/models/feed.dart';
import 'package:newspod/models/story.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/utils/feed_parser.dart';

/// Reads a feed, given its address and the name to credit its stories to.

typedef FeedFetcher = Future<ParsedFeed> Function(String url, {String source});

/// The news: every feed's stories in one list, newest first, read again on
/// [refresh] and whenever the feeds change.

class News extends ChangeNotifier {
  News(this._feeds, [this._fetch = fetchFeed]) {
    _feeds.addListener(refresh);
  }

  final FeedList _feeds;
  final FeedFetcher _fetch;

  Future<void>? _running;
  bool _again = false;

  /// The stories, newest first, those without a date last.

  List<Story> stories = const [];

  /// Why each feed that could not be read failed, by its address.

  Map<String, String> errors = const {};

  /// Whether the feeds are being read now.

  bool get loading => _running != null;

  /// Read every feed again. A refresh asked for while one is running runs
  /// once more when it finishes, so a feed just added is not missed.

  Future<void> refresh() {
    if (_running case final running?) {
      _again = true;
      return running;
    }

    return _running = _run();
  }

  Future<void> _run() async {
    notifyListeners();

    do {
      _again = false;
      final results = await Future.wait(_feeds.feeds.map(_read));

      stories = _merge([for (final r in results) ...r.stories]);
      errors = {for (final r in results) r.feed.url: ?r.error};
    } while (_again);

    _running = null;
    notifyListeners();
  }

  Future<({Feed feed, List<Story> stories, String? error})> _read(
    Feed feed,
  ) async {
    try {
      final parsed = await _fetch(feed.url, source: feed.title);
      return (feed: feed, stories: parsed.stories, error: null);
    } catch (e) {
      return (feed: feed, stories: const <Story>[], error: feedError(e));
    }
  }

  // 20261102 gjw A story in more than one feed is listed once.

  static List<Story> _merge(List<Story> all) {
    final seen = <String>{};
    final unique = [
      for (final story in all)
        if (seen.add(story.link)) story,
    ];

    return unique..sort((a, b) {
      final at = a.published;
      final bt = b.published;
      if (at != null && bt != null) return bt.compareTo(at);

      return (at == null ? 1 : 0) - (bt == null ? 1 : 0);
    });
  }
}

/// The app's one news list.

final news = News(feedList);

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

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:newspod/models/feed.dart';
import 'package:newspod/models/story.dart';
import 'package:newspod/models/story_place.dart';
import 'package:newspod/services/dismissed_links.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/services/kept_stories.dart';
import 'package:newspod/utils/feed_parser.dart';

/// Reads a feed, given its address and the name to credit its stories to.

typedef FeedFetcher = Future<ParsedFeed> Function(String url, {String source});

/// The news: every feed's stories in one list, newest first, read again on
/// [refresh] and whenever the feeds change. A story swiped away stays away,
/// and one kept for later or viewed stays kept, on this device and, through
/// the Pod, on the others.

class News extends ChangeNotifier {
  News(
    this._feeds, [
    this._fetch = fetchFeed,
    DismissedLinks? dismissed,
    KeptStories? later,
    KeptStories? viewed,
  ]) : _dismissed = dismissed ?? DismissedLinks(),
       _later = later ?? KeptStories(name: 'later'),
       _viewed = viewed ?? KeptStories(name: 'viewed', keep: 500) {
    _feeds.addListener(refresh);
    _dismissed.addListener(_reshow);
    _later.addListener(_reshow);
    _viewed.addListener(_reshow);
  }

  final FeedList _feeds;
  final FeedFetcher _fetch;
  final DismissedLinks _dismissed;
  final KeptStories _later;
  final KeptStories _viewed;

  Map<StoryPlace, KeptStories> get _kept => {
    StoryPlace.later: _later,
    StoryPlace.viewed: _viewed,
  };

  Future<void>? _running;
  bool _again = false;

  List<Story> _all = const [];

  /// The stories, newest first, those without a date last, less those
  /// dismissed, kept for later or viewed.

  List<Story> stories = const [];

  /// The stories dismissed that the feeds still have, newest first, for
  /// Dismissed to list and bring back.

  List<Story> dismissed = const [];

  /// The stories kept for later, the latest kept first, whether or not the
  /// feeds still have them.

  List<Story> get later => _later.items.reversed.toList();

  /// The stories opened from the news, the latest viewed first, whether or
  /// not the feeds still have them.

  List<Story> get viewed => _viewed.items.reversed.toList();

  /// Why each feed that could not be read failed, by its address.

  Map<String, String> errors = const {};

  /// Whether the feeds are being read now.

  bool get loading => _running != null;

  /// Read which stories were dismissed, kept for later and viewed, before
  /// the first [refresh].

  Future<void> load() =>
      Future.wait([_dismissed.load(), _later.load(), _viewed.load()]);

  /// Move [story] to [place], out of the list it was in.

  Future<void> move(Story story, StoryPlace place) {
    final link = story.link;

    // 20261103 gjw The changes start together, before any is awaited, so the
    // story is never shown in two lists, or back in the news, in between.

    return Future.wait([
      for (final MapEntry(key: at, value: kept) in _kept.entries)
        if (at == place)
          kept.add(story)
        else if (kept.contains(link))
          kept.remove(link),
      if (place == StoryPlace.dismissed)
        _dismissed.add(link)
      else if (_dismissed.contains(link))
        _dismissed.remove(link),
    ]);
  }

  /// Bring the feeds, and the stories dismissed, kept for later and viewed,
  /// up to date with the Pod, as on logging in.

  Future<void> sync() => Future.wait([
    _feeds.sync(),
    _dismissed.sync(),
    _later.sync(),
    _viewed.sync(),
  ]);

  // The stories dismissed, kept for later or viewed changed, here or from
  // the Pod.

  void _reshow() {
    _split();
    notifyListeners();
  }

  void _split() {
    stories = [
      for (final story in _all)
        if (!_dismissed.contains(story.link) &&
            !_kept.values.any((kept) => kept.contains(story.link)))
          story,
    ];
    dismissed = [
      for (final story in _all)
        if (_dismissed.contains(story.link)) story,
    ];
  }

  /// Read every feed again. A refresh asked for while one is running runs
  /// once more when it finishes, so a feed just added is not missed.

  Future<void> refresh() {
    if (_running case final running?) {
      _again = true;
      return running;
    }

    return _running = _run();
  }

  // 20261102 gjw A refresh also syncs the feeds, and the stories dismissed,
  // kept for later and viewed, with the Pod, so changes made on another device show
  // here, and any queued here reach the Pod. The feeds changing then reads
  // the news again.

  Future<void> _run() async {
    notifyListeners();
    unawaited(sync());

    do {
      _again = false;
      final results = await Future.wait(_feeds.feeds.map(_read));

      _all = _merge([for (final r in results) ...r.stories]);
      _split();
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

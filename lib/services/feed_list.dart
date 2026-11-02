/// The feeds the news is gathered from.
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

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/constants/default_feeds.dart';
import 'package:newspod/models/feed.dart';

/// The feeds, saved on this device as they change. A new install starts with
/// [defaultFeeds].

class FeedList extends ChangeNotifier {
  static const _key = 'newspod_feeds';

  List<Feed> _feeds = defaultFeeds;

  /// The feeds, in the order they were added.

  List<Feed> get feeds => List.unmodifiable(_feeds);

  /// Whether [url] is already one of the feeds.

  bool contains(String url) => _feeds.any((feed) => feed.url == url);

  /// Read the saved feeds, keeping the defaults when none are saved yet.

  Future<void> load() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    if (saved == null) return;

    _feeds = [
      for (final json in jsonDecode(saved) as List)
        Feed.fromJson(json as Map<String, dynamic>),
    ];
    notifyListeners();
  }

  /// Add [feed], at the end or back [at] where it was.

  Future<void> add(Feed feed, {int? at}) =>
      _save([..._feeds]..insert(at ?? _feeds.length, feed));

  /// Remove [feed], returning where it was so it can be put back.

  Future<int> remove(Feed feed) async {
    final at = _feeds.indexWhere((f) => f.url == feed.url);
    await _save([..._feeds]..removeAt(at));

    return at;
  }

  Future<void> _save(List<Feed> feeds) async {
    _feeds = feeds;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(feeds));
  }
}

/// The app's one list of feeds.

final feedList = FeedList();

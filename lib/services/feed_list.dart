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

import 'package:newspod/constants/default_feeds.dart';
import 'package:newspod/models/feed.dart';
import 'package:newspod/services/synced_list.dart';

/// The feeds, kept on this device and, when logged in, in feeds.ttl on the
/// Pod, so every device subscribes to the same. A new install starts with
/// [defaultFeeds] until the Pod's list is read.

class FeedList extends SyncedList<Feed> {
  FeedList({super.connected, super.read, super.write})
    : super(
        key: 'newspod_feeds',
        file: 'feeds.ttl',
        initial: defaultFeeds,
        keyOf: (feed) => feed.url,
        toJson: (feed) => feed.toJson(),
        fromJson: (json) => Feed.fromJson(json as Map<String, dynamic>),
      );

  /// The feeds, in the order they were added.

  List<Feed> get feeds => items;

  /// Whether [url] is already one of the feeds.

  bool contains(String url) => containsKey(url);

  /// Remove [feed], returning where it was so it can be put back.

  Future<int> remove(Feed feed) => removeKey(feed.url);
}

/// The app's one list of feeds.

final feedList = FeedList();

/// Find feeds by a site's address or by words.
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

import 'package:newspod/models/found_feed.dart';
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/utils/feed_links.dart';
import 'package:newspod/utils/feed_parser.dart';
import 'package:newspod/utils/feed_url.dart';
import 'package:newspod/utils/feedly_feeds.dart';

/// Finds the feeds for what was typed.

typedef FeedFinder = Future<List<FoundFeed>> Function(String text);

/// The feeds for [text]. An address is read: a feed is itself, and a web
/// page gives the feeds it links to. Anything else is words, searched for
/// on Feedly. Throws a [FormatException] saying so when nothing is found.

Future<List<FoundFeed>> findFeeds(
  String text, {
  Future<String> Function(String url) read = fetchText,
}) async {
  final url = feedUrl(text);

  if (url == null) {
    final search = Uri.https('cloud.feedly.com', '/v3/search/feeds', {
      'query': text.trim(),
      'count': '20',
    });
    final found = feedlyFeeds(await read(search.toString()));
    if (found.isEmpty) {
      throw const FormatException(
        'No feeds were found. Try other words, or the address of a site.',
      );
    }

    return found;
  }

  final body = await read(url);

  try {
    final parsed = parseFeed(body);

    return [
      FoundFeed(
        url: url,
        title: parsed.title.isEmpty ? Uri.parse(url).host : parsed.title,
      ),
    ];
  } on FormatException {
    final found = feedLinks(body, Uri.parse(url));
    if (found.isEmpty) {
      throw const FormatException(
        'This page does not say where its feeds are. Try words about the '
        'site instead.',
      );
    }

    return found;
  }
}

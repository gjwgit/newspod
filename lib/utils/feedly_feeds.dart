/// The feeds a Feedly search answered with.
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

import 'package:newspod/models/found_feed.dart';
import 'package:newspod/utils/plain_text.dart';

/// The feeds in [body], the JSON Feedly answers a feed search with, most
/// followed first as Feedly ranks them.

List<FoundFeed> feedlyFeeds(String body) {
  final results = (jsonDecode(body) as Map<String, dynamic>)['results'];

  // 20261103 gjw Feedly knows many feeds by an old http:// address. Android
  // will not read those, and the sites now serve the same feed over https://,
  // so the address is upgraded.

  return [
    for (final result in (results as List? ?? const []).cast<Map>())
      if (result['feedId'] case final String id when id.startsWith('feed/'))
        FoundFeed(
          url: id.substring(5).replaceFirst(RegExp('^http:'), 'https:'),
          title: plainText(result['title'] as String? ?? id.substring(5)),
          description: plainText(result['description'] as String? ?? ''),
          followers: (result['subscribers'] as num?)?.toInt(),
        ),
  ];
}

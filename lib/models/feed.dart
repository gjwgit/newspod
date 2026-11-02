/// One feed the news is gathered from.
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

/// An RSS or Atom feed, by its address, with the name its stories are shown
/// under.

class Feed {
  const Feed({required this.url, required this.title});

  /// Read back a feed saved with [toJson].

  factory Feed.fromJson(Map<String, dynamic> json) =>
      Feed(url: json['url'] as String, title: json['title'] as String);

  /// The address of the feed itself.

  final String url;

  /// The name shown beside each of its stories.

  final String title;

  /// The feed as JSON, to save.

  Map<String, String> toJson() => {'url': url, 'title': title};
}

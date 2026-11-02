/// A feed found by a search, to be added.
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

/// A feed found by [findFeeds], by its address and name, with what the
/// search knows of it.

class FoundFeed {
  const FoundFeed({
    required this.url,
    required this.title,
    this.description = '',
    this.followers,
  });

  /// The address of the feed itself.

  final String url;

  /// The name of the feed.

  final String title;

  /// What the feed is about, or empty when not known.

  final String description;

  /// How many follow the feed on Feedly, or null when not known.

  final int? followers;
}

/// One story from a feed.
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

/// A story as a feed lists it: enough to show it in the news and open it in
/// full on its own site.

class Story {
  const Story({
    required this.title,
    required this.link,
    required this.source,
    this.summary = '',
    this.published,
    this.imageUrl,
  });

  /// The headline.

  final String title;

  /// The address of the full story.

  final String link;

  /// The name of the feed it came from.

  final String source;

  /// The opening of the story as plain text, or empty.

  final String summary;

  /// When it was published, if the feed says.

  final DateTime? published;

  /// A picture for the story, if the feed has one.

  final String? imageUrl;
}

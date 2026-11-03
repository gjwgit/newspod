/// The feeds a new install starts with.
//
// Time-stamp: <Wednesday 2026-11-04 09:47:27 +1100 Graham Williams>
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

import 'package:newspod/models/feed.dart';

/// A few well known feeds so the news is there on first opening. Each can be
/// removed under Feeds.

const defaultFeeds = [
  Feed(
    url: 'https://www.abc.net.au/news/feed/51120/rss.xml',
    title: 'ABC News',
  ),
  Feed(url: 'https://feeds.bbci.co.uk/news/world/rss.xml', title: 'BBC World'),
  Feed(url: 'https://www.theguardian.com/au/rss', title: 'The Guardian'),
  Feed(
    url: 'https://theconversation.com/au/articles.atom',
    title: 'The Conversation',
  ),

  // 20261104 gjw The feeds above fail in a browser (CORS). These send
  // Access-Control-Allow-Origin: * so a browser still shows some news.
  Feed(url: 'https://www.wired.com/feed/rss', title: 'WIRED'),
  Feed(url: 'https://www.nasa.gov/feed/', title: 'NASA'),
  Feed(url: 'https://github.blog/feed/', title: 'The GitHub Blog'),
];

/// The feeds a web page says it has.
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

import 'package:html/parser.dart' show parse;

import 'package:newspod/models/found_feed.dart';

const _feedTypes = {
  'application/rss+xml',
  'application/atom+xml',
  'application/rdf+xml',
};

/// The feeds [page], a web page read from [base], links to in its head, as
/// a site does to tell readers where its feeds are. Each is named by its
/// link or else by the page.

List<FoundFeed> feedLinks(String page, Uri base) {
  final document = parse(page);
  final name = document.querySelector('title')?.text.trim() ?? '';
  final found = <String, FoundFeed>{};

  for (final link in document.querySelectorAll('link')) {
    final rel = (link.attributes['rel'] ?? '').toLowerCase().split(' ');
    final type = (link.attributes['type'] ?? '').toLowerCase().trim();
    final href = link.attributes['href']?.trim() ?? '';
    if (!rel.contains('alternate') || !_feedTypes.contains(type)) continue;
    if (href.isEmpty) continue;

    final url = base.resolve(href).toString();
    final title = link.attributes['title']?.trim() ?? '';

    found.putIfAbsent(
      url,
      () => FoundFeed(
        url: url,
        title: [title, name, base.host].firstWhere((t) => t.isNotEmpty),
      ),
    );
  }

  return found.values.toList();
}

/// Read the stories from an RSS or Atom feed.
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

import 'package:xml/xml.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/utils/feed_date.dart';
import 'package:newspod/utils/plain_text.dart';

/// A feed as read: its own title and its stories.

typedef ParsedFeed = ({String title, List<Story> stories});

/// The title and stories of [body], an RSS 2.0, RSS 1.0 (RDF) or Atom feed,
/// each story credited to [source]. Throws a [FormatException] for anything
/// else.

ParsedFeed parseFeed(String body, {String source = ''}) {
  final XmlElement root;

  try {
    root = XmlDocument.parse(body.trim()).rootElement;
  } on XmlException {
    throw const FormatException('This is not an RSS or Atom feed.');
  }

  // 20261102 gjw Matched on local names throughout, so prefixes and default
  // namespaces, which differ from feed to feed, do not matter.

  final XmlElement? channel = switch (root.localName) {
    'rss' => _child(root, 'channel'),
    'RDF' => _child(root, 'channel'),
    'feed' => root,
    _ => null,
  };

  if (channel == null) {
    throw const FormatException('This is not an RSS or Atom feed.');
  }

  final atom = root.localName == 'feed';
  final items = (root.localName == 'RDF' ? root : channel).childElements.where(
    (e) => e.localName == (atom ? 'entry' : 'item'),
  );

  return (
    title: plainText(_text(channel, 'title')),
    stories: [
      for (final item in items)
        ?(atom ? _atomStory(item, source) : _rssStory(item, source)),
    ],
  );
}

Story? _rssStory(XmlElement item, String source) {
  final guid = _child(item, 'guid');
  final permalink = guid?.getAttribute('isPermaLink') != 'false';
  final link = _text(item, 'link').isNotEmpty
      ? _text(item, 'link')
      : (permalink ? guid?.innerText.trim() ?? '' : '');

  return _story(
    title: _text(item, 'title'),
    link: link,
    source: source,
    summary: _text(item, 'description'),
    published: _text(item, 'pubDate').isNotEmpty
        ? _text(item, 'pubDate')
        : _text(item, 'date'),
    imageUrl: _image(item),
  );
}

Story? _atomStory(XmlElement entry, String source) {
  final links = entry.childElements.where((e) => e.localName == 'link');
  final link = links
      .where((e) => (e.getAttribute('rel') ?? 'alternate') == 'alternate')
      .followedBy(links)
      .firstOrNull
      ?.getAttribute('href');

  return _story(
    title: _text(entry, 'title'),
    link: link ?? '',
    source: source,
    summary: _text(entry, 'summary').isNotEmpty
        ? _text(entry, 'summary')
        : _text(entry, 'content'),
    published: _text(entry, 'published').isNotEmpty
        ? _text(entry, 'published')
        : _text(entry, 'updated'),
    imageUrl: _image(entry),
  );
}

// A story needs a title and a link to be worth listing.

Story? _story({
  required String title,
  required String link,
  required String source,
  required String summary,
  required String published,
  String? imageUrl,
}) {
  if (title.isEmpty || link.isEmpty) return null;

  return Story(
    title: plainText(title),
    link: link,
    source: source,
    summary: plainText(summary),
    published: parseFeedDate(published),
    imageUrl: imageUrl,
  );
}

// The picture for a story: a media thumbnail, else media content or an
// enclosure that is an image. ABC wraps its media in a media:group, so the
// whole item is searched.

String? _image(XmlElement item) {
  final media = item.descendants.whereType<XmlElement>();

  for (final e in media.where((e) => e.localName == 'thumbnail')) {
    if (e.getAttribute('url') case final url?) return url;
  }

  for (final e in media) {
    final url = e.getAttribute('url');
    final type = e.getAttribute('type') ?? '';
    final medium = e.getAttribute('medium') ?? '';
    final image =
        type.startsWith('image/') ||
        medium == 'image' ||
        (e.localName == 'content' && type.isEmpty && medium.isEmpty);

    if (url != null && image && e.localName != 'link') return url;
  }

  return null;
}

XmlElement? _child(XmlElement e, String name) =>
    e.childElements.where((c) => c.localName == name).firstOrNull;

String _text(XmlElement e, String name) =>
    _child(e, name)?.innerText.trim() ?? '';

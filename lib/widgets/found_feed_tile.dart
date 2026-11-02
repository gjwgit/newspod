/// A feed found by a search, with a button to add it.
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

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidui/solidui.dart';

import 'package:newspod/models/feed.dart';
import 'package:newspod/models/found_feed.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/services/news.dart';

/// [found] by its name, followers and what it is about. Add reads the feed
/// first, so that only a feed that works is kept, and says why when it does
/// not.

class FoundFeedTile extends StatefulWidget {
  const FoundFeedTile({super.key, required this.found, required this.fetch});

  /// The feed found.

  final FoundFeed found;

  /// How the feed is read before it is added.

  final FeedFetcher fetch;

  @override
  State<FoundFeedTile> createState() => _FoundFeedTileState();
}

class _FoundFeedTileState extends State<FoundFeedTile> {
  String? _error;
  bool _busy = false;

  Future<void> _add() async {
    final found = widget.found;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final parsed = await widget.fetch(found.url);
      final title = parsed.title.isEmpty ? found.title : parsed.title;

      await feedList.add(Feed(url: found.url, title: title));
      if (mounted) showPositiveSnackBar(context, 'Added $title.');
    } catch (e) {
      _error = feedError(e);
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final found = widget.found;
    final added = feedList.contains(found.url);
    final error = _error;
    final about = [
      if (found.followers case final n?) n == 1 ? '1 follower' : '$n followers',
      found.description.isEmpty ? found.url : found.description,
    ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        error == null ? Icons.rss_feed : Icons.error_outline,
        color: error == null ? null : Theme.of(context).colorScheme.error,
      ),
      title: Text(found.title),
      subtitle: Text(
        error ?? about,
        maxLines: error == null ? 2 : 4,
        overflow: TextOverflow.ellipsis,
        style: error == null
            ? null
            : TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      trailing: added
          ? MarkdownTooltip(
              message: """

**Added**

This is already one of your feeds.

""",
              child: const Icon(Icons.check),
            )
          : MarkdownTooltip(
              message: """

**Add Feed**

Read the feed and, when it works, add its stories to the news.

""",
              child: TextButton(
                onPressed: _busy ? null : _add,
                child: Text(_busy ? 'Adding' : 'Add'),
              ),
            ),
    );
  }
}

/// One feed in the list of feeds.
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
import 'package:newspod/services/feed_list.dart';

/// A feed by name and address, marked with why when it could not be read,
/// and a button to remove it, with Undo.

class FeedTile extends StatelessWidget {
  const FeedTile({super.key, required this.feed, this.error});

  /// The feed to show.

  final Feed feed;

  /// Why the feed could not be read last time, or null when it was.

  final String? error;

  Future<void> _remove(BuildContext context) async {
    final at = await feedList.remove(feed);
    if (!context.mounted) return;

    showPositiveSnackBar(
      context,
      'Removed ${feed.title}.',
      actionLabel: 'Undo',
      onAction: () => feedList.add(feed, at: at),
    );
  }

  @override
  Widget build(BuildContext context) {
    final problem = error;

    return ListTile(
      leading: problem == null
          ? const Icon(Icons.rss_feed)
          : MarkdownTooltip(
              message:
                  """

**Could Not Read**

$problem

""",
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
      title: Text(feed.title),
      subtitle: Text(feed.url, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: MarkdownTooltip(
        message: """

**Remove**

Stop gathering stories from this feed. Undo puts it back.

""",
        child: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _remove(context),
        ),
      ),
    );
  }
}

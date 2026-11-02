/// A field to find feeds, by address or by words, and add them.
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

import 'package:newspod/models/found_feed.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/services/find_feeds.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/found_feed_tile.dart';

/// The address of a feed or a site, or words to search for, and the feeds
/// found, each to add. What is wrong shows under the field until it is
/// edited.

class FindFeedsField extends StatefulWidget {
  const FindFeedsField({
    super.key,
    this.find = findFeeds,
    this.fetch = fetchFeed,
  });

  /// How the feeds are found, replaced in tests.

  final FeedFinder find;

  /// How a feed is read before it is added, replaced in tests.

  final FeedFetcher fetch;

  @override
  State<FindFeedsField> createState() => _FindFeedsFieldState();
}

class _FindFeedsFieldState extends State<FindFeedsField> {
  final _controller = TextEditingController();
  List<FoundFeed> _found = const [];
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return setState(
        () => _error = 'Enter a feed or site address, or words to search for.',
      );
    }

    setState(() => _busy = true);

    try {
      _found = await widget.find(text);
    } catch (e) {
      _found = const [];
      _error = feedError(e);
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: 'Find feeds',
                  hintText: 'abc.net.au, or words like canberra',
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _find(),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: MarkdownTooltip(
                message: """

**Find Feeds**

Give the address of a feed, or of a site to list the feeds it offers. Or give
words to search for: they are sent to Feedly, which suggests the feeds most
followed there.

""",
                child: FilledButton(
                  onPressed: _busy ? null : _find,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Find'),
                ),
              ),
            ),
          ],
        ),

        // 20261103 gjw The tiles show which feeds are already added, so
        // they follow the feed list, as Undo on a removed feed changes it.
        ListenableBuilder(
          listenable: feedList,
          builder: (context, _) => Column(
            children: [
              for (final found in _found)
                FoundFeedTile(
                  key: ValueKey(found.url),
                  found: found,
                  fetch: widget.fetch,
                ),
              if (_found.isNotEmpty) const Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

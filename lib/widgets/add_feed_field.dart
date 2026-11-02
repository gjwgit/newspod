/// A field to add a feed by its address.
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
import 'package:newspod/services/fetch_feed.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/utils/feed_url.dart';

/// The address of a new feed, read before it is added so that only a feed
/// that works is kept, named by its own title. What is wrong shows under the
/// field until it is edited.

class AddFeedField extends StatefulWidget {
  const AddFeedField({super.key, this.fetch = fetchFeed});

  /// How the feed is read, replaced in tests.

  final FeedFetcher fetch;

  @override
  State<AddFeedField> createState() => _AddFeedFieldState();
}

class _AddFeedFieldState extends State<AddFeedField> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final url = feedUrl(_controller.text);

    if (url == null) {
      return setState(
        () => _error = 'Enter the address of an RSS or Atom feed.',
      );
    }
    if (feedList.contains(url)) {
      return setState(() => _error = 'This is already one of your feeds.');
    }

    setState(() => _busy = true);

    try {
      final parsed = await widget.fetch(url);
      final title = parsed.title.isEmpty ? Uri.parse(url).host : parsed.title;

      await feedList.add(Feed(url: url, title: title));
      _controller.clear();
      if (mounted) showPositiveSnackBar(context, 'Added $title.');
    } catch (e) {
      _error = feedError(e);
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Feed address',
              hintText: 'https://example.com/feed.xml',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _add(),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MarkdownTooltip(
            message: """

**Add Feed**

Read the feed at this address and, when it works, add its stories to the
news.

""",
            child: FilledButton(
              onPressed: _busy ? null : _add,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ),
        ),
      ],
    );
  }
}

/// A story that can be swiped left out of the news.
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

import 'package:solidui/solidui.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/story_tile.dart';

/// [story] in the news list, with the divider beneath it. Swiped left it is
/// removed, for good, with Undo to bring it back. In the list of [dismissed]
/// stories it is swiped right instead, to bring it back to the news.

class DismissibleStory extends StatelessWidget {
  const DismissibleStory({
    super.key,
    required this.story,
    required this.now,
    this.dismissed = false,
  });

  /// The story to show.

  final Story story;

  /// The time the ages are reckoned from, the same for the whole list.

  final DateTime now;

  /// Whether the story is listed under Dismissed, to be brought back.

  final bool dismissed;

  void _swiped(BuildContext context) {
    if (dismissed) {
      news.restore(story);
    } else {
      news.dismiss(story);
    }

    showPositiveSnackBar(
      context,
      dismissed ? 'Back in the news.' : 'Removed from the news.',
      actionLabel: 'Undo',
      onAction: () => dismissed ? news.dismiss(story) : news.restore(story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(story.link),
      direction: dismissed
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      onDismissed: (_) => _swiped(context),
      background: ColoredBox(
        color: dismissed ? colours.primaryContainer : colours.errorContainer,
        child: Align(
          alignment: dismissed ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(
              dismissed ? Icons.restore : Icons.delete_outline,
              color: dismissed
                  ? colours.onPrimaryContainer
                  : colours.onErrorContainer,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          StoryTile(story: story, now: now),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
